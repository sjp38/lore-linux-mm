Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E664F6B0033
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 15:20:51 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 04/11] frontswap: Use static_key instead of frontswap_enabled and frontswap_ops
Date: Fri, 15 Feb 2013 15:20:28 -0500
Message-Id: <1360959635-18922-5-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
References: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, minchan@kernel.org
Cc: ric.masonn@gmail.com, lliubbo@gmail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

As ways to determine whether to allow certain functions to be called.
This makes it easier to understand the code - the two functions
that can be called irregardless whether a backend is set or not is
the frontswap_init and frontswap_invalidate_area. The rest of the
frontswap functions end up being NOPs if the backend has not yet
registered.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/frontswap.h | 17 ++++++++------
 mm/frontswap.c            | 58 ++++++++++++++++++++---------------------------
 2 files changed, 34 insertions(+), 41 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 140323b..8d24167 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -12,8 +12,6 @@ struct frontswap_ops {
 	void (*invalidate_page)(unsigned, pgoff_t);
 	void (*invalidate_area)(unsigned);
 };
-
-extern bool frontswap_enabled;
 extern struct frontswap_ops *
 	frontswap_register_ops(struct frontswap_ops *ops);
 extern void frontswap_shrink(unsigned long);
@@ -29,25 +27,30 @@ extern void __frontswap_invalidate_page(unsigned, pgoff_t);
 extern void __frontswap_invalidate_area(unsigned);
 
 #ifdef CONFIG_FRONTSWAP
+#include <linux/jump_label.h>
+
+extern struct static_key frontswap_key;
+
+#define frontswap_enabled (1)
 
 static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
 {
 	bool ret = false;
 
-	if (frontswap_enabled && sis->frontswap_map)
+	if (static_key_false(&frontswap_key) && sis->frontswap_map)
 		ret = test_bit(offset, sis->frontswap_map);
 	return ret;
 }
 
 static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
 {
-	if (frontswap_enabled && sis->frontswap_map)
+	if (static_key_false(&frontswap_key) && sis->frontswap_map)
 		set_bit(offset, sis->frontswap_map);
 }
 
 static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
 {
-	if (frontswap_enabled && sis->frontswap_map)
+	if (static_key_false(&frontswap_key) && sis->frontswap_map)
 		clear_bit(offset, sis->frontswap_map);
 }
 
@@ -94,7 +97,7 @@ static inline int frontswap_store(struct page *page)
 {
 	int ret = -1;
 
-	if (frontswap_enabled)
+	if (static_key_false(&frontswap_key))
 		ret = __frontswap_store(page);
 	return ret;
 }
@@ -103,7 +106,7 @@ static inline int frontswap_load(struct page *page)
 {
 	int ret = -1;
 
-	if (frontswap_enabled)
+	if (static_key_false(&frontswap_key))
 		ret = __frontswap_load(page);
 	return ret;
 }
diff --git a/mm/frontswap.c b/mm/frontswap.c
index b9b23b1..ebf4c18 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -27,13 +27,13 @@
 static struct frontswap_ops *frontswap_ops __read_mostly;
 
 /*
- * This global enablement flag reduces overhead on systems where frontswap_ops
- * has not been registered, so is preferred to the slower alternative: a
- * function call that checks a non-global.
+ * The key is enabled once a backend has registered itself. The key
+ * by default is set to false which means that all (except frontswap_init
+ * and frontswap_invalidate) calls are NOPs. Once the key is turned on
+ * all functions execute the __frontswap code.
  */
