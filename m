Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 925066B003B
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 02:22:07 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 4/4] mm: Enhance per process reclaim
Date: Mon, 25 Mar 2013 15:21:34 +0900
Message-Id: <1364192494-22185-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1364192494-22185-1-git-send-email-minchan@kernel.org>
References: <1364192494-22185-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sangseok Lee <sangseok.lee@lge.com>, Minchan Kim <minchan@kernel.org>

Some pages could be shared by several processes. (ex, libc)
In case of that, it's too bad to reclaim them from the beginnig.

This patch causes VM to keep them on memory until last task
try to reclaim them so shared pages will be reclaimed only if
all of task has gone swapping out.

This feature doesn't handle non-linear mapping on ramfs because
it's very time-consuming and doesn't make sure of reclaiming and
not common.

Signed-off-by: Sangseok Lee <sangseok.lee@lge.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/proc/task_mmu.c   |  2 +-
 include/linux/ksm.h  |  6 ++++--
 include/linux/rmap.h |  8 +++++---
 mm/ksm.c             |  9 +++++++-
 mm/memory-failure.c  |  2 +-
 mm/migrate.c         |  6 ++++--
 mm/rmap.c            | 58 +++++++++++++++++++++++++++++++++++++---------------
 mm/vmscan.c          | 14 +++++++++++--
 8 files changed, 77 insertions(+), 28 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c3713a4..7f6aaf5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1154,7 +1154,7 @@ cont:
 			break;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-	reclaim_pages_from_list(&page_list);
