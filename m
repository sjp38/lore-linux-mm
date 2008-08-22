Date: Fri, 22 Aug 2008 20:33:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/14]  delay page_cgroup freeing
Message-Id: <20080822203324.409635c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Freeing page_cgroup at mem_cgroup_uncharge() in lazy way.

In mem_cgroup_uncharge_common(), we don't free page_cgroup
and just link it to per-cpu free queue.
And remove it later by checking threshold.

This patch is a base patch for freeing page_cgroup by RCU patch.
This patch depends on make-page_cgroup_flag-atomic patch.

Changelog: (v1) -> (v2)
  - fixed mem_cgroup_move_list()'s checking of PcgObsolete()
  - fixed force_empty.
Changelog: (preview) -> (v1)
  - Clean up.
  - renamed functions

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  122 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 110 insertions(+), 12 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -164,11 +164,13 @@ struct page_cgroup {
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
 	unsigned long flags;
+	struct page_cgroup *next;
 };
 
 enum {
 	/* flags for mem_cgroup */
 	Pcg_CACHE, /* charged as cache */
+	Pcg_OBSOLETE,	/* this page cgroup is invalid (unused) */
 	/* flags for LRU placement */
 	Pcg_ACTIVE, /* page is active in this cgroup */
 	Pcg_FILE, /* page is file system backed */
@@ -199,6 +201,10 @@ static inline void __ClearPcg##uname(str
 TESTPCGFLAG(Cache, CACHE)
 __SETPCGFLAG(Cache, CACHE)
 
+/* No "Clear" routine for OBSOLETE flag */
+TESTPCGFLAG(Obsolete, OBSOLETE);
+SETPCGFLAG(Obsolete, OBSOLETE);
+
 /* LRU management flags (from global-lru definition) */
 TESTPCGFLAG(File, FILE)
 SETPCGFLAG(File, FILE)
@@ -225,6 +231,18 @@ static enum zone_type page_cgroup_zid(st
 	return page_zonenum(pc->page);
 }
 
+/*
+ * per-cpu slot for freeing page_cgroup in lazy manner.
+ * All page_cgroup linked to this list is OBSOLETE.
+ */
+struct mem_cgroup_sink_list {
+	int count;
+	struct page_cgroup *next;
+};
+DEFINE_PER_CPU(struct mem_cgroup_sink_list, memcg_sink_list);
+#define MEMCG_LRU_THRESH	(16)
+
+
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -440,7 +458,7 @@ void mem_cgroup_move_lists(struct page *
 		/*
 		 * check against the race with force_empty.
 		 */
-		if (likely(mem == pc->mem_cgroup))
+		if (!PcgObsolete(pc) && likely(mem == pc->mem_cgroup))
 			__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
@@ -531,6 +549,10 @@ unsigned long mem_cgroup_isolate_pages(u
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
 		if (scan >= nr_to_scan)
 			break;
+
+		if (PcgObsolete(pc))
+			continue;
+
 		page = pc->page;
 
 		if (unlikely(!PageLRU(page)))
@@ -563,6 +585,81 @@ unsigned long mem_cgroup_isolate_pages(u
 }
 
 /*
+ * Free obsolete page_cgroups which is linked to per-cpu drop list.
+ */
+
+static void __free_obsolete_page_cgroup(void)
+{
+	struct mem_cgroup *memcg;
+	struct page_cgroup *pc, *next;
+	struct mem_cgroup_per_zone *mz, *page_mz;
+	struct mem_cgroup_sink_list *mcsl;
+	unsigned long flags;
+
+	mcsl = &get_cpu_var(memcg_sink_list);
+	next = mcsl->next;
+	mcsl->next = NULL;
+	mcsl->count = 0;
+	put_cpu_var(memcg_sink_list);
+
+	mz = NULL;
+
+	local_irq_save(flags);
+	while (next) {
+		pc = next;
+		VM_BUG_ON(!PcgObsolete(pc));
+		next = pc->next;
+		prefetch(next);
+		page_mz = page_cgroup_zoneinfo(pc);
+		memcg = pc->mem_cgroup;
+		if (page_mz != mz) {
+			if (mz)
+				spin_unlock(&mz->lru_lock);
+			mz = page_mz;
+			spin_lock(&mz->lru_lock);
+		}
+		__mem_cgroup_remove_list(mz, pc);
+		css_put(&memcg->css);
+		kmem_cache_free(page_cgroup_cache, pc);
+	}
+	if (mz)
+		spin_unlock(&mz->lru_lock);
+	local_irq_restore(flags);
+}
+
+static void free_obsolete_page_cgroup(struct page_cgroup *pc)
+{
+	int count;
+	struct mem_cgroup_sink_list *mcsl;
+
+	mcsl = &get_cpu_var(memcg_sink_list);
+	pc->next = mcsl->next;
+	mcsl->next = pc;
+	count = ++mcsl->count;
+	put_cpu_var(memcg_sink_list);
+	if (count >= MEMCG_LRU_THRESH)
+		__free_obsolete_page_cgroup();
+}
+
+/*
+ * Used when freeing memory resource controller to remove all
+ * page_cgroup (in obsolete list).
+ */
+static DEFINE_MUTEX(memcg_force_drain_mutex);
+
+static void mem_cgroup_local_force_drain(struct work_struct *work)
+{
+	__free_obsolete_page_cgroup();
+}
+
+static void mem_cgroup_all_force_drain(void)
+{
+	mutex_lock(&memcg_force_drain_mutex);
+	schedule_on_each_cpu(mem_cgroup_local_force_drain);
+	mutex_unlock(&memcg_force_drain_mutex);
+}
+
+/*
  * Charge the memory controller for page usage.
  * Return
  * 0 if the charge was successful
@@ -627,6 +724,7 @@ static int mem_cgroup_charge_common(stru
 	pc->mem_cgroup = mem;
 	pc->page = page;
 	pc->flags = 0;
+	pc->next = NULL;
 	/*
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
@@ -729,8 +827,6 @@ __mem_cgroup_uncharge_common(struct page
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
@@ -748,20 +844,14 @@ __mem_cgroup_uncharge_common(struct page
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
 	    && ((PcgCache(pc) || page_mapped(page))))
 		goto unlock;
-
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(mz, pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
+	mem = pc->mem_cgroup;
+	SetPcgObsolete(pc);
 	page_assign_page_cgroup(page, NULL);
 	unlock_page_cgroup(page);
 
-	mem = pc->mem_cgroup;
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
-	css_put(&mem->css);
+	free_obsolete_page_cgroup(pc);
 
-	kmem_cache_free(page_cgroup_cache, pc);
 	return;
 unlock:
 	unlock_page_cgroup(page);
@@ -937,6 +1027,14 @@ static void mem_cgroup_force_empty_list(
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
+		if (PcgObsolete(pc)) {
+			list_move(&pc->lru, list);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			mem_cgroup_all_force_drain();
+			yield();
+			spin_lock_irqsave(&mz->lru_lock, flags);
+			continue;
+		}
 		page = pc->page;
 		if (!get_page_unless_zero(page)) {
 			list_move(&pc->lru, list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
