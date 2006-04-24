Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCZvZ9020310
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:35:57 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCb1Gv076702
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:37:01 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCZvn5007773
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:35:57 +0200
Date: Mon, 24 Apr 2006 14:36:01 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 6/8] Page host virtual assist: minor fault optimization.
Message-ID: <20060424123601.GG15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[patch 6/8] Page host virtual assist: minor fault optimization.

On of the challenges of hva is the cost for the state transitions.
If the cost gets too big the whole concept of page state information
is in question. Therefore it is very important to avoid the state
transitions for minor faults. Why change the page state to stable in
find_get_page and back in page_add_anon_rmap/page_add_file_rmap if the
discarded pages can be handled by the discard fault handler? If the page
is in page/swap cache just map it even if it is already discarded. The
first access to the page will cause a discard fault which needs to be
able to deal with this kind of situation anyway because of races in the
memory management.

To do this the special find_get_page_nohv variant introduced for volatile
swap cache is used which does not change the page state. The call to
find_get_page in filemap_nopage and filemap_getpage are replaced with
find_get_page_nohv. By the use of this function a new race condition is
created. If a minor fault races with the discard of a page the page may
not get mapped to the page table because the discard handler removed the
page from the cache which removes the page->mapping that is needed to
find the page table entry. A check for the PG_discarded bit is added to
do_swap_page and do_no_page. The page table lock for the pte takes care
of the synchronization.

After that there is only one state transition left in the minor fault.
page_add_anon_rmap/page_add_file_rmap try to get the page into volatile
state. If these two calls are removed we end up with almost all pages
in stable. The reason is that if a page is not uptodate yet, there is
an additional reference acquired from filemap_nopage. After the page
has been brought uptodate a page_hva_make_volatile needs to be done
with an offset of 2 (page cache reference + additional reference from
filemap_nopage).

That removes the state transitions on the minor fault path. A page that
has been mapped will eventually be unmapped again. On the unmap path
each page that has been removed from the page table is freed with a call
to page_cache_release. In general that causes an unnecessary page state
transition from volatile to volatile. Not what we want. To get rid of
these state transitions as well special variants of put_page_testzero/
page_cache_release are introduced that do not attempt to make the page
volatile. page_cache_release_nohv is then used in free_page_and_swap_cache
and release_pages. This makes the unmap of ptes state transitions free.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/mm.h      |   11 +++++--
 include/linux/pagemap.h |    5 +++
 include/linux/swap.h    |    2 -
 mm/filemap.c            |   73 +++++++++++++++++++++++++++++++++++++++++++-----
 mm/fremap.c             |    1 
 mm/memory.c             |    6 ++-
 mm/rmap.c               |    4 --
 mm/swap.c               |   26 ++++++++++++++++-
 mm/swap_state.c         |    4 +-
 9 files changed, 113 insertions(+), 19 deletions(-)