+	reclaim_pages_from_list(&page_list, vma);
 	if (addr != end)
 		goto cont;
 
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 45c9b6a..d8e556b 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -75,7 +75,8 @@ struct page *ksm_might_need_to_copy(struct page *page,
 
 int page_referenced_ksm(struct page *page,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
-int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
+int try_to_unmap_ksm(struct page *page,
+			enum ttu_flags flags, struct vm_area_struct *vma);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
@@ -115,7 +116,8 @@ static inline int page_referenced_ksm(struct page *page,
 	return 0;
 }
 
-static inline int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
+static inline int try_to_unmap_ksm(struct page *page,
+			enum ttu_flags flags, struct vm_area_struct *target_vma)
 {
 	return 0;
 }
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index a24e34e..6c7d030 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -12,7 +12,8 @@
 
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
-extern unsigned long reclaim_pages_from_list(struct list_head *page_list);
+extern unsigned long reclaim_pages_from_list(struct list_head *page_list,
+					     struct vm_area_struct *vma);
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -192,7 +193,8 @@ int page_referenced_one(struct page *, struct vm_area_struct *,
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
-int try_to_unmap(struct page *, enum ttu_flags flags);
+int try_to_unmap(struct page *, enum ttu_flags flags,
+			struct vm_area_struct *vma);
 int try_to_unmap_one(struct page *, struct vm_area_struct *,
 			unsigned long address, enum ttu_flags flags);
 
@@ -259,7 +261,7 @@ static inline int page_referenced(struct page *page, int is_locked,
 	return 0;
 }
 
-#define try_to_unmap(page, refs) SWAP_FAIL
+#define try_to_unmap(page, refs, vma) SWAP_FAIL
 
 static inline int page_mkclean(struct page *page)
 {
diff --git a/mm/ksm.c b/mm/ksm.c
index 7f629e4..1a90d13 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1949,7 +1949,8 @@ out:
 	return referenced;
 }
 
-int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
+int try_to_unmap_ksm(struct page *page, enum ttu_flags flags,
+			struct vm_area_struct *target_vma)
 {
 	struct stable_node *stable_node;
 	struct hlist_node *hlist;
@@ -1963,6 +1964,12 @@ int try_to_unmap_ksm(struct page *page, enum ttu_flags flags)
 	stable_node = page_stable_node(page);
 	if (!stable_node)
 		return SWAP_FAIL;
+
+	if (target_vma) {
+		unsigned long address = vma_address(page, target_vma);
+		ret = try_to_unmap_one(page, vma, address, flags);
+		goto out;
+	}
 again:
 	hlist_for_each_entry(rmap_item, hlist, &stable_node->hlist, hlist) {
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ceb0c7f..f3928e4 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -955,7 +955,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (hpage != ppage)
 		lock_page(ppage);
 
-	ret = try_to_unmap(ppage, ttu);
+	ret = try_to_unmap(ppage, ttu, NULL);
 	if (ret != SWAP_SUCCESS)
 		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
 				pfn, page_mapcount(ppage));
diff --git a/mm/migrate.c b/mm/migrate.c
index 6fa4ebc..aafbc66 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -820,7 +820,8 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	}
 
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS,
+			NULL);
 
 skip_unmap:
 	if (!page_mapped(page))
@@ -947,7 +948,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
-	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS,
+						NULL);
 
 	if (!page_mapped(hpage))
 		rc = move_to_new_page(new_hpage, hpage, 1, mode);
diff --git a/mm/rmap.c b/mm/rmap.c
index 6280da8..a880f24 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1435,13 +1435,16 @@ bool is_vma_temporary_stack(struct vm_area_struct *vma)
 
 /**
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
- * rmap method
+ * rmap method if @vma is NULL
  * @page: the page to unmap/unlock
  * @flags: action and flags
+ * @target_vma: vma for unmapping a @page
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the anon_vma struct it points to.
  *
+ * If @target_vma isn't NULL, this function unmap a page from the vma
+ *
  * This function is only called from try_to_unmap/try_to_munlock for
  * anonymous pages.
  * When called from try_to_munlock(), the mmap_sem of the mm containing the vma
@@ -1449,12 +1452,19 @@ bool is_vma_temporary_stack(struct vm_area_struct *vma)
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * 'LOCKED.
  */
-static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
+static int try_to_unmap_anon(struct page *page, enum ttu_flags flags,
+					struct vm_area_struct *target_vma)
 {
+	int ret = SWAP_AGAIN;
+	unsigned long address;
 	struct anon_vma *anon_vma;
 	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
-	int ret = SWAP_AGAIN;
+
+	if (target_vma) {
+		address = vma_address(page, target_vma);
+		return try_to_unmap_one(page, target_vma, address, flags);
+	}
 
 	anon_vma = page_lock_anon_vma_read(page);
 	if (!anon_vma)
@@ -1463,7 +1473,6 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address;
 
 		/*
 		 * During exec, a temporary VMA is setup and later moved.
@@ -1491,6 +1500,7 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
  * try_to_unmap_file - unmap/unlock file page using the object-based rmap method
  * @page: the page to unmap/unlock
  * @flags: action and flags
+ * @target_vma: vma for unmapping @page
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the address_space struct it points to.
@@ -1502,7 +1512,8 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * 'LOCKED.
  */
-static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
+static int try_to_unmap_file(struct page *page, enum ttu_flags flags,
+				struct vm_area_struct *target_vma)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -1512,16 +1523,27 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
+	unsigned long address;
 
 	if (PageHuge(page))
 		pgoff = page->index << compound_order(page);
 
 	mutex_lock(&mapping->i_mmap_mutex);
-	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		unsigned long address = vma_address(page, vma);
-		ret = try_to_unmap_one(page, vma, address, flags);
-		if (ret != SWAP_AGAIN || !page_mapped(page))
+	if (target_vma) {
+		/* We don't handle non-linear vma on ramfs */
+		if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 			goto out;
+
+		address = vma_address(page, target_vma);
+		ret = try_to_unmap_one(page, target_vma, address, flags);
+		goto out;
+	} else {
+		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+			address = vma_address(page, vma);
+			ret = try_to_unmap_one(page, vma, address, flags);
+			if (ret != SWAP_AGAIN || !page_mapped(page))
+				goto out;
+		}
 	}
 
 	if (list_empty(&mapping->i_mmap_nonlinear))
@@ -1602,9 +1624,12 @@ out:
  * try_to_unmap - try to remove all page table mappings to a page
  * @page: the page to get unmapped
  * @flags: action and flags
+ * @vma : target vma for reclaim
  *
  * Tries to remove all the page table entries which are mapping this
  * page, used in the pageout path.  Caller must hold the page lock.
+ * If @vma is not NULL, this function try to remove @page from only @vma
+ * without peeking all mapped vma for @page.
  * Return values are:
  *
  * SWAP_SUCCESS	- we succeeded in removing all mappings
@@ -1612,7 +1637,8 @@ out:
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
  */
-int try_to_unmap(struct page *page, enum ttu_flags flags)
+int try_to_unmap(struct page *page, enum ttu_flags flags,
+				struct vm_area_struct *vma)
 {
 	int ret;
 
@@ -1620,11 +1646,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
 
 	if (unlikely(PageKsm(page)))
-		ret = try_to_unmap_ksm(page, flags);
+		ret = try_to_unmap_ksm(page, flags, vma);
 	else if (PageAnon(page))
-		ret = try_to_unmap_anon(page, flags);
+		ret = try_to_unmap_anon(page, flags, vma);
 	else
-		ret = try_to_unmap_file(page, flags);
+		ret = try_to_unmap_file(page, flags, vma);
 	if (ret != SWAP_MLOCK && !page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;
@@ -1650,11 +1676,11 @@ int try_to_munlock(struct page *page)
 	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
 
 	if (unlikely(PageKsm(page)))
-		return try_to_unmap_ksm(page, TTU_MUNLOCK);
+		return try_to_unmap_ksm(page, TTU_MUNLOCK, NULL);
 	else if (PageAnon(page))
-		return try_to_unmap_anon(page, TTU_MUNLOCK);
+		return try_to_unmap_anon(page, TTU_MUNLOCK, NULL);
 	else
-		return try_to_unmap_file(page, TTU_MUNLOCK);
+		return try_to_unmap_file(page, TTU_MUNLOCK, NULL);
 }
 
 void __put_anon_vma(struct anon_vma *anon_vma)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 367d0f4..df9c4d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -92,6 +92,13 @@ struct scan_control {
 	 * are scanned.
 	 */
 	nodemask_t	*nodemask;
+
+	/*
+	 * Reclaim pages from a vma. If the page is shared by other tasks
+	 * it is zapped from a vma without reclaim so it ends up remaining
+	 * on memory until last task zap it.
+	 */
+	struct vm_area_struct *target_vma;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -793,7 +800,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, ttu_flags)) {
+			switch (try_to_unmap(page,
+					ttu_flags, sc->target_vma)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1000,13 +1008,15 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 }
 
 #ifdef CONFIG_PROCESS_RECLAIM
-unsigned long reclaim_pages_from_list(struct list_head *page_list)
+unsigned long reclaim_pages_from_list(struct list_head *page_list,
+					struct vm_area_struct *vma)
 {
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.target_vma = vma,
 	};
 
 	unsigned long nr_reclaimed;
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
