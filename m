Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id DC0986B0027
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:23:39 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 13/16] thp: handle file pages in split_huge_page()
Date: Mon, 28 Jan 2013 11:24:25 +0200
Message-Id: <1359365068-10147-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The base scheme is the same as for anonymous pages, but we walk by
mapping->i_mmap rather then anon_vma->rb_root.

__split_huge_page_refcount() has been tunned a bit: we need to transfer
PG_swapbacked to tail pages.

Splitting mapped pages haven't tested at all, since we cannot mmap()
file-backed huge pages yet.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 53 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c63a21d..008b2c9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1613,7 +1613,8 @@ static void __split_huge_page_refcount(struct page *page)
 				     ((1L << PG_referenced) |
 				      (1L << PG_swapbacked) |
 				      (1L << PG_mlocked) |
-				      (1L << PG_uptodate)));
+				      (1L << PG_uptodate) |
+				      (1L << PG_swapbacked)));
 		page_tail->flags |= (1L << PG_dirty);
 
 		/* clear PageTail before overwriting first_page */
@@ -1641,10 +1642,8 @@ static void __split_huge_page_refcount(struct page *page)
 		page_tail->index = page->index + i;
 		page_xchg_last_nid(page_tail, page_last_nid(page));
 
-		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
 		BUG_ON(!PageDirty(page_tail));
-		BUG_ON(!PageSwapBacked(page_tail));
 
 		lru_add_page_tail(page, page_tail, lruvec);
 	}
@@ -1752,7 +1751,7 @@ static int __split_huge_page_map(struct page *page,
 }
 
 /* must be called with anon_vma->root->rwsem held */
-static void __split_huge_page(struct page *page,
+static void __split_anon_huge_page(struct page *page,
 			      struct anon_vma *anon_vma)
 {
 	int mapcount, mapcount2;
@@ -1799,14 +1798,11 @@ static void __split_huge_page(struct page *page,
 	BUG_ON(mapcount != mapcount2);
 }
 
-int split_huge_page(struct page *page)
+static int split_anon_huge_page(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	int ret = 1;
 
-	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
-	BUG_ON(!PageAnon(page));
-
 	/*
 	 * The caller does not necessarily hold an mmap_sem that would prevent
 	 * the anon_vma disappearing so we first we take a reference to it
@@ -1824,7 +1820,7 @@ int split_huge_page(struct page *page)
 		goto out_unlock;
 
 	BUG_ON(!PageSwapBacked(page));
-	__split_huge_page(page, anon_vma);
+	__split_anon_huge_page(page, anon_vma);
 	count_vm_event(THP_SPLIT);
 
 	BUG_ON(PageCompound(page));
@@ -1835,6 +1831,54 @@ out:
 	return ret;
 }
 
+static int split_file_huge_page(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	int mapcount, mapcount2;
+
+	BUG_ON(!PageHead(page));
+	BUG_ON(PageTail(page));
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	mapcount = 0;
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long addr = vma_address(page, vma);
+		mapcount += __split_huge_page_splitting(page, vma, addr);
+	}
+
+	if (mapcount != page_mapcount(page))
+		printk(KERN_ERR "mapcount %d page_mapcount %d\n",
+		       mapcount, page_mapcount(page));
+	BUG_ON(mapcount != page_mapcount(page));
+
+	__split_huge_page_refcount(page);
+
+	mapcount2 = 0;
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long addr = vma_address(page, vma);
+		mapcount2 += __split_huge_page_map(page, vma, addr);
+	}
+
+	if (mapcount != mapcount2)
+		printk(KERN_ERR "mapcount %d mapcount2 %d page_mapcount %d\n",
+		       mapcount, mapcount2, page_mapcount(page));
+	BUG_ON(mapcount != mapcount2);
+	mutex_unlock(&mapping->i_mmap_mutex);
+	return 0;
+}
+
+int split_huge_page(struct page *page)
+{
+	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
+
+	if (PageAnon(page))
+		return split_anon_huge_page(page);
+	else
+		return split_file_huge_page(page);
+}
+
 #define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
