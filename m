Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6B795900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 06:41:32 -0400 (EDT)
Received: by wgin8 with SMTP id n8so208414367wgi.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 03:41:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si20696429wix.117.2015.04.21.03.41.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 03:41:26 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/6] mm: Defer TLB flush after unmap as long as possible
Date: Tue, 21 Apr 2015 11:41:17 +0100
Message-Id: <1429612880-21415-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1429612880-21415-1-git-send-email-mgorman@suse.de>
References: <1429612880-21415-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If a PTE is unmapped and it's dirty then it was writable recently. Due
to deferred TLB flushing, it's best to assume a writable TLB cache entry
exists. With that assumption, the TLB must be flushed before any IO can
start or the page is freed to avoid lost writes or data corruption. Prior
to this patch, such PFNs were simply flushed immediately. In this patch,
the caller is informed that such entries potentially exist and it's up to
the caller to flush before pages are freed or IO can start.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/rmap.h | 10 ++++++----
 mm/rmap.c            | 55 ++++++++++++++++++++++++++++++++++++++--------------
 mm/vmscan.c          |  9 ++++++++-
 3 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 8d23914b219e..5bbaec19cb21 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -290,9 +290,11 @@ static inline int page_mkclean(struct page *page)
 /*
  * Return values of try_to_unmap
  */
-#define SWAP_SUCCESS	0
-#define SWAP_AGAIN	1
-#define SWAP_FAIL	2
-#define SWAP_MLOCK	3
+#define SWAP_SUCCESS		0
+#define SWAP_SUCCESS_CACHED	1
+#define SWAP_AGAIN		2
+#define SWAP_AGAIN_CACHED	3
+#define SWAP_FAIL		4
+#define SWAP_MLOCK		5
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index c5badb6c72c9..dcf1df16bf4d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1262,6 +1262,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 	bool deferred;
+	bool dirty_cached = false;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
@@ -1309,12 +1310,13 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if (pte_dirty(pteval)) {
 		/*
 		 * If the PTE was dirty then it's best to assume it's writable.
-		 * The TLB must be flushed before the page is unlocked as IO
-		 * can start in parallel. Without the flush, writes could
-		 * happen and data be potentially lost.
+		 * Inform the caller that it is possible there is a writable
+		 * cached TLB entry. It is the responsibility of the caller
+		 * to flush the TLB before the page is freed or any IO is
+		 * initiated.
 		 */
 		if (deferred)
-			flush_tlb_page(vma, address);
+			dirty_cached = true;
 
 		set_page_dirty(page);
 	}
@@ -1388,6 +1390,9 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	page_remove_rmap(page);
 	page_cache_release(page);
 
+	if (dirty_cached)
+		ret = SWAP_AGAIN_CACHED;
+
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
@@ -1450,10 +1455,11 @@ static int page_not_mapped(struct page *page)
  * page, used in the pageout path.  Caller must hold the page lock.
  * Return values are:
  *
- * SWAP_SUCCESS	- we succeeded in removing all mappings
- * SWAP_AGAIN	- we missed a mapping, try again later
- * SWAP_FAIL	- the page is unswappable
- * SWAP_MLOCK	- page is mlocked.
+ * SWAP_SUCCESS	       - we succeeded in removing all mappings
+ * SWAP_SUCCESS_CACHED - Like SWAP_SUCCESS but a writable TLB entry may exist
+ * SWAP_AGAIN	       - we missed a mapping, try again later
+ * SWAP_FAIL	       - the page is unswappable
+ * SWAP_MLOCK	       - page is mlocked.
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
@@ -1481,7 +1487,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	ret = rmap_walk(page, &rwc);
 
 	if (ret != SWAP_MLOCK && !page_mapped(page))
-		ret = SWAP_SUCCESS;
+		ret = (ret == SWAP_AGAIN_CACHED) ? SWAP_SUCCESS_CACHED : SWAP_SUCCESS;
+
 	return ret;
 }
 
@@ -1577,15 +1584,24 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address = vma_address(page, vma);
+		int this_ret;
 
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		ret = rwc->rmap_one(page, vma, address, rwc->arg);
-		if (ret != SWAP_AGAIN)
+		this_ret = rwc->rmap_one(page, vma, address, rwc->arg);
+		if (this_ret != SWAP_AGAIN && this_ret != SWAP_AGAIN_CACHED) {
+			ret = this_ret;
 			break;
-		if (rwc->done && rwc->done(page))
+		}
+		if (rwc->done && rwc->done(page)) {
+			ret = this_ret;
 			break;
+		}
+
+		/* Remember if there is possible a writable TLB entry */
+		if (this_ret == SWAP_AGAIN_CACHED)
+			ret = SWAP_AGAIN_CACHED;
 	}
 	anon_vma_unlock_read(anon_vma);
 	return ret;
@@ -1626,15 +1642,24 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
+		int this_ret;
 
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		ret = rwc->rmap_one(page, vma, address, rwc->arg);
-		if (ret != SWAP_AGAIN)
+		this_ret = rwc->rmap_one(page, vma, address, rwc->arg);
+		if (this_ret != SWAP_AGAIN && this_ret != SWAP_AGAIN_CACHED) {
+			ret = this_ret;
 			goto done;
-		if (rwc->done && rwc->done(page))
+		}
+		if (rwc->done && rwc->done(page)) {
+			ret = this_ret;
 			goto done;
+		}
+
+		/* Remember if there is possible a writable TLB entry */
+		if (this_ret == SWAP_AGAIN_CACHED)
+			ret = SWAP_AGAIN_CACHED;
 	}
 
 done:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 12ec298087b6..0ad3f435afdd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -860,6 +860,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
 	unsigned long nr_immediate = 0;
+	bool tlb_flush_required = false;
 
 	cond_resched();
 
@@ -1032,6 +1033,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			case SWAP_MLOCK:
 				goto cull_mlocked;
+			case SWAP_SUCCESS_CACHED:
+				/* Must flush before free, fall through */
+				tlb_flush_required = true;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1176,7 +1180,8 @@ keep:
 	}
 
 	mem_cgroup_uncharge_list(&free_pages);
-	try_to_unmap_flush();
+	if (tlb_flush_required)
+		try_to_unmap_flush();
 	free_hot_cold_page_list(&free_pages, true);
 
 	list_splice(&ret_pages, page_list);
@@ -1213,6 +1218,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	ret = shrink_page_list(&clean_pages, zone, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS,
 			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+	try_to_unmap_flush();
 	list_splice(&clean_pages, page_list);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -2225,6 +2231,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 		scan_adjusted = true;
 	}
 	blk_finish_plug(&plug);
+	try_to_unmap_flush();
 	sc->nr_reclaimed += nr_reclaimed;
 
 	/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
