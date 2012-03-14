Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 06A276B007E
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 13:14:36 -0400 (EDT)
From: Andor Daam <andor.daam@googlemail.com>
Subject: [PATCH 1/2] frontswap: allow backends to register after frontswap initilization
Date: Wed, 14 Mar 2012 18:13:27 +0100
Message-Id: <1331745208-1010-2-git-send-email-andor.daam@googlemail.com>
In-Reply-To: <1331745208-1010-1-git-send-email-andor.daam@googlemail.com>
References: <1331745208-1010-1-git-send-email-andor.daam@googlemail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, ilendir@googlemail.com, konrad.wilk@oracle.com, fschmaus@gmail.com, i4passt@lists.informatik.uni-erlangen.de, ngupta@vflare.org, Andor Daam <andor.daam@googlemail.com>

This patch allows backends to register to frontswap even after
swapon was run. Before a backend registers all calls to init are
recorded and the creation of tmem_pools delayed until a backend
registers.

Sigend-off-by: Stefan Hengelein <ilendir@googlemail.com>
Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
Sigend-off-by: Andor Daam <andor.daam@googlemail.com>
---
 mm/frontswap.c |   72 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 63 insertions(+), 9 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 2b80c5a..209487b 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -49,15 +49,33 @@ static u64 frontswap_failed_puts;
 static u64 frontswap_invalidates;
 
 /*
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
+/*
  * Register operations for frontswap, returning previous thus allowing
  * detection of multiple backends and possible nesting
  */
 struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
 {
 	struct frontswap_ops old = frontswap_ops;
+	int i;
 
 	frontswap_ops = *ops;
-	frontswap_enabled = 1;
+
+	backend_registered = 1;
+	for (i = 0; i < MAX_INITIALIZABLE_SD; i++) {
+		if (sds[i] != -1)
+			(*frontswap_ops.init)(sds[i]);
+	}
 	return old;
 }
 EXPORT_SYMBOL(frontswap_register_ops);
@@ -66,12 +84,21 @@ EXPORT_SYMBOL(frontswap_register_ops);
 void __frontswap_init(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
+	int i;
 
 	BUG_ON(sis == NULL);
 	if (sis->frontswap_map == NULL)
 		return;
-	if (frontswap_enabled)
-		(*frontswap_ops.init)(type);
+	if (frontswap_enabled) {
+		if (backend_registered)
+			(*frontswap_ops.init)(type);
+		for (i = 0; i < MAX_INITIALIZABLE_SD; i++) {
+			if (sds[i] == -1) {
+				sds[i] = type;
+				break;
+			}
+		}
+	}
 }
 EXPORT_SYMBOL(__frontswap_init);
 
@@ -90,6 +117,11 @@ int __frontswap_put_page(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
+	if (!backend_registered) {
+		frontswap_failed_puts++;
+		return ret;
+	}
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
@@ -127,12 +159,16 @@ int __frontswap_get_page(struct page *page)
 	struct swap_info_struct *sis = swap_info[type];
 	pgoff_t offset = swp_offset(entry);
 
+	if (!backend_registered)
+		return ret;
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		ret = (*frontswap_ops.get_page)(type, offset, page);
 	if (ret == 0)
 		frontswap_gets++;
+
 	return ret;
 }
 EXPORT_SYMBOL(__frontswap_get_page);
@@ -145,6 +181,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
+	if (!backend_registered)
+		return;
+
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset)) {
 		(*frontswap_ops.invalidate_page)(type, offset);
@@ -162,13 +201,23 @@ EXPORT_SYMBOL(__frontswap_invalidate_page);
 void __frontswap_invalidate_area(unsigned type)
 {
 	struct swap_info_struct *sis = swap_info[type];
+	int i;
 
-	BUG_ON(sis == NULL);
-	if (sis->frontswap_map == NULL)
-		return;
-	(*frontswap_ops.invalidate_area)(type);
-	atomic_set(&sis->frontswap_pages, 0);
-	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
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
 
@@ -255,6 +304,7 @@ EXPORT_SYMBOL(frontswap_curr_pages);
 static int __init init_frontswap(void)
 {
 	int err = 0;
+	int i;
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *root = debugfs_create_dir("frontswap", NULL);
@@ -267,6 +317,10 @@ static int __init init_frontswap(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
+	for (i = 0; i < MAX_INITIALIZABLE_SD; i++)
+		sds[i] = -1;
+
+	frontswap_enabled = 1;
 	return err;
 }
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
