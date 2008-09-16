Date: Tue, 16 Sep 2008 21:17:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 10/9] get/put page at charge/uncharge
Message-Id: <20080916211746.f1cf643f.kamezawa.hiroyu@jp.fujitsu.com>
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

While page_cgroup() has reference to the page, it doesn't increment
page->count.

Now, the page and its page_cgroup has one-to-one relationship and there is no
dynamic allocation. But the behavior of global LRU and memory resource
controller is not synchronized. What this means is
  - LRU handling cost is not high. (because there is no synchronization)
  - We have to be afraid of "reuse" of the page.

Synchronizing global LRU and memcg's LRU means to make the cost of LRU
handling twice. Instead of that, this patch add get_page()/put_page() to
charge/uncharge(). By this, at least, alloc/free/reuse of page and page_cgroup
is synchronized.
This makes memcg robust and helps optimization of memcg in future.

What this patch does is.
 - Ignore Compound pages.
 - get_page()/put_page() at charge/uncharge
 - handle special method of "freeze" page_count() in page migration and
   speculative page cache. To do this, callee of mem_cgroup_uncharge_cache_page()
   is moved. It's called after all speculative-page-cache ops are finished.
 - remove charge/uncharge() from insert_page()...for irregular handlers.
   which doesn't uses radix-tree.
 - move charge() in do_swap_page() under lock_page().
 
Needs careful and enough review.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 include/linux/memcontrol.h |   20 ++++++++++++++++++++
 mm/filemap.c               |    2 +-
 mm/memcontrol.c            |   24 ++++++++++++------------
 mm/memory.c                |   18 +++++-------------
 mm/migrate.c               |   10 +++++++++-
 mm/swapfile.c              |   18 ++++++++++++++++--
 mm/vmscan.c                |   42 ++++++++++++++++++++++++++++--------------
 7 files changed, 91 insertions(+), 43 deletions(-)

