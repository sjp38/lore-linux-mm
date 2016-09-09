Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4556B0253
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 05:59:39 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u14so42335488lfd.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 02:59:39 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id hr7si2232118wjb.178.2016.09.09.02.59.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 02:59:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 7F093989D7
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 09:59:36 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/4] mm, vmscan: Batch removal of mappings under a single lock during reclaim
Date: Fri,  9 Sep 2016 10:59:32 +0100
Message-Id: <1473415175-20807-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

Pages unmapped during reclaim acquire/release the mapping->tree_lock for
every single page. There are two cases when it's likely that pages at the
tail of the LRU share the same mapping -- large amounts of IO to/from a
single file and swapping. This patch acquires the mapping->tree_lock for
multiple page removals.

To trigger heavy swapping, varying numbers of usemem instances were used to
read anonymous memory larger than the physical memory size. A UMA machine
was used with 4 fake NUMA nodes to increase interference from kswapd. The
swap device was backed by ramdisk using the brd driver. NUMA balancing
was disabled to limit interference.

                              4.8.0-rc5             4.8.0-rc5
                                vanilla              batch-v1
Amean    System-1      260.53 (  0.00%)      192.98 ( 25.93%)
Amean    System-3      179.59 (  0.00%)      198.33 (-10.43%)
Amean    System-5      205.71 (  0.00%)      105.22 ( 48.85%)
Amean    System-7      146.46 (  0.00%)       97.79 ( 33.23%)
Amean    System-8      275.37 (  0.00%)      149.39 ( 45.75%)
Amean    Elapsd-1      292.89 (  0.00%)      219.95 ( 24.90%)
Amean    Elapsd-3       69.47 (  0.00%)       79.02 (-13.74%)
Amean    Elapsd-5       54.12 (  0.00%)       29.88 ( 44.79%)
Amean    Elapsd-7       34.28 (  0.00%)       24.06 ( 29.81%)
Amean    Elapsd-8       57.98 (  0.00%)       33.34 ( 42.50%)

System is system CPU usage and elapsed time is the time to complete the
workload. Regardless of the thread count, the workload generally completes
faster although there is a lot of varability as much more work is being
done under a single lock.

xfs_io and pwrite was used to rewrite a file multiple times to measure any
locking overhead reduction.

xfsio Time
                                                        4.8.0-rc5             4.8.0-rc5
                                                          vanilla           batch-v1r18
Amean    pwrite-single-rewrite-async-System       49.19 (  0.00%)       49.49 ( -0.60%)
Amean    pwrite-single-rewrite-async-Elapsd      322.87 (  0.00%)      322.72 (  0.05%)

Unfortunately the difference here is well within the noise as the workload
is dominated by the cost of the IO. It may be the case that the benefit
is noticable on faster storage or in KVM instances where the data may be
resident in the page cache of the host.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 170 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 142 insertions(+), 28 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b1e12a1ea9cf..f7beb573a594 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -622,18 +622,47 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 }
 
 /*
+ * Finalise the mapping removal without the mapping lock held. The pages
+ * are placed on the free_list and the caller is expected to drop the
+ * final reference.
+ */
+static void finalise_remove_mapping_list(struct list_head *swapcache,
+				    struct list_head *filecache,
+				    void (*freepage)(struct page *),
+				    struct list_head *free_list)
+{
+	struct page *page;
+
+	list_for_each_entry(page, swapcache, lru) {
+		swp_entry_t swap = { .val = page_private(page) };
+		swapcache_free(swap);
+		set_page_private(page, 0);
+	}
+
+	list_for_each_entry(page, filecache, lru)
+		freepage(page);
+
+	list_splice_init(swapcache, free_list);
+	list_splice_init(filecache, free_list);
+}
+
+enum remove_mapping {
+	REMOVED_FAIL,
+	REMOVED_SWAPCACHE,
+	REMOVED_FILECACHE
+};
+
+/*
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page,
-			    bool reclaimed)
+static enum remove_mapping __remove_mapping(struct address_space *mapping,
+				struct page *page, bool reclaimed,
+				void (**freepage)(struct page *))
 {
-	unsigned long flags;
-
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	spin_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -668,16 +697,17 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	}
 
 	if (PageSwapCache(page)) {
-		swp_entry_t swap = { .val = page_private(page) };
+		unsigned long swapval = page_private(page);
+		swp_entry_t swap = { .val = swapval };
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		swapcache_free(swap);
+		set_page_private(page, swapval);
+		return REMOVED_SWAPCACHE;
 	} else {
-		void (*freepage)(struct page *);
 		void *shadow = NULL;
 
-		freepage = mapping->a_ops->freepage;
+		*freepage = mapping->a_ops->freepage;
+
 		/*
 		 * Remember a shadow entry for reclaimed file cache in
 		 * order to detect refaults, thus thrashing, later on.
@@ -698,17 +728,76 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		    !mapping_exiting(mapping) && !dax_mapping(mapping))
 			shadow = workingset_eviction(mapping, page);
 		__delete_from_page_cache(page, shadow);
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		return REMOVED_FILECACHE;
+	}
 
-		if (freepage != NULL)
-			freepage(page);
+cannot_free:
+	return REMOVED_FAIL;
+}
+
+static unsigned long remove_mapping_list(struct list_head *mapping_list,
+					 struct list_head *free_pages,
+					 struct list_head *ret_pages)
+{
+	unsigned long flags;
+	struct address_space *mapping = NULL;
+	void (*freepage)(struct page *) = NULL;
+	LIST_HEAD(swapcache);
+	LIST_HEAD(filecache);
+	struct page *page, *tmp;
+	unsigned long nr_reclaimed = 0;
+
+continue_removal:
+	list_for_each_entry_safe(page, tmp, mapping_list, lru) {
+		/* Batch removals under one tree lock at a time */
+		if (mapping && page_mapping(page) != mapping)
+			continue;
+
+		list_del(&page->lru);
+		if (!mapping) {
+			mapping = page_mapping(page);
+			spin_lock_irqsave(&mapping->tree_lock, flags);
+		}
+
+		switch (__remove_mapping(mapping, page, true, &freepage)) {
+		case REMOVED_FILECACHE:
+			/*
+			 * At this point, we have no other references and there
+			 * is no way to pick any more up (removed from LRU,
+			 * removed from pagecache). Can use non-atomic bitops
+			 * now (and we obviously don't have to worry about
+			 * waking up a process  waiting on the page lock,
+			 * because there are no references.
+			 */
+			__ClearPageLocked(page);
+			if (freepage)
+				list_add(&page->lru, &filecache);
+			else
+				list_add(&page->lru, free_pages);
+			nr_reclaimed++;
+			break;
+		case REMOVED_SWAPCACHE:
+			/* See FILECACHE case as to why non-atomic is safe */
+			__ClearPageLocked(page);
+			list_add(&page->lru, &swapcache);
+			nr_reclaimed++;
+			break;
+		case REMOVED_FAIL:
+			unlock_page(page);
+			list_add(&page->lru, ret_pages);
+		}
 	}
 
