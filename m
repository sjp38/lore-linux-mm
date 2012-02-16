Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 2BDCF6B0092
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:50 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 03/18] Compound read / write locking aka get / put.
Date: Thu, 16 Feb 2012 15:31:30 +0100
Message-Id: <1329402705-25454-3-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Adds compound usage count for pages of higher order. This change is
required to add faster locking techniques then compound_lock, and to
prevents dead locks during operating on compound page.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/mm.h       |  127 +++++++++++++++++++++++++++++++++++++++++++---
 include/linux/mm_types.h |   15 +++++-
 mm/page_alloc.c          |    4 +-
 mm/swap.c                |   58 +++++++++++++++++++--
 4 files changed, 191 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bacb023..72f6a50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -284,6 +284,126 @@ static inline void compound_unlock(struct page *page)
 #endif
 }
 
+static inline int compound_order(struct page *page)
+{
+	if (!PageHead(page))
+		return 0;
+	return (unsigned long)page[1]._compound_order;
+}
+
+/** Get's usage count for compound page.
+ * This involves compound_lock, so do not call it having compound lock
+ * raised.
+ * @return 1 - success, 0 - page was splitted.
+ */
+static inline int compound_get(struct page *head)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(PageTail(head));
+repeat:
+	if (!PageHead(head))
+		return 0;
+
+	VM_BUG_ON(!atomic_read(&head->_count));
+	VM_BUG_ON(compound_order(head) < 2);
+
+	compound_lock(head);
+	if (unlikely(!PageHead(head))) {
+		compound_unlock(head);
+		return 0;
+	}
+
+	if (atomic_inc_not_zero(&head[2]._compound_usage)) {
+		compound_unlock(head);
+		return 1;
+	} else {
+		compound_unlock(head);
+		goto repeat;
+	}
+#else
+	return 0;
+#endif
+}
+
+/** Decrases compound usage count.
+ * This involves compound_lock, so do not call it having compound lock
+ * raised.
+ */
+extern void compound_put(struct page *head);
+
+
+
+/** Tries to freeze compound page. If upgrade_lock is true function tries to
+ * <b>exchange</b> page "gotten" to "forozen" (so after unfreeze page will be
+ * "not used"), caller must have page excatly once. If upgrade_lock is false
+ * then page must be "not gotten".
+ *
+ * @return 0 - success, -1 splitted, 1 - can't freez, but not splitted
+ */
+static inline int compound_try_freeze(struct page *head, int upgrade_lock)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	int expected_usage;
+
+	VM_BUG_ON(PageTail(head));
+	VM_BUG_ON(compound_order(head) < 2);
+	VM_BUG_ON(!atomic_read(&head->_count));
+	VM_BUG_ON(upgrade_lock && atomic_read(&head[2]._compound_usage) == 1);
+
+	if (!PageHead(head))
+		return 0;
+
+	compound_lock(head);
+	if (!upgrade_lock) {
+		/* Not needed. Page is gotten so no split, GCC will make this
+		 * faster.
+		 */
+		if (unlikely(!PageHead(head))) {
+			return -1;
+		}
+	}
+
+	expected_usage = upgrade_lock ? 2 : 1;
+	if (atomic_cmpxchg(&head[2]._compound_usage, expected_usage, 0) == 1) {
+		compound_unlock(head);
+		return 0;
+	} else {
+		compound_unlock(head);
+		return 1;
+	}
+#else
+	return 0;
+#endif
+}
+
+/** Freeze compound page (like write barrier.
+ * This involves compound_lock, so do not call it having compound lock
+ * raised.
+ *
+ * @return 1 - success, 0 - page was splitted.
+ */
+static inline int compound_freeze(struct page *head)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+repeat:
+	switch (compound_try_freeze(head, false)) {
+	case 0:
+		return 1;
+	case -1:
+		return 0;
+	default:
+		goto repeat;
+	}
+#else
+	return 1;
+#endif
+}
+
+/** Unfreezes compound page.
+ * Do not call this after you splitted page or you may corrupt memory.
+ */
+extern void compound_unfreeze(struct page *head);
+
 /** Gets head of compound page. If page is no longer head returns {@code page}.
  * This function involves makes memory barrier to ensure page was not splitted.
  */
@@ -485,13 +605,6 @@ static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 	 return page[1]._dtor;
 }
 
