Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
References: <Pine.LNX.4.10.10005021439320.12403-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Tue, 2 May 2000 14:40:34 -0700 (PDT)"
Date: 03 May 2000 00:06:01 +0200
Message-ID: <yttwvlczjxy.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

>> If you want the patch for get rid of PG_swap_entry, I can do it and send it to
>> you.

linus> I'd rather get rid of it entirely, yes, as I hate having "crud" around
linus> that nobody realizes isn't really even active any more (and your one-liner
linus> de-activates the whole thing as far as I can tell).

Attached is the patch that removes all the PG_swap_entry logic, the
*SwapEntry macros, and the acquire_swap_entry function.  This function
becomes a call to get_swap_page.  I have substituted that.

Later, Juan.

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1/include/linux/mm.h swap_entry/include/linux/mm.h
--- pre7-1/include/linux/mm.h	Sat Apr 29 20:53:36 2000
+++ swap_entry/include/linux/mm.h	Tue May  2 23:51:16 2000
@@ -173,7 +173,7 @@
 #define PG_slab			 8
 #define PG_swap_cache		 9
 #define PG_skip			10
-#define PG_swap_entry		11
+#define PG_unused_03		11
 #define PG_highmem		12
 				/* bits 21-30 unused */
 #define PG_reserved		31
@@ -210,9 +210,6 @@
 #define PageClearSwapCache(page)	clear_bit(PG_swap_cache, &(page)->flags)
 
 #define PageTestandClearSwapCache(page)	test_and_clear_bit(PG_swap_cache, &(page)->flags)
-#define PageSwapEntry(page)		test_bit(PG_swap_entry, &(page)->flags)
-#define SetPageSwapEntry(page)		set_bit(PG_swap_entry, &(page)->flags)
-#define ClearPageSwapEntry(page)	clear_bit(PG_swap_entry, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)		test_bit(PG_highmem, &(page)->flags)
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1/include/linux/swap.h swap_entry/include/linux/swap.h
--- pre7-1/include/linux/swap.h	Thu Apr 27 00:29:07 2000
+++ swap_entry/include/linux/swap.h	Tue May  2 23:54:50 2000
@@ -121,7 +121,6 @@
 					struct inode **);
 extern int swap_duplicate(swp_entry_t);
 extern int swap_count(struct page *);
-extern swp_entry_t acquire_swap_entry(struct page *page);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 #define get_swap_page() __get_swap_page(1)
 extern void __swap_free(swp_entry_t, unsigned short);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1/mm/memory.c swap_entry/mm/memory.c
--- pre7-1/mm/memory.c	Tue Apr 25 00:46:18 2000
+++ swap_entry/mm/memory.c	Tue May  2 23:51:53 2000
@@ -1053,8 +1053,6 @@
 
 	pte = mk_pte(page, vma->vm_page_prot);
 
-	SetPageSwapEntry(page);
-
 	/*
 	 * Freeze the "shared"ness of the page, ie page_count + swap_count.
 	 * Must lock page before transferring our swap count to already
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1/mm/swap_state.c swap_entry/mm/swap_state.c
--- pre7-1/mm/swap_state.c	Wed Apr 26 02:28:56 2000
+++ swap_entry/mm/swap_state.c	Tue May  2 23:52:39 2000
@@ -130,9 +130,6 @@
 		}
 		UnlockPage(page);
 	}
-
-	ClearPageSwapEntry(page);
-
 	__free_page(page);
 }
 
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1/mm/swapfile.c swap_entry/mm/swapfile.c
--- pre7-1/mm/swapfile.c	Fri Apr 21 22:36:40 2000
+++ swap_entry/mm/swapfile.c	Tue May  2 23:54:44 2000
@@ -200,49 +200,6 @@
 	goto out;
 }
 
-/* needs the big kernel lock */
-swp_entry_t acquire_swap_entry(struct page *page)
-{
-	struct swap_info_struct * p;
-	unsigned long offset, type;
-	swp_entry_t entry;
-
-	if (!PageSwapEntry(page))
-		goto new_swap_entry;
-
-	/* We have the old entry in the page offset still */
-	if (!page->index)
-		goto new_swap_entry;
-	entry.val = page->index;
-	type = SWP_TYPE(entry);
-	if (type >= nr_swapfiles)
-		goto new_swap_entry;
-	p = type + swap_info;
-	if ((p->flags & SWP_WRITEOK) != SWP_WRITEOK)
-		goto new_swap_entry;
-	offset = SWP_OFFSET(entry);
-	if (offset >= p->max)
-		goto new_swap_entry;
-	/* Has it been re-used for something else? */
-	swap_list_lock();
-	swap_device_lock(p);
-	if (p->swap_map[offset])
-		goto unlock_new_swap_entry;
-
-	/* We're cool, we can just use the old one */
-	p->swap_map[offset] = 1;
-	swap_device_unlock(p);
-	nr_swap_pages--;
-	swap_list_unlock();
-	return entry;
-
-unlock_new_swap_entry:
-	swap_device_unlock(p);
-	swap_list_unlock();
-new_swap_entry:
-	return get_swap_page();
-}
-
 /*
  * The swap entry has been read in advance, and we return 1 to indicate
  * that the page has been used or is no longer needed.
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1/mm/vmscan.c swap_entry/mm/vmscan.c
--- pre7-1/mm/vmscan.c	Sat Apr 29 20:53:36 2000
+++ swap_entry/mm/vmscan.c	Tue May  2 23:54:36 2000
@@ -151,7 +151,7 @@
 	 * we have the swap cache set up to associate the
 	 * page with that swap entry.
 	 */
-	entry = acquire_swap_entry(page);
+	entry = get_swap_page();
 	if (!entry.val)
 		goto out_failed; /* No swap space left */
 		




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
