From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:38:33 +0200
Message-Id: <20060712143833.16998.19358.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 8/39] mm: pgrep: move useful macros around
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

move macro's out of vmscan into the generic page replace header so the
rest of the world can use them too.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h |   30 ++++++++++++++++++++++++++++++
 mm/vmscan.c                     |   30 ------------------------------
 2 files changed, 30 insertions(+), 30 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:52.000000000 +0200
@@ -8,6 +8,36 @@
 #include <linux/pagevec.h>
 #include <linux/mm_inline.h>
 
+#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
+
+#ifdef ARCH_HAS_PREFETCH
+#define prefetch_prev_lru_page(_page, _base, _field)			\
+	do {								\
+		if ((_page)->lru.prev != _base) {			\
+			struct page *prev;				\
+									\
+			prev = lru_to_page(&(_page->lru));		\
+			prefetch(&prev->_field);			\
+		}							\
+	} while (0)
+#else
+#define prefetch_prev_lru_page(_page, _base, _field) do { } while (0)
+#endif
+
+#ifdef ARCH_HAS_PREFETCHW
+#define prefetchw_prev_lru_page(_page, _base, _field)			\
+	do {								\
+		if ((_page)->lru.prev != _base) {			\
+			struct page *prev;				\
+									\
+			prev = lru_to_page(&(_page->lru));		\
+			prefetchw(&prev->_field);			\
+		}							\
+	} while (0)
+#else
+#define prefetchw_prev_lru_page(_page, _base, _field) do { } while (0)
+#endif
+
 /* void pgrep_hint_active(struct page *); */
 /* void pgrep_hint_use_once(struct page *); */
 extern void fastcall pgrep_add(struct page *);
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:52.000000000 +0200
@@ -77,36 +77,6 @@ struct shrinker {
 	long			nr;	/* objs pending delete */
 };
 
-#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
-
-#ifdef ARCH_HAS_PREFETCH
-#define prefetch_prev_lru_page(_page, _base, _field)			\
-	do {								\
-		if ((_page)->lru.prev != _base) {			\
-			struct page *prev;				\
-									\
-			prev = lru_to_page(&(_page->lru));		\
-			prefetch(&prev->_field);			\
-		}							\
-	} while (0)
-#else
-#define prefetch_prev_lru_page(_page, _base, _field) do { } while (0)
-#endif
-
-#ifdef ARCH_HAS_PREFETCHW
-#define prefetchw_prev_lru_page(_page, _base, _field)			\
-	do {								\
-		if ((_page)->lru.prev != _base) {			\
-			struct page *prev;				\
-									\
-			prev = lru_to_page(&(_page->lru));		\
-			prefetchw(&prev->_field);			\
-		}							\
-	} while (0)
-#else
-#define prefetchw_prev_lru_page(_page, _base, _field) do { } while (0)
-#endif
-
 /*
  * From 0 .. 100.  Higher means more swappy.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
