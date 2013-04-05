Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 49F346B00B6
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:30 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 20/34] thp: handle file pages in split_huge_page()
Date: Fri,  5 Apr 2013 14:59:44 +0300
Message-Id: <1365163198-29726-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The base scheme is the same as for anonymous pages, but we walk by
mapping->i_mmap rather then anon_vma->rb_root.

__split_huge_page_refcount() has been tunned a bit: we need to transfer
PG_swapbacked to tail pages.

Splitting mapped pages haven't tested at all, since we cannot mmap()
file-backed huge pages yet.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   71 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 59 insertions(+), 12 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 46a44ac..ac0dc80 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1637,24 +1637,25 @@ static void __split_huge_page_refcount(struct page *page)
 		*/
 		page_tail->_mapcount = page->_mapcount;
 
-		BUG_ON(page_tail->mapping);
 		page_tail->mapping = page->mapping;
-
 		page_tail->index = page->index + i;
 		page_nid_xchg_last(page_tail, page_nid_last(page));
 
-		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
 		BUG_ON(!PageDirty(page_tail));
-		BUG_ON(!PageSwapBacked(page_tail));
 
 		lru_add_page_tail(page, page_tail, lruvec);
 	}
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
-	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
-	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	if (PageAnon(page)) {
+		__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
+		__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+	} else {
+		__mod_zone_page_state(zone, NR_FILE_TRANSPARENT_HUGEPAGES, -1);
+		__mod_zone_page_state(zone, NR_FILE_PAGES, HPAGE_PMD_NR);
+	}
 
 	ClearPageCompound(page);
 	compound_unlock(page);
@@ -1754,7 +1755,7 @@ static int __split_huge_page_map(struct page *page,
 }
 
 /* must be called with anon_vma->root->rwsem held */
-static void __split_huge_page(struct page *page,
+static void __split_anon_huge_page(struct page *page,
 			      struct anon_vma *anon_vma)
 {
 	int mapcount, mapcount2;
@@ -1801,14 +1802,11 @@ static void __split_huge_page(struct page *page,
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
@@ -1826,7 +1824,7 @@ int split_huge_page(struct page *page)
 		goto out_unlock;
 
 	BUG_ON(!PageSwapBacked(page));
-	__split_huge_page(page, anon_vma);
+	__split_anon_huge_page(page, anon_vma);
 	count_vm_event(THP_SPLIT);
 
 	BUG_ON(PageCompound(page));
@@ -1837,6 +1835,55 @@ out:
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
+	count_vm_event(THP_SPLIT);
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
