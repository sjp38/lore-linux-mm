Date: Tue, 15 May 2007 22:33:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Do our own flags based on PG_active and PG_error
Message-ID: <Pine.LNX.4.64.0705152231200.5545@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The atomicity when handling flags in SLUB is not necessary since both 
flags used by SLUB are not updated in a racy way. Flag updates are either 
done during slab creation or destruction or under slab_lock. Some of these
flags do not have the non atomic variants that we need. So define our own.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-15 21:22:25.000000000 -0700
+++ slub/mm/slub.c	2007-05-15 21:25:09.000000000 -0700
@@ -99,42 +99,42 @@
  * 			the fast path and disables lockless freelists.
  */
 
+#define FROZEN (1 << PG_active)
+
+#ifdef CONFIG_SLUB_DEBUG
+#define SLABDEBUG (1 << PG_error)
+#else
+#define SLABDEBUG 0
+#endif
+
 static inline int SlabFrozen(struct page *page)
 {
-	return PageActive(page);
+	return page->flags & FROZEN;
 }
 
 static inline void SetSlabFrozen(struct page *page)
 {
-	SetPageActive(page);
+	page->flags |= FROZEN;
 }
 
 static inline void ClearSlabFrozen(struct page *page)
 {
-	ClearPageActive(page);
+	page->flags &= ~FROZEN;
 }
 
 static inline int SlabDebug(struct page *page)
 {
-#ifdef CONFIG_SLUB_DEBUG
-	return PageError(page);
-#else
-	return 0;
-#endif
+	return page->flags & SLABDEBUG;
 }
 
 static inline void SetSlabDebug(struct page *page)
 {
-#ifdef CONFIG_SLUB_DEBUG
-	SetPageError(page);
-#endif
+	page->flags |= SLABDEBUG;
 }
 
 static inline void ClearSlabDebug(struct page *page)
 {
-#ifdef CONFIG_SLUB_DEBUG
-	ClearPageError(page);
-#endif
+	page->flags &= ~SLABDEBUG;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