Index: mmtom-2.6.27-rc5+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc5+/mm/memcontrol.c
@@ -332,7 +332,7 @@ void mem_cgroup_move_lists(struct page *
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
-	if (mem_cgroup_subsys.disabled)
+	if (!under_mem_cgroup(page))
 		return;
 
 	/*
@@ -555,6 +555,10 @@ static int mem_cgroup_charge_common(stru
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
+	/* avoid case in boot sequence */
+	if (unlikely(PageReserved(page)))
+		return 0;
+
 	pc = lookup_page_cgroup(page_to_pfn(page));
 	/* can happen at boot */
 	if (unlikely(!pc))
@@ -630,6 +634,7 @@ static int mem_cgroup_charge_common(stru
 	default:
 		BUG();
 	}
+	get_page(pc->page);
 	unlock_page_cgroup(pc);
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -647,9 +652,7 @@ out:
 
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
-	if (mem_cgroup_subsys.disabled)
-		return 0;
-	if (PageCompound(page))
+	if (!under_mem_cgroup(page))
 		return 0;
 	/*
 	 * If already mapped, we don't have to account.
@@ -669,9 +672,7 @@ int mem_cgroup_charge(struct page *page,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	if (mem_cgroup_subsys.disabled)
-		return 0;
-	if (PageCompound(page))
+	if (!under_mem_cgroup(page))
 		return 0;
 	/*
 	 * Corner case handling. This is called from add_to_page_cache()
@@ -716,10 +717,8 @@ __mem_cgroup_uncharge_common(struct page
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long flags;
 
-	if (mem_cgroup_subsys.disabled)
+	if (!under_mem_cgroup(page))
 		return;
-	/* check the condition we can know from page */
-
 	pc = lookup_page_cgroup(pfn);
 	if (unlikely(!pc || !PageCgroupUsed(pc)))
 		return;
@@ -735,6 +734,7 @@ __mem_cgroup_uncharge_common(struct page
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_remove_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	put_page(pc->page);
 	pc->mem_cgroup = NULL;
 	css_put(&mem->css);
 	preempt_enable();
@@ -769,7 +769,7 @@ int mem_cgroup_prepare_migration(struct 
 	enum charge_type ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
 	int ret = 0;
 
-	if (mem_cgroup_subsys.disabled)
+	if (!under_mem_cgroup(page))
 		return 0;
 
 
@@ -822,7 +822,7 @@ int mem_cgroup_shrink_usage(struct mm_st
 	int progress = 0;
 	int retry = MEM_CGROUP_RECLAIM_RETRIES;
 
-	if (mem_cgroup_subsys.disabled)
+	if (!under_mem_cgroup(NULL))
 		return 0;
 	if (!mm)
 		return 0;
Index: mmtom-2.6.27-rc5+/mm/swapfile.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/swapfile.c
+++ mmtom-2.6.27-rc5+/mm/swapfile.c
@@ -390,20 +390,34 @@ static int remove_exclusive_swap_page_co
 /*
  * Most of the time the page should have two references: one for the
  * process and one for the swap cache.
+ * If memory resource controller is used, the page has extra reference from it.
  */
 int remove_exclusive_swap_page(struct page *page)
 {
-	return remove_exclusive_swap_page_count(page, 2);
+	int count;
+	/* page is accounted only when it's mapped. (if swapcache) */
+	if (under_mem_cgroup(page) && page_mapped(page))
+		count = 3;
+	else
+		count = 2;
+	return remove_exclusive_swap_page_count(page, count);
 }
 
 /*
  * The pageout code holds an extra reference to the page.  That raises
  * the reference count to test for to 2 for a page that is only in the
  * swap cache plus 1 for each process that maps the page.
+ * If memory resource controller is used, the page has extra reference from it.
  */
 int remove_exclusive_swap_page_ref(struct page *page)
 {
-	return remove_exclusive_swap_page_count(page, 2 + page_mapcount(page));
+	int count;
+
+	count = page_mapcount(page);
+	/* page is accounted only when it's mapped. (if swapcache) */
+	if (under_mem_cgroup(page) && count)
+		count += 1;
+	return remove_exclusive_swap_page_count(page, 2 + count);
 }
 
 /*
Index: mmtom-2.6.27-rc5+/include/linux/memcontrol.h
===================================================================
--- mmtom-2.6.27-rc5+.orig/include/linux/memcontrol.h
+++ mmtom-2.6.27-rc5+/include/linux/memcontrol.h
@@ -20,6 +20,8 @@
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
 
+#include <linux/page-flags.h>
+#include <linux/cgroup.h>
 struct mem_cgroup;
 struct page_cgroup;
 struct page;
@@ -72,6 +74,19 @@ extern void mem_cgroup_record_reclaim_pr
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
 
+extern struct cgroup_subsys mem_cgroup_subsys;
+static inline int under_mem_cgroup(struct page *page)
+{
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+	if (!page)
+		return 1;
+	if (PageCompound(page))
+		return 0;
+	return 1;
+}
+
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline void page_reset_bad_cgroup(struct page *page)
 {
@@ -163,6 +178,11 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
+static inline int under_mem_cgroup(void)
+{
+	return 0;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
Index: mmtom-2.6.27-rc5+/mm/migrate.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/migrate.c
+++ mmtom-2.6.27-rc5+/mm/migrate.c
@@ -283,8 +283,16 @@ static int migrate_page_move_mapping(str
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
+	/*
+	 * Here, the page is unmapped and memcg's refcnt should be 0
+	 * if it's anon or SwapCache.
+	 */
+	if (PageAnon(page))
+		expected_count = 2 + !!PagePrivate(page);
+	else
+		expected_count = 2 + !!PagePrivate(page)
+				   + under_mem_cgroup(page);
 
-	expected_count = 2 + !!PagePrivate(page);
 	if (page_count(page) != expected_count ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
Index: mmtom-2.6.27-rc5+/mm/vmscan.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/vmscan.c
+++ mmtom-2.6.27-rc5+/mm/vmscan.c
@@ -310,7 +310,10 @@ static inline int page_mapping_inuse(str
 
 static inline int is_page_cache_freeable(struct page *page)
 {
-	return page_count(page) - !!PagePrivate(page) == 2;
+	if (under_mem_cgroup(page))
+		return page_count(page) - !!PagePrivate(page) == 3;
+	else
+		return page_count(page) - !!PagePrivate(page) == 2;
 }
 
 static int may_write_to_queue(struct backing_dev_info *bdi)
@@ -453,6 +456,7 @@ static pageout_t pageout(struct page *pa
  */
 static int __remove_mapping(struct address_space *mapping, struct page *page)
 {
+	int freeze_ref;
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
@@ -481,12 +485,19 @@ static int __remove_mapping(struct addre
 	 *
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
+ 	 *
+	 * If memory resource controller is enabled, it has extra ref.
 	 */
-	if (!page_freeze_refs(page, 2))
+	if (!PageSwapCache(page))
+		freeze_ref = 2 + under_mem_cgroup(page);
+	else
+		freeze_ref = 2;
+
+	if (!page_freeze_refs(page, freeze_ref))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
-		page_unfreeze_refs(page, 2);
+		page_unfreeze_refs(page, freeze_ref);
 		goto cannot_free;
 	}
 
@@ -500,7 +511,7 @@ static int __remove_mapping(struct addre
 		spin_unlock_irq(&mapping->tree_lock);
 	}
 
-	return 1;
+	return freeze_ref - 1;
 
 cannot_free:
 	spin_unlock_irq(&mapping->tree_lock);
@@ -515,16 +526,19 @@ cannot_free:
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page)) {
-		/*
-		 * Unfreezing the refcount with 1 rather than 2 effectively
-		 * drops the pagecache ref for us without requiring another
-		 * atomic operation.
-		 */
-		page_unfreeze_refs(page, 1);
-		return 1;
-	}
-	return 0;
+	int ret;
+	ret = __remove_mapping(mapping, page);
+	if (!ret)
+		return 0;
+	/*
+	 * Unfreezing the refcount with 1 or 2 rather than 2 effectively
+	 * drops the pagecache ref for us without requiring another
+	 * atomic operation.
+	 */
+	page_unfreeze_refs(page, ret);
+	if (ret == 2)
+		mem_cgroup_uncharge_cache_page(page);
+	return 1;
 }
 
 /**
Index: mmtom-2.6.27-rc5+/mm/memory.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/memory.c
+++ mmtom-2.6.27-rc5+/mm/memory.c
@@ -1319,22 +1319,17 @@ static int insert_page(struct vm_area_st
 			struct page *page, pgprot_t prot)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int retval;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int retval = -EINVAL;
 
-	retval = mem_cgroup_charge(page, mm, GFP_KERNEL);
-	if (retval)
-		goto out;
-
-	retval = -EINVAL;
 	if (PageAnon(page))
-		goto out_uncharge;
+		goto out;
 	retval = -ENOMEM;
 	flush_dcache_page(page);
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
-		goto out_uncharge;
+		goto out;
 	retval = -EBUSY;
 	if (!pte_none(*pte))
 		goto out_unlock;
@@ -1350,8 +1345,6 @@ static int insert_page(struct vm_area_st
 	return retval;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
-out_uncharge:
-	mem_cgroup_uncharge_page(page);
 out:
 	return retval;
 }
@@ -2325,16 +2318,15 @@ static int do_swap_page(struct mm_struct
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	}
+	lock_page(page);
 
+	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
-		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		ret = VM_FAULT_OOM;
 		goto out;
 	}
 
 	mark_page_accessed(page);
-	lock_page(page);
-	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 
 	/*
 	 * Back out if somebody else already faulted in this pte.
Index: mmtom-2.6.27-rc5+/mm/filemap.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/filemap.c
+++ mmtom-2.6.27-rc5+/mm/filemap.c
@@ -121,7 +121,6 @@ void __remove_from_page_cache(struct pag
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	BUG_ON(page_mapped(page));
-	mem_cgroup_uncharge_cache_page(page);
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
@@ -144,6 +143,7 @@ void remove_from_page_cache(struct page 
 
 	spin_lock_irq(&mapping->tree_lock);
 	__remove_from_page_cache(page);
+	mem_cgroup_uncharge_cache_page(page);
 	spin_unlock_irq(&mapping->tree_lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
