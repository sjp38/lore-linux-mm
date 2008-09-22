Date: Mon, 22 Sep 2008 20:22:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 12/13] memcg: lazy LRU add
Message-Id: <20080922202252.3bbd36de.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Delaying add_to_lru() and do it in batched manner like page_vec.
For doint that 2 flags PCG_USED and PCG_LRU.

If PCG_LRU is set, page is on LRU. It safe to access LRU via page_cgroup.
(under some lock.)

For avoiding race, this patch uses TestSetPageCgroupUsed().
and checking PCG_USED bit and PCG_LRU bit in add/free vector.
By this, lock_page_cgroup() in mem_cgroup_charge() is removed.

(I don't want to call lock_page_cgroup() under mz->lru_lock when 
 add/free vector core logic. So, TestSetPageCgroupUsed() logic is added.
 TestSet is an easy way to avoid unneccesary nest of locks.)


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/page_cgroup.h |   10 +++
 mm/memcontrol.c             |  125 ++++++++++++++++++++++++++++++--------------
 2 files changed, 98 insertions(+), 37 deletions(-)

Index: mmotm-2.6.27-rc6+/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.27-rc6+.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.27-rc6+/include/linux/page_cgroup.h
@@ -23,6 +23,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_LRU, /* this is on LRU */
 	/* flags for LRU placement */
 	PCG_ACTIVE, /* page is active in this cgroup */
 	PCG_FILE, /* page is file system backed */
