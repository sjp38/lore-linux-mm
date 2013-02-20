Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id DA3366B0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 17:25:50 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 20 Feb 2013 15:25:44 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C474538CCA3E
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 17:05:21 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1KM5Le4291844
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 17:05:21 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1KM5KdD030431
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 17:05:21 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv6 3/8] debugfs: add get/set for atomic types
Date: Wed, 20 Feb 2013 16:04:43 -0600
Message-Id: <1361397888-14863-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

debugfs currently lack the ability to create attributes
that set/get atomic_t values.

This patch adds support for this through a new
debugfs_create_atomic_t() function.

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 fs/debugfs/file.c       | 42 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/debugfs.h |  2 ++
 2 files changed, 44 insertions(+)

diff --git a/fs/debugfs/file.c b/fs/debugfs/file.c
index c5ca6ae..fa26d5b 100644
--- a/fs/debugfs/file.c
+++ b/fs/debugfs/file.c
@@ -21,6 +21,7 @@
 #include <linux/debugfs.h>
 #include <linux/io.h>
 #include <linux/slab.h>
+#include <linux/atomic.h>
 
 static ssize_t default_read_file(struct file *file, char __user *buf,
 				 size_t count, loff_t *ppos)
@@ -403,6 +404,47 @@ struct dentry *debugfs_create_size_t(const char *name, umode_t mode,
 }
 EXPORT_SYMBOL_GPL(debugfs_create_size_t);
 
+static int debugfs_atomic_t_set(void *data, u64 val)
+{
+	atomic_set((atomic_t *)data, val);
+	return 0;
+}
+static int debugfs_atomic_t_get(void *data, u64 *val)
+{
+	*val = atomic_read((atomic_t *)data);
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t, debugfs_atomic_t_get,
+			debugfs_atomic_t_set, "%llu\n");
+DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t_ro, debugfs_atomic_t_get, NULL, "%llu\n");
+DEFINE_SIMPLE_ATTRIBUTE(fops_atomic_t_wo, NULL, debugfs_atomic_t_set, "%llu\n");
+
+/**
+ * debugfs_create_atomic_t - create a debugfs file that is used to read and
+ * write an atomic_t value
+ * @name: a pointer to a string containing the name of the file to create.
+ * @mode: the permission that the file should have
+ * @parent: a pointer to the parent dentry for this file.  This should be a
+ *          directory dentry if set.  If this parameter is %NULL, then the
+ *          file will be created in the root of the debugfs filesystem.
+ * @value: a pointer to the variable that the file should read to and write
+ *         from.
+ */
+struct dentry *debugfs_create_atomic_t(const char *name, umode_t mode,
+				 struct dentry *parent, atomic_t *value)
+{
+	/* if there are no write bits set, make read only */
+	if (!(mode & S_IWUGO))
+		return debugfs_create_file(name, mode, parent, value,
+					&fops_atomic_t_ro);
+	/* if there are no read bits set, make write only */
+	if (!(mode & S_IRUGO))
+		return debugfs_create_file(name, mode, parent, value,
+					&fops_atomic_t_wo);
+
+	return debugfs_create_file(name, mode, parent, value, &fops_atomic_t);
+}
+EXPORT_SYMBOL_GPL(debugfs_create_atomic_t);
 
 static ssize_t read_file_bool(struct file *file, char __user *user_buf,
 			      size_t count, loff_t *ppos)
diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index 66c434f..51fea70 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -79,6 +79,8 @@ struct dentry *debugfs_create_x64(const char *name, umode_t mode,
 				  struct dentry *parent, u64 *value);
 struct dentry *debugfs_create_size_t(const char *name, umode_t mode,
 				     struct dentry *parent, size_t *value);
+struct dentry *debugfs_create_atomic_t(const char *name, umode_t mode,
+				     struct dentry *parent, atomic_t *value);
 struct dentry *debugfs_create_bool(const char *name, umode_t mode,
 				  struct dentry *parent, u32 *value);
 
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
