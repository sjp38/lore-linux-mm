Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9A96I1B017718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Oct 2008 18:06:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFCC01B8020
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 18:06:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9773B2DC01D
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 18:06:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DC9E1DB8037
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 18:06:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 308071DB803A
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 18:06:18 +0900 (JST)
Date: Fri, 10 Oct 2008 18:06:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/5] memcg: lazy lru add
Message-Id: <20081010180600.5c49432c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081010175936.f3b1f4e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081010175936.f3b1f4e0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Delaying add_to_lru() and do it in batched manner like page_vec.
For doing that 2 flags PCG_USED and PCG_LRU.

Because __set_page_cgroup_lru() itself doesn't take lock_page_cgroup(),
we need a sanity check inside lru_lock().

And this delaying make css_put()/get() complicated. To make it clear,
 * css_get() is called from mem_cgroup_add_list().
 * css_put() is called from mem_cgroup_remove_list().
 * css_get()->css_put() is called while try_charge()->commit/cancel sequence.


Changelog: v6 -> v7
 - removed redundant css_put()

Changelog: v5 -> v6.
 - css_get()/put comes back again...it's called via add_list(), remove_list().
 - patch for PCG_LRU bit part is moved to release_page_cgroup_lru() patch.
 - Avoid TestSet and just use lock_page_cgroup() etc.
 - fixed race condition we saw in v5. (smp_wmb() and USED bit magic help us)

Changelog: v3 -> v5.
 - removed css_get/put per page_cgroup struct.
   Now, *new* force_empty checks there is page_cgroup on the memcg.
   We don't need to be afraid of leak.

Changelog: v2 -> v3
 - added TRANSIT flag and removed lock from core logic.
Changelog: v1 -> v2:
 - renamed function name from use_page_cgroup to set_page_cgroup_lru().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 73 insertions(+), 11 deletions(-)

Index: mmotm-2.6.27-rc8+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc8+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc8+/mm/memcontrol.c
@@ -255,6 +255,7 @@ static void __mem_cgroup_remove_list(str
 
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, false);
 	list_del(&pc->lru);
+	css_put(&pc->mem_cgroup->css);
 }
 
 static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
@@ -278,6 +279,7 @@ static void __mem_cgroup_add_list(struct
 		list_add_tail(&pc->lru, &mz->lists[lru]);
 
 	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, true);
+	css_get(&pc->mem_cgroup->css);
 }
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, enum lru_list lru)
@@ -479,6 +481,7 @@ struct memcg_percpu_vec {
 	struct page_cgroup *vec[MEMCG_PCPVEC_SIZE];
 };
 static DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_free_vec);
+static DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_add_vec);
 
 static void
 __release_page_cgroup(struct memcg_percpu_vec *mpv)
@@ -516,7 +519,6 @@ __release_page_cgroup(struct memcg_percp
 		    && tmp == pc->mem_cgroup) {
 			ClearPageCgroupLRU(pc);
 			__mem_cgroup_remove_list(mz, pc);
-			css_put(&pc->mem_cgroup->css);
 		}
 	}
 	if (prev_mz)
@@ -526,10 +528,53 @@ __release_page_cgroup(struct memcg_percp
 }
 
 static void
