From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20060322223218.12658.40531.sendpatchset@twins.localnet>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Subject: [PATCH 07/34] mm: page-replace-move-macros.patch
Date: Wed, 22 Mar 2006 23:32:50 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

move macro's out of vmscan into the generic page replace header so the
rest of the world can use them too.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

---

 include/linux/mm_page_replace.h |   30 ++++++++++++++++++++++++++++++
 mm/vmscan.c                     |   30 ------------------------------
 2 files changed, 30 insertions(+), 30 deletions(-)

Index: linux-2.6-git/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_page_replace.h
+++ linux-2.6-git/include/linux/mm_page_replace.h
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
 /* void page_replace_hint_active(struct page *); */
 /* void page_replace_hint_use_once(struct page *); */
 extern void fastcall page_replace_add(struct page *);
Index: linux-2.6-git/mm/vmscan.c
===================================================================
--- linux-2.6-git.orig/mm/vmscan.c
+++ linux-2.6-git/mm/vmscan.c
@@ -93,36 +93,6 @@ struct shrinker {
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
