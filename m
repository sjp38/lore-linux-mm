Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 0F9586B0038
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:31:43 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 06:58:26 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id DA5A5E004A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 07:03:29 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1VYEP10223950
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 07:01:34 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1VbGb018745
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 01:31:38 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART2 v2 3/7] staging: ramster/debug: Use an array to initialize/use debugfs attributes
Date: Fri, 12 Apr 2013 09:31:23 +0800
Message-Id: <1365730287-16876-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
