Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A90AE6B0354
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:47:06 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so6955561pab.8
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:47:06 -0700 (PDT)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id kg8si10246177pad.9.2013.10.21.14.47.05
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:47:05 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so6988061pad.30
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:47:04 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:47:00 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 05/13] mm, thp, tmpfs: split huge page when moving from
 page cache to swap
Message-ID: <20131021214700.GF29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

in shmem_writepage, we have to split the huge page when moving pages
from page cache to swap because we don't support huge page in swap
yet.

On the second thought, we probably should split the huge page at
the upper level, otherwise, we are running into the pain to refactor
writepage function for each file system.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 include/linux/huge_mm.h |  2 ++
 mm/shmem.c              | 79 ++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 61 insertions(+), 20 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 65f90db..58b0208 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -64,6 +64,7 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
 #define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
+#define HPAGE_NR_PAGES HPAGE_PMD_NR
 
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
@@ -207,6 +208,7 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 #define THP_READ_ALLOC_FAILED	({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
+#define HPAGE_NR_PAGES 1
 
 #define transparent_hugepage_enabled(__vma) 0
 #define transparent_hugepage_defrag(__vma) 0
diff --git a/mm/shmem.c b/mm/shmem.c
index 5bde8d0..b80ace7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -862,14 +862,16 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	struct shmem_inode_info *info;
 	struct address_space *mapping;
 	struct inode *inode;
-	swp_entry_t swap;
+	swp_entry_t swap[HPAGE_NR_PAGES];
 	pgoff_t index;
+	int nr = 1;
+	int i;
 
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
-	index = page->index;
 	inode = mapping->host;
 	info = SHMEM_I(inode);
+
 	if (info->flags & VM_LOCKED)
 		goto redirty;
 	if (!total_swap_pages)
@@ -887,6 +889,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		goto redirty;
 	}
 
+	index = page->index;
 	/*
 	 * This is somewhat ridiculous, but without plumbing a SWAP_MAP_FALLOC
 	 * value into swapfile.c, the only way we can correctly account for a
@@ -906,21 +909,35 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 			if (shmem_falloc &&
 			    index >= shmem_falloc->start &&
 			    index < shmem_falloc->next)
-				shmem_falloc->nr_unswapped++;
+				shmem_falloc->nr_unswapped +=
+					hpagecache_nr_pages(page);
 			else
 				shmem_falloc = NULL;
 			spin_unlock(&inode->i_lock);
 			if (shmem_falloc)
 				goto redirty;
 		}
-		clear_highpage(page);
+		clear_pagecache_page(page);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
 
-	swap = get_swap_page();
-	if (!swap.val)
-		goto redirty;
+	/* We can only have nr correct after huge page splitted,
+	 * otherwise, it will fail the redirty logic
+	 */
+	nr = hpagecache_nr_pages(page);
+	/* We have to break the huge page at this point,
+	 * since we have no idea how to swap a huge page.
+	 */
+	if (PageTransHugeCache(page))
+		split_huge_page(compound_trans_head(page));
+
+	/* Pre-allocate all the swap pages */
+	for (i = 0; i < nr; i++) {
+		swap[i] = get_swap_page();
+		if (!swap[i].val)
+			goto undo_alloc_swap;
+	}
 
 	/*
 	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
@@ -934,25 +951,47 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	if (list_empty(&info->swaplist))
 		list_add_tail(&info->swaplist, &shmem_swaplist);
 
-	if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
-		swap_shmem_alloc(swap);
-		shmem_delete_from_page_cache(page, swp_to_radix_entry(swap));
+	for (i = 0; i < nr; i++) {
+		if (add_to_swap_cache(page + i, swap[i], GFP_ATOMIC))
+			goto undo_add_to_swap_cache;
+	}
 
-		spin_lock(&info->lock);
-		info->swapped++;
-		shmem_recalc_inode(inode);
-		spin_unlock(&info->lock);
+	/* We make sure everything is correct before moving further */
+	for (i = 0; i < nr; i++) {
+		swap_shmem_alloc(swap[i]);
+		shmem_delete_from_page_cache(page + i,
+			swp_to_radix_entry(swap[i]));
+	}
 
-		mutex_unlock(&shmem_swaplist_mutex);
-		BUG_ON(page_mapped(page));
-		swap_writepage(page, wbc);
-		return 0;
+	spin_lock(&info->lock);
+	info->swapped += nr;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	mutex_unlock(&shmem_swaplist_mutex);
+
+	for (i = 0; i < nr; i++) {
+		BUG_ON(page_mapped(page + i));
+		swap_writepage(page + i, wbc);
 	}
 
+	return 0;
+
+undo_add_to_swap_cache:
+	while (i) {
+		i--;
+		__delete_from_swap_cache(page + i);
+	}
 	mutex_unlock(&shmem_swaplist_mutex);
-	swapcache_free(swap, NULL);
+	i = nr;
+undo_alloc_swap:
+	while (i) {
+		i--;
+		swapcache_free(swap[i], NULL);
+	}
 redirty:
-	set_page_dirty(page);
+	for (i = 0; i < nr; i++)
+		set_page_dirty(page + i);
 	if (wbc->for_reclaim)
 		return AOP_WRITEPAGE_ACTIVATE;	/* Return with page locked */
 	unlock_page(page);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
