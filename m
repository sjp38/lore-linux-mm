Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3C96B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:40:18 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so52574258pab.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:40:17 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id jb1si17153215pbb.255.2015.11.11.20.32.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 20:32:47 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 16/17] mm: support MADV_FREE on swapless system
Date: Thu, 12 Nov 2015 13:33:12 +0900
Message-Id: <1447302793-5376-17-git-send-email-minchan@kernel.org>
In-Reply-To: <1447302793-5376-1-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

Historically, we have disabled reclaiming of anonymous pages
completely with swapoff or non-swap configurable system.
It did make sense but problem for lazy free pages is that
we couldn't get a chance to discard MADV_FREE hinted pages
in reclaim path in those systems.

That's why current MADV_FREE implementation drops pages instantly
like MADV_DONTNNED in swapless system so that users on those
systems couldn't get the benefit of MADV_FREE.

Now we have lazyfree LRU list to keep MADV_FREEed pages without
relying on anonymous LRU so that we could scan MADV_FREE pages
on swapless system without relying on anonymous LRU list.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c    |  7 +------
 mm/swap_state.c |  6 ------
 mm/vmscan.c     | 37 +++++++++++++++++++++++++++----------
 3 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 7c88c6cfe300..3a4c3f7efe20 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -547,12 +547,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_WILLNEED:
 		return madvise_willneed(vma, prev, start, end);
 	case MADV_FREE:
-		/*
-		 * XXX: In this implementation, MADV_FREE works like
-		 * MADV_DONTNEED on swapless system or full swap.
-		 */
-		if (get_nr_swap_pages() > 0)
-			return madvise_free(vma, prev, start, end);
+		return madvise_free(vma, prev, start, end);
 		/* passthrough */
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 10f63eded7b7..49c683b02ee4 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -170,12 +170,6 @@ int add_to_swap(struct page *page, struct list_head *list)
 	if (!entry.val)
 		return 0;
 
-	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page_to_list(page, list))) {
-			swapcache_free(entry);
-			return 0;
-		}
-
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
 	 * completely exhaust the page allocator. __GFP_NOMEMALLOC
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3a7d57cbceb3..cd65db9d3004 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -611,13 +611,18 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 			    bool reclaimed)
 {
 	unsigned long flags;
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = NULL;
+	int expected = mapping ? 2 : 1;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
+	VM_BUG_ON_PAGE(mapping == NULL && !PageLazyFree(page), page);
+
+	if (mapping) {
+		memcg = mem_cgroup_begin_page_stat(page);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
+	}
 
-	memcg = mem_cgroup_begin_page_stat(page);
-	spin_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -643,14 +648,18 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
-	if (!page_freeze_refs(page, 2))
+	if (!page_freeze_refs(page, expected))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
-		page_unfreeze_refs(page, 2);
+		page_unfreeze_refs(page, expected);
 		goto cannot_free;
 	}
 
+	/* No more work to do with backing store */
+	if (!mapping)
+		return 1;
+
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		mem_cgroup_swapout(page, swap);
@@ -687,8 +696,10 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	return 1;
 
 cannot_free:
-	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	mem_cgroup_end_page_stat(memcg);
+	if (mapping) {
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		mem_cgroup_end_page_stat(memcg);
+	}
 	return 0;
 }
 
@@ -1051,7 +1062,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageAnon(page) && !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			if (!add_to_swap(page, page_list))
+			if (unlikely(PageTransHuge(page)) &&
+				unlikely(split_huge_page_to_list(page,
+						page_list)))
+				goto activate_locked;
+			if (total_swap_pages &&
+					!add_to_swap(page, page_list))
 				goto activate_locked;
 			if (ttu_flags & TTU_LZFREE) {
 				freeable = true;
@@ -1073,7 +1089,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page) && (mapping || freeable)) {
 			switch (try_to_unmap(page, freeable ?
 				(ttu_flags | TTU_BATCH_FLUSH) :
 				((ttu_flags & ~TTU_LZFREE) |
@@ -1190,7 +1206,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page, true))
+		if ((!mapping && !freeable) ||
+			!__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
 		/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