-bool frontswap_enabled __read_mostly;
-EXPORT_SYMBOL(frontswap_enabled);
-
+struct static_key frontswap_key = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL(frontswap_key);
 /*
  * If enabled, frontswap_store will return failure even on success.  As
  * a result, the swap subsystem will always write the page to swap, in
@@ -83,8 +83,8 @@ static inline void inc_frontswap_invalidates(void) { }
 
 /*
  * Due to the asynchronous nature of the backends loading potentially
- * _after_ the swap system has been activated, we have chokepoints
- * on all frontswap functions to not call the backend until the backend
+ * _after_ the swap system has been activated, we have a static key
+ * on all almost frontswap functions to not call the backend until the backend
  * has registered.
  *
  * Specifically when no backend is registered (nobody called
@@ -104,21 +104,19 @@ static inline void inc_frontswap_invalidates(void) { }
  * swapoff) is again guarded by the swap subsystem.
  *
  * While no backend is registered all calls to frontswap_[store|load|
- * invalidate_area|invalidate_page] are ignored or fail.
+ * invalidate_page] are never executed as the __frontswap_*
+ * macros are based on the key which is set to false
  *
  * The time between the backend being registered and the swap file system
- * calling the backend (via the frontswap_* functions) is indeterminate as
- * frontswap_ops is not atomic_t (or a value guarded by a spinlock).
- * That is OK as we are comfortable missing some of these calls to the newly
- * registered backend.
+ * calling the backend (via the frontswap_* functions) is instant as the
+ * static_key patches over the code in question.
  *
- * Obviously the opposite (unloading the backend) must be done after all
- * the frontswap_[store|load|invalidate_area|invalidate_page] start
- * ignorning or failing the requests - at which point frontswap_ops
- * would have to be made in some fashion atomic.
+ * Obviously the opposite (unloading the backend) can be done after the
+ * the frontswap_[store|load|invalidate_page] have been turned off so there
+ * are no more requests to process. The backend has to flush out all its
+ * pages back to the swap system after that.
  */
 static DECLARE_BITMAP(need_init, MAX_SWAPFILES);
-
 /*
  * Register operations for frontswap, returning previous thus allowing
  * detection of multiple backends and possible nesting.
@@ -128,8 +126,6 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 	struct frontswap_ops *old = frontswap_ops;
 	int i;
 
-	frontswap_enabled = true;
-
 	for (i = 0; i < MAX_SWAPFILES; i++) {
 		if (test_and_clear_bit(i, need_init))
 			ops->init(i);
@@ -141,6 +137,8 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 	 */
 	barrier();
 	frontswap_ops = ops;
+	if (!static_key_enabled(&frontswap_key))
+		static_key_slow_inc(&frontswap_key);
 	return old;
 }
 EXPORT_SYMBOL(frontswap_register_ops);
@@ -165,12 +163,14 @@ EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
 
 /*
  * Called when a swap device is swapon'd.
+ *
+ * Can be called without any backend driver is registered.
  */
 void __frontswap_init(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (frontswap_ops) {
+	if (static_key_false(&frontswap_key)) {
 		BUG_ON(sis == NULL);
 		if (sis->frontswap_map == NULL)
 			return;
@@ -205,11 +205,6 @@ int __frontswap_store(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!frontswap_ops) {
-		inc_frontswap_failed_stores();
-		return ret;
-	}
-
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
@@ -249,9 +244,6 @@ int __frontswap_load(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!frontswap_ops)
-		return ret;
-
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
@@ -275,9 +267,6 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (!frontswap_ops)
-		return;
-
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset)) {
 		frontswap_ops->invalidate_page(type, offset);
@@ -290,12 +279,14 @@ EXPORT_SYMBOL(__frontswap_invalidate_page);
 /*
  * Invalidate all data from frontswap associated with all offsets for the
  * specified swaptype.
+ *
+ * Can be called without any backend driver registered.
  */
 void __frontswap_invalidate_area(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (frontswap_ops) {
+	if (static_key_false(&frontswap_key)) {
 		BUG_ON(sis == NULL);
 		if (sis->frontswap_map == NULL)
 			return;
@@ -436,7 +427,6 @@ static int __init init_frontswap(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
-	frontswap_enabled = 1;
 	return 0;
 }
 
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
