Date: Thu, 2 Nov 2000 12:32:07 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: PATCH [2.4.0test10]: Kiobuf#00, moving code
Message-ID: <20001102123207.Z1876@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZwgA9U+XZDXt4+m+"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--ZwgA9U+XZDXt4+m+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Patch 00 for kiobufs: moves a chunk of code from mm/memory.c to
fs/iobuf.c.  The code concerned touches physical pages but has
absolutely nothing to do with virtual memory, so doesn't deserve to be
lumped with the map_user_kiobuf code.

--Stephen

--ZwgA9U+XZDXt4+m+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="00-movecode.diff"

diff -ru linux-2.4.0-test10.orig/fs/iobuf.c linux-2.4.0-test10.kio.00/fs/iobuf.c
--- linux-2.4.0-test10.orig/fs/iobuf.c	Mon Mar 13 13:26:09 2000
+++ linux-2.4.0-test10.kio.00/fs/iobuf.c	Thu Nov  2 12:02:21 2000
@@ -9,6 +9,7 @@
 #include <linux/iobuf.h>
 #include <linux/malloc.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
 
 static kmem_cache_t *kiobuf_cachep;
 
@@ -126,5 +127,131 @@
 	remove_wait_queue(&kiobuf->wait_queue, &wait);
 }
 
+
+/*
+ * Unmap all of the pages referenced by a kiobuf.  We release the pages,
+ * and unlock them if they were locked. 
+ */
+
+void unmap_kiobuf (struct kiobuf *iobuf) 
+{
+	int i;
+	struct page *map;
+	
+	for (i = 0; i < iobuf->nr_pages; i++) {
+		map = iobuf->maplist[i];
+		if (map) {
+			if (iobuf->locked)
+				UnlockPage(map);
+			__free_page(map);
+		}
+	}
+	
+	iobuf->nr_pages = 0;
+	iobuf->locked = 0;
+}
+
+
+/*
+ * Lock down all of the pages of a kiovec for IO.
+ *
+ * If any page is mapped twice in the kiovec, we return the error -EINVAL.
+ *
+ * The optional wait parameter causes the lock call to block until all
+ * pages can be locked if set.  If wait==0, the lock operation is
+ * aborted if any locked pages are found and -EAGAIN is returned.
+ */
+
+int lock_kiovec(int nr, struct kiobuf *iovec[], int wait)
+{
+	struct kiobuf *iobuf;
+	int i, j;
+	struct page *page, **ppage;
+	int doublepage = 0;
+	int repeat = 0;
+	
+ repeat:
+	
+	for (i = 0; i < nr; i++) {
+		iobuf = iovec[i];
+
+		if (iobuf->locked)
+			continue;
+		iobuf->locked = 1;
+
+		ppage = iobuf->maplist;
+		for (j = 0; j < iobuf->nr_pages; ppage++, j++) {
+			page = *ppage;
+			if (!page)
+				continue;
+			
+			if (TryLockPage(page))
+				goto retry;
+		}
+	}
+
+	return 0;
+	
+ retry:
+	
+	/* 
+	 * We couldn't lock one of the pages.  Undo the locking so far,
+	 * wait on the page we got to, and try again.  
+	 */
+	
+	unlock_kiovec(nr, iovec);
+	if (!wait)
+		return -EAGAIN;
+	
+	/* 
+	 * Did the release also unlock the page we got stuck on?
+	 */
+	if (!PageLocked(page)) {
+		/* 
+		 * If so, we may well have the page mapped twice
+		 * in the IO address range.  Bad news.  Of
+		 * course, it _might_ just be a coincidence,
+		 * but if it happens more than once, chances
+		 * are we have a double-mapped page. 
+		 */
+		if (++doublepage >= 3) 
+			return -EINVAL;
+		
+		/* Try again...  */
+		wait_on_page(page);
+	}
+	
+	if (++repeat < 16)
+		goto repeat;
+	return -EAGAIN;
+}
+
+/*
+ * Unlock all of the pages of a kiovec after IO.
+ */
+
+int unlock_kiovec(int nr, struct kiobuf *iovec[])
+{
+	struct kiobuf *iobuf;
+	int i, j;
+	struct page *page, **ppage;
+	
+	for (i = 0; i < nr; i++) {
+		iobuf = iovec[i];
+
+		if (!iobuf->locked)
+			continue;
+		iobuf->locked = 0;
+		
+		ppage = iobuf->maplist;
+		for (j = 0; j < iobuf->nr_pages; ppage++, j++) {
+			page = *ppage;
+			if (!page)
+				continue;
+			UnlockPage(page);
+		}
+	}
+	return 0;
+}
 
 
diff -ru linux-2.4.0-test10.orig/include/linux/iobuf.h linux-2.4.0-test10.kio.00/include/linux/iobuf.h
--- linux-2.4.0-test10.orig/include/linux/iobuf.h	Mon Mar 13 13:26:09 2000
+++ linux-2.4.0-test10.kio.00/include/linux/iobuf.h	Thu Nov  2 12:02:43 2000
@@ -61,9 +61,6 @@
 /* mm/memory.c */
 
 int	map_user_kiobuf(int rw, struct kiobuf *, unsigned long va, size_t len);
