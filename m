Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11231
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:07:16 -0500
Date: Sat, 19 Dec 1998 17:04:26 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: PG_clean for shared mapping smart syncing
Message-ID: <Pine.LNX.3.96.981219165802.208A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

I' ve done a preliminary/experimental/unstable patch that should allow us
to account when a shared page in a shared mmap has to be synced. Here the
preliminary patch:

Index: mm//filemap.c
===================================================================
RCS file: /var/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.1.1.2.14
diff -u -r1.1.1.1.2.14 filemap.c
--- filemap.c	1998/12/17 16:34:07	1.1.1.1.2.14
+++ linux/mm/filemap.c	1998/12/19 15:37:30
@@ -1210,8 +1210,9 @@
 	unsigned long address, unsigned int flags)
 {
 	pte_t pte = *ptep;
-	unsigned long page;
+	unsigned long page = pte_page(pte);
 	int error;
+	struct page * map = mem_map + MAP_NR(page);
 
 	if (!(flags & MS_INVALIDATE)) {
 		if (!pte_present(pte))
@@ -1220,10 +1221,9 @@
 			return 0;
 		flush_page_to_ram(pte_page(pte));
 		flush_cache_page(vma, address);
-		set_pte(ptep, pte_mkclean(pte));
+		set_pte(ptep, pte_wrprotect(pte_mkclean(pte)));
 		flush_tlb_page(vma, address);
-		page = pte_page(pte);
-		atomic_inc(&mem_map[MAP_NR(page)].count);
+		atomic_inc(&map->count);
 	} else {
 		if (pte_none(pte))
 			return 0;
@@ -1234,14 +1234,15 @@
 			swap_free(pte_val(pte));
 			return 0;
 		}
-		page = pte_page(pte);
 		if (!pte_dirty(pte) || flags == MS_INVALIDATE) {
-			free_page(page);
+			__free_page(map);
 			return 0;
 		}
 	}
-	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page);
-	free_page(page);
+	if (!PageTestAndSetClean(map))
+		error = filemap_write_page(vma, address - vma->vm_start +
+					   vma->vm_offset, page);
+	__free_page(map);
 	return error;
 }
 
