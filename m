Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA30989
	for <linux-mm@kvack.org>; Tue, 22 Dec 1998 12:33:21 -0500
Date: Tue, 22 Dec 1998 18:23:03 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] swap_out now really free (the right) pages [Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)]
In-Reply-To: <Pine.LNX.3.96.981222114610.538B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981222180806.478B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Dec 1998, Andrea Arcangeli wrote:

>page is a bit messy though. Should we always do a shrink_mmap()  after
>every succesfully swapout? 

Tried and seems to work greatly here! This my new mm patch improves things
because now swap_out() is able to really free pages and so very less
frequently processes get blocked in try_to_free_pages because now kswapd
is able to take the freepages over the min limit. It seems to _not_ hurt the
aging at all. And btw this my patch make _tons_ of sense to me.

Could you try the patch and feedback?

Andrea Arcangeli

PS. As usual I don't know if adding a Copyright there can make sense or is
    legal...

Patch against 2.1.132-4

Index: filemap.c
===================================================================
RCS file: /var/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.1.1.2.24
diff -u -r1.1.1.1.2.24 filemap.c
--- filemap.c	1998/12/22 11:07:28	1.1.1.1.2.24
+++ linux/mm/filemap.c	1998/12/22 17:03:55
@@ -181,26 +181,6 @@
 }
 
 /*
- * This is called from try_to_swap_out() when we try to get rid of some
- * pages..  If we're unmapping the last occurrence of this page, we also
- * free it from the page hash-queues etc, as we don't want to keep it
- * in-core unnecessarily.
- */
-unsigned long page_unuse(struct page * page)
-{
-	int count = atomic_read(&page->count);
-
-	if (count != 2)
-		return count;
-	if (!page->inode)
-		return count;
-	if (PageSwapCache(page))
-		panic ("Doing a normal page_unuse of a swap cache page");
-	remove_inode_page(page);
-	return 1;
-}
-
-/*
  * Update a page cache copy, when we're doing a "write()" system call
  * See also "update_vm_cache()".
  */
Index: swap_state.c
===================================================================
RCS file: /var/cvs/linux/mm/swap_state.c,v
retrieving revision 1.1.1.1.2.7
diff -u -r1.1.1.1.2.7 swap_state.c
--- swap_state.c	1998/12/20 15:51:32	1.1.1.1.2.7
+++ linux/mm/swap_state.c	1998/12/22 16:33:29
@@ -248,7 +248,7 @@
 		delete_from_swap_cache(page);
 	}
 	
-	free_page(addr);
+	__free_page(page);
 }
 
 
Index: vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.1.2.39
diff -u -r1.1.1.1.2.39 vmscan.c
--- vmscan.c	1998/12/22 11:07:28	1.1.1.1.2.39
+++ linux/mm/vmscan.c	1998/12/22 17:19:17
@@ -10,6 +10,16 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * Changed swap_out() to have really freed one page when it returns 1
+ * (that was not longer true since 2.1.130).
+ * The trick is done doing a fast pass of shrink_mmap() and freeing
+ * the swapped out page by hand from the swap cache only if shrink_mmap()
+ * has failed. This way we are swapping out and freeing ram but taking care
+ * of the page aging (PG_referenced).
+ *			Copyright (C) 1998  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -27,6 +37,8 @@
 
 static void init_swap_timer(void);
 
+#define	SWAPOUT_SHRINK_PRIORITY	6
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -162,7 +174,12 @@
 			 * copy in memory, so we add it to the swap
 			 * cache. */
 			if (PageSwapCache(page_map)) {
-				free_page(page);
+				if (shrink_mmap(SWAPOUT_SHRINK_PRIORITY, 0))
+				{
+					__free_page(page_map);
+					return 1;
+				}
+				free_page_and_swap_cache(page);
 				return (atomic_read(&page_map->count) == 0);
 			}
 			add_to_swap_cache(page_map, entry);
@@ -180,7 +197,11 @@
 		 * asynchronously.  That's no problem, shrink_mmap() can
 		 * correctly clean up the occassional unshared page
 		 * which gets left behind in the swap cache. */
-		free_page(page);
+		if (shrink_mmap(SWAPOUT_SHRINK_PRIORITY, 0))
+			__free_page(page_map);
+		else
+			free_page_and_swap_cache(page);
+
 		return 1;	/* we slept: the process may not exist any more */
 	}
 
@@ -194,8 +215,14 @@
 		set_pte(page_table, __pte(entry));
 		flush_tlb_page(vma, address);
 		swap_duplicate(entry);
-		free_page(page);
-		return (atomic_read(&page_map->count) == 0);
+		if (shrink_mmap(SWAPOUT_SHRINK_PRIORITY, 0))
+		{
+			__free_page(page_map);
+			return 1;
+		} else {
+			free_page_and_swap_cache(page);
+			return (atomic_read(&page_map->count) == 0);
+		}
 	} 
 	/* 
 	 * A clean page to be discarded?  Must be mmap()ed from
@@ -210,9 +237,15 @@
 	flush_cache_page(vma, address);
 	pte_clear(page_table);
 	flush_tlb_page(vma, address);
-	entry = (atomic_read(&page_map->count) == 1);
+	entry = atomic_read(&page_map->count);
 	__free_page(page_map);
-	return entry;
+	if (entry == 2 && page_map->inode)
+	{
+		if (!shrink_mmap(SWAPOUT_SHRINK_PRIORITY, 0))
+			remove_inode_page(page_map);
+		return 1;
+	}
+	return entry == 1;
 }
 
 /*

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
