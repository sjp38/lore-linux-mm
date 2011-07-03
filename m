Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 590A26B0083
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 09:58:41 -0400 (EDT)
Received: by pzk4 with SMTP id 4so842635pzk.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 06:58:38 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 6/7] fail_page_alloc: simplify debugfs initialization
Date: Sun,  3 Jul 2011 22:59:47 +0900
Message-Id: <1309701588-16588-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1309701588-16588-1-git-send-email-akinobu.mita@gmail.com>
References: <1309701588-16588-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-mm@kvack.org

Now cleanup_fault_attr_dentries() recursively removes a directory,
So we can simplify the error handling in the initialization code
and no need to hold dentry structs for each debugfs file.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-mm@kvack.org
---
 mm/page_alloc.c |   47 ++++++++++++++++-------------------------------
 1 files changed, 16 insertions(+), 31 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 71159b2..44b0f09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1370,21 +1370,12 @@ failed:
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
-static struct fail_page_alloc_attr {
+static struct {
 	struct fault_attr attr;
 
 	u32 ignore_gfp_highmem;
 	u32 ignore_gfp_wait;
 	u32 min_order;
-
-#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
-
-	struct dentry *ignore_gfp_highmem_file;
-	struct dentry *ignore_gfp_wait_file;
-	struct dentry *min_order_file;
-
-#endif /* CONFIG_FAULT_INJECTION_DEBUG_FS */
-
 } fail_page_alloc = {
 	.attr = FAULT_ATTR_INITIALIZER,
 	.ignore_gfp_wait = 1,
@@ -1424,30 +1415,24 @@ static int __init fail_page_alloc_debugfs(void)
 				       "fail_page_alloc");
 	if (err)
 		return err;
+
 	dir = fail_page_alloc.attr.dir;
 
-	fail_page_alloc.ignore_gfp_wait_file =
-		debugfs_create_bool("ignore-gfp-wait", mode, dir,
-				      &fail_page_alloc.ignore_gfp_wait);
-
-	fail_page_alloc.ignore_gfp_highmem_file =
-		debugfs_create_bool("ignore-gfp-highmem", mode, dir,
-				      &fail_page_alloc.ignore_gfp_highmem);
-	fail_page_alloc.min_order_file =
-		debugfs_create_u32("min-order", mode, dir,
-				   &fail_page_alloc.min_order);
-
-	if (!fail_page_alloc.ignore_gfp_wait_file ||
-            !fail_page_alloc.ignore_gfp_highmem_file ||
-            !fail_page_alloc.min_order_file) {
-		err = -ENOMEM;
-		debugfs_remove(fail_page_alloc.ignore_gfp_wait_file);
-		debugfs_remove(fail_page_alloc.ignore_gfp_highmem_file);
-		debugfs_remove(fail_page_alloc.min_order_file);
-		cleanup_fault_attr_dentries(&fail_page_alloc.attr);
-	}
+	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
+				&fail_page_alloc.ignore_gfp_wait))
+		goto fail;
+	if (!debugfs_create_bool("ignore-gfp-highmem", mode, dir,
+				&fail_page_alloc.ignore_gfp_highmem))
+		goto fail;
+	if (!debugfs_create_u32("min-order", mode, dir,
+				&fail_page_alloc.min_order))
+		goto fail;
+
+	return 0;
+fail:
+	cleanup_fault_attr_dentries(&fail_page_alloc.attr);
 
-	return err;
+	return -ENOMEM;
 }
 
 late_initcall(fail_page_alloc_debugfs);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
