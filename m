Date: Mon, 3 Apr 2000 18:22:25 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: PG_swap_entry bug in recent kernels
Message-ID: <Pine.LNX.4.21.0004031817420.3672-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following one-liner is a painful bug present in recent kernels: swap
cache pages left in the LRU lists and subsequently reclaimed by
shrink_mmap were resulting in new pages having the PG_swap_entry bit set.  
This leads to invalid swap entries being put into users page tables if the
page is eventually swapped out.  This was nasty to track down.

		-ben


diff -ur 2.3.99-pre4-3/mm/swap_state.c test-pre4-3/mm/swap_state.c
--- 2.3.99-pre4-3/mm/swap_state.c	Mon Dec  6 13:19:45 1999
+++ test-pre4-3/mm/swap_state.c	Mon Apr  3 17:59:30 2000
@@ -80,6 +80,7 @@
 #endif
 	remove_from_swap_cache(page);
 	swap_free(entry);
+	clear_bit(PG_swap_entry, &page->flags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
