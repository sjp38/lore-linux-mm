Subject: PATCH: alloc_pages solving problems for machines with a lot of memory
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 11 Jul 2000 18:10:32 +0200
Message-ID: <yttsntgmyvb.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lkml <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi
        Users of 1GB RAM machines are having problems with the
        machines swapping too soon.  That happens due to the fact that
        they got out of pages in the HIGH_MEM zone (only around 100MB
        on that machines)  and they begin to swap searching for pages
        free in the NORMAL zone.  That problem also appears with the
        DMA zone.  This is the same patch that I send to
        2.4.0-test1-ac22-*

Later, Juan.

This patch does:
- We allocate for a zone with more than pages_high free pages if
  possible.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/page_alloc.c working/mm/page_alloc.c
--- base/mm/page_alloc.c	Tue Jul 11 12:00:55 2000
+++ working/mm/page_alloc.c	Tue Jul 11 17:39:07 2000
@@ -227,6 +227,23 @@
 	 * We are falling back to lower-level zones if allocation
 	 * in a higher zone fails.
 	 */
+
+	for (;;) {
+		zone_t *z = *(zone++);
+		if (!z)
+			break;
+		if (!z->size)
+			BUG();
+
+		/* If there are zones with a lot of free memory allocate from them */
+		if (z->free_pages > z->pages_high) {
+			struct page *page = rmqueue(z, order);
+			if (page)
+				return page;
+		}
+	}
+
+	zone = zonelist->zones;
 	for (;;) {
 		zone_t *z = *(zone++);
 		if (!z)



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
