Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 9BD486B0006
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:51:55 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ro8so5705221pbb.32
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 00:51:54 -0800 (PST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH V2 02/11] frontswap: Make frontswap_init use a pointer for the ops.
Date: Wed,  6 Mar 2013 16:51:21 +0800
Message-Id: <1362559890-16710-2-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com, Bob Liu <lliubbo@gmail.com>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

This simplifies the code in the frontswap - we can get rid
of the 'backend_registered' test and instead check against
frontswap_ops.

[v1: Rebase on top of 703ba7fe5e085f2c85eeb451c2ac13cf275c7cb2
(ramster->zcache move]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 drivers/staging/zcache/zcache-main.c |    8 +++----
 drivers/xen/tmem.c                   |    6 +++---
 include/linux/frontswap.h            |    2 +-
 mm/frontswap.c                       |   38 ++++++++++++++++------------------
 4 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 328898e..3365f59 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1825,9 +1825,9 @@ static struct frontswap_ops zcache_frontswap_ops = {
 	.init = zcache_frontswap_init
 };
 
-struct frontswap_ops zcache_frontswap_register_ops(void)
+struct frontswap_ops *zcache_frontswap_register_ops(void)
 {
-	struct frontswap_ops old_ops =
+	struct frontswap_ops *old_ops =
 		frontswap_register_ops(&zcache_frontswap_ops);
 
 	return old_ops;
@@ -1994,7 +1994,7 @@ static int __init zcache_init(void)
 			pr_warn("%s: cleancache_ops overridden\n", namestr);
 	}
 	if (zcache_enabled && !disable_frontswap) {
-		struct frontswap_ops old_ops;
+		struct frontswap_ops *old_ops;
 
 		old_ops = zcache_frontswap_register_ops();
 		if (frontswap_has_exclusive_gets)
@@ -2006,7 +2006,7 @@ static int __init zcache_init(void)
 			namestr, frontswap_has_exclusive_gets,
 			!disable_frontswap_ignore_nonactive);
 #endif
-		if (old_ops.init != NULL)
+		if (old_ops != NULL)
 			pr_warn("%s: frontswap_ops overridden\n", namestr);
 	}
 	if (ramster_enabled)
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 144564e..4b02c07 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -362,7 +362,7 @@ static int __init no_frontswap(char *s)
 }
 __setup("nofrontswap", no_frontswap);
 
