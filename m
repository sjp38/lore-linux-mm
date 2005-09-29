Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.12.10/8.12.10) with ESMTP id j8TDGcO0146646
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 13:16:38 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TDGc9P176556
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:16:38 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j8TDGcQ1008539
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:16:38 +0200
Date: Thu, 29 Sep 2005 15:16:49 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 4/6] Page host virtual assist: minor fault optimization.
Message-ID: <20050929131649.GE5700@skybase.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Page host virtual assist: minor fault optimization.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>

On of the big problems with hva is the cost for the state transitions.
If the cost gets too big the whole concept of page state information is
in question. Therefore it is very important to avoid the state transtitions
for minor faults. Why change the page state to stable in find_get_page and
back in page_add_anon_rmap/page_add_file_rmap if the discarded pages can
be handled by the discard fault handler? If the page is in page/swap cache
just map it even if it is already discarded. The first access to the page
will cause a discard fault which needs to be able to deal with this kind
of situation anyway because of races in the memory management.

To do this we need a special variant of find_get_page, with the name
find_get_page_nohv. That function is in fact an exact copy of the original
find_get_page function which didn't care about page states as well.
This new function is then used in filemap_nopage and filemap_getpage.
After that there is only one state transition left in the minor fault.
page_add_anon_rmap/page_add_file_rmap try to get the page into volatile
state. If these two calls are removed we end up with almost all pages
in stable. The reason is that if a page is not uptodate yet, there is
an additional reference acquired from filemap_nopage. After the page
has been brought uptodate a page_hva_make_volatile needs to be done
with an offset of 2 (page cache reference + additional reference from
filemap_nopage).

That removes the state transitions on the minor fault path. A page that
has been mapped will eventually be unmapped again. On the unmap() path
the page is referenced that has been removed from the page table is
freed with a call to page_cache_release. In general that causes an
unnecessary page state transition from volatile to volatile. Not what
we want. To get rid of these state transitions as well special variants
of put_page_testzero/page_cache_release are introduced that do not
try to make the page volatile. page_cache_release_nohv is then used
in free_page_and_swap_cache and release_pages. This makes the unmap
of ptes state transitions free.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

diffstat:
 include/linux/mm.h      |   28 ++++++++++++++++++-------
 include/linux/pagemap.h |    1 
 include/linux/swap.h    |    2 -
 mm/filemap.c            |   53 ++++++++++++++++++++++++++++++++++++++++++------
 mm/fremap.c             |    1 
 mm/rmap.c               |    2 -
 mm/swap.c               |    2 -
 mm/swap_state.c         |    2 -
 8 files changed, 72 insertions(+), 19 deletions(-)

