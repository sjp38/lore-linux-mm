Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1124D6B00EE
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 19:05:05 -0400 (EDT)
Received: by pzk33 with SMTP id 33so1665637pzk.36
        for <linux-mm@kvack.org>; Tue, 26 Jul 2011 16:04:59 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -mmotm] fault-injection: add ability to export fault_attr in arbitrary directory
Date: Wed, 27 Jul 2011 08:06:37 +0900
Message-Id: <1311721597-2606-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Per Forlin <per.forlin@linaro.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

init_fault_attr_dentries() is used to export fault_attr via debugfs.  But
it can only export it in debugfs root directory.

Per Forlin is working on mmc_fail_request which adds support to inject
data errors after a completed host transfer in MMC subsystem.

The fault_attr for mmc_fail_request should be defined per mmc host and
export it in debugfs directory per mmc host like
/sys/kernel/debug/mmc0/mmc_fail_request.

init_fault_attr_dentries() doesn't help for mmc_fail_request.  So this
introduces debugfs_create_fault_attr() which is able to create a directory
in the arbitrary directory and replace init_fault_attr_dentries().

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Tested-by: Per Forlin <per.forlin@linaro.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
---
 Documentation/fault-injection/fault-injection.txt |    3 +--
 block/blk-core.c                                  |    6 ++++--
 block/blk-timeout.c                               |    5 ++++-
 include/linux/fault-inject.h                      |   18 +++++-------------
 lib/fault-inject.c                                |   20 +++++++-------------
 mm/failslab.c                                     |   14 +++++++-------
 mm/page_alloc.c                                   |   13 +++++--------
 7 files changed, 33 insertions(+), 46 deletions(-)

diff --git a/Documentation/fault-injection/fault-injection.txt b/Documentation/fault-injection/fault-injection.txt
index 7be15e4..dda989e 100644
--- a/Documentation/fault-injection/fault-injection.txt
+++ b/Documentation/fault-injection/fault-injection.txt
@@ -143,8 +143,7 @@ o provide a way to configure fault attributes
   failslab, fail_page_alloc, and fail_make_request use this way.
   Helper functions:
 
-	init_fault_attr_dentries(entries, attr, name);
-	void cleanup_fault_attr_dentries(entries);
+	debugfs_create_fault_attr(name, parent, attr);
 
 - module parameters
 
diff --git a/block/blk-core.c b/block/blk-core.c
index 1d70eda..6ba3563 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1368,8 +1368,10 @@ static bool should_fail_request(struct hd_struct *part, unsigned int bytes)
 
 static int __init fail_make_request_debugfs(void)
 {
-	return init_fault_attr_dentries(&fail_make_request,
-					"fail_make_request");
+	struct dentry *dir = debugfs_create_fault_attr("fail_make_request",
+						NULL, &fail_make_request);
+
+	return IS_ERR(dir) ? PTR_ERR(dir) : 0;
 }
 
 late_initcall(fail_make_request_debugfs);
diff --git a/block/blk-timeout.c b/block/blk-timeout.c
index 4f0c06c..6397e2e 100644
--- a/block/blk-timeout.c
+++ b/block/blk-timeout.c
@@ -28,7 +28,10 @@ int blk_should_fake_timeout(struct request_queue *q)
 
 static int __init fail_io_timeout_debugfs(void)
 {
-	return init_fault_attr_dentries(&fail_io_timeout, "fail_io_timeout");
+	struct dentry *dir = debugfs_create_fault_attr("fail_io_timeout",
+						NULL, &fail_io_timeout);
+
+	return IS_ERR(dir) ? PTR_ERR(dir) : 0;
 }
 
 late_initcall(fail_io_timeout_debugfs);
diff --git a/include/linux/fault-inject.h b/include/linux/fault-inject.h
index a842db6..3f583df 100644
--- a/include/linux/fault-inject.h
+++ b/include/linux/fault-inject.h
@@ -25,10 +25,6 @@ struct fault_attr {
 	unsigned long reject_end;
 
 	unsigned long count;
-
-#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
-	struct dentry *dir;
-#endif
 };
 
 #define FAULT_ATTR_INITIALIZER {				\
@@ -45,19 +41,15 @@ bool should_fail(struct fault_attr *attr, ssize_t size);
 
 #ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
 
