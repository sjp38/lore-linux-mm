Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 19BA16B003D
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:13:11 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so8050994pde.38
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:10 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so8038722pbc.9
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:08 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:13:04 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 07/12] mm, thp, tmpfs: handle huge page in shmem_undo_range
 for truncate
Message-ID: <20131015001304.GH3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

When comes to truncate file, add support to handle huge page in the
truncate range.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 86 insertions(+), 11 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 0a423a9..90f2e0e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -559,6 +559,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
+	/* Whether we have to do partial truncate */
 	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
 	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
 	struct pagevec pvec;
@@ -570,12 +571,16 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	if (lend == -1)
 		end = -1;	/* unsigned, so actually very big */
 
+	i_split_down_read(inode);
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
+		bool thp = false;
+
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 							pvec.pages, indices);
+
 		if (!pvec.nr)
 			break;
 		mem_cgroup_uncharge_start();
@@ -586,6 +591,25 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			if (index >= end)
 				break;
 
+			thp = PageTransHugeCache(page);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+			if (thp) {
+				/* the range starts in middle of huge page */
+			       if (index < start) {
+					partial_start = true;
+					start = index + HPAGE_CACHE_NR;
+					break;
+			       }
+
+			       /* the range ends on huge page */
+			       if (index == (end & ~HPAGE_CACHE_INDEX_MASK)) {
+					partial_end = true;
+					end = index;
+					break;
+			       }
+			}
+#endif
+
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
 					continue;
@@ -603,26 +627,52 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				}
 			}
 			unlock_page(page);
+			if (thp)
+				break;
 		}
 		shmem_deswap_pagevec(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
-		index++;
+		if (thp)
+			index += HPAGE_CACHE_NR;
+		else
+			index++;
 	}
 
 	if (partial_start) {
 		struct page *page = NULL;
 		gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+		int flags = 0;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+		flags |= AOP_FLAG_TRANSHUGE;
+#endif
 
-		shmem_getpage(inode, start - 1, &page, SGP_READ, gfp, 0, NULL);
+		shmem_getpage(inode, start - 1, &page, SGP_READ, gfp,
+				flags, NULL);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
-			if (start > end) {
-				top = partial_end;
-				partial_end = 0;
+			pgoff_t index_mask;
+			loff_t page_cache_mask;
+			unsigned pstart, pend;
+
+			index_mask = 0UL;
+			page_cache_mask = PAGE_CACHE_MASK;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+			if (PageTransHugeCache(page)) {
+				index_mask = HPAGE_CACHE_INDEX_MASK;
+				page_cache_mask = HPAGE_PMD_MASK;
 			}
-			zero_user_segment(page, partial_start, top);
+#endif
+
+			pstart = lstart & ~page_cache_mask;
+			if ((end & ~index_mask) == page->index) {
+				pend = (lend + 1) & ~page_cache_mask;
+				end = page->index;
+				partial_end = false; /* handled here */
+			} else
+				pend = PAGE_CACHE_SIZE << compound_order(page);
+
+			zero_pagecache_segment(page, pstart, pend);
 			set_page_dirty(page);
 			unlock_page(page);
 			page_cache_release(page);
@@ -631,20 +681,37 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	if (partial_end) {
 		struct page *page = NULL;
 		gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+		int flags = 0;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+		flags |= AOP_FLAG_TRANSHUGE;
+#endif
 
-		shmem_getpage(inode, end, &page, SGP_READ, gfp, 0, NULL);
+		shmem_getpage(inode, end, &page, SGP_READ, gfp,
+				flags, NULL);
 		if (page) {
-			zero_user_segment(page, 0, partial_end);
+			loff_t page_cache_mask;
+			unsigned pend;
+
+			page_cache_mask = PAGE_CACHE_MASK;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+			if (PageTransHugeCache(page))
+				page_cache_mask = HPAGE_PMD_MASK;
+#endif
+			pend = (lend + 1) & ~page_cache_mask;
+			end = page->index;
+			zero_pagecache_segment(page, 0, pend);
 			set_page_dirty(page);
 			unlock_page(page);
 			page_cache_release(page);
 		}
 	}
 	if (start >= end)
-		return;
+		goto out;
 
 	index = start;
 	for ( ; ; ) {
+		bool thp = false;
+
 		cond_resched();
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
@@ -676,6 +743,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				continue;
 			}
 
+			thp = PageTransHugeCache(page);
 			lock_page(page);
 			if (!unfalloc || !PageUptodate(page)) {
 				if (page->mapping == mapping) {
@@ -684,17 +752,24 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				}
 			}
 			unlock_page(page);
+			if (thp)
+				break;
 		}
 		shmem_deswap_pagevec(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
-		index++;
+		if (thp)
+			index += HPAGE_CACHE_NR;
+		else
+			index++;
 	}
 
 	spin_lock(&info->lock);
 	info->swapped -= nr_swaps_freed;
 	shmem_recalc_inode(inode);
 	spin_unlock(&info->lock);
+out:
+	i_split_up_read(inode);
 }
 
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