diff -urpN linux-2.5/include/linux/mm.h linux-2.5-cmm2/include/linux/mm.h
--- linux-2.5/include/linux/mm.h	2005-09-29 14:49:52.000000000 +0200
+++ linux-2.5-cmm2/include/linux/mm.h	2005-09-29 14:49:54.000000000 +0200
@@ -295,17 +295,22 @@ struct page {
  *
  * put_page_testzero checks if the page can be made volatile if the page
  * still has users and the page host virtual assist is enabled.
+ * put_page_testzero_nohv does not check the hva page state.
  */
+#define put_page_testzero_nohv(p)			\
+	({						\
+		BUG_ON(page_count(p) == 0);		\
+		atomic_add_negative(-1, &(p)->_count);	\
+	})
 
-#define put_page_testzero(p)					\
-	({							\
-		int ret;					\
-		BUG_ON(page_count(p) == 0);			\
-		ret = atomic_add_negative(-1, &(p)->_count);	\
-		if (!ret)					\
-			page_hva_make_volatile(p, 1);		\
-		ret;						\
+#define put_page_testzero(p)				\
+	({						\
+		int ret = put_page_testzero_nohv(p);    \
+		if (!ret)				\
+			page_hva_make_volatile(p, 1);	\
+		ret;					\
 	})
+
 /*
  * Grab a ref, return true if the page previously had a logical refcount of
  * zero.  ie: returns true if we just grabbed an already-deemed-to-be-free page
@@ -334,6 +339,7 @@ static inline void get_page(struct page 
 }
 
 void put_page(struct page *page);
+void put_page_nohv(struct page *page);
 
 #else		/* CONFIG_HUGETLB_PAGE */
 
@@ -350,6 +356,12 @@ static inline void put_page(struct page 
 		__page_cache_release(page);
 }
 
+static inline void put_page_nohv(struct page *page)
+{
+	if (!PageReserved(page) && put_page_testzero_nohv(page))
+		__page_cache_release(page);
+}
+
 #endif		/* CONFIG_HUGETLB_PAGE */
 
 /*
diff -urpN linux-2.5/include/linux/pagemap.h linux-2.5-cmm2/include/linux/pagemap.h
--- linux-2.5/include/linux/pagemap.h	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/include/linux/pagemap.h	2005-09-29 14:49:54.000000000 +0200
@@ -48,6 +48,7 @@ static inline void mapping_set_gfp_mask(
 
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
+#define page_cache_release_nohv(page)	put_page_nohv(page)
 void release_pages(struct page **pages, int nr, int cold);
 
 static inline struct page *page_cache_alloc(struct address_space *x)
diff -urpN linux-2.5/include/linux/swap.h linux-2.5-cmm2/include/linux/swap.h
--- linux-2.5/include/linux/swap.h	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/include/linux/swap.h	2005-09-29 14:49:54.000000000 +0200
@@ -257,7 +257,7 @@ static inline void put_swap_token(struct
 /* only sparc can not include linux/pagemap.h in this file
  * so leave page_cache_release and release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	page_cache_release_nohv(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
 
diff -urpN linux-2.5/mm/filemap.c linux-2.5-cmm2/mm/filemap.c
--- linux-2.5/mm/filemap.c	2005-09-29 14:49:52.000000000 +0200
+++ linux-2.5-cmm2/mm/filemap.c	2005-09-29 14:49:54.000000000 +0200
@@ -513,7 +513,20 @@ EXPORT_SYMBOL(__lock_page);
  * a rather lightweight function, finding and getting a reference to a
  * hashed page atomically.
  */
-struct page * find_get_page(struct address_space *mapping, unsigned long offset)
+static struct page *find_get_page_nohv(struct address_space *mapping,
+				       unsigned long offset)
+{
+	struct page *page;
+
+	read_lock_irq(&mapping->tree_lock);
+	page = radix_tree_lookup(&mapping->page_tree, offset);
+	if (page)
+		page_cache_get(page);
+	read_unlock_irq(&mapping->tree_lock);
+	return page;
+}
+
+struct page *find_get_page(struct address_space *mapping, unsigned long offset)
 {
 	struct page *page;
 
@@ -1282,7 +1295,14 @@ retry_all:
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	/*
+	 * The find_get_page_nohv version of find_get_page will refrain from
+	 * moving the page to stable if page is found in page cache. This is
+	 * an optimization for common case where most of the page cache pages
+	 * will not be in discarded state. In case the page indeed is
+	 * discarded, the access will result in a discard fault.
+	 */
+	page = find_get_page_nohv(mapping, pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
@@ -1316,7 +1336,7 @@ retry_find:
 				start = pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_get_page(mapping, pgoff);
+		page = find_get_page_nohv(mapping, pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1390,13 +1410,21 @@ page_not_uptodate:
 	/* Did somebody else get it up-to-date? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
+		/*
+		 * Because we held a reference to the page while somebody
+		 * else got it up-to-date the page could not be made volatile.
+		 * Do it now.
+		 */
+		page_hva_make_volatile(page, 2);
 		goto success;
 	}
 
 	if (!mapping->a_ops->readpage(file, page)) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			page_hva_make_volatile(page, 2);
 			goto success;
+		}
 	}
 
 	/*
@@ -1417,13 +1445,26 @@ page_not_uptodate:
 	/* Somebody else successfully read it in? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
+		/*
+		 * Because we held a reference to the page while somebody
+		 * else read it in the page could not be made volatile.
+		 * Do it now.
+		 */
+		page_hva_make_volatile(page, 2);
 		goto success;
 	}
 	ClearPageError(page);
 	if (!mapping->a_ops->readpage(file, page)) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			/*
+			 * Because we held an additional reference to the page
+			 * while we read it in the page could not be made
+			 * volatile. Do it now.
+			 */
+			page_hva_make_volatile(page, 2);
 			goto success;
+		}
 	}
 
 	/*
@@ -1447,7 +1488,7 @@ static struct page * filemap_getpage(str
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_get_page_nohv(mapping, pgoff);
 	if (!page) {
 		if (nonblock)
 			return NULL;
diff -urpN linux-2.5/mm/fremap.c linux-2.5-cmm2/mm/fremap.c
--- linux-2.5/mm/fremap.c	2005-09-29 14:49:53.000000000 +0200
+++ linux-2.5-cmm2/mm/fremap.c	2005-09-29 14:49:54.000000000 +0200
@@ -98,6 +98,7 @@ int install_page(struct mm_struct *mm, s
 	page_hva_check_write(page, pte_val);
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
+	page_hva_make_volatile(page, 1);
 	pte_val = *pte;
 	pte_unmap(pte);
 	update_mmu_cache(vma, addr, pte_val);
diff -urpN linux-2.5/mm/rmap.c linux-2.5-cmm2/mm/rmap.c
--- linux-2.5/mm/rmap.c	2005-09-29 14:49:54.000000000 +0200
+++ linux-2.5-cmm2/mm/rmap.c	2005-09-29 14:49:54.000000000 +0200
@@ -461,7 +461,6 @@ void page_add_anon_rmap(struct page *pag
 		inc_page_state(nr_mapped);
 	}
 	/* else checking page index and mapping is racy */
-	page_hva_make_volatile(page, 1);
 }
 
 /**
@@ -478,7 +477,6 @@ void page_add_file_rmap(struct page *pag
 
 	if (atomic_inc_and_test(&page->_mapcount))
 		inc_page_state(nr_mapped);
-	page_hva_make_volatile(page, 1);
 }
 
 #if defined(CONFIG_PAGE_HVA)
diff -urpN linux-2.5/mm/swap.c linux-2.5-cmm2/mm/swap.c
--- linux-2.5/mm/swap.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/swap.c	2005-09-29 14:49:54.000000000 +0200
@@ -215,7 +215,7 @@ void release_pages(struct page **pages, 
 		struct page *page = pages[i];
 		struct zone *pagezone;
 
-		if (PageReserved(page) || !put_page_testzero(page))
+		if (PageReserved(page) || !put_page_testzero_nohv(page))
 			continue;
 
 		pagezone = page_zone(page);
diff -urpN linux-2.5/mm/swap_state.c linux-2.5-cmm2/mm/swap_state.c
--- linux-2.5/mm/swap_state.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/swap_state.c	2005-09-29 14:49:54.000000000 +0200
@@ -269,7 +269,7 @@ static inline void free_swap_cache(struc
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	page_cache_release(page);
+	page_cache_release_nohv(page);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
