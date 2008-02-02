Message-Id: <20080202230228.852294646@szeredi.hu>
References: <20080202230111.346847183@szeredi.hu>
Date: Sun, 03 Feb 2008 00:01:13 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 2/3] mm: bdi: use MAJOR:MINOR in /sys/class/bdi
Content-Disposition: inline; filename=mm-bdi-use-major-minor-in-sys-class-bdi.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Uniformly use MAJOR:MINOR in /sys/class/bdi/ for both block devices
and non-block device backed filesystems: FUSE and NFS.

Add symlink for block devices:

    /sys/block/<name>/bdi -> /sys/class/bdi/<bdi>

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/block/genhd.c
===================================================================
--- linux.orig/block/genhd.c	2008-02-02 22:41:03.000000000 +0100
+++ linux/block/genhd.c	2008-02-02 22:50:03.000000000 +0100
@@ -178,13 +178,17 @@ static int exact_lock(dev_t devt, void *
  */
 void add_disk(struct gendisk *disk)
 {
+	struct backing_dev_info *bdi;
+
 	disk->flags |= GENHD_FL_UP;
 	blk_register_region(MKDEV(disk->major, disk->first_minor),
 			    disk->minors, NULL, exact_match, exact_lock, disk);
 	register_disk(disk);
 	blk_register_queue(disk);
-	bdi_register(&disk->queue->backing_dev_info, NULL,
-		"blk-%s", disk->disk_name);
+
+	bdi = &disk->queue->backing_dev_info;
+	bdi_register_dev(bdi, MKDEV(disk->major, disk->first_minor));
+	sysfs_create_link(&disk->dev.kobj, &bdi->dev->kobj, "bdi");
 }
 
 EXPORT_SYMBOL(add_disk);
@@ -192,8 +196,9 @@ EXPORT_SYMBOL(del_gendisk);	/* in partit
 
 void unlink_gendisk(struct gendisk *disk)
 {
-	blk_unregister_queue(disk);
+	sysfs_remove_link(&disk->dev.kobj, "bdi");
 	bdi_unregister(&disk->queue->backing_dev_info);
+	blk_unregister_queue(disk);
 	blk_unregister_region(MKDEV(disk->major, disk->first_minor),
 			      disk->minors);
 }
Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2008-02-02 22:41:03.000000000 +0100
+++ linux/include/linux/backing-dev.h	2008-02-02 22:50:03.000000000 +0100
@@ -62,6 +62,7 @@ void bdi_destroy(struct backing_dev_info
 
 int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		const char *fmt, ...);
+int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
 void bdi_unregister(struct backing_dev_info *bdi);
 
 static inline void __add_bdi_stat(struct backing_dev_info *bdi,
Index: linux/mm/backing-dev.c
===================================================================
--- linux.orig/mm/backing-dev.c	2008-02-02 22:43:36.000000000 +0100
+++ linux/mm/backing-dev.c	2008-02-02 22:50:03.000000000 +0100
@@ -143,6 +143,12 @@ exit:
 }
 EXPORT_SYMBOL(bdi_register);
 
+int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev)
+{
+	return bdi_register(bdi, NULL, "%u:%u", MAJOR(dev), MINOR(dev));
+}
+EXPORT_SYMBOL(bdi_register_dev);
+
 void bdi_unregister(struct backing_dev_info *bdi)
 {
 	if (bdi->dev) {
Index: linux/fs/fuse/inode.c
===================================================================
--- linux.orig/fs/fuse/inode.c	2008-02-02 22:41:03.000000000 +0100
+++ linux/fs/fuse/inode.c	2008-02-02 22:50:03.000000000 +0100
@@ -472,8 +472,7 @@ static struct fuse_conn *new_conn(struct
 		err = bdi_init(&fc->bdi);
 		if (err)
 			goto error_kfree;
-		err = bdi_register(&fc->bdi, NULL, "fuse-%u:%u",
-				   MAJOR(fc->dev), MINOR(fc->dev));
+		err = bdi_register_dev(&fc->bdi, fc->dev);
 		if (err)
 			goto error_bdi_destroy;
 		fc->reqctr = 0;
Index: linux/fs/nfs/super.c
===================================================================
--- linux.orig/fs/nfs/super.c	2008-02-02 22:41:03.000000000 +0100
+++ linux/fs/nfs/super.c	2008-02-02 22:50:03.000000000 +0100
@@ -1477,8 +1477,7 @@ static int nfs_compare_super(struct supe
 
 static int nfs_bdi_register(struct nfs_server *server)
 {
-	return bdi_register(&server->backing_dev_info, NULL, "nfs-%u:%u",
-			    MAJOR(server->s_dev), MINOR(server->s_dev));
+	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
 static int nfs_get_sb(struct file_system_type *fs_type,
Index: linux/Documentation/ABI/testing/sysfs-class-bdi
===================================================================
--- linux.orig/Documentation/ABI/testing/sysfs-class-bdi	2008-02-02 22:41:03.000000000 +0100
+++ linux/Documentation/ABI/testing/sysfs-class-bdi	2008-02-02 22:50:03.000000000 +0100
@@ -6,17 +6,13 @@ Description:
 Provide a place in sysfs for the backing_dev_info object.
 This allows us to see and set the various BDI specific variables.
 
-The <bdi> identifyer can take the following forms:
+The <bdi> identifier can be either of the following:
 
-blk-NAME
+MAJOR:MINOR
 
-	Block devices, NAME is 'sda', 'loop0', etc...
-
-FSTYPE-MAJOR:MINOR
-
-	Non-block device backed filesystems which provide their own
-	BDI, such as NFS and FUSE.  MAJOR:MINOR is the value of st_dev
-	for files on this filesystem.
+	Device number for block devices, or value of st_dev on
+	non-block filesystems which provide their own BDI, such as NFS
+	and FUSE.
 
 default
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