-static inline int compound_order(struct page *page)
-{
-	if (!PageHead(page))
-		return 0;
-	return (unsigned long)page[1]._compound_order;
-}
-
 static inline int compound_trans_order(struct page *page)
 {
 	int order;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 05fefae..7649722 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -117,7 +117,8 @@ struct page {
 				 * address 64L. So if we will see here value
 				 * less then 64L we are sure it's 2nd page of
 				 * compound (so first page is "this - 1").
-				 * <b>Valid only on 3rd and next elements</b>
+				 * <b>Valid only on 3rd and next elements,
+				 * head[2], head[3]...</b>
 				 */
 				struct page *__first_page;
 			};
@@ -131,6 +132,18 @@ struct page {
 				 */
 				compound_page_dtor *_dtor;
 
+				/** Usage count of compound page "as whole".
+				 * This is rather split barrier then something
+				 * usefull. Compound page with order greater
+				 * then 1 should start with this value setted to
+				 * {@code 1} - mean no lock, locking page for
+				 * reading is obtained by bumping lock if not
+				 * zero, locking for splitting by setting it
+				 * to zero when value of counter is {@code 1}.
+				 * <b>Valid only on 3rd element (head[2])</b>
+				 */
+				atomic_t _compound_usage;
+
 				/** Number of pages in compound page(including
 				 * head and tails) that are used (having
 				 * {@code _count > 0}). If this number fell to
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b48e313..bbdd94e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -357,8 +357,10 @@ void prep_compound_page(struct page *page, unsigned long order)
 	/* Order, dtor was replaced in for loop, set it correctly. */
 	set_compound_order(page, order);
 	set_compound_page_dtor(page, free_compound_page);
-	if (order > 1)
+	if (order > 1) {
 		atomic_set(&page[3]._tail_count, 0);
+		atomic_set(&page[2]._compound_usage, 1);
+	}
 }
 
 /* update __split_huge_page_refcount if you change this function */
diff --git a/mm/swap.c b/mm/swap.c
index 365363c..ded81c9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -104,10 +104,17 @@ int put_compound_head(struct page *head)
 		 *    __recover_page bumps if head->_count > 0, then at this
 		 *    point head->_count will be 1 - contradiction.
 		 */
-		if (PageCompound(head))
-			__free_compound_page(head);
-		else
+		smp_rmb();
+		if (PageCompound(head)) {
+			if (compound_order(head) > 1) {
+				if (atomic_read(&head[2]._compound_usage) == 1)
+					__free_compound_page(head);
+			} else {
+				__free_compound_page(head);
+			}
+		} else {
 			__put_single_page(head);
+		}
 		return 1;
 	}
 	return 0;
@@ -173,7 +180,9 @@ int put_compound_tail(struct page *page)
 				VM_BUG_ON(!atomic_read(&head->_count));
 
 				/* and this one for get_page_unless_zero(head)*/
-				if (atomic_dec_and_test(&head->_count)) {
+				if (atomic_dec_and_test(&head->_count) &&
+					(atomic_read(&head[2]._compound_usage)
+									== 1)) {
 					/* Putted last ref - now noone may get
 					* head. Details in put_compound_head
 					*/
@@ -201,6 +210,47 @@ int put_compound_tail(struct page *page)
 }
 EXPORT_SYMBOL(put_compound_tail);
 
+extern void compound_put(struct page *head)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(PageTail(head));
+	/* Bug if page was splitted. */
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(!atomic_read(&head[2]._compound_usage));
+	VM_BUG_ON(compound_order(head) < 2);
+	compound_lock(head);
+	if (atomic_add_return(-1, &head[2]._compound_usage) == 1) {
+		if (!atomic_read(&head->_count)) {
+			compound_unlock(head);
+			__free_compound_page(head);
+		}
+	}
+	compound_unlock(head);
+#endif
+}
+
+extern void compound_unfreeze(struct page *head)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(PageTail(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage));
+	VM_BUG_ON(compound_order(head) < 2);
+
+	/* It's quite important to check during "experimental" phase if page is
+	 * unfrozen on splitted page (the counter overlaps lru, so this may
+	 * cause problems.
+	 */
+	BUG_ON(!PageCompound(head));
+	compound_lock(head);
+	atomic_set(&head[2]._compound_usage, 1);
+	if (!atomic_read(&head->_count)) {
+		compound_unlock(head);
+		__free_compound_page(head);
+	}
+	compound_unlock(head);
+#endif
+}
+
 void put_page(struct page *page)
 {
 	if (unlikely(PageCompound(page))) {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
