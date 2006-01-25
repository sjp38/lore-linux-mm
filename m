Date: Wed, 25 Jan 2006 10:11:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] hugepage allocator cleanup
Message-ID: <20060125091103.GA32653@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

This is a slight rework of the mechanism for allocating "fresh" hugepages.
Comments?

Thanks,
Nick

--
Insert "fresh" huge pages into the hugepage allocator by the same
means as they are freed back into it. This reduces code size and
allows enqueue_huge_page to be inlined into the hugepage free
fastpath.

Eliminate occurances of hugepages on the free list with non-zero
refcount. This can allow stricter refcount checks in future. Also
required for lockless pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -64,7 +64,7 @@ static struct page *dequeue_huge_page(st
 	return page;
 }
 
-static struct page *alloc_fresh_huge_page(void)
+static int alloc_fresh_huge_page(void)
 {
 	static int nid = 0;
 	struct page *page;
@@ -72,12 +72,15 @@ static struct page *alloc_fresh_huge_pag
 					HUGETLB_PAGE_ORDER);
 	nid = (nid + 1) % num_online_nodes();
 	if (page) {
+		page[1].mapping = (void *)free_huge_page;
 		spin_lock(&hugetlb_lock);
 		nr_huge_pages++;
 		nr_huge_pages_node[page_to_nid(page)]++;
 		spin_unlock(&hugetlb_lock);
+		put_page(page); /* free it into the hugepage allocator */
+		return 1;
 	}
-	return page;
+	return 0;
 }
 
 void free_huge_page(struct page *page)
@@ -85,7 +88,6 @@ void free_huge_page(struct page *page)
 	BUG_ON(page_count(page));
 
 	INIT_LIST_HEAD(&page->lru);
-	page[1].mapping = NULL;
 
 	spin_lock(&hugetlb_lock);
 	enqueue_huge_page(page);
@@ -105,7 +107,6 @@ struct page *alloc_huge_page(struct vm_a
 	}
 	spin_unlock(&hugetlb_lock);
 	set_page_count(page, 1);
-	page[1].mapping = (void *)free_huge_page;
 	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); ++i)
 		clear_highpage(&page[i]);
 	return page;
@@ -114,7 +115,6 @@ struct page *alloc_huge_page(struct vm_a
 static int __init hugetlb_init(void)
 {
 	unsigned long i;
-	struct page *page;
 
 	if (HPAGE_SHIFT == 0)
 		return 0;
@@ -123,12 +123,8 @@ static int __init hugetlb_init(void)
 		INIT_LIST_HEAD(&hugepage_freelists[i]);
 
 	for (i = 0; i < max_huge_pages; ++i) {
-		page = alloc_fresh_huge_page();
-		if (!page)
+		if (!alloc_fresh_huge_page())
 			break;
-		spin_lock(&hugetlb_lock);
-		enqueue_huge_page(page);
-		spin_unlock(&hugetlb_lock);
 	}
 	max_huge_pages = free_huge_pages = nr_huge_pages = i;
 	printk("Total HugeTLB memory allocated, %ld\n", free_huge_pages);
@@ -154,8 +150,8 @@ static void update_and_free_page(struct 
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
 				1 << PG_private | 1<< PG_writeback);
-		set_page_count(&page[i], 0);
 	}
+	page[1].mapping = NULL;
 	set_page_count(page, 1);
 	__free_pages(page, HUGETLB_PAGE_ORDER);
 }
@@ -188,12 +184,8 @@ static inline void try_to_free_low(unsig
 static unsigned long set_max_huge_pages(unsigned long count)
 {
 	while (count > nr_huge_pages) {
-		struct page *page = alloc_fresh_huge_page();
-		if (!page)
+		if (!alloc_fresh_huge_page())
 			return nr_huge_pages;
-		spin_lock(&hugetlb_lock);
-		enqueue_huge_page(page);
-		spin_unlock(&hugetlb_lock);
 	}
 	if (count >= nr_huge_pages)
 		return nr_huge_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
