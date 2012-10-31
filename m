Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id CC91D6B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:08:03 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem backends to build/run as modules
Date: Wed, 31 Oct 2012 08:07:51 -0700
Message-Id: <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com, fschmaus@gmail.com, andor.damm@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
built/loaded as modules rather than built-in and enabled by a boot parameter,
this patch provides "lazy initialization", allowing backends to register to
frontswap even after swapon was run. Before a backend registers all calls
to init are recorded and the creation of tmem_pools delayed until a backend
registers or until a frontswap put is attempted.

Signed-off-by: Stefan Hengelein <ilendir@googlemail.com>
Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
Signed-off-by: Andor Daam <andor.daam@googlemail.com>
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 include/linux/frontswap.h |    1 +
 mm/frontswap.c            |   70 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 63 insertions(+), 8 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 3044254..ef6ada6 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -23,6 +23,7 @@ extern void frontswap_writethrough(bool);
 extern void frontswap_tmem_exclusive_gets(bool);
 
 extern void __frontswap_init(unsigned type);
+#define FRONTSWAP_HAS_LAZY_INIT
 extern int __frontswap_store(struct page *page);
 extern int __frontswap_load(struct page *page);
 extern void __frontswap_invalidate_page(unsigned, pgoff_t);
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 2890e67..523a19b 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -80,6 +80,19 @@ static inline void inc_frontswap_succ_stores(void) { }
 static inline void inc_frontswap_failed_stores(void) { }
 static inline void inc_frontswap_invalidates(void) { }
 #endif
+
+/*
+ * When no backend is registered all calls to init are registered and
+ * remembered but fail to create tmem_pools. When a backend registers with
+ * frontswap the previous calls to init are executed to create tmem_pools
+ * and set the respective poolids.
+ * While no backend is registered all "puts", "gets" and "flushes" are
+ * ignored or fail.
+ */
+#define MAX_INITIALIZABLE_SD 32
+static int sds[MAX_INITIALIZABLE_SD];
+static int backend_registered;
+
 /*
  * Register operations for frontswap, returning previous thus allowing
  * detection of multiple backends and possible nesting.
@@ -87,9 +100,16 @@ static inline void inc_frontswap_invalidates(void) { }
 struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
 {
 	struct frontswap_ops old = frontswap_ops;
+	int i;
 
 	frontswap_ops = *ops;
 	frontswap_enabled = true;
+
+	backend_registered = 1;
+	for (i = 0; i < MAX_INITIALIZABLE_SD; i++) {
+		if (sds[i] != -1)
+			(*frontswap_ops.init)(sds[i]);
+	}
 	return old;
 }
 EXPORT_SYMBOL(frontswap_register_ops);
@@ -122,7 +142,10 @@ void __frontswap_init(unsigned type)
 	BUG_ON(sis == NULL);
 	if (sis->frontswap_map == NULL)
 		return;
-	frontswap_ops.init(type);
+	if (backend_registered) {
+		(*frontswap_ops.init)(type);
+		sds[type] = type;
+	}
 }
 EXPORT_SYMBOL(__frontswap_init);
 
@@ -147,10 +170,20 @@ int __frontswap_store(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
+	if (!backend_registered) {
+		inc_frontswap_failed_stores();
+		return ret;
+	}
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		dup = 1;
+	if (type < MAX_INITIALIZABLE_SD && sds[type] == -1) {
+		/* lazy init call to handle post-boot insmod backends*/
+		(*frontswap_ops.init)(type);
+		sds[type] = type;
+	}
 	ret = frontswap_ops.store(type, offset, page);
 	if (ret == 0) {
 		frontswap_set(sis, offset);
@@ -186,6 +219,9 @@ int __frontswap_load(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
+	if (!backend_registered)
+		return ret;
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
@@ -209,6 +245,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
+	if (!backend_registered)
+		return;
+
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset)) {
 		frontswap_ops.invalidate_page(type, offset);
@@ -225,13 +264,23 @@ EXPORT_SYMBOL(__frontswap_invalidate_page);
 void __frontswap_invalidate_area(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
-
-	BUG_ON(sis == NULL);
-	if (sis->frontswap_map == NULL)
-		return;
-	frontswap_ops.invalidate_area(type);
-	atomic_set(&sis->frontswap_pages, 0);
-	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+	int i;
+
+	if (backend_registered) {
+		BUG_ON(sis == NULL);
+		if (sis->frontswap_map == NULL)
+			return;
+		(*frontswap_ops.invalidate_area)(type);
+		atomic_set(&sis->frontswap_pages, 0);
+		memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+	} else {
+		for (i = 0; i < MAX_INITIALIZABLE_SD; i++) {
+			if (sds[i] == type) {
+				sds[i] = -1;
+				break;
+			}
+		}
+	}
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
@@ -353,6 +402,7 @@ EXPORT_SYMBOL(frontswap_curr_pages);
 
 static int __init init_frontswap(void)
 {
+	int i;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *root = debugfs_create_dir("frontswap", NULL);
 	if (root == NULL)
@@ -364,6 +414,10 @@ static int __init init_frontswap(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
+	for (i = 0; i < MAX_INITIALIZABLE_SD; i++)
+		sds[i] = -1;
+
+	frontswap_enabled = 1;
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