diff -urpN linux-2.6/include/linux/mm.h linux-2.6-patched/include/linux/mm.h
--- linux-2.6/include/linux/mm.h	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/include/linux/mm.h	2006-04-24 12:51:30.000000000 +0200
@@ -307,11 +307,15 @@ struct page {
  * put_page_testzero checks if the page can be made volatile if the page
  * still has users and the page host virtual assist is enabled.
  */
-static inline int put_page_testzero(struct page *page)
+static inline int put_page_testzero_nohv(struct page *page)
 {
-	int ret;
 	VM_BUG_ON(atomic_read(&page->_count) == 0);
-	ret = atomic_dec_and_test(&page->_count);
+	return atomic_dec_and_test(&page->_count);
+}
+
+static inline int put_page_testzero(struct page *page)
+{
+	int ret = put_page_testzero_nohv(page);
 	if (!ret)
 		page_hva_make_volatile(page, 1);
 	return ret;
@@ -354,6 +358,7 @@ static inline void init_page_count(struc
 }
 
 void put_page(struct page *page);
+void put_page_nohv(struct page *page);
 
 void split_page(struct page *page, unsigned int order);
 
diff -urpN linux-2.6/include/linux/pagemap.h linux-2.6-patched/include/linux/pagemap.h
--- linux-2.6/include/linux/pagemap.h	2006-04-24 12:51:28.000000000 +0200
+++ linux-2.6-patched/include/linux/pagemap.h	2006-04-24 12:51:30.000000000 +0200
@@ -49,6 +49,11 @@ static inline void mapping_set_gfp_mask(
 
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
+#if defined(CONFIG_PAGE_HVA)
+#define page_cache_release_nohv(page)	put_page_nohv(page)
+#else
+#define page_cache_release_nohv(page)	put_page(page)
+#endif
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
diff -urpN linux-2.6/include/linux/swap.h linux-2.6-patched/include/linux/swap.h
--- linux-2.6/include/linux/swap.h	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/include/linux/swap.h	2006-04-24 12:51:30.000000000 +0200
@@ -294,7 +294,7 @@ static inline void disable_swap_token(vo
 /* only sparc can not include linux/pagemap.h in this file
  * so leave page_cache_release and release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	page_cache_release_nohv(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), 0);
 
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2006-04-24 12:51:28.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2006-04-24 12:51:30.000000000 +0200
@@ -1338,7 +1338,14 @@ retry_all:
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
 
@@ -1372,7 +1379,7 @@ retry_find:
 				start = pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_get_page(mapping, pgoff);
+		page = find_get_page_nohv(mapping, pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1446,14 +1453,27 @@ page_not_uptodate:
 	/* Did somebody else get it up-to-date? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
+		/*
+		 * Because we held an additional reference
+		 * to the page while we read it in the page
+		 * could not be made volatile. Do it now.
+		 */
+		page_hva_make_volatile(page, 2);
 		goto success;
 	}
 
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			/*
+			 * Because we held an additional reference
+			 * to the page while we read it in the page
+			 * could not be made volatile. Do it now.
+			 */
+			page_hva_make_volatile(page, 2);
 			goto success;
+		}
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
 		goto retry_find;
@@ -1477,14 +1497,27 @@ page_not_uptodate:
 	/* Somebody else successfully read it in? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
+		/*
+		 * Because we held an additional reference
+		 * to the page while we read it in the page
+		 * could not be made volatile. Do it now.
+		 */
+		page_hva_make_volatile(page, 2);
 		goto success;
 	}
 	ClearPageError(page);
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			/*
+			 * Because we held an additional reference
+			 * to the page while we read it in the page
+			 * could not be made volatile. Do it now.
+			 */
+			page_hva_make_volatile(page, 2);
 			goto success;
+		}
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
 		goto retry_find;
@@ -1511,7 +1544,7 @@ static struct page * filemap_getpage(str
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_get_page_nohv(mapping, pgoff);
 	if (!page) {
 		if (nonblock)
 			return NULL;
@@ -1567,14 +1600,27 @@ page_not_uptodate:
 	/* Did somebody else get it up-to-date? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
+		/*
+		 * Because we held an additional reference
+		 * to the page while we read it in the page
+		 * could not be made volatile. Do it now.
+		 */
+		page_hva_make_volatile(page, 2);
 		goto success;
 	}
 
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			/*
+			 * Because we held an additional reference
+			 * to the page while we read it in the page
+			 * could not be made volatile. Do it now.
+			 */
+			page_hva_make_volatile(page, 2);
 			goto success;
+		}
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
 		goto retry_find;
@@ -1596,6 +1642,12 @@ page_not_uptodate:
 	/* Somebody else successfully read it in? */
 	if (PageUptodate(page)) {
 		unlock_page(page);
+		/*
+		 * Because we held an additional reference
+		 * to the page while we read it in the page
+		 * could not be made volatile. Do it now.
+		 */
+		page_hva_make_volatile(page, 2);
 		goto success;
 	}
 
@@ -1603,8 +1655,15 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			/*
+			 * Because we held an additional reference
+			 * to the page while we read it in the page
+			 * could not be made volatile. Do it now.
+			 */
+			page_hva_make_volatile(page, 2);
 			goto success;
