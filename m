Subject: PATCH: Change in __alloc_pages
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 20 Jun 2000 03:43:44 +0200
Message-ID: <yttog4xnn3j.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
        with this change in top of my previous patch (shrink_mmap take2)
I get the same performance on IO that the removing the page->zone test
from shrink_mmap.  Could people seing improvements in ac21 (or later)
test this patch.  

Comments and positive/negative reports are welcome.

Later, Juan.

This patch does:
- We allocate for a zone with more than pages_high free pages if
  possible.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/page_alloc.c working/mm/page_alloc.c
--- base/mm/page_alloc.c	Mon Jun 19 23:35:41 2000
+++ working/mm/page_alloc.c	Tue Jun 20 03:03:51 2000
@@ -233,6 +233,23 @@
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
+		/* If there are zones with a lot of free memory
allocate from them */
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