-	return 1;
+	if (mapping) {
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		finalise_remove_mapping_list(&swapcache, &filecache, freepage, free_pages);
+		mapping = NULL;
+	}
 
-cannot_free:
-	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	return 0;
+	if (!list_empty(mapping_list))
+		goto continue_removal;
+
+	return nr_reclaimed;
 }
 
 /*
@@ -719,16 +808,42 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page, false)) {
+	unsigned long flags;
+	LIST_HEAD(swapcache);
+	LIST_HEAD(filecache);
+	void (*freepage)(struct page *) = NULL;
+	swp_entry_t swap;
+	int ret = 0;
+
+	spin_lock_irqsave(&mapping->tree_lock, flags);
+	freepage = mapping->a_ops->freepage;
+	ret = __remove_mapping(mapping, page, false, &freepage);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+
+	if (ret != REMOVED_FAIL) {
 		/*
 		 * Unfreezing the refcount with 1 rather than 2 effectively
 		 * drops the pagecache ref for us without requiring another
 		 * atomic operation.
 		 */
 		page_ref_unfreeze(page, 1);
+	}
+
+	switch (ret) {
+	case REMOVED_FILECACHE:
+		if (freepage)
+			freepage(page);
+		return 1;
+	case REMOVED_SWAPCACHE:
+		swap.val = page_private(page);
+		swapcache_free(swap);
+		set_page_private(page, 0);
 		return 1;
+	case REMOVED_FAIL:
+		return 0;
 	}
-	return 0;
+
+	BUG();
 }
 
 /**
@@ -910,6 +1025,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(mapping_pages);
 	int pgactivate = 0;
 	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_dirty = 0;
@@ -1206,17 +1322,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 lazyfree:
-		if (!mapping || !__remove_mapping(mapping, page, true))
+		if (!mapping)
 			goto keep_locked;
 
-		/*
-		 * At this point, we have no other references and there is
-		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
-		 * we obviously don't have to worry about waking up a process
-		 * waiting on the page lock, because there are no references.
-		 */
-		__ClearPageLocked(page);
+		list_add(&page->lru, &mapping_pages);
+		if (ret == SWAP_LZFREE)
+			count_vm_event(PGLAZYFREED);
+		continue;
+
 free_it:
 		if (ret == SWAP_LZFREE)
 			count_vm_event(PGLAZYFREED);
@@ -1251,6 +1364,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
 
+	nr_reclaimed += remove_mapping_list(&mapping_pages, &free_pages, &ret_pages);
 	mem_cgroup_uncharge_list(&free_pages);
 	try_to_unmap_flush();
 	free_hot_cold_page_list(&free_pages, true);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
