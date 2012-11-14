Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id AD5796B00AC
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:57:30 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 3/8] frontswap: Make frontswap_init use a pointer for the ops.
Date: Wed, 14 Nov 2012 13:57:07 -0500
Message-Id: <1352919432-9699-4-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

This simplifies the code in the frontswap - we can get rid
of the 'backend_registered' test and instead check against
frontswap_ops.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |    8 +++---
 drivers/staging/zcache/zcache-main.c  |    8 +++---
 drivers/xen/tmem.c                    |    6 ++--
 include/linux/frontswap.h             |    2 +-
 mm/frontswap.c                        |   34 +++++++++++++++-----------------
 5 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index a09dd5c..6c8959d 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -1626,9 +1626,9 @@ static struct frontswap_ops zcache_frontswap_ops = {
 	.init = zcache_frontswap_init
 };
 
-struct frontswap_ops zcache_frontswap_register_ops(void)
+struct frontswap_ops *zcache_frontswap_register_ops(void)
 {
-	struct frontswap_ops old_ops =
+	struct frontswap_ops *old_ops =
 		frontswap_register_ops(&zcache_frontswap_ops);
 
 	return old_ops;
@@ -1795,7 +1795,7 @@ static int __init zcache_init(void)
 			pr_warn("%s: cleancache_ops overridden\n", namestr);
 	}
 	if (zcache_enabled && !disable_frontswap) {
-		struct frontswap_ops old_ops;
+		struct frontswap_ops *old_ops;
 
 		old_ops = zcache_frontswap_register_ops();
 		if (frontswap_has_exclusive_gets)
@@ -1807,7 +1807,7 @@ static int __init zcache_init(void)
 			namestr, frontswap_has_exclusive_gets,
 			!disable_frontswap_ignore_nonactive);
 #endif
-		if (old_ops.init != NULL)
+		if (old_ops)
 			pr_warn("%s: frontswap_ops overridden\n", namestr);
 	}
 	if (ramster_enabled)
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 52b43b7..3db38cb 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1919,9 +1919,9 @@ static struct frontswap_ops zcache_frontswap_ops = {
 	.init = zcache_frontswap_init
 };
 
-struct frontswap_ops zcache_frontswap_register_ops(void)
+struct frontswap_ops *zcache_frontswap_register_ops(void)
 {
-	struct frontswap_ops old_ops =
+	struct frontswap_ops *old_ops =
 		frontswap_register_ops(&zcache_frontswap_ops);
 
 	return old_ops;
@@ -2061,12 +2061,12 @@ static int __init zcache_init(void)
 #endif
 #ifdef CONFIG_FRONTSWAP
 	if (zcache_enabled && use_frontswap) {
-		struct frontswap_ops old_ops;
+		struct frontswap_ops *old_ops;
 
 		old_ops = zcache_frontswap_register_ops();
 		pr_info("zcache: frontswap enabled using kernel "
 			"transcendent memory and zsmalloc\n");
-		if (old_ops.init != NULL)
+		if (old_ops)
 			pr_warning("zcache: frontswap_ops overridden");
 	}
 #endif
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
index ba58157..e73dd23 100644
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
@@ -90,28 +90,26 @@ static inline void inc_frontswap_invalidates(void) { }
  * ignored or fail.
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
-	/* We MUST have backend_registered called _after_ the frontswap_init's
+	/* We MUST have frontswap_ops set _after_ the frontswap_init's
  	 * have been called. Otherwise __frontswap_store might fail. */
 	barrier();
-	backend_registered = true;
+	frontswap_ops = ops;
 	return old;
 }
 EXPORT_SYMBOL(frontswap_register_ops);
@@ -141,11 +139,11 @@ void __frontswap_init(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (backend_registered) {
+	if (frontswap_ops) {
 		BUG_ON(sis == NULL);
 		if (sis->frontswap_map == NULL)
 			return;
-		(*frontswap_ops.init)(type);
+		frontswap_ops->init(type);
 	}
 	else {
 		BUG_ON(type > MAX_SWAPFILES);
@@ -176,7 +174,7 @@ int __frontswap_store(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
-	if (!backend_registered) {
+	if (!frontswap_ops) {
 		inc_frontswap_failed_stores();
 		return ret;
 	}
@@ -185,7 +183,7 @@ int __frontswap_store(struct page *page)
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		dup = 1;
-	ret = frontswap_ops.store(type, offset, page);
+	ret = frontswap_ops->store(type, offset, page);
 	if (ret == 0) {
 		frontswap_set(sis, offset);
 		inc_frontswap_succ_stores();
@@ -220,13 +218,13 @@ int __frontswap_load(struct page *page)
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
@@ -246,12 +244,12 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
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
@@ -266,11 +264,11 @@ void __frontswap_invalidate_area(unsigned type)
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
