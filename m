Date: Mon, 15 May 2000 12:12:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [patch] VM stable again?
Message-ID: <Pine.LNX.4.21.0005151157240.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

the patch below makes sure processes won't "eat" the pages
another process is freeing and seems to avoid the nasty
out of memory situations that people have seen.

With this patch performance isn't quite what it should be,
but I have some ideas on making performance fly (without
impacting stability, of course).

With this patch kswapd uses extremely little cpu, compared
to other kernel versions. This is probably a sign that the
apps will be able to manage VM by themselves without help
from kswapd ... except for performance of course ;)

The patch works in a very simple way:
- keep track of whether some process is critically low on
  memory and needs to call try_to_free_pages()
- if another allocation starts while the other app is in
  try_to_free_pages(), free some memory ourselves
- (skip point 2 if there is enough free memory, but that's
  just a minor performance optimisation)

This way we won't "eat" the free memory 

I'd appreciate it if some people could try it and see if
it fixes all the OOM situations.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- mm/page_alloc.c.orig	Fri May 12 20:13:08 2000
+++ mm/page_alloc.c	Mon May 15 11:00:17 2000
@@ -216,6 +216,7 @@
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
 	zone_t **zone = zonelist->zones;
+	static atomic_t free_before_allocate = ATOMIC_INIT(0);
 	extern wait_queue_head_t kswapd_wait;
 
 	/*
@@ -243,6 +244,9 @@
 			if (page)
 				return page;
 		}
+		/* Somebody else is freeing pages? */
+		if (atomic_read(&free_before_allocate))
+			try_to_free_pages(zonelist->gfp_mask);
 	}
 
 	/*
@@ -270,10 +274,12 @@
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		int gfp_mask = zonelist->gfp_mask;
+		atomic_inc(&free_before_allocate);
 		if (!try_to_free_pages(gfp_mask)) {
 			if (!(gfp_mask & __GFP_HIGH))
 				goto fail;
 		}
+		atomic_dec(&free_before_allocate);
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
