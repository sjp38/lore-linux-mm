Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9E5A36B0033
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 16:12:21 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so6628067ied.14
        for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:12:21 -0700 (PDT)
Date: Sat, 29 Jun 2013 13:12:20 -0700 (PDT)
From: Rob Landley <rob@landley.net>
In-Reply-To: <1372536729.850447@landley.net>
Message-Id: <1372536729.851443@landley.net>
Subject: [PATCH 4/5] initmpfs: Make rootfs use tmpfs when CONFIG_TMPFS enabled.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, Stephen Warren <swarren@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

From: Rob Landley <rob@landley.net>

Conditionally call the appropriate fs_init function and fill_super functions.
Add a use once guard to shmem_init() to simply succeed on a second call.

(Note that IS_ENABLED() is a compile time constant so dead code elimination
removes unused function calls when CONFIG_TMPFS is disabled.)

Signed-off-by: Rob Landley <rob@landley.net>
---

 init/do_mounts.c |   10 ++++++++--
 mm/shmem.c       |    4 ++++
 2 files changed, 12 insertions(+), 2 deletions(-)

--- initold/init/do_mounts.c	2013-06-27 00:02:26.283442977 -0500
+++ initwork/init/do_mounts.c	2013-06-27 00:45:21.599550312 -0500
@@ -27,6 +27,7 @@
 #include <linux/fs_struct.h>
 #include <linux/slab.h>
 #include <linux/ramfs.h>
+#include <linux/shmem_fs.h>
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_fs_sb.h>
@@ -600,7 +599,8 @@
 	else
 		once++;
 
-	return mount_nodev(fs_type, flags, data, ramfs_fill_super);
+	return mount_nodev(fs_type, flags, data,
+		IS_ENABLED(CONFIG_TMPFS) ? shmem_fill_super : ramfs_fill_super);
 }
 
 static struct file_system_type rootfs_fs_type = {
@@ -616,7 +616,11 @@
 	if (err)
 		return err;
 
-	err = init_ramfs_fs();
+	if (IS_ENABLED(CONFIG_TMPFS))
+		err = shmem_init();
+	else
+		err = init_ramfs_fs();
+
 	if (err)
 		unregister_filesystem(&rootfs_fs_type);
 
--- initold/mm/shmem.c	2013-06-25 13:09:22.215743137 -0500
+++ initwork/mm/shmem.c	2013-06-27 00:16:58.195479317 -0500
@@ -2787,6 +2787,10 @@
 {
 	int error;
 
+	/* If rootfs called this, don't re-init */
+	if (shmem_inode_cachep)
+		return 0;
+
 	error = bdi_init(&shmem_backing_dev_info);
 	if (error)
 		goto out4;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
