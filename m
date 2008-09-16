Date: Tue, 16 Sep 2008 21:21:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 12/9] lazy lru add vie per cpu vector for memcg.
Message-Id: <20080916212103.200934bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080916211355.277b625d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
	<48CA9500.5060309@linux.vnet.ibm.com>
	<20080916211355.277b625d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Delaying add_to_lru() and do it by batch.

For delaying, PCG_LRU flag is added. If PCG_LRU is set, page is on
LRU and unchage() have to call remove from lru. If not, the page is
not added to LRU.

For avoid race, all flags are modified under lock_page_cgroup().

Lazy-add logic reuses Lazy-free's one.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/page_cgroup.h |    4 +
 mm/memcontrol.c             |   91 ++++++++++++++++++++++++++++++++++++++------
 2 files changed, 84 insertions(+), 11 deletions(-)

Index: mmtom-2.6.27-rc5+/include/linux/page_cgroup.h
===================================================================
--- mmtom-2.6.27-rc5+.orig/include/linux/page_cgroup.h
+++ mmtom-2.6.27-rc5+/include/linux/page_cgroup.h
@@ -23,6 +23,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_LRU, /* this is on LRU */
 	/* flags for LRU placement */
 	PCG_ACTIVE, /* page is active in this cgroup */
 	PCG_FILE, /* page is file system backed */
@@ -57,6 +58,9 @@ TESTPCGFLAG(Used, USED)
 __SETPCGFLAG(Used, USED)
 __CLEARPCGFLAG(Used, USED)
 
+TESTPCGFLAG(LRU, LRU)
+SETPCGFLAG(LRU, LRU)
+
 /* LRU management flags (from global-lru definition) */
 TESTPCGFLAG(File, FILE)
 SETPCGFLAG(File, FILE)
Index: mmtom-2.6.27-rc5+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc5+/mm/memcontrol.c
@@ -348,7 +348,7 @@ void mem_cgroup_move_lists(struct page *
 	if (!trylock_page_cgroup(pc))
 		return;
 
-	if (PageCgroupUsed(pc)) {
+	if (PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
 		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
@@ -508,6 +508,9 @@ int mem_cgroup_move_account(struct page 
 	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
 	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
 
+	if (!PageCgroupLRU(pc))
+		return ret;
+
 	if (res_counter_charge(&to->res, PAGE_SIZE)) {
 		/* Now, we assume no_limit...no failure here. */
 		return ret;
@@ -550,6 +553,7 @@ struct memcg_percpu_vec {
 	struct page_cgroup *vec[MEMCG_PCPVEC_SIZE];
 };
 DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_free_vec);
+DEFINE_PER_CPU(struct memcg_percpu_vec, memcg_add_vec);
 
 static void
 __release_page_cgroup(struct memcg_percpu_vec *mpv)
@@ -580,6 +584,40 @@ __release_page_cgroup(struct memcg_percp
 }
 
 static void
+__use_page_cgroup(struct memcg_percpu_vec *mpv)
+{
+	unsigned long flags;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *owner;
+	struct page_cgroup *pc;
+	struct page *freed[MEMCG_PCPVEC_SIZE];
+	int i, nr, freed_num;
+
+	mz = mpv->hot_mz;
+	owner = mpv->hot_memcg;
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	nr = mpv->nr;
+	mpv->nr = 0;
+	freed_num = 0;
+	for (i = nr - 1; i >= 0; i--) {
+		pc = mpv->vec[i];
+		lock_page_cgroup(pc);
+		if (likely(PageCgroupUsed(pc))) {
+			__mem_cgroup_add_list(mz, pc);
+			SetPageCgroupLRU(pc);
+		} else {
+			css_put(&owner->css);
+			freed[freed_num++] = pc->page;
+			pc->mem_cgroup = NULL;
+		}
+		unlock_page_cgroup(pc);
+	}
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	while (freed_num--)
+		put_page(freed[freed_num]);
+}
+
+static void
 release_page_cgroup(struct mem_cgroup_per_zone *mz,struct page_cgroup *pc)
 {
 	struct memcg_percpu_vec *mpv;
@@ -597,11 +635,30 @@ release_page_cgroup(struct mem_cgroup_pe
 	put_cpu_var(memcg_free_vec);
 }
 
+static void
+use_page_cgroup(struct mem_cgroup_per_zone *mz, struct page_cgroup *pc)
+{
+	struct memcg_percpu_vec *mpv;
+	mpv = &get_cpu_var(memcg_add_vec);
+	if (mpv->hot_mz != mz) {
+		if (mpv->nr > 0)
+			__use_page_cgroup(mpv);
+		mpv->hot_mz = mz;
+		mpv->hot_memcg = pc->mem_cgroup;
+	}
+	mpv->vec[mpv->nr++] = pc;
+	if (mpv->nr >= mpv->limit)
+		__use_page_cgroup(mpv);
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
@@ -610,6 +667,8 @@ static void page_cgroup_stop_cache_cpu(i
 	struct memcg_percpu_vec *mpv;
 	mpv = &per_cpu(memcg_free_vec, cpu);
 	mpv->limit = 0;
+	mpv = &per_cpu(memcg_add_vec, cpu);
+	mpv->limit = 0;
 }
 #endif
 
@@ -623,6 +682,9 @@ static DEFINE_MUTEX(memcg_force_drain_mu
 static void drain_page_cgroup_local(struct work_struct *work)
 {
 	struct memcg_percpu_vec *mpv;
+	mpv = &get_cpu_var(memcg_add_vec);
+	__use_page_cgroup(mpv);
+	put_cpu_var(mpv);
 	mpv = &get_cpu_var(memcg_free_vec);
 	__release_page_cgroup(mpv);
 	put_cpu_var(mpv);
@@ -668,7 +730,6 @@ static int mem_cgroup_charge_common(stru
 	struct page_cgroup *pc;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 
 	/* avoid case in boot sequence */
 	if (unlikely(PageReserved(page)))
@@ -753,9 +814,7 @@ static int mem_cgroup_charge_common(stru
 	unlock_page_cgroup(pc);
 
 	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	use_page_cgroup(mz, pc);
 	preempt_enable();
 
 done:
@@ -830,23 +889,33 @@ __mem_cgroup_uncharge_common(struct page
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long pfn = page_to_pfn(page);
+	int need_to_release;
 
 	if (!under_mem_cgroup(page))
 		return;
 	pc = lookup_page_cgroup(pfn);
-	if (unlikely(!pc || !PageCgroupUsed(pc)))
+	if (unlikely(!pc))
 		return;
-
 	preempt_disable();
+
 	lock_page_cgroup(pc);
+
+	if (unlikely(!PageCgroupUsed(pc))) {
+		unlock_page_cgroup(pc);
+		preempt_enable();
+		return;
+	}
+
+	need_to_release = PageCgroupLRU(pc);
+	mem = pc->mem_cgroup;
 	__ClearPageCgroupUsed(pc);
 	unlock_page_cgroup(pc);
 	preempt_enable();
 
-	mem = pc->mem_cgroup;
-	mz = page_cgroup_zoneinfo(pc);
-
-	release_page_cgroup(mz, pc);
+	if (likely(need_to_release)) {
+		mz = page_cgroup_zoneinfo(pc);
+		release_page_cgroup(mz, pc);
+	}
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
 
 	return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
