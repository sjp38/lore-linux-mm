Date: Sat, 7 Aug 1999 17:08:32 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] 2.3.12 persistence of dirty pages on the swap space
Message-ID: <Pine.LNX.4.10.9908071700240.7637-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As just said some time ago there's a simple way to swapout the swapped-in
dirty pages always on the same location on disk (so avoiding swap
fragmentation and taking the swapped out data contigous on disk).

We have the swap-entry information cached in the page->offset field all
the time after the first swapin. It will stay uptodate also after removing
the page from the swap cache in the do_wp_page fault.

We only need to know when the entry is uptodate and I take care of that
with a per-page bitflag (PG_swap_entry).

Here it is the simple patch against 2.3.12:

diff -ur 2.3.12/include/linux/mm.h 2.3.12-swap_entry/include/linux/mm.h
--- 2.3.12/include/linux/mm.h	Wed Aug  4 12:28:17 1999
+++ 2.3.12-swap_entry/include/linux/mm.h	Sat Aug  7 16:59:12 1999
@@ -152,6 +152,7 @@
 #define PG_Slab			 8
 #define PG_swap_cache		 9
 #define PG_skip			10
+#define PG_swap_entry		11
 				/* bits 21-30 unused */
 #define PG_reserved		31
 
diff -ur 2.3.12/mm/memory.c 2.3.12-swap_entry/mm/memory.c
--- 2.3.12/mm/memory.c	Sun Aug  1 18:11:22 1999
+++ 2.3.12-swap_entry/mm/memory.c	Sat Aug  7 16:51:49 1999
@@ -990,6 +990,7 @@
 
 	pte = mk_pte(page_address(page), vma->vm_page_prot);
 
+	set_bit(PG_swap_entry, &page->flags);
 	if (write_access && !is_page_shared(page)) {
 		delete_from_swap_cache(page);
 		pte = pte_mkwrite(pte_mkdirty(pte));
diff -ur 2.3.12/mm/swap_state.c 2.3.12-swap_entry/mm/swap_state.c
--- 2.3.12/mm/swap_state.c	Tue Jul 13 02:02:10 1999
+++ 2.3.12-swap_entry/mm/swap_state.c	Sat Aug  7 16:53:51 1999
@@ -274,6 +274,8 @@
 	}
 	UnlockPage(page);
 	
+	clear_bit(PG_swap_entry, &page->flags);
+
 	__free_page(page);
 }
 
diff -ur 2.3.12/mm/swapfile.c 2.3.12-swap_entry/mm/swapfile.c
--- 2.3.12/mm/swapfile.c	Thu Jul 22 01:07:28 1999
+++ 2.3.12-swap_entry/mm/swapfile.c	Sat Aug  7 16:55:21 1999
@@ -157,6 +157,35 @@
 	goto out;
 }
 
+/* needs the big kernel lock */
+int reacquire_swap_entry(unsigned long entry)
+{
+	struct swap_info_struct * p;
+	unsigned long offset, type;
+	int retval = 0;
+
+	if (!entry)
+		goto out;
+	type = SWP_TYPE(entry);
+	if (type & SHM_SWP_TYPE)
+		goto out;
+	if (type >= nr_swapfiles)
+		goto out;
+	p = type + swap_info;
+	if ((p->flags & SWP_WRITEOK) != SWP_WRITEOK)
+		goto out;
+	offset = SWP_OFFSET(entry);
+	if (offset >= p->max)
+		goto out;
+	if (!p->swap_map[offset])
+	{
+		retval = p->swap_map[offset] = 1;
+		nr_swap_pages--;
+	}
+out:
+	return retval;
+}
+
 /*
  * The swap entry has been read in advance, and we return 1 to indicate
  * that the page has been used or is no longer needed.
diff -ur 2.3.12/mm/vmscan.c 2.3.12-swap_entry/mm/vmscan.c
--- 2.3.12/mm/vmscan.c	Thu Jul 22 01:07:28 1999
+++ 2.3.12-swap_entry/mm/vmscan.c	Sat Aug  7 16:57:00 1999
@@ -153,9 +153,16 @@
 	 * we have the swap cache set up to associate the
 	 * page with that swap entry.
 	 */
+	if (test_and_clear_bit(PG_swap_entry, &page->flags))
+	{
+		entry = page->offset;
+		if (reacquire_swap_entry(entry))
+			goto swap_entry_reacquired;
+	}
 	entry = get_swap_page();
 	if (!entry)
 		goto out_failed; /* No swap space left */
+ swap_entry_reacquired:
 		
 	vma->vm_mm->rss--;
 	tsk->nswap++;


When I benchmarked it on 2.2.x long ago it was a very nice improvement.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
