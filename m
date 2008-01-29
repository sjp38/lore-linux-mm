Message-Id: <20080129154951.479862245@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:04 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 4/6] mm: bdi: expose the BDI object in sysfs for FUSE
Content-Disposition: inline; filename=bdi-sysfs-fuse.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Register FUSE's backing_dev_info under sysfs with the name
"fuse-MAJOR:MINOR"

Make the fuse control filesystem use s_dev instead of a fuse specific
ID.  This makes it easier to match directories under
/sys/fs/fuse/connections/ with directories under /sys/class/bdi, and
with actual mounts.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

Index: linux/fs/fuse/control.c
===================================================================
--- linux.orig/fs/fuse/control.c	2008-01-29 10:26:47.000000000 +0100
+++ linux/fs/fuse/control.c	2008-01-29 12:16:06.000000000 +0100
@@ -117,7 +117,7 @@ int fuse_ctl_add_conn(struct fuse_conn *
 
 	parent = fuse_control_sb->s_root;
 	inc_nlink(parent->d_inode);
-	sprintf(name, "%llu", (unsigned long long) fc->id);
+	sprintf(name, "%u", fc->dev);
 	parent = fuse_ctl_add_dentry(parent, fc, name, S_IFDIR | 0500, 2,
 				     &simple_dir_inode_operations,
 				     &simple_dir_operations);
Index: linux/fs/fuse/fuse_i.h
===================================================================
--- linux.orig/fs/fuse/fuse_i.h	2008-01-29 10:26:47.000000000 +0100
+++ linux/fs/fuse/fuse_i.h	2008-01-29 12:16:06.000000000 +0100
@@ -384,8 +384,8 @@ struct fuse_conn {
 	/** Entry on the fuse_conn_list */
 	struct list_head entry;
 
-	/** Unique ID */
-	u64 id;
+	/** Device ID from super block */
+	dev_t dev;
 
 	/** Dentries in the control filesystem */
 	struct dentry *ctl_dentry[FUSE_CTL_NUM_DENTRIES];
Index: linux/fs/fuse/inode.c
===================================================================
--- linux.orig/fs/fuse/inode.c	2008-01-29 10:26:47.000000000 +0100
+++ linux/fs/fuse/inode.c	2008-01-29 12:57:26.000000000 +0100
@@ -448,7 +448,7 @@ static int fuse_show_options(struct seq_
 	return 0;
 }
 
-static struct fuse_conn *new_conn(void)
+static struct fuse_conn *new_conn(struct super_block *sb)
 {
 	struct fuse_conn *fc;
 	int err;
@@ -468,19 +468,27 @@ static struct fuse_conn *new_conn(void)
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		fc->dev = sb->s_dev;
 		err = bdi_init(&fc->bdi);
-		if (err) {
-			kfree(fc);
-			fc = NULL;
-			goto out;
-		}
+		if (err)
+			goto error_kfree;
+		err = bdi_register(&fc->bdi, NULL, "fuse-%u:%u",
+				   MAJOR(fc->dev), MINOR(fc->dev));
+		if (err)
+			goto error_bdi_destroy;
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		fc->attr_version = 1;
 		get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));
 	}
-out:
 	return fc;
+
+error_bdi_destroy:
+	bdi_destroy(&fc->bdi);
+error_kfree:
+	mutex_destroy(&fc->inst_mutex);
+	kfree(fc);
+	return NULL;
 }
 
 void fuse_conn_put(struct fuse_conn *fc)
@@ -578,12 +586,6 @@ static void fuse_send_init(struct fuse_c
 	request_send_background(fc, req);
 }
 
-static u64 conn_id(void)
-{
-	static u64 ctr = 1;
-	return ctr++;
-}
-
 static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct fuse_conn *fc;
@@ -621,7 +623,7 @@ static int fuse_fill_super(struct super_
 	if (file->f_op != &fuse_dev_operations)
 		return -EINVAL;
 
-	fc = new_conn();
+	fc = new_conn(sb);
 	if (!fc)
 		return -ENOMEM;
 
@@ -659,7 +661,6 @@ static int fuse_fill_super(struct super_
 	if (file->private_data)
 		goto err_unlock;
 
-	fc->id = conn_id();
 	err = fuse_ctl_add_conn(fc);
 	if (err)
 		goto err_unlock;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
