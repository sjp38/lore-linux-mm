Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4631A6B0039
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 20:36:55 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 10:27:49 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id CA75F3578053
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:36:51 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3D0aG6a11010454
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:36:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3D0aLCf026743
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:36:21 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART3 v3 3/6] staging: ramster/debug: Use an array to initialize/use debugfs attributes
Date: Sat, 13 Apr 2013 08:36:07 +0800
Message-Id: <1365813371-19006-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365813371-19006-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365813371-19006-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use an array to initialize/use debugfs attributes, it makes them 
neater as zcache/debug.c does.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/ramster/debug.c |   68 +++++++++++++++-----------------
 1 file changed, 32 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/zcache/ramster/debug.c b/drivers/staging/zcache/ramster/debug.c
index 76861e4..bf34133 100644
--- a/drivers/staging/zcache/ramster/debug.c
+++ b/drivers/staging/zcache/ramster/debug.c
@@ -3,8 +3,6 @@
 
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
-#define zdfs    debugfs_create_size_t
-#define zdfs64  debugfs_create_u64
 
 ssize_t ramster_eph_pages_remoted;
 ssize_t ramster_pers_pages_remoted;
@@ -20,48 +18,46 @@ ssize_t ramster_remote_object_flushes_failed;
 ssize_t ramster_remote_pages_flushed;
 ssize_t ramster_remote_page_flushes_failed;
 
+#define ATTR(x)  { .name = #x, .val = &ramster_##x, }
+static struct debug_entry {
+	const char *name;
+	ssize_t *val;
+} attrs[] = {
+	ATTR(eph_pages_remoted),
+	ATTR(pers_pages_remoted),
+	ATTR(eph_pages_remote_failed),
+	ATTR(pers_pages_remote_failed),
+	ATTR(remote_eph_pages_succ_get),
+	ATTR(remote_pers_pages_succ_get),
+	ATTR(remote_eph_pages_unsucc_get),
+	ATTR(remote_pers_pages_unsucc_get),
+	ATTR(pers_pages_remote_nomem),
+	ATTR(remote_objects_flushed),
+	ATTR(remote_pages_flushed),
+	ATTR(remote_object_flushes_failed),
+	ATTR(remote_page_flushes_failed),
+	ATTR(foreign_eph_pages),
+	ATTR(foreign_eph_pages_max),
+	ATTR(foreign_pers_pages),
+	ATTR(foreign_pers_pages_max),
+};
+#undef ATTR
+
 int __init ramster_debugfs_init(void)
 {
+	int i;
 	struct dentry *root = debugfs_create_dir("ramster", NULL);
 	if (root == NULL)
 		return -ENXIO;
 
-	zdfs("eph_pages_remoted", S_IRUGO, root, &ramster_eph_pages_remoted);
-	zdfs("pers_pages_remoted", S_IRUGO, root, &ramster_pers_pages_remoted);
-	zdfs("eph_pages_remote_failed", S_IRUGO, root,
-		&ramster_eph_pages_remote_failed);
-	zdfs("pers_pages_remote_failed", S_IRUGO, root,
-		&ramster_pers_pages_remote_failed);
-	zdfs("remote_eph_pages_succ_get", S_IRUGO, root,
-		&ramster_remote_eph_pages_succ_get);
-	zdfs("remote_pers_pages_succ_get", S_IRUGO, root,
-		&ramster_remote_pers_pages_succ_get);
-	zdfs("remote_eph_pages_unsucc_get", S_IRUGO, root,
-		&ramster_remote_eph_pages_unsucc_get);
-	zdfs("remote_pers_pages_unsucc_get", S_IRUGO, root,
-		&ramster_remote_pers_pages_unsucc_get);
-	zdfs("pers_pages_remote_nomem", S_IRUGO, root,
-		&ramster_pers_pages_remote_nomem);
-	zdfs("remote_objects_flushed", S_IRUGO, root,
-		&ramster_remote_objects_flushed);
-	zdfs("remote_pages_flushed", S_IRUGO, root,
-		&ramster_remote_pages_flushed);
-	zdfs("remote_object_flushes_failed", S_IRUGO, root,
-		&ramster_remote_object_flushes_failed);
-	zdfs("remote_page_flushes_failed", S_IRUGO, root,
-		&ramster_remote_page_flushes_failed);
-	zdfs("foreign_eph_pages", S_IRUGO, root,
-		&ramster_foreign_eph_pages);
-	zdfs("foreign_eph_pages_max", S_IRUGO, root,
-		&ramster_foreign_eph_pages_max);
-	zdfs("foreign_pers_pages", S_IRUGO, root,
-		&ramster_foreign_pers_pages);
-	zdfs("foreign_pers_pages_max", S_IRUGO, root,
-		&ramster_foreign_pers_pages_max);
+	for (i = 0; i < ARRAY_SIZE(attrs); i++)
+		if (!debugfs_create_size_t(attrs[i].name,
+				S_IRUGO, root, attrs[i].val))
+			goto out;
 	return 0;
+out:
+	return -ENODEV;
 }
-#undef  zdebugfs
-#undef  zdfs64
 #else
 static inline int ramster_debugfs_init(void)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
