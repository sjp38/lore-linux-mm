Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9327A6B00AB
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:57:29 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 2/8] mm: frontswap: lazy initialization to allow tmem backends to build/run as modules
Date: Wed, 14 Nov 2012 13:57:06 -0500
Message-Id: <1352919432-9699-3-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

From: Dan Magenheimer <dan.magenheimer@oracle.com>

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
[v1: Fixes per Seth Jennings suggestions]
[v2: Removed FRONTSWAP_HAS_.. ]
[v3: Fix up per Bob Liu <lliubbo@gmail.com> recommendations]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 mm/frontswap.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 56 insertions(+), 10 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 2890e67..ba58157 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -80,6 +80,18 @@ static inline void inc_frontswap_succ_stores(void) { }
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
+static DECLARE_BITMAP(need_init, MAX_SWAPFILES);
+static bool backend_registered __read_mostly;
+
 /*
  * Register operations for frontswap, returning previous thus allowing
  * detection of multiple backends and possible nesting.
@@ -87,9 +99,19 @@ static inline void inc_frontswap_invalidates(void) { }
 struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
 {
 	struct frontswap_ops old = frontswap_ops;
+	int i;
 
 	frontswap_ops = *ops;
 	frontswap_enabled = true;
+
+	for (i = 0; i < MAX_SWAPFILES; i++) {
+		if (test_and_clear_bit(i, need_init))
+			(*frontswap_ops.init)(i);
+	}
+	/* We MUST have backend_registered called _after_ the frontswap_init's
+ 	 * have been called. Otherwise __frontswap_store might fail. */
+	barrier();
+	backend_registered = true;
 	return old;
 }
 EXPORT_SYMBOL(frontswap_register_ops);
@@ -119,10 +141,17 @@ void __frontswap_init(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	BUG_ON(sis == NULL);
-	if (sis->frontswap_map == NULL)
-		return;
-	frontswap_ops.init(type);
+	if (backend_registered) {
+		BUG_ON(sis == NULL);
+		if (sis->frontswap_map == NULL)
+			return;
+		(*frontswap_ops.init)(type);
+	}
+	else {
+		BUG_ON(type > MAX_SWAPFILES);
+		set_bit(type, need_init);
+	}
+
 }
 EXPORT_SYMBOL(__frontswap_init);
 
@@ -147,6 +176,11 @@ int __frontswap_store(struct page *page)
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
@@ -186,6 +220,9 @@ int __frontswap_load(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
+	if (!backend_registered)
+		return ret;
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
@@ -209,6 +246,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
+	if (!backend_registered)
+		return;
+
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset)) {
 		frontswap_ops.invalidate_page(type, offset);
@@ -226,12 +266,15 @@ void __frontswap_invalidate_area(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	BUG_ON(sis == NULL);
-	if (sis->frontswap_map == NULL)
-		return;
-	frontswap_ops.invalidate_area(type);
-	atomic_set(&sis->frontswap_pages, 0);
-	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+	if (backend_registered) {
+		BUG_ON(sis == NULL);
+		if (sis->frontswap_map == NULL)
+			return;
+		(*frontswap_ops.invalidate_area)(type);
+		atomic_set(&sis->frontswap_pages, 0);
+		memset(sis->frontswap_map, 0, sis->max / sizeof(long));
+	}
+	clear_bit(type, need_init);
 }
 EXPORT_SYMBOL(__frontswap_invalidate_area);
 
@@ -364,6 +407,9 @@ static int __init init_frontswap(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
+	bitmap_zero(need_init, MAX_SWAPFILES);
+
+	frontswap_enabled = 1;
 	return 0;
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