+		}
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
 		goto retry_find;
diff -urpN linux-2.6/mm/fremap.c linux-2.6-patched/mm/fremap.c
--- linux-2.6/mm/fremap.c	2006-04-24 12:51:30.000000000 +0200
+++ linux-2.6-patched/mm/fremap.c	2006-04-24 12:51:30.000000000 +0200
@@ -83,6 +83,7 @@ int install_page(struct mm_struct *mm, s
 	page_hva_check_write(page, pte_val);
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
+	page_hva_make_volatile(page, 1);
 	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
 	err = 0;
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2006-04-24 12:51:30.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2006-04-24 12:51:30.000000000 +0200
@@ -1942,7 +1942,8 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else already faulted in this pte.
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	if (unlikely(!pte_same(*page_table, orig_pte) ||
+		     (page_hva_enabled() && PageDiscarded(page))))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2156,7 +2157,8 @@ retry:
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
+	if (pte_none(*page_table) &&
+	    !unlikely(page_hva_enabled() && PageDiscarded(new_page))) {
 		flush_icache_page(vma, new_page);
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2006-04-24 12:51:30.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2006-04-24 12:51:30.000000000 +0200
@@ -472,7 +472,6 @@ void page_add_anon_rmap(struct page *pag
 	if (atomic_inc_and_test(&page->_mapcount))
 		__page_set_anon_rmap(page, vma, address);
 	/* else checking page index and mapping is racy */
-	page_hva_make_volatile(page, 1);
 }
 
 /*
@@ -501,7 +500,6 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_page_state(nr_mapped);
-	page_hva_make_volatile(page, 1);
 }
 
 /**
@@ -610,7 +608,7 @@ static int try_to_unmap_one(struct page 
 		dec_mm_counter(mm, file_rss);
 
 	page_remove_rmap(page);
-	page_cache_release(page);
+	page_cache_release_nohv(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
diff -urpN linux-2.6/mm/swap.c linux-2.6-patched/mm/swap.c
--- linux-2.6/mm/swap.c	2006-04-24 12:51:21.000000000 +0200
+++ linux-2.6-patched/mm/swap.c	2006-04-24 12:51:30.000000000 +0200
@@ -55,6 +55,30 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
+#if defined(CONFIG_PAGE_HVA)
+
+static void put_compound_page_nohv(struct page *page)
+{
+	page = (struct page *)page_private(page);
+	if (put_page_testzero_nohv(page)) {
+		void (*dtor)(struct page *page);
+
+		dtor = (void (*)(struct page *))page[1].lru.next;
+		(*dtor)(page);
+	}
+}
+
+void put_page_nohv(struct page *page)
+{
+	if (unlikely(PageCompound(page)))
+		put_compound_page_nohv(page);
+	else if (put_page_testzero_nohv(page))
+		__page_cache_release(page);
+}
+EXPORT_SYMBOL(put_page_nohv);
+
+#endif
+
 /*
  * Writeback is about to end against a page which has been marked for immediate
  * reclaim.  If it still appears to be reclaimable, move it to the tail of the
@@ -254,7 +278,7 @@ void release_pages(struct page **pages, 
 			continue;
 		}
 
-		if (!put_page_testzero(page))
+		if (!put_page_testzero_nohv(page))
 			continue;
 
 		if (PageLRU(page)) {
diff -urpN linux-2.6/mm/swap_state.c linux-2.6-patched/mm/swap_state.c
--- linux-2.6/mm/swap_state.c	2006-04-24 12:51:21.000000000 +0200
+++ linux-2.6-patched/mm/swap_state.c	2006-04-24 12:51:30.000000000 +0200
@@ -271,7 +271,7 @@ static inline void free_swap_cache(struc
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	page_cache_release(page);
+	page_cache_release_nohv(page);
 }
 
 /*
@@ -305,7 +305,7 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
-	page = find_get_page(&swapper_space, entry.val);
+	page = find_get_page_nohv(&swapper_space, entry.val);
 
 	if (page)
 		INC_CACHE_INFO(find_success);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