Index: mm//memory.c
===================================================================
RCS file: /var/cvs/linux/mm/memory.c,v
retrieving revision 1.1.1.1.2.1
diff -u -r1.1.1.1.2.1 memory.c
--- memory.c	1998/11/27 10:41:41	1.1.1.1.2.1
+++ linux/mm/memory.c	1998/12/19 15:32:48
@@ -623,11 +623,10 @@
 	unsigned long address, pte_t *page_table)
 {
 	pte_t pte;
-	unsigned long old_page, new_page;
+	unsigned long old_page;
 	struct page * page_map;
 	
 	pte = *page_table;
-	new_page = __get_free_page(GFP_USER);
 	/* Did someone else copy this page for us while we slept? */
 	if (pte_val(*page_table) != pte_val(pte))
 		goto end_wp_page;
@@ -640,16 +639,25 @@
 		goto bad_wp_page;
 	tsk->min_flt++;
 	page_map = mem_map + MAP_NR(old_page);
-	
+
+	/* If the page is clean we just know why it was write protect -arca */
+	if (PageTestAndClearClean(page_map))
+	{
+		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
+		goto end_wp_page;
+	}
+
 	/*
 	 * Do we need to copy?
 	 */
 	if (is_page_shared(page_map)) {
+		unsigned long new_page;
 		unlock_kernel();
+		new_page = __get_free_page(GFP_USER);
 		if (!new_page)
 			return 0;
 
-		if (PageReserved(mem_map + MAP_NR(old_page)))
+		if (PageReserved(page_map))
 			++vma->vm_mm->rss;
 		copy_cow_page(old_page,new_page);
 		flush_page_to_ram(old_page);
@@ -670,16 +678,15 @@
 	flush_cache_page(vma, address);
 	set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
 	flush_tlb_page(vma, address);
+	return 1;
 end_wp_page:
-	if (new_page)
-		free_page(new_page);
+	unlock_kernel();
 	return 1;
 
 bad_wp_page:
+	unlock_kernel();
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	send_sig(SIGKILL, tsk, 1);
-	if (new_page)
-		free_page(new_page);
 	return 0;
 }
 
Index: mm//page_alloc.c
===================================================================
RCS file: /var/cvs/linux/mm/page_alloc.c,v
retrieving revision 1.1.1.1.2.6
diff -u -r1.1.1.1.2.6 page_alloc.c
--- page_alloc.c	1998/12/17 14:44:43	1.1.1.1.2.6
+++ linux/mm/page_alloc.c	1998/12/19 15:52:43
@@ -151,6 +151,7 @@
 	if (!PageReserved(page) && atomic_dec_and_test(&page->count)) {
 		if (PageSwapCache(page))
 			panic ("Freeing swap cache page");
+		PageClearClean(page);
 		free_pages_ok(page->map_nr, 0);
 		return;
 	}
@@ -172,6 +173,7 @@
 		if (atomic_dec_and_test(&map->count)) {
 			if (PageSwapCache(map))
 				panic ("Freeing swap cache pages");
+			PageClearClean(map);
 			free_pages_ok(map_nr, order);
 			return;
 		}
Index: include/linux//mm.h
===================================================================
RCS file: /var/cvs/linux/include/linux/mm.h,v
retrieving revision 1.1.1.1.2.5
diff -u -r1.1.1.1.2.5 mm.h
--- mm.h	1998/12/17 14:44:37	1.1.1.1.2.5
+++ linux/include/linux/mm.h	1998/12/19 15:29:31
@@ -136,6 +136,7 @@
 #define PG_Slab			 8
 #define PG_swap_cache		 9
 #define PG_skip			10
+#define PG_clean		11
 #define PG_reserved		31
 
 /* Make it prettier to test the above... */
@@ -149,16 +150,24 @@
 #define PageDMA(page)		(test_bit(PG_DMA, &(page)->flags))
 #define PageSlab(page)		(test_bit(PG_Slab, &(page)->flags))
 #define PageSwapCache(page)	(test_bit(PG_swap_cache, &(page)->flags))
+#define PageClean(page)		(test_bit(PG_clean, &(page)->flags))
 #define PageReserved(page)	(test_bit(PG_reserved, &(page)->flags))
 
 #define PageSetSlab(page)	(set_bit(PG_Slab, &(page)->flags))
+#define PageSetClean(page)	(set_bit(PG_clean, &(page)->flags))
 #define PageSetSwapCache(page)	(set_bit(PG_swap_cache, &(page)->flags))
+
+#define PageTestAndSetClean(page)	\
+			(test_and_set_bit(PG_clean, &(page)->flags))
 #define PageTestandSetSwapCache(page)	\
 			(test_and_set_bit(PG_swap_cache, &(page)->flags))
 
 #define PageClearSlab(page)	(clear_bit(PG_Slab, &(page)->flags))
+#define PageClearClean(page)	(clear_bit(PG_clean, &(page)->flags))
 #define PageClearSwapCache(page)(clear_bit(PG_swap_cache, &(page)->flags))
 
+#define PageTestAndClearClean(page)	\
+			(test_and_clear_bit(PG_clean, &(page)->flags))
 #define PageTestandClearSwapCache(page)	\
 			(test_and_clear_bit(PG_swap_cache, &(page)->flags))
 


Seems to work here but I' ve not tested it very well yet. At first I
forgot to clean the PG_clean flag in *free_pages and you can guess that I
had to reboot very soon after the first msync ;). It was not msyncing
anymore!! Luckily I understood the culprit after a msec.

NOTE, the do_wp_page() patch I think it' s needed also in the stock
kernel, there are some unbalanced unlock_kernel() otherwise and we would
run a __get_free_pages()  even if not needed and while the kernel lock was
locked (maybe it was intentional? do we need the big kernel lock while we
run __get_free_pages() in do_wp_page?). You only need to reverse:

-
+
+       /* If the page is clean we just know why it was write protect -arca */
+       if (PageTestAndClearClean(page_map))
+       {
+               set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
+               goto end_wp_page;
+       }
+

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