+__set_page_cgroup_lru(struct memcg_percpu_vec *mpv)
+{
+	unsigned long flags;
+	struct mem_cgroup *mem;
+	struct mem_cgroup_per_zone *mz, *prev_mz;
+	struct page_cgroup *pc;
+	int i, nr;
+
+	local_irq_save(flags);
+	nr = mpv->nr;
+	mpv->nr = 0;
+	prev_mz = NULL;
+
+	for (i = nr - 1; i >= 0; i--) {
+		pc = mpv->vec[i];
+		mem = pc->mem_cgroup;
+		mz = page_cgroup_zoneinfo(pc);
+		if (prev_mz != mz) {
+			if (prev_mz)
+				spin_unlock(&prev_mz->lru_lock);
+			prev_mz = mz;
+			spin_lock(&mz->lru_lock);
+		}
+		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
+			/*
+			 * while we wait for lru_lock, uncharge()->charge()
+			 * can occur. check here pc->mem_cgroup is what
+			 * we expected or yet.
+			 */
+			smp_rmb();
+			if (likely(mem == pc->mem_cgroup)) {
+				SetPageCgroupLRU(pc);
+				__mem_cgroup_add_list(mz, pc, true);
+			}
+		}
+	}
+
+	if (prev_mz)
+		spin_unlock(&prev_mz->lru_lock);
+	local_irq_restore(flags);
+
+}
+
+static void
 release_page_cgroup(struct page_cgroup *pc)
 {
 	struct memcg_percpu_vec *mpv;
-
 	mpv = &get_cpu_var(memcg_free_vec);
 	mpv->vec[mpv->nr++] = pc;
 	if (mpv->nr >= mpv->limit)
@@ -537,11 +582,25 @@ release_page_cgroup(struct page_cgroup *
 	put_cpu_var(memcg_free_vec);
 }
 
+static void
+set_page_cgroup_lru(struct page_cgroup *pc)
+{
+	struct memcg_percpu_vec *mpv;
+
+	mpv = &get_cpu_var(memcg_add_vec);
+	mpv->vec[mpv->nr++] = pc;
+	if (mpv->nr >= mpv->limit)
+		__set_page_cgroup_lru(mpv);
+	put_cpu_var(memcg_add_vec);
+}
+
 static void page_cgroup_start_cache_cpu(int cpu)
 {
 	struct memcg_percpu_vec *mpv;
 	mpv = &per_cpu(memcg_free_vec, cpu);
 	mpv->limit = MEMCG_PCPVEC_SIZE;
+	mpv = &per_cpu(memcg_add_vec, cpu);
+	mpv->limit = MEMCG_PCPVEC_SIZE;
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
@@ -550,6 +609,8 @@ static void page_cgroup_stop_cache_cpu(i
 	struct memcg_percpu_vec *mpv;
 	mpv = &per_cpu(memcg_free_vec, cpu);
 	mpv->limit = 0;
+	mpv = &per_cpu(memcg_add_vec, cpu);
+	mpv->limit = 0;
 }
 #endif
 
@@ -563,6 +624,9 @@ static DEFINE_MUTEX(memcg_force_drain_mu
 static void drain_page_cgroup_local(struct work_struct *work)
 {
 	struct memcg_percpu_vec *mpv;
+	mpv = &get_cpu_var(memcg_add_vec);
+	__set_page_cgroup_lru(mpv);
+	put_cpu_var(mpv);
 	mpv = &get_cpu_var(memcg_free_vec);
 	__release_page_cgroup(mpv);
 	put_cpu_var(mpv);
@@ -710,24 +774,24 @@ static void __mem_cgroup_commit_charge(s
 		if (PageCgroupLRU(pc)) {
 			ClearPageCgroupLRU(pc);
 			__mem_cgroup_remove_list(mz, pc);
-			css_put(&pc->mem_cgroup->css);
 		}
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
 	/* Here, PCG_LRU bit is cleared */
 	pc->mem_cgroup = mem;
 	/*
+	 * We have to set pc->mem_cgroup before set USED bit for avoiding
+	 * race with (delayed) __set_page_cgroup_lru() in other cpu.
+	 */
+	smp_wmb();
+	/*
 	 * below pcg_default_flags includes PCG_LOCK bit.
 	 */
 	pc->flags = pcg_default_flags[ctype];
 	unlock_page_cgroup(pc);
 
-	mz = page_cgroup_zoneinfo(pc);
-
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(mz, pc, true);
-	SetPageCgroupLRU(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	set_page_cgroup_lru(pc);
+	css_put(&mem->css);
 }
 
 /**
@@ -774,10 +838,8 @@ static int mem_cgroup_move_account(struc
 
 	if (spin_trylock(&to_mz->lru_lock)) {
 		__mem_cgroup_remove_list(from_mz, pc);
-		css_put(&from->css);
 		res_counter_uncharge(&from->res, PAGE_SIZE);
 		pc->mem_cgroup = to;
-		css_get(&to->css);
 		__mem_cgroup_add_list(to_mz, pc, false);
 		ret = 0;
 		spin_unlock(&to_mz->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
