Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 26EC56B0082
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 09:58:38 -0400 (EDT)
Received: by pvc12 with SMTP id 12so5017803pvc.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 06:58:35 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 5/7] failslab: simplify debugfs initialization
Date: Sun,  3 Jul 2011 22:59:46 +0900
Message-Id: <1309701588-16588-6-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1309701588-16588-1-git-send-email-akinobu.mita@gmail.com>
References: <1309701588-16588-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Now cleanup_fault_attr_dentries() recursively removes a directory,
So we can simplify the error handling in the initialization code
and no need to hold dentry structs for each debugfs file.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
---
 mm/failslab.c |   31 ++++++++++---------------------
 1 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/mm/failslab.c b/mm/failslab.c
index 7df9f7f..1ce58c2 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -5,10 +5,6 @@ static struct {
 	struct fault_attr attr;
 	u32 ignore_gfp_wait;
 	int cache_filter;
-#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
-	struct dentry *ignore_gfp_wait_file;
-	struct dentry *cache_filter_file;
-#endif
 } failslab = {
 	.attr = FAULT_ATTR_INITIALIZER,
 	.ignore_gfp_wait = 1,
@@ -39,31 +35,24 @@ __setup("failslab=", setup_failslab);
 static int __init failslab_debugfs_init(void)
 {
 	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
-	struct dentry *dir;
 	int err;
 
 	err = init_fault_attr_dentries(&failslab.attr, "failslab");
 	if (err)
 		return err;
-	dir = failslab.attr.dir;
-
-	failslab.ignore_gfp_wait_file =
-		debugfs_create_bool("ignore-gfp-wait", mode, dir,
-				      &failslab.ignore_gfp_wait);
 
-	failslab.cache_filter_file =
-		debugfs_create_bool("cache-filter", mode, dir,
-				      &failslab.cache_filter);
+	if (!debugfs_create_bool("ignore-gfp-wait", mode, failslab.attr.dir,
+				&failslab.ignore_gfp_wait))
+		goto fail;
+	if (!debugfs_create_bool("cache-filter", mode, failslab.attr.dir,
+				&failslab.cache_filter))
+		goto fail;
 
-	if (!failslab.ignore_gfp_wait_file ||
-	    !failslab.cache_filter_file) {
-		err = -ENOMEM;
-		debugfs_remove(failslab.cache_filter_file);
-		debugfs_remove(failslab.ignore_gfp_wait_file);
-		cleanup_fault_attr_dentries(&failslab.attr);
-	}
+	return 0;
+fail:
+	cleanup_fault_attr_dentries(&failslab.attr);
 
-	return err;
+	return -ENOMEM;
 }
 
 late_initcall(failslab_debugfs_init);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
