From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 12/12] memcg: fix race at charging swap-in
Date: Thu, 25 Sep 2008 15:36:30 +0900
Message-ID: <20080925153630.b59da31e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754829AbYIYGaT@vger.kernel.org>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

There is a small race in do_swap_page(). When the page swapped-in is charged,
the mapcount can be greater than 0. But, at the same time some process (shares
it ) call unmap and make mapcount 1->0 and the page is uncharged.

For fixing this, I added a new interface.
  - precharge
   account to res_counter by PAGE_SIZE and try to free pages if necessary.
  - commit	
   register page_cgroup and add to LRU if necessary.
  - cancel
   uncharge PAGE_SIZE because of do_swap_page failure.

This protocol uses PCG_USED bit on page_cgroup for avoiding over accounting.
Usual mem_cgroup_charge_common() does precharge -> commit at a time.

These precharge/commit/cancel is useful and can be used for other places,
 - shmem, (and other places need precharge.)
 - migration
 - move_account(force_empty) etc...
etc..we'll revisit later.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/memcontrol.h |   21 +++++++
 mm/memcontrol.c            |  135 +++++++++++++++++++++++++++++++--------------
 mm/memory.c                |    6 +-
 3 files changed, 120 insertions(+), 42 deletions(-)

Index: mmotm-2.6.27-rc7+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.27-rc7+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.27-rc7+/include/linux/memcontrol.h
@@ -31,6 +31,13 @@ struct mm_struct;
 
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
+/* for swap handling */
+extern int mem_cgroup_precharge(struct mm_struct *mm,
+		gfp_t gfp_mask, struct mem_cgroup **ptr);
+extern void mem_cgroup_commit_charge_swap(struct page *page,
+					struct mem_cgroup *ptr);
+extern void mem_cgroup_cancel_charge_swap(struct mem_cgroup *ptr);
+
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
 extern void mem_cgroup_move_lists(struct page *page, enum lru_list lru);
@@ -85,6 +92,20 @@ static inline int mem_cgroup_cache_charg
 	return 0;
 }
 
+static int mem_cgroup_precharge(struct mm_struct *mm,
+				gfp_t gfp_mask, struct mem_cgroup **ptr)
+{
+	return 0;
+}
+
+static void mem_cgroup_commit_charge_swap(struct page *page,
+					  struct mem_cgroup *ptr)
+{
+}
+static void mem_cgroup_cancel_charge_swap(struct mem_cgroup *ptr)
+{
+}
+
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -698,52 +698,44 @@ static void drain_page_cgroup_all(void)
 
 
 /*
- * Charge the memory controller for page usage.
- * Return
- * 0 if the charge was successful
- * < 0 if the cgroup is over its limit
+ * charge against mem_cgroup linked to this mm. (or *ptr)
+ *
+ * This just charge PAGE_SIZE and reduce memory usage if necessary.
+ *
+ * Pages on radix-tree is charged at radix-tree add/remove under lock.
+ * new pages are charged at allocation and both are guaranteed to be that
+ * there are no racy users. We does precharge->commit at once.
+ *
+ * About swapcache, we can't trust page->mapcount until it's mapped.
+ * Then we do precharge before map and commit/cancel after the mapping is
+ * established. (see below, we have commit_swap and cancel_swap)
  */
