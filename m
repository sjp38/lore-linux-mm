Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2A11E6B003B
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:01:02 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so5601985pbc.29
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:01:01 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id sl10si9119139pab.186.2013.12.16.07.00.58
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:00:59 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 5/5] VFS: Extend drop_caches sysctl handler to allow directory level cache cleaning
Date: Mon, 16 Dec 2013 07:00:09 -0800
Message-Id: <612334c18d31f67fb41416638f40cdf090062140.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>


Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 fs/drop_caches.c |   45 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 8 deletions(-)

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 9fd702f..ab31393 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -8,10 +8,11 @@
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
+#include <linux/fs_struct.h>
 #include "internal.h"
 
 /* A global variable is a bit ugly, but it keeps the code simple */
-int sysctl_drop_caches;
+char sysctl_drop_caches[PATH_MAX];
 
 static void drop_pagecache_sb(struct super_block *sb, void *unused)
 {
@@ -54,15 +55,43 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	int ret;
+	int command;
+	struct path path;
+	struct path root;
 
-	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (ret)
-		return ret;
-	if (write) {
-		if (sysctl_drop_caches & 1)
+	ret = proc_dostring(table, write, buffer, length, ppos);
+	if (ret || !write)
+		goto out;
+	ret = -EINVAL;
+	command = sysctl_drop_caches[0] - '0';
+	if (command < 1 || command > 3)
+		goto out;
+	if (sysctl_drop_caches[1] == '\0') {
+		if (command & 1)
 			iterate_supers(drop_pagecache_sb, NULL);
-		if (sysctl_drop_caches & 2)
+		if (command & 2)
 			drop_slab();
+		ret = 0;
+		goto out;
 	}
-	return 0;
+	if (sysctl_drop_caches[1] != ':' || sysctl_drop_caches[2] == '\0')
+		goto out;
+	if (sysctl_drop_caches[2] == '/')
+		get_fs_root(current->fs, &root);
+	else
+		get_fs_pwd(current->fs, &root);
+	ret = vfs_path_lookup(root.dentry, root.mnt,
+		&sysctl_drop_caches[2], 0, &path);
+	path_put(&root);
+	if (ret)
+		goto out;
+	if (command & 1)
+		shrink_pagecache_parent(path.dentry);
+	if (command & 2)
+		shrink_dcache_parent(path.dentry);
+	path_put(&path);
+out:
+	if (ret)
+		memset(sysctl_drop_caches, 0, PATH_MAX);
+	return ret;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
