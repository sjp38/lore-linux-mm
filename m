Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 3BB1C6B0035
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:52:04 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id rr4so5672945pbb.41
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 00:52:03 -0800 (PST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH V2 03/11] mm: frontswap: cleanup code
Date: Wed,  6 Mar 2013 16:51:22 +0800
Message-Id: <1362559890-16710-3-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com, Bob Liu <lliubbo@gmail.com>

After allowing tmem backends to build/run as modules, frontswap_enabled always
true if defined CONFIG_FRONTSWAP.
But frontswap_test() depends on whether backend is registered, mv it into
frontswap.c using fronstswap_ops to make the decision.

frontswap_set/clear are not used outside frontswap, so don't export them.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 include/linux/frontswap.h |   28 +++-------------------
 mm/frontswap.c            |   57 ++++++++++++++++++++++++---------------------
 2 files changed, 33 insertions(+), 52 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index d4f2987..6c49e1e 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -22,6 +22,7 @@ extern void frontswap_writethrough(bool);
 #define FRONTSWAP_HAS_EXCLUSIVE_GETS
 extern void frontswap_tmem_exclusive_gets(bool);
 
+extern bool __frontswap_test(struct swap_info_struct *, pgoff_t);
 extern void __frontswap_init(unsigned type);
 extern int __frontswap_store(struct page *page);
 extern int __frontswap_load(struct page *page);
@@ -29,26 +30,11 @@ extern void __frontswap_invalidate_page(unsigned, pgoff_t);
 extern void __frontswap_invalidate_area(unsigned);
 
 #ifdef CONFIG_FRONTSWAP
+#define frontswap_enabled (1)
 
 static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
 {
-	bool ret = false;
-
-	if (frontswap_enabled && sis->frontswap_map)
-		ret = test_bit(offset, sis->frontswap_map);
-	return ret;
-}
-
-static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
-{
-	if (frontswap_enabled && sis->frontswap_map)
-		set_bit(offset, sis->frontswap_map);
-}
-
-static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
-{
-	if (frontswap_enabled && sis->frontswap_map)
-		clear_bit(offset, sis->frontswap_map);
+	return __frontswap_test(sis, offset);
 }
 
 static inline void frontswap_map_set(struct swap_info_struct *p,
@@ -71,14 +57,6 @@ static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
 	return false;
 }
 
-static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
-{
-}
-
-static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
-{
-}
-
 static inline void frontswap_map_set(struct swap_info_struct *p,
 				     unsigned long *map)
 {
diff --git a/mm/frontswap.c b/mm/frontswap.c
index e44c9cb..2760b0f 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -27,14 +27,6 @@
 static struct frontswap_ops *frontswap_ops __read_mostly;
 
 /*
- * This global enablement flag reduces overhead on systems where frontswap_ops
- * has not been registered, so is preferred to the slower alternative: a
- * function call that checks a non-global.
- */
-bool frontswap_enabled __read_mostly;
-EXPORT_SYMBOL(frontswap_enabled);
-
-/*
  * If enabled, frontswap_store will return failure even on success.  As
  * a result, the swap subsystem will always write the page to swap, in
  * effect converting frontswap into a writethrough cache.  In this mode,
@@ -128,8 +120,6 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 	struct frontswap_ops *old = frontswap_ops;
 	int i;
 
-	frontswap_enabled = true;
-
 	for (i = 0; i < MAX_SWAPFILES; i++) {
 		if (test_and_clear_bit(i, need_init))
 			ops->init(i);
@@ -183,9 +173,21 @@ void __frontswap_init(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_init);
 
-static inline void __frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+bool __frontswap_test(struct swap_info_struct *sis,
+				pgoff_t offset)
+{
+	bool ret = false;
+
+	if (frontswap_ops && sis->frontswap_map)
+		ret = test_bit(offset, sis->frontswap_map);
+	return ret;
+}
+EXPORT_SYMBOL(__frontswap_test);
+
+static inline void __frontswap_clear(struct swap_info_struct *sis,
+				pgoff_t offset)
 {
-	frontswap_clear(sis, offset);
+	clear_bit(offset, sis->frontswap_map);
 	atomic_dec(&sis->frontswap_pages);
 }
 
@@ -204,18 +206,20 @@ int __frontswap_store(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!frontswap_ops) {
-		inc_frontswap_failed_stores();
+	/*
+	 * Return if no backend registed.
+	 * Don't need to inc frontswap_failed_stores here.
+	 */
+	if (!frontswap_ops)
 		return ret;
-	}
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
-	if (frontswap_test(sis, offset))
+	if (__frontswap_test(sis, offset))
 		dup = 1;
 	ret = frontswap_ops->store(type, offset, page);
 	if (ret == 0) {
-		frontswap_set(sis, offset);
+		set_bit(offset, sis->frontswap_map);
 		inc_frontswap_succ_stores();
 		if (!dup)
 			atomic_inc(&sis->frontswap_pages);
@@ -248,18 +252,18 @@ int __frontswap_load(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!frontswap_ops)
-		return ret;
-
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
-	if (frontswap_test(sis, offset))
+	/*
+	 * __frontswap_test() will check whether there is backend registered
+	 */
+	if (__frontswap_test(sis, offset))
 		ret = frontswap_ops->load(type, offset, page);
 	if (ret == 0) {
 		inc_frontswap_loads();
 		if (frontswap_tmem_exclusive_gets_enabled) {
 			SetPageDirty(page);
-			frontswap_clear(sis, offset);
+			__frontswap_clear(sis, offset);
 		}
 	}
 	return ret;
@@ -274,11 +278,11 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (!frontswap_ops)
-		return;
-
 	BUG_ON(sis == NULL);
-	if (frontswap_test(sis, offset)) {
+	/*
+	 * __frontswap_test() will check whether there is backend registered
+	 */
+	if (__frontswap_test(sis, offset)) {
 		frontswap_ops->invalidate_page(type, offset);
 		__frontswap_clear(sis, offset);
 		inc_frontswap_invalidates();
@@ -435,7 +439,6 @@ static int __init init_frontswap(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
-	frontswap_enabled = 1;
 	return 0;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