-void	unmap_kiobuf(struct kiobuf *iobuf);
-int	lock_kiovec(int nr, struct kiobuf *iovec[], int wait);
-int	unlock_kiovec(int nr, struct kiobuf *iovec[]);
 
 /* fs/iobuf.c */
 
@@ -75,6 +72,9 @@
 void	free_kiovec(int nr, struct kiobuf **);
 int	expand_kiobuf(struct kiobuf *, int);
 void	kiobuf_wait_for_io(struct kiobuf *);
+void	unmap_kiobuf(struct kiobuf *iobuf);
+int	lock_kiovec(int nr, struct kiobuf *iovec[], int wait);
+int	unlock_kiovec(int nr, struct kiobuf *iovec[]);
 
 /* fs/buffer.c */
 
diff -ru linux-2.4.0-test10.orig/mm/memory.c linux-2.4.0-test10.kio.00/mm/memory.c
--- linux-2.4.0-test10.orig/mm/memory.c	Wed Nov  1 22:25:48 2000
+++ linux-2.4.0-test10.kio.00/mm/memory.c	Thu Nov  2 11:51:41 2000
@@ -504,132 +504,6 @@
 }
 
 
-/*
- * Unmap all of the pages referenced by a kiobuf.  We release the pages,
- * and unlock them if they were locked. 
- */
-
-void unmap_kiobuf (struct kiobuf *iobuf) 
-{
-	int i;
-	struct page *map;
-	
-	for (i = 0; i < iobuf->nr_pages; i++) {
-		map = iobuf->maplist[i];
-		if (map) {
-			if (iobuf->locked)
-				UnlockPage(map);
-			__free_page(map);
-		}
-	}
-	
-	iobuf->nr_pages = 0;
-	iobuf->locked = 0;
-}
-
-
-/*
- * Lock down all of the pages of a kiovec for IO.
- *
- * If any page is mapped twice in the kiovec, we return the error -EINVAL.
- *
- * The optional wait parameter causes the lock call to block until all
- * pages can be locked if set.  If wait==0, the lock operation is
- * aborted if any locked pages are found and -EAGAIN is returned.
- */
-
-int lock_kiovec(int nr, struct kiobuf *iovec[], int wait)
-{
-	struct kiobuf *iobuf;
-	int i, j;
-	struct page *page, **ppage;
-	int doublepage = 0;
-	int repeat = 0;
-	
- repeat:
-	
-	for (i = 0; i < nr; i++) {
-		iobuf = iovec[i];
-
-		if (iobuf->locked)
-			continue;
-		iobuf->locked = 1;
-
-		ppage = iobuf->maplist;
-		for (j = 0; j < iobuf->nr_pages; ppage++, j++) {
-			page = *ppage;
-			if (!page)
-				continue;
-			
-			if (TryLockPage(page))
-				goto retry;
-		}
-	}
-
-	return 0;
-	
- retry:
-	
-	/* 
-	 * We couldn't lock one of the pages.  Undo the locking so far,
-	 * wait on the page we got to, and try again.  
-	 */
-	
-	unlock_kiovec(nr, iovec);
-	if (!wait)
-		return -EAGAIN;
-	
-	/* 
-	 * Did the release also unlock the page we got stuck on?
-	 */
-	if (!PageLocked(page)) {
-		/* 
-		 * If so, we may well have the page mapped twice
-		 * in the IO address range.  Bad news.  Of
-		 * course, it _might_ just be a coincidence,
-		 * but if it happens more than once, chances
-		 * are we have a double-mapped page. 
-		 */
-		if (++doublepage >= 3) 
-			return -EINVAL;
-		
-		/* Try again...  */
-		wait_on_page(page);
-	}
-	
-	if (++repeat < 16)
-		goto repeat;
-	return -EAGAIN;
-}
-
-/*
- * Unlock all of the pages of a kiovec after IO.
- */
-
-int unlock_kiovec(int nr, struct kiobuf *iovec[])
-{
-	struct kiobuf *iobuf;
-	int i, j;
-	struct page *page, **ppage;
-	
-	for (i = 0; i < nr; i++) {
-		iobuf = iovec[i];
-
-		if (!iobuf->locked)
-			continue;
-		iobuf->locked = 0;
-		
-		ppage = iobuf->maplist;
-		for (j = 0; j < iobuf->nr_pages; ppage++, j++) {
-			page = *ppage;
-			if (!page)
-				continue;
-			UnlockPage(page);
-		}
-	}
-	return 0;
-}
-
 static inline void zeromap_pte_range(pte_t * pte, unsigned long address,
                                      unsigned long size, pgprot_t prot)
 {

--ZwgA9U+XZDXt4+m+--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
