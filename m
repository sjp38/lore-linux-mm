Received: from Linuz.sns.it (max@Linuz.sns.it [192.167.206.227])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA20643
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 12:00:39 -0500
Date: Sun, 10 Jan 1999 18:00:52 +0100 (MET)
From: Max <max@Linuz.sns.it>
Reply-To: Max <max@Linuz.sns.it>
Subject: tiny patch, reduces kernel memory usage (memory_save patch)
Message-ID: <Pine.LNX.3.96.990110174423.15469A-100000@Linuz.sns.it>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1480530994-1486697280-915726022=:4716"
Content-ID: <Pine.LNX.3.96.990107172805.4810A@Linuz.sns.it>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1480530994-1486697280-915726022=:4716
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.3.96.990107172805.4810B@Linuz.sns.it>


I am really sorry to disturb with something that is supposed to be discussed
in linux-kernel, but looks linux-kernel is terribly lagged, and also my
original message (sent on Jan 7) got somehow ignored.

This patch reduces kernel memory usage of 4kb for every 2Mb of physical RAM.
On my 16Mb box this means the kernel uses 32kb less memory, and on a typical
64Mb Intel you save 128kb.

The patch attached is for 2.2.0-pre4, but I couldn't test it yet, sorry.
(I hope it patches 2.2.0-pre5 cleanly too)
I have tested the patch on 2.0.36 and 2.1.119, and it worked for me.
Anyway the patch is so straightforward that it really should give no problems.

Bye,

                        Massimiliano Ghilardi


diff -urN linux-2.2.0-pre4/include/linux/mm.h linux-mine/include/linux/mm.h
--- linux-2.2.0-pre4/include/linux/mm.h	Fri Jan  1 20:56:22 1999
+++ linux-mine/include/linux/mm.h	Thu Jan  7 16:41:35 1999
@@ -118,12 +118,10 @@
 	unsigned long offset;
 	struct page *next_hash;
 	atomic_t count;
-	unsigned int unused;
	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct wait_queue *wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
-	unsigned long map_nr;	/* page->map_nr == page - mem_map */
 } mem_map_t;
 
 /* Page flag bit values */
diff -urN linux-2.2.0-pre4/include/linux/pagemap.h linux-mine/include/linux/pagemap.h
--- linux-2.2.0-pre4/include/linux/pagemap.h	Fri Jan  1 20:56:22 1999
+++ linux-mine/include/linux/pagemap.h	Thu Jan  7 16:45:56 1999
@@ -14,7 +14,7 @@
 
 static inline unsigned long page_address(struct page * page)
 {
-	return PAGE_OFFSET + PAGE_SIZE * page->map_nr;
+	return PAGE_OFFSET + PAGE_SIZE * (page - mem_map);
 }
 
 #define PAGE_HASH_BITS 11
diff -urN linux-2.2.0-pre4/include/linux/version.h linux-mine/include/linux/version.h
--- linux-2.2.0-pre4/include/linux/version.h	Thu Jan  1 01:00:00 1970
+++ linux-mine/include/linux/version.h	Thu Jan  7 16:46:58 1999
@@ -0,0 +1,3 @@
+#define UTS_RELEASE "2.2.0-pre4"
+#define LINUX_VERSION_CODE 131584
+#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))
diff -urN linux-2.2.0-pre4/mm/filemap.c linux-mine/mm/filemap.c
--- linux-2.2.0-pre4/mm/filemap.c	Fri Jan  1 00:15:17 1999
+++ linux-mine/mm/filemap.c	Thu Jan  7 16:46:22 1999
@@ -138,7 +138,7 @@
 		if (PageSkip(page)) {
 			/* next_hash is overloaded for PageSkip */
 			page = page->next_hash;
-			clock = page->map_nr;
+			clock = page - mem_map;
 		}
 		
 		if (test_and_clear_bit(PG_referenced, &page->flags))
diff -urN linux-2.2.0-pre4/mm/page_alloc.c linux-mine/mm/page_alloc.c
--- linux-2.2.0-pre4/mm/page_alloc.c	Sun Jan  3 04:02:16 1999
+++ linux-mine/mm/page_alloc.c	Thu Jan  7 16:44:19 1999
@@ -152,7 +152,7 @@
 		if (PageSwapCache(page))
 			panic ("Freeing swap cache page");
 		page->flags &= ~(1 << PG_referenced);
-		free_pages_ok(page->map_nr, 0);
+		free_pages_ok(page - mem_map, 0);
 		return;
 	}
 #if 0
@@ -201,7 +201,7 @@
 			if (!dma || CAN_DMA(ret)) { \
 				unsigned long map_nr; \
 				(prev->next = ret->next)->prev = prev; \
-				map_nr = ret->map_nr; \
+				map_nr = ret - mem_map; \
 				MARK_USED(map_nr, new_order, area); \
 				nr_free_pages -= 1 << order; \
 				EXPAND(ret, map_nr, order, new_order, area); \
@@ -363,7 +363,6 @@
 		--p;
 		atomic_set(&p->count, 0);
 		p->flags = (1 << PG_DMA) | (1 << PG_reserved);
-		p->map_nr = p - mem_map;
 	} while (p > mem_map);
 
 	for (i = 0 ; i < NR_MEM_LISTS ; i++) {

---1480530994-1486697280-915726022=:4716--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
