Date: Mon, 15 May 2000 16:11:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [patch2] pre8 VM stable
Message-ID: <Pine.LNX.4.21.0005151611010.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

here is the second version of the patch, with the
leak fixed and per-zonelist status.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- mm/page_alloc.c.orig	Fri May 12 20:13:08 2000
+++ mm/page_alloc.c	Mon May 15 15:57:06 2000
@@ -243,6 +243,9 @@
 			if (page)
 				return page;
 		}
+		/* Somebody else is freeing pages? */
+		if (atomic_read(&zonelist->free_before_allocate))
+			try_to_free_pages(zonelist->gfp_mask);
 	}
 
 	/*
@@ -270,7 +273,11 @@
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		int gfp_mask = zonelist->gfp_mask;
-		if (!try_to_free_pages(gfp_mask)) {
+		int result;
+		atomic_inc(&zonelist->free_before_allocate);
+		result = try_to_free_pages(gfp_mask);
+		atomic_dec(&zonelist->free_before_allocate);
+		if (!result) {
 			if (!(gfp_mask & __GFP_HIGH))
 				goto fail;
 		}
@@ -414,6 +421,7 @@
 		zonelist = pgdat->node_zonelists + i;
 		memset(zonelist, 0, sizeof(*zonelist));
 
+		atomic_set(&zonelist->free_before_allocate, 0);
 		zonelist->gfp_mask = i;
 		j = 0;
 		k = ZONE_NORMAL;
--- include/linux/mmzone.h.orig	Mon May 15 15:47:39 2000
+++ include/linux/mmzone.h	Mon May 15 15:48:04 2000
@@ -70,6 +70,7 @@
 typedef struct zonelist_struct {
 	zone_t * zones [MAX_NR_ZONES+1]; // NULL delimited
 	int gfp_mask;
+	atomic_t free_before_allocate;
 } zonelist_t;
 
 #define NR_GFPINDEX		0x100

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
