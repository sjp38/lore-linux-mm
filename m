Received: from alogconduit1ah.ccr.net (root@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA12409
	for <linux-mm@kvack.org>; Sun, 23 May 1999 15:27:32 -0400
Subject: [PATCH] Allow different uses of page->buffers.
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 13:38:07 -0500
Message-ID: <m1d7zrskc0.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

diff -uNrX linux-ignore-files linux-2.3.3/fs/buffer.c linux-2.3.3.eb1/fs/buffer.c
--- linux-2.3.3/fs/buffer.c	Sun May 16 22:09:09 1999
+++ linux-2.3.3.eb1/fs/buffer.c	Tue May 18 01:11:51 1999
@@ -1400,7 +1400,8 @@
 	}
 	tmp->b_this_page = bh;
 	free_list[isize] = bh;
-	mem_map[MAP_NR(page)].buffers = bh;
+	PageSetBuffer(&mem_map[MAP_NR(page)]);
+	mem_map[MAP_NR(page)].generic_pp = bh;
 	buffermem += PAGE_SIZE;
 	return 1;
 }
@@ -1420,7 +1421,7 @@
  */
 int try_to_free_buffers(struct page * page_map)
 {
-	struct buffer_head * tmp, * bh = page_map->buffers;
+	struct buffer_head * tmp, * bh = page_map->generic_pp;
 
 	tmp = bh;
 	do {
@@ -1448,7 +1449,8 @@
 
 	/* And free the page */
 	buffermem -= PAGE_SIZE;
-	page_map->buffers = NULL;
+	PageClearBuffer(page_map);
+	page_map->generic_pp = NULL;
 	__free_page(page_map);
 	return 1;
 }
diff -uNrX linux-ignore-files linux-2.3.3/include/linux/mm.h linux-2.3.3.eb1/include/linux/mm.h
--- linux-2.3.3/include/linux/mm.h	Sun May 16 22:07:49 1999
+++ linux-2.3.3.eb1/include/linux/mm.h	Tue May 18 01:11:51 1999
@@ -128,7 +128,7 @@
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	wait_queue_head_t wait;
 	struct page **pprev_hash;
-	struct buffer_head * buffers;
+	void *generic_pp; /* This is page buffers iff PageBuffer(page) is true. */
 } mem_map_t;
 
 /* Page flag bit values */
@@ -144,6 +144,7 @@
 #define PG_Slab			 9
 #define PG_swap_cache		10
 #define PG_skip			11
+#define PG_buffer		12
 #define PG_reserved		31
 
 /* Make it prettier to test the above... */
@@ -158,10 +159,12 @@
 #define PageDMA(page)		(test_bit(PG_DMA, &(page)->flags))
 #define PageSlab(page)		(test_bit(PG_Slab, &(page)->flags))
 #define PageSwapCache(page)	(test_bit(PG_swap_cache, &(page)->flags))
+#define PageBuffer(page)	(test_bit(PG_buffer, &(page)->flags))
 #define PageReserved(page)	(test_bit(PG_reserved, &(page)->flags))
 
 #define PageSetSlab(page)	(set_bit(PG_Slab, &(page)->flags))
 #define PageSetSwapCache(page)	(set_bit(PG_swap_cache, &(page)->flags))
+#define PageSetBuffer(page)	(set_bit(PG_buffer, &(page)->flags))
 
 #define PageTestandSetDirty(page)	\
 			(test_and_set_bit(PG_dirty, &(page)->flags))
@@ -170,6 +173,7 @@
 
 #define PageClearSlab(page)	(clear_bit(PG_Slab, &(page)->flags))
 #define PageClearSwapCache(page)(clear_bit(PG_swap_cache, &(page)->flags))
+#define PageClearBuffer(page)	(clear_bit(PG_buffer, &(page)->flags))
 
 #define PageTestandClearDirty(page) \
 			(test_and_clear_bit(PG_dirty, &(page)->flags))
@@ -210,8 +214,8 @@
  * file offset of the page (not necessarily a multiple of PAGE_SIZE).
  *
  * A page may have buffers allocated to it. In this case,
- * page->buffers is a circular list of these buffer heads. Else,
- * page->buffers == NULL.
+ * PageBuffer(page) is true and page->generic_pp is a circular list of
+ * these buffer heads. Else, PageBuffer(page) is false.
  *
  * For pages belonging to inodes, the page->count is the number of
  * attaches, plus 1 if buffers are allocated to the page.
diff -uNrX linux-ignore-files linux-2.3.3/mm/filemap.c linux-2.3.3.eb1/mm/filemap.c
--- linux-2.3.3/mm/filemap.c	Sun May 16 22:07:54 1999
+++ linux-2.3.3.eb1/mm/filemap.c	Tue May 18 01:11:52 1999
@@ -192,7 +192,7 @@
 			continue;
 
 		/* Is it a buffer page? */
-		if (page->buffers) {
+		if (PageBuffer(page)) {
 			if (buffer_under_min())
 				continue;
 			if (!try_to_free_buffers(page))
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