-static struct frontswap_ops __initdata tmem_frontswap_ops = {
+static struct frontswap_ops tmem_frontswap_ops = {
 	.store = tmem_frontswap_store,
 	.load = tmem_frontswap_load,
 	.invalidate_page = tmem_frontswap_flush_page,
@@ -378,11 +378,11 @@ static int __init xen_tmem_init(void)
 #ifdef CONFIG_FRONTSWAP
 	if (tmem_enabled && use_frontswap) {
 		char *s = "";
-		struct frontswap_ops old_ops =
+		struct frontswap_ops *old_ops =
 			frontswap_register_ops(&tmem_frontswap_ops);
 
 		tmem_frontswap_poolid = -1;
-		if (old_ops.init != NULL)
+		if (old_ops)
 			s = " (WARNING: frontswap_ops overridden)";
 		printk(KERN_INFO "frontswap enabled, RAM provided by "
 				 "Xen Transcendent Memory\n");
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 3044254..d4f2987 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -14,7 +14,7 @@ struct frontswap_ops {
 };
 
 extern bool frontswap_enabled;
-extern struct frontswap_ops
+extern struct frontswap_ops *
 	frontswap_register_ops(struct frontswap_ops *ops);
 extern void frontswap_shrink(unsigned long);
 extern unsigned long frontswap_curr_pages(void);
diff --git a/mm/frontswap.c b/mm/frontswap.c
index cbd2b8a..e44c9cb 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -24,7 +24,7 @@
  * frontswap_ops is set by frontswap_register_ops to contain the pointers
  * to the frontswap "backend" implementation functions.
  */
-static struct frontswap_ops frontswap_ops __read_mostly;
+static struct frontswap_ops *frontswap_ops __read_mostly;
 
 /*
  * This global enablement flag reduces overhead on systems where frontswap_ops
@@ -108,41 +108,39 @@ static inline void inc_frontswap_invalidates(void) { }
  *
  * The time between the backend being registered and the swap file system
  * calling the backend (via the frontswap_* functions) is indeterminate as
- * backend_registered is not atomic_t (or a value guarded by a spinlock).
+ * frontswap_ops is not atomic_t (or a value guarded by a spinlock).
  * That is OK as we are comfortable missing some of these calls to the newly
  * registered backend.
  *
  * Obviously the opposite (unloading the backend) must be done after all
  * the frontswap_[store|load|invalidate_area|invalidate_page] start
- * ignorning or failing the requests - at which point backend_registered
+ * ignorning or failing the requests - at which point frontswap_ops
  * would have to be made in some fashion atomic.
  */
 static DECLARE_BITMAP(need_init, MAX_SWAPFILES);
-static bool backend_registered __read_mostly;
 
 /*
  * Register operations for frontswap, returning previous thus allowing
  * detection of multiple backends and possible nesting.
  */
-struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
+struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 {
-	struct frontswap_ops old = frontswap_ops;
+	struct frontswap_ops *old = frontswap_ops;
 	int i;
 
-	frontswap_ops = *ops;
 	frontswap_enabled = true;
 
 	for (i = 0; i < MAX_SWAPFILES; i++) {
 		if (test_and_clear_bit(i, need_init))
-			(*frontswap_ops.init)(i);
+			ops->init(i);
 	}
 	/*
-	 * We MUST have backend_registered set _after_ the frontswap_init's
+	 * We MUST have frontswap_ops set _after_ the frontswap_init's
 	 * have been called. Otherwise __frontswap_store might fail. Hence
 	 * the barrier to make sure compiler does not re-order us.
 	 */
 	barrier();
-	backend_registered = true;
+	frontswap_ops = ops;
 	return old;
 }
 EXPORT_SYMBOL(frontswap_register_ops);
@@ -172,11 +170,11 @@ void __frontswap_init(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (backend_registered) {
+	if (frontswap_ops) {
 		BUG_ON(sis == NULL);
 		if (sis->frontswap_map == NULL)
 			return;
-		(*frontswap_ops.init)(type);
+		frontswap_ops->init(type);
 	} else {
 		BUG_ON(type > MAX_SWAPFILES);
 		set_bit(type, need_init);
@@ -206,7 +204,7 @@ int __frontswap_store(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!backend_registered) {
+	if (!frontswap_ops) {
 		inc_frontswap_failed_stores();
 		return ret;
 	}
@@ -215,7 +213,7 @@ int __frontswap_store(struct page *page)
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		dup = 1;
-	ret = frontswap_ops.store(type, offset, page);
+	ret = frontswap_ops->store(type, offset, page);
 	if (ret == 0) {
 		frontswap_set(sis, offset);
 		inc_frontswap_succ_stores();
@@ -250,13 +248,13 @@ int __frontswap_load(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!backend_registered)
+	if (!frontswap_ops)
 		return ret;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
-		ret = frontswap_ops.load(type, offset, page);
+		ret = frontswap_ops->load(type, offset, page);
 	if (ret == 0) {
 		inc_frontswap_loads();
 		if (frontswap_tmem_exclusive_gets_enabled) {
@@ -276,12 +274,12 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (!backend_registered)
+	if (!frontswap_ops)
 		return;
 
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset)) {
-		frontswap_ops.invalidate_page(type, offset);
+		frontswap_ops->invalidate_page(type, offset);
 		__frontswap_clear(sis, offset);
 		inc_frontswap_invalidates();
 	}
@@ -296,11 +294,11 @@ void __frontswap_invalidate_area(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (backend_registered) {
+	if (frontswap_ops) {
 		BUG_ON(sis == NULL);
 		if (sis->frontswap_map == NULL)
 			return;
-		(*frontswap_ops.invalidate_area)(type);
+		frontswap_ops->invalidate_area(type);
 		atomic_set(&sis->frontswap_pages, 0);
 		memset(sis->frontswap_map, 0, sis->max / sizeof(long));
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