@@ -41,11 +42,20 @@ static inline void SetPageCgroup##uname(
 static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ clear_bit(PCG_##lname, &pc->flags);  }
 
+#define TESTSETPCGFLAG(uname, lname)\
+static inline int TestSetPageCgroup##uname(struct page_cgroup *pc)	\
+	{ return test_and_set_bit(PCG_##lname, &pc->flags);  }
+
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
 
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
+TESTSETPCGFLAG(Used, USED)
+
+TESTPCGFLAG(LRU, LRU)
+SETPCGFLAG(LRU, LRU)
+CLEARPCGFLAG(LRU, LRU)
 
 /* LRU management flags (from global-lru definition) */
 TESTPCGFLAG(File, FILE)
Index: mmotm-2.6.27-rc6+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc6+/mm/memcontrol.c
@@ -149,9 +149,9 @@ enum charge_type {
 
 static const unsigned long
 pcg_default_flags[NR_CHARGE_TYPE] = {
-	(1 << PCG_CACHE) | (1 << PCG_FILE) | (1 << PCG_USED) | (1 << PCG_LOCK),
-	(1 << PCG_ACTIVE) | (1 << PCG_LOCK) | (1 << PCG_USED),
-	(1 << PCG_ACTIVE) | (1 << PCG_CACHE) | (1 << PCG_USED)|  (1 << PCG_LOCK),
+	(1 << PCG_CACHE) | (1 << PCG_FILE) | (1 << PCG_USED),
+	(1 << PCG_ACTIVE) | (1 << PCG_USED),
+	(1 << PCG_ACTIVE) | (1 << PCG_CACHE) | (1 << PCG_USED),
 	0,
 };
 
@@ -194,7 +194,6 @@ page_cgroup_zoneinfo(struct page_cgroup 
 	struct mem_cgroup *mem = pc->mem_cgroup;
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
-
 	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
 
@@ -342,7 +341,7 @@ void mem_cgroup_move_lists(struct page *
 	if (!trylock_page_cgroup(pc))
 		return;
 
-	if (PageCgroupUsed(pc)) {
+	if (PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
 		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
@@ -502,6 +501,9 @@ int mem_cgroup_move_account(struct page 
 	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
 	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
 
+	if (!PageCgroupLRU(pc))
+		return ret;
+
 	if (res_counter_charge(&to->res, PAGE_SIZE)) {
 		/* Now, we assume no_limit...no failure here. */
 		return ret;
@@ -518,10 +520,8 @@ int mem_cgroup_move_account(struct page 
 
 	if (spin_trylock(&to_mz->lru_lock)) {
 		__mem_cgroup_remove_list(from_mz, pc);
-		css_put(&from->css);
 		res_counter_uncharge(&from->res, PAGE_SIZE);
 		pc->mem_cgroup = to;
-		css_get(&to->css);
 		__mem_cgroup_add_list(to_mz, pc);
 		ret = 0;
 		spin_unlock(&to_mz->lru_lock);
@@ -542,6 +542,7 @@ struct memcg_percpu_vec {
 	struct page_cgroup *vec[MEMCG_PCPVEC_SIZE];
 };
 static DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_free_vec);
+static DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_add_vec);
 
 static void
 __release_page_cgroup(struct memcg_percpu_vec *mpv)
@@ -557,7 +558,6 @@ __release_page_cgroup(struct memcg_percp
 	prev_mz = NULL;
 	for (i = nr - 1; i >= 0; i--) {
 		pc = mpv->vec[i];
-		VM_BUG_ON(PageCgroupUsed(pc));
 		mz = page_cgroup_zoneinfo(pc);
 		if (prev_mz != mz) {
 			if (prev_mz)
@@ -565,9 +565,10 @@ __release_page_cgroup(struct memcg_percp
 			prev_mz = mz;
 			spin_lock(&mz->lru_lock);
 		}
-		__mem_cgroup_remove_list(mz, pc);
-		css_put(&pc->mem_cgroup->css);
-		pc->mem_cgroup = NULL;
+		if (!PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
+			__mem_cgroup_remove_list(mz, pc);
+			ClearPageCgroupLRU(pc);
+		}
 	}
 	if (prev_mz)
 		spin_unlock(&prev_mz->lru_lock);
@@ -576,10 +577,43 @@ __release_page_cgroup(struct memcg_percp
 }
 
 static void
+__set_page_cgroup_lru(struct memcg_percpu_vec *mpv)
+{
+	unsigned long flags;
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
+		mz = page_cgroup_zoneinfo(pc);
+		if (prev_mz != mz) {
+			if (prev_mz)
+				spin_unlock(&prev_mz->lru_lock);
+			prev_mz = mz;
+			spin_lock(&mz->lru_lock);
+		}
+		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
+			SetPageCgroupLRU(pc);
+			__mem_cgroup_add_list(mz, pc);
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
@@ -587,11 +621,25 @@ release_page_cgroup(struct page_cgroup *
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
@@ -600,6 +648,8 @@ static void page_cgroup_stop_cache_cpu(i
 	struct memcg_percpu_vec *mpv;
 	mpv = &per_cpu(memcg_free_vec, cpu);
 	mpv->limit = 0;
+	mpv = &per_cpu(memcg_add_vec, cpu);
+	mpv->limit = 0;
 }
 #endif
 
@@ -613,6 +663,9 @@ static DEFINE_MUTEX(memcg_force_drain_mu
 static void drain_page_cgroup_local(struct work_struct *work)
 {
 	struct memcg_percpu_vec *mpv;
+	mpv = &get_cpu_var(memcg_add_vec);
+	__set_page_cgroup_lru(mpv);
+	put_cpu_var(mpv);
 	mpv = &get_cpu_var(memcg_free_vec);
 	__release_page_cgroup(mpv);
 	put_cpu_var(mpv);
@@ -679,14 +732,9 @@ static int mem_cgroup_charge_common(stru
 			rcu_read_unlock();
 			return 0;
 		}
-		/*
-		 * For every charge from the cgroup, increment reference count
-		 */
-		css_get(&mem->css);
 		rcu_read_unlock();
 	} else {
 		mem = memcg;
-		css_get(&memcg->css);
 	}
 
 	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
@@ -713,33 +761,36 @@ static int mem_cgroup_charge_common(stru
 	}
 
 	preempt_disable();
-	lock_page_cgroup(pc);
-	if (unlikely(PageCgroupUsed(pc))) {
-		unlock_page_cgroup(pc);
+	if (TestSetPageCgroupUsed(pc)) {
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
 		preempt_enable();
 		goto done;
 	}
-	pc->mem_cgroup = mem;
 	/*
-	 * If a page is accounted as a page cache, insert to inactive list.
-	 * If anon, insert to active list.
-	 */
-	pc->flags = pcg_default_flags[ctype];
-
-	mz = page_cgroup_zoneinfo(pc);
+ 	 *  page cgroup is *unused* now....but....
+ 	 *  We can assume old mem_cgroup's metadata is still available
+ 	 *  because pc is not on stale LRU after force_empty() is called.
+ 	 */
+	if (likely(!PageCgroupLRU(pc)))
+		pc->flags = pcg_default_flags[ctype];
+	else {
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		if (PageCgroupLRU(pc)) {
+			__mem_cgroup_remove_list(mz, pc);
+			ClearPageCgroupLRU(pc);
+		}
+		pc->flags = pcg_default_flags[ctype];
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+	}
 
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	unlock_page_cgroup(pc);
+	pc->mem_cgroup = mem;
+	set_page_cgroup_lru(pc);
 	preempt_enable();
 
 done:
 	return 0;
 out:
-	css_put(&mem->css);
 	return -ENOMEM;
 }
 
@@ -830,12 +881,12 @@ __mem_cgroup_uncharge_common(struct page
 		return;
 	}
 	ClearPageCgroupUsed(pc);
+	mem = pc->mem_cgroup;
 	unlock_page_cgroup(pc);
 	preempt_enable();
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
 
-	mem = pc->mem_cgroup;
 	release_page_cgroup(pc);
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
 
 	return;
 }
@@ -1054,6 +1105,7 @@ static int mem_cgroup_force_empty(struct
 	}
 	ret = 0;
 	drain_page_cgroup_all();
+	synchronize_sched();
 out:
 	css_put(&mem->css);
 	return ret;
@@ -1340,8 +1392,7 @@ static void mem_cgroup_destroy(struct cg
 
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
-
-	mem_cgroup_free(mem_cgroup_from_cont(cont));
+	mem_cgroup_free(mem);
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