-int init_fault_attr_dentries(struct fault_attr *attr, const char *name);
-void cleanup_fault_attr_dentries(struct fault_attr *attr);
+struct dentry *debugfs_create_fault_attr(const char *name,
+			struct dentry *parent, struct fault_attr *attr);
 
 #else /* CONFIG_FAULT_INJECTION_DEBUG_FS */
 
-static inline int init_fault_attr_dentries(struct fault_attr *attr,
-					  const char *name)
-{
-	return -ENODEV;
-}
-
-static inline void cleanup_fault_attr_dentries(struct fault_attr *attr)
+static inline struct dentry *debugfs_create_fault_attr(const char *name,
+			struct dentry *parent, struct fault_attr *attr);
 {
+	return ERR_PTR(-ENODEV);
 }
 
 #endif /* CONFIG_FAULT_INJECTION_DEBUG_FS */
diff --git a/lib/fault-inject.c b/lib/fault-inject.c
index 2577b12..d15d521 100644
--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -197,21 +197,15 @@ static struct dentry *debugfs_create_atomic_t(const char *name, mode_t mode,
 	return debugfs_create_file(name, mode, parent, value, &fops_atomic_t);
 }
 
-void cleanup_fault_attr_dentries(struct fault_attr *attr)
-{
-	debugfs_remove_recursive(attr->dir);
-}
-
-int init_fault_attr_dentries(struct fault_attr *attr, const char *name)
+struct dentry *debugfs_create_fault_attr(const char *name,
+			struct dentry *parent, struct fault_attr *attr)
 {
 	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
 	struct dentry *dir;
 
-	dir = debugfs_create_dir(name, NULL);
+	dir = debugfs_create_dir(name, parent);
 	if (!dir)
-		return -ENOMEM;
-
-	attr->dir = dir;
+		return ERR_PTR(-ENOMEM);
 
 	if (!debugfs_create_ul("probability", mode, dir, &attr->probability))
 		goto fail;
@@ -243,11 +237,11 @@ int init_fault_attr_dentries(struct fault_attr *attr, const char *name)
 
 #endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
 
-	return 0;
+	return dir;
 fail:
-	debugfs_remove_recursive(attr->dir);
+	debugfs_remove_recursive(dir);
 
-	return -ENOMEM;
+	return ERR_PTR(-ENOMEM);
 }
 
 #endif /* CONFIG_FAULT_INJECTION_DEBUG_FS */
diff --git a/mm/failslab.c b/mm/failslab.c
index 1ce58c2..59a3093 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -34,23 +34,23 @@ __setup("failslab=", setup_failslab);
 #ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
 static int __init failslab_debugfs_init(void)
 {
+	struct dentry *dir;
 	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
-	int err;
 
-	err = init_fault_attr_dentries(&failslab.attr, "failslab");
-	if (err)
-		return err;
+	dir = debugfs_create_fault_attr("failslab", NULL, &failslab.attr);
+	if (IS_ERR(dir))
+		return PTR_ERR(dir);
 
-	if (!debugfs_create_bool("ignore-gfp-wait", mode, failslab.attr.dir,
+	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
 				&failslab.ignore_gfp_wait))
 		goto fail;
-	if (!debugfs_create_bool("cache-filter", mode, failslab.attr.dir,
+	if (!debugfs_create_bool("cache-filter", mode, dir,
 				&failslab.cache_filter))
 		goto fail;
 
 	return 0;
 fail:
-	cleanup_fault_attr_dentries(&failslab.attr);
+	debugfs_remove_recursive(dir);
 
 	return -ENOMEM;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1dbcf88..f5a3512 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1409,14 +1409,11 @@ static int __init fail_page_alloc_debugfs(void)
 {
 	mode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
 	struct dentry *dir;
-	int err;
 
-	err = init_fault_attr_dentries(&fail_page_alloc.attr,
-				       "fail_page_alloc");
-	if (err)
-		return err;
-
-	dir = fail_page_alloc.attr.dir;
+	dir = debugfs_create_fault_attr("fail_page_alloc", NULL,
+					&fail_page_alloc.attr);
+	if (IS_ERR(dir))
+		return PTR_ERR(dir);
 
 	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
 				&fail_page_alloc.ignore_gfp_wait))
@@ -1430,7 +1427,7 @@ static int __init fail_page_alloc_debugfs(void)
 
 	return 0;
 fail:
-	cleanup_fault_attr_dentries(&fail_page_alloc.attr);
+	debugfs_remove_recursive(dir);
 
 	return -ENOMEM;
 }
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
