Date: Wed, 17 May 2000 23:32:24 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [patch] pre9-2 shm balance
Message-ID: <Pine.LNX.4.21.0005172331320.3951-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

with quintela's latest patch and the small patch below, the
system works fine again, even under heavy shm stress testing.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/


--- ipc/shm.c.orig	Wed May 17 22:59:47 2000
+++ ipc/shm.c	Wed May 17 23:24:52 2000
@@ -1468,7 +1468,7 @@
 }
 
 /*
- * Goes through counter = (shm_rss >> prio) present shm pages.
+ * Goes through counter = (shm_rss / (prio + 1)) present shm pages.
  */
 static unsigned long swap_id; /* currently being swapped */
 static unsigned long swap_idx; /* next to swap */
@@ -1483,7 +1483,7 @@
 	struct page * page_map;
 
 	zshm_swap(prio, gfp_mask);
-	counter = shm_rss >> prio;
+	counter = shm_rss / (prio + 1);
 	if (!counter)
 		return 0;
 	if (shm_swap_preop(&swap_entry))
@@ -1809,7 +1809,7 @@
 	int counter;
 	struct page * page_map;
 
-	counter = zshm_rss >> prio;
+	counter = zshm_rss / (prio + 1);
 	if (!counter)
 		return;
 next:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