-static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype,
-				struct mem_cgroup *memcg)
+
+int mem_cgroup_precharge(struct mm_struct *mm,
+			 gfp_t mask, struct mem_cgroup **ptr)
 {
 	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
-	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
-
-	pc = lookup_page_cgroup(page);
-	/* can happen at boot */
-	if (unlikely(!pc))
-		return 0;
-	prefetchw(pc);
-	/*
-	 * We always charge the cgroup the mm_struct belongs to.
-	 * The mm_struct's mem_cgroup changes on task migration if the
-	 * thread group leader migrates. It's possible that mm is not
-	 * set, if so charge the init_mm (happens for pagecache usage).
-	 */
+	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 
-	if (likely(!memcg)) {
-		rcu_read_lock();
+	rcu_read_lock();
+	if (!*ptr) {
 		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
 		if (unlikely(!mem)) {
 			rcu_read_unlock();
-			return 0;
+			return -ESRCH;
 		}
-		rcu_read_unlock();
+		*ptr = mem;
 	} else {
-		mem = memcg;
+		mem = *ptr;
 	}
+	rcu_read_unlock();
 
+	css_get(&mem->css);
 	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
-		if (!(gfp_mask & __GFP_WAIT))
-			goto out;
-
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
+		if (!(mask & __GFP_WAIT))
+			goto nomem;
+		if (try_to_free_mem_cgroup_pages(mem, mask))
 			continue;
-
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
 		 * picture of reclaim. Some pages are reclaimed and might be
@@ -755,16 +747,31 @@ static int mem_cgroup_charge_common(stru
 			continue;
 
 		if (!nr_retries--) {
-			mem_cgroup_out_of_memory(mem, gfp_mask);
-			goto out;
+			mem_cgroup_out_of_memory(mem, mask);
+			goto nomem;
 		}
 	}
+	return 0;
+nomem:
+	css_put(&mem->css);
+	return -ENOMEM;
+}
 
+void mem_cgroup_commit_charge(struct page_cgroup *pc,
+			      struct mem_cgroup *mem,
+			      enum charge_type ctype)
+{
+	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
+
+	if (!mem)
+		return;
 	preempt_disable();
 	if (TestSetPageCgroupUsed(pc)) {
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
 		preempt_enable();
-		goto done;
+		return;
 	}
 	/*
  	 *  page cgroup is *unused* now....but....
@@ -786,14 +793,43 @@ static int mem_cgroup_charge_common(stru
 
 	pc->mem_cgroup = mem;
 	set_page_cgroup_lru(pc);
+	css_put(&mem->css);
 	preempt_enable();
+}
 
-done:
+/*
+ * Charge the memory controller for page usage.
+ * Return
+ * 0 if the charge was successful
+ * < 0 if the cgroup is over its limit
+ */
+static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
+				gfp_t gfp_mask, enum charge_type ctype,
+				struct mem_cgroup *memcg)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *ptr = memcg;
+	int ret;
+
+	pc = lookup_page_cgroup(page);
+	/* can happen at boot */
+	if (unlikely(!pc))
+		return 0;
+	prefetchw(pc);
+
+	ret = mem_cgroup_precharge(mm, gfp_mask, &ptr);
+	if (likely(!ret)) {
+		mem_cgroup_commit_charge(pc, ptr, ctype);
+		return 0;
+	}
+	if (unlikely((ret == -ENOMEM)))
+		return ret;
+	/* ESRCH case */
 	return 0;
-out:
-	return -ENOMEM;
 }
 
+
+
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
 	if (mem_cgroup_subsys.disabled)
@@ -806,7 +842,7 @@ int mem_cgroup_charge(struct page *page,
 	 * But page->mapping may have out-of-use anon_vma pointer,
 	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
 	 * is NULL.
-  	 */
+	 */
 	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
 		return 0;
 	if (unlikely(!mm))
@@ -857,6 +893,25 @@ int mem_cgroup_cache_charge(struct page 
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
+
+void mem_cgroup_commit_charge_swap(struct page *page, struct mem_cgroup *ptr)
+{
+	struct page_cgroup *pc;
+	if (!ptr)
+		return;
+	pc = lookup_page_cgroup(page);
+	mem_cgroup_commit_charge(pc, ptr, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+}
+
+void mem_cgroup_cancel_charge_swap(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return;
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	css_put(&mem->css);
+}
+
+
 /*
  * uncharge if !page_mapped(page)
  */
Index: mmotm-2.6.27-rc7+/mm/memory.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memory.c
+++ mmotm-2.6.27-rc7+/mm/memory.c
@@ -2287,6 +2287,7 @@ static int do_swap_page(struct mm_struct
 	struct page *page;
 	swp_entry_t entry;
 	pte_t pte;
+	struct mem_cgroup *ptr = NULL;
 	int ret = 0;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
@@ -2323,7 +2324,7 @@ static int do_swap_page(struct mm_struct
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
-	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
+	if (mem_cgroup_precharge(mm, GFP_KERNEL, &ptr) == -ENOMEM) {
 		ret = VM_FAULT_OOM;
 		goto out;
 	}
@@ -2353,6 +2354,7 @@ static int do_swap_page(struct mm_struct
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
+	mem_cgroup_commit_charge_swap(page, ptr);
 
 	swap_free(entry);
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
@@ -2373,7 +2375,7 @@ unlock:
 out:
 	return ret;
 out_nomap:
-	mem_cgroup_uncharge_page(page);
+	mem_cgroup_cancel_charge_swap(ptr);
 	pte_unmap_unlock(page_table, ptl);
 	unlock_page(page);
 	page_cache_release(page);
