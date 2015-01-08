Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 94D5B6B0070
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:46:36 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so3939155wgh.6
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:46:36 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id hq9si14435499wib.106.2015.01.08.09.46.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 09:46:29 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/12] fs: introduce f_op->mmap_capabilities for nommu mmap support
Date: Thu,  8 Jan 2015 18:45:24 +0100
Message-Id: <1420739133-27514-4-git-send-email-hch@lst.de>
In-Reply-To: <1420739133-27514-1-git-send-email-hch@lst.de>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

Since "BDI: Provide backing device capability information [try #3]" the
backing_dev_info structure also provides flags for the kind of mmap
operation available in a nommu environment, which is entirely unrelated
to it's original purpose.

Introduce a new nommu-only file operation to provide this information to
the nommu mmap code instead.  Splitting this from the backing_dev_info
structure allows to remove lots of backing_dev_info instance that aren't
otherwise needed, and entirely gets rid of the concept of providing a
backing_dev_info for a character device.  It also removes the need for
the mtd_inodefs filesystem.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/nommu-mmap.txt                    |  8 +--
 block/blk-core.c                                |  2 +-
 drivers/char/mem.c                              | 64 ++++++++++----------
 drivers/mtd/mtdchar.c                           | 72 ++++------------------
 drivers/mtd/mtdconcat.c                         | 10 ----
 drivers/mtd/mtdcore.c                           | 80 +++++++------------------
 drivers/mtd/mtdpart.c                           |  1 -
 drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
 fs/9p/v9fs.c                                    |  2 +-
 fs/afs/volume.c                                 |  2 +-
 fs/aio.c                                        | 14 +----
 fs/btrfs/disk-io.c                              |  3 +-
 fs/char_dev.c                                   | 24 --------
 fs/cifs/connect.c                               |  2 +-
 fs/coda/inode.c                                 |  2 +-
 fs/configfs/configfs_internal.h                 |  2 -
 fs/configfs/inode.c                             | 18 +-----
 fs/configfs/mount.c                             | 11 +---
 fs/ecryptfs/main.c                              |  2 +-
 fs/exofs/super.c                                |  2 +-
 fs/ncpfs/inode.c                                |  2 +-
 fs/ramfs/file-nommu.c                           |  7 +++
 fs/ramfs/inode.c                                | 22 +------
 fs/romfs/mmap-nommu.c                           | 10 ++++
 fs/ubifs/super.c                                |  2 +-
 include/linux/backing-dev.h                     | 33 ++--------
 include/linux/cdev.h                            |  2 -
 include/linux/fs.h                              | 23 +++++++
 include/linux/mtd/mtd.h                         |  2 +
 mm/backing-dev.c                                |  7 +--
 mm/nommu.c                                      | 69 ++++++++++-----------
 security/security.c                             | 13 ++--
 32 files changed, 169 insertions(+), 346 deletions(-)

diff --git a/Documentation/nommu-mmap.txt b/Documentation/nommu-mmap.txt
index 8e1ddec..ae57b9e 100644
--- a/Documentation/nommu-mmap.txt
+++ b/Documentation/nommu-mmap.txt
@@ -43,12 +43,12 @@ and it's also much more restricted in the latter case:
            even if this was created by another process.
 
          - If possible, the file mapping will be directly on the backing device
-           if the backing device has the BDI_CAP_MAP_DIRECT capability and
+           if the backing device has the NOMMU_MAP_DIRECT capability and
            appropriate mapping protection capabilities. Ramfs, romfs, cramfs
            and mtd might all permit this.
 
 	 - If the backing device device can't or won't permit direct sharing,
-           but does have the BDI_CAP_MAP_COPY capability, then a copy of the
+           but does have the NOMMU_MAP_COPY capability, then a copy of the
            appropriate bit of the file will be read into a contiguous bit of
            memory and any extraneous space beyond the EOF will be cleared
 
@@ -220,7 +220,7 @@ directly (can't be copied).
 
 The file->f_op->mmap() operation will be called to actually inaugurate the
 mapping. It can be rejected at that point. Returning the ENOSYS error will
-cause the mapping to be copied instead if BDI_CAP_MAP_COPY is specified.
+cause the mapping to be copied instead if NOMMU_MAP_COPY is specified.
 
 The vm_ops->close() routine will be invoked when the last mapping on a chardev
 is removed. An existing mapping will be shared, partially or not, if possible
@@ -232,7 +232,7 @@ want to handle it, despite the fact it's got an operation. For instance, it
 might try directing the call to a secondary driver which turns out not to
 implement it. Such is the case for the framebuffer driver which attempts to
 direct the call to the device-specific driver. Under such circumstances, the
-mapping request will be rejected if BDI_CAP_MAP_COPY is not specified, and a
+mapping request will be rejected if NOMMU_MAP_COPY is not specified, and a
 copy mapped otherwise.
 
 IMPORTANT NOTE:
diff --git a/block/blk-core.c b/block/blk-core.c
index 30f6153..56bc2b8 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -588,7 +588,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->backing_dev_info.ra_pages =
 			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 	q->backing_dev_info.state = 0;
-	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
+	q->backing_dev_info.capabilities = 0;
 	q->backing_dev_info.name = "block";
 	q->node = node_id;
 
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 4c58333..9a6b637 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -287,13 +287,24 @@ static unsigned long get_unmapped_area_mem(struct file *file,
 	return pgoff << PAGE_SHIFT;
 }
 
+/* permit direct mmap, for read, write or exec */
+static unsigned memory_mmap_capabilities(struct file *file)
+{
+	return NOMMU_MAP_DIRECT |
+		NOMMU_MAP_READ | NOMMU_MAP_WRITE | NOMMU_MAP_EXEC;
+}
+
+static unsigned zero_mmap_capabilities(struct file *file)
+{
+	return NOMMU_MAP_COPY;
+}
+
 /* can't do an in-place private mapping if there's no MMU */
 static inline int private_mapping_ok(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & VM_MAYSHARE;
 }
 #else
-#define get_unmapped_area_mem	NULL
 
 static inline int private_mapping_ok(struct vm_area_struct *vma)
 {
@@ -721,7 +732,10 @@ static const struct file_operations mem_fops = {
 	.write		= write_mem,
 	.mmap		= mmap_mem,
 	.open		= open_mem,
+#ifndef CONFIG_MMU
 	.get_unmapped_area = get_unmapped_area_mem,
+	.mmap_capabilities = memory_mmap_capabilities,
+#endif
 };
 
 #ifdef CONFIG_DEVKMEM
@@ -731,7 +745,10 @@ static const struct file_operations kmem_fops = {
 	.write		= write_kmem,
 	.mmap		= mmap_kmem,
 	.open		= open_kmem,
+#ifndef CONFIG_MMU
 	.get_unmapped_area = get_unmapped_area_mem,
+	.mmap_capabilities = memory_mmap_capabilities,
+#endif
 };
 #endif
 
@@ -760,16 +777,9 @@ static const struct file_operations zero_fops = {
 	.read_iter	= read_iter_zero,
 	.aio_write	= aio_write_zero,
 	.mmap		= mmap_zero,
-};
-
-/*
- * capabilities for /dev/zero
- * - permits private mappings, "copies" are taken of the source of zeros
- * - no writeback happens
- */
-static struct backing_dev_info zero_bdi = {
-	.name		= "char/mem",
-	.capabilities	= BDI_CAP_MAP_COPY | BDI_CAP_NO_ACCT_AND_WRITEBACK,
+#ifndef CONFIG_MMU
+	.mmap_capabilities = zero_mmap_capabilities,
+#endif
 };
 
 static const struct file_operations full_fops = {
@@ -783,22 +793,22 @@ static const struct memdev {
 	const char *name;
 	umode_t mode;
 	const struct file_operations *fops;
-	struct backing_dev_info *dev_info;
+	fmode_t fmode;
 } devlist[] = {
-	 [1] = { "mem", 0, &mem_fops, &directly_mappable_cdev_bdi },
+	 [1] = { "mem", 0, &mem_fops, FMODE_UNSIGNED_OFFSET },
 #ifdef CONFIG_DEVKMEM
-	 [2] = { "kmem", 0, &kmem_fops, &directly_mappable_cdev_bdi },
+	 [2] = { "kmem", 0, &kmem_fops, FMODE_UNSIGNED_OFFSET },
 #endif
-	 [3] = { "null", 0666, &null_fops, NULL },
+	 [3] = { "null", 0666, &null_fops, 0 },
 #ifdef CONFIG_DEVPORT
-	 [4] = { "port", 0, &port_fops, NULL },
+	 [4] = { "port", 0, &port_fops, 0 },
 #endif
-	 [5] = { "zero", 0666, &zero_fops, &zero_bdi },
-	 [7] = { "full", 0666, &full_fops, NULL },
-	 [8] = { "random", 0666, &random_fops, NULL },
-	 [9] = { "urandom", 0666, &urandom_fops, NULL },
+	 [5] = { "zero", 0666, &zero_fops, 0 },
+	 [7] = { "full", 0666, &full_fops, 0 },
+	 [8] = { "random", 0666, &random_fops, 0 },
+	 [9] = { "urandom", 0666, &urandom_fops, 0 },
 #ifdef CONFIG_PRINTK
-	[11] = { "kmsg", 0644, &kmsg_fops, NULL },
+	[11] = { "kmsg", 0644, &kmsg_fops, 0 },
 #endif
 };
 
@@ -816,12 +826,7 @@ static int memory_open(struct inode *inode, struct file *filp)
 		return -ENXIO;
 
 	filp->f_op = dev->fops;
-	if (dev->dev_info)
-		filp->f_mapping->backing_dev_info = dev->dev_info;
-
-	/* Is /dev/mem or /dev/kmem ? */
-	if (dev->dev_info == &directly_mappable_cdev_bdi)
-		filp->f_mode |= FMODE_UNSIGNED_OFFSET;
+	filp->f_mode |= dev->fmode;
 
 	if (dev->fops->open)
 		return dev->fops->open(inode, filp);
@@ -846,11 +851,6 @@ static struct class *mem_class;
 static int __init chr_dev_init(void)
 {
 	int minor;
-	int err;
-
-	err = bdi_init(&zero_bdi);
-	if (err)
-		return err;
 
 	if (register_chrdev(MEM_MAJOR, "mem", &memory_fops))
 		printk("unable to get major %d for memory devs\n", MEM_MAJOR);
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index 5356395..55fa27e 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -49,7 +49,6 @@ static DEFINE_MUTEX(mtd_mutex);
  */
 struct mtd_file_info {
 	struct mtd_info *mtd;
-	struct inode *ino;
 	enum mtd_file_modes mode;
 };
 
@@ -59,10 +58,6 @@ static loff_t mtdchar_lseek(struct file *file, loff_t offset, int orig)
 	return fixed_size_llseek(file, offset, orig, mfi->mtd->size);
 }
 
-static int count;
-static struct vfsmount *mnt;
-static struct file_system_type mtd_inodefs_type;
-
 static int mtdchar_open(struct inode *inode, struct file *file)
 {
 	int minor = iminor(inode);
@@ -70,7 +65,6 @@ static int mtdchar_open(struct inode *inode, struct file *file)
 	int ret = 0;
 	struct mtd_info *mtd;
 	struct mtd_file_info *mfi;
-	struct inode *mtd_ino;
 
 	pr_debug("MTD_open\n");
 
@@ -78,10 +72,6 @@ static int mtdchar_open(struct inode *inode, struct file *file)
 	if ((file->f_mode & FMODE_WRITE) && (minor & 1))
 		return -EACCES;
 
-	ret = simple_pin_fs(&mtd_inodefs_type, &mnt, &count);
-	if (ret)
-		return ret;
-
 	mutex_lock(&mtd_mutex);
 	mtd = get_mtd_device(NULL, devnum);
 
@@ -95,43 +85,26 @@ static int mtdchar_open(struct inode *inode, struct file *file)
 		goto out1;
 	}
 
-	mtd_ino = iget_locked(mnt->mnt_sb, devnum);
-	if (!mtd_ino) {
-		ret = -ENOMEM;
-		goto out1;
-	}
-	if (mtd_ino->i_state & I_NEW) {
-		mtd_ino->i_private = mtd;
-		mtd_ino->i_mode = S_IFCHR;
-		mtd_ino->i_data.backing_dev_info = mtd->backing_dev_info;
-		unlock_new_inode(mtd_ino);
-	}
-	file->f_mapping = mtd_ino->i_mapping;
-
 	/* You can't open it RW if it's not a writeable device */
 	if ((file->f_mode & FMODE_WRITE) && !(mtd->flags & MTD_WRITEABLE)) {
 		ret = -EACCES;
-		goto out2;
+		goto out1;
 	}
 
 	mfi = kzalloc(sizeof(*mfi), GFP_KERNEL);
 	if (!mfi) {
 		ret = -ENOMEM;
-		goto out2;
+		goto out1;
 	}
-	mfi->ino = mtd_ino;
 	mfi->mtd = mtd;
 	file->private_data = mfi;
 	mutex_unlock(&mtd_mutex);
 	return 0;
 
-out2:
-	iput(mtd_ino);
 out1:
 	put_mtd_device(mtd);
 out:
 	mutex_unlock(&mtd_mutex);
-	simple_release_fs(&mnt, &count);
 	return ret;
 } /* mtdchar_open */
 
@@ -148,12 +121,9 @@ static int mtdchar_close(struct inode *inode, struct file *file)
 	if ((file->f_mode & FMODE_WRITE))
 		mtd_sync(mtd);
 
-	iput(mfi->ino);
-
 	put_mtd_device(mtd);
 	file->private_data = NULL;
 	kfree(mfi);
-	simple_release_fs(&mnt, &count);
 
 	return 0;
 } /* mtdchar_close */
@@ -1117,6 +1087,13 @@ static unsigned long mtdchar_get_unmapped_area(struct file *file,
 	ret = mtd_get_unmapped_area(mtd, len, offset, flags);
 	return ret == -EOPNOTSUPP ? -ENODEV : ret;
 }
+
+static unsigned mtdchar_mmap_capabilities(struct file *file)
+{
+	struct mtd_file_info *mfi = file->private_data;
+
+	return mtd_mmap_capabilities(mfi->mtd);
+}
 #endif
 
 /*
@@ -1160,27 +1137,10 @@ static const struct file_operations mtd_fops = {
 	.mmap		= mtdchar_mmap,
 #ifndef CONFIG_MMU
 	.get_unmapped_area = mtdchar_get_unmapped_area,
+	.mmap_capabilities = mtdchar_mmap_capabilities,
 #endif
 };
 
-static const struct super_operations mtd_ops = {
-	.drop_inode = generic_delete_inode,
-	.statfs = simple_statfs,
-};
-
-static struct dentry *mtd_inodefs_mount(struct file_system_type *fs_type,
-				int flags, const char *dev_name, void *data)
-{
-	return mount_pseudo(fs_type, "mtd_inode:", &mtd_ops, NULL, MTD_INODE_FS_MAGIC);
-}
-
-static struct file_system_type mtd_inodefs_type = {
-       .name = "mtd_inodefs",
-       .mount = mtd_inodefs_mount,
-       .kill_sb = kill_anon_super,
-};
-MODULE_ALIAS_FS("mtd_inodefs");
-
 int __init init_mtdchar(void)
 {
 	int ret;
@@ -1193,23 +1153,11 @@ int __init init_mtdchar(void)
 		return ret;
 	}
 
-	ret = register_filesystem(&mtd_inodefs_type);
-	if (ret) {
-		pr_err("Can't register mtd_inodefs filesystem, error %d\n",
-		       ret);
-		goto err_unregister_chdev;
-	}
-
-	return ret;
-
-err_unregister_chdev:
-	__unregister_chrdev(MTD_CHAR_MAJOR, 0, 1 << MINORBITS, "mtd");
 	return ret;
 }
 
 void __exit cleanup_mtdchar(void)
 {
-	unregister_filesystem(&mtd_inodefs_type);
 	__unregister_chrdev(MTD_CHAR_MAJOR, 0, 1 << MINORBITS, "mtd");
 }
 
diff --git a/drivers/mtd/mtdconcat.c b/drivers/mtd/mtdconcat.c
index b900056..eacc3aa 100644
--- a/drivers/mtd/mtdconcat.c
+++ b/drivers/mtd/mtdconcat.c
@@ -732,8 +732,6 @@ struct mtd_info *mtd_concat_create(struct mtd_info *subdev[],	/* subdevices to c
 
 	concat->mtd.ecc_stats.badblocks = subdev[0]->ecc_stats.badblocks;
 
-	concat->mtd.backing_dev_info = subdev[0]->backing_dev_info;
-
 	concat->subdev[0] = subdev[0];
 
 	for (i = 1; i < num_devs; i++) {
@@ -761,14 +759,6 @@ struct mtd_info *mtd_concat_create(struct mtd_info *subdev[],	/* subdevices to c
 				    subdev[i]->flags & MTD_WRITEABLE;
 		}
 
-		/* only permit direct mapping if the BDIs are all the same
-		 * - copy-mapping is still permitted
-		 */
-		if (concat->mtd.backing_dev_info !=
-		    subdev[i]->backing_dev_info)
-			concat->mtd.backing_dev_info =
-				&default_backing_dev_info;
-
 		concat->mtd.size += subdev[i]->size;
 		concat->mtd.ecc_stats.badblocks +=
 			subdev[i]->ecc_stats.badblocks;
diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
index 4c61187..ff38a1d 100644
--- a/drivers/mtd/mtdcore.c
+++ b/drivers/mtd/mtdcore.c
@@ -43,33 +43,7 @@
 
 #include "mtdcore.h"
 
-/*
- * backing device capabilities for non-mappable devices (such as NAND flash)
- * - permits private mappings, copies are taken of the data
- */
-static struct backing_dev_info mtd_bdi_unmappable = {
-	.capabilities	= BDI_CAP_MAP_COPY,
-};
-
-/*
- * backing device capabilities for R/O mappable devices (such as ROM)
- * - permits private mappings, copies are taken of the data
- * - permits non-writable shared mappings
- */
-static struct backing_dev_info mtd_bdi_ro_mappable = {
-	.capabilities	= (BDI_CAP_MAP_COPY | BDI_CAP_MAP_DIRECT |
-			   BDI_CAP_EXEC_MAP | BDI_CAP_READ_MAP),
-};
-
-/*
- * backing device capabilities for writable mappable devices (such as RAM)
- * - permits private mappings, copies are taken of the data
- * - permits non-writable shared mappings
- */
-static struct backing_dev_info mtd_bdi_rw_mappable = {
-	.capabilities	= (BDI_CAP_MAP_COPY | BDI_CAP_MAP_DIRECT |
-			   BDI_CAP_EXEC_MAP | BDI_CAP_READ_MAP |
-			   BDI_CAP_WRITE_MAP),
+static struct backing_dev_info mtd_bdi = {
 };
 
 static int mtd_cls_suspend(struct device *dev, pm_message_t state);
@@ -365,6 +339,22 @@ static struct device_type mtd_devtype = {
 	.release	= mtd_release,
 };
 
+#ifndef CONFIG_MMU
+unsigned mtd_mmap_capabilities(struct mtd_info *mtd)
+{
+	switch (mtd->type) {
+	case MTD_RAM:
+		return NOMMU_MAP_COPY | NOMMU_MAP_DIRECT | NOMMU_MAP_EXEC |
+			NOMMU_MAP_READ | NOMMU_MAP_WRITE;
+	case MTD_ROM:
+		return NOMMU_MAP_COPY | NOMMU_MAP_DIRECT | NOMMU_MAP_EXEC |
+			NOMMU_MAP_READ;
+	default:
+		return NOMMU_MAP_COPY;
+	}
+}
+#endif
+
 /**
  *	add_mtd_device - register an MTD device
  *	@mtd: pointer to new MTD device info structure
@@ -380,19 +370,7 @@ int add_mtd_device(struct mtd_info *mtd)
 	struct mtd_notifier *not;
 	int i, error;
 
-	if (!mtd->backing_dev_info) {
-		switch (mtd->type) {
-		case MTD_RAM:
-			mtd->backing_dev_info = &mtd_bdi_rw_mappable;
-			break;
-		case MTD_ROM:
-			mtd->backing_dev_info = &mtd_bdi_ro_mappable;
-			break;
-		default:
-			mtd->backing_dev_info = &mtd_bdi_unmappable;
-			break;
-		}
-	}
+	mtd->backing_dev_info = &mtd_bdi;
 
 	BUG_ON(mtd->writesize == 0);
 	mutex_lock(&mtd_table_mutex);
@@ -1237,17 +1215,9 @@ static int __init init_mtd(void)
 	if (ret)
 		goto err_reg;
 
-	ret = mtd_bdi_init(&mtd_bdi_unmappable, "mtd-unmap");
-	if (ret)
-		goto err_bdi1;
-
-	ret = mtd_bdi_init(&mtd_bdi_ro_mappable, "mtd-romap");
-	if (ret)
-		goto err_bdi2;
-
-	ret = mtd_bdi_init(&mtd_bdi_rw_mappable, "mtd-rwmap");
+	ret = mtd_bdi_init(&mtd_bdi, "mtd");
 	if (ret)
-		goto err_bdi3;
+		goto err_bdi;
 
 	proc_mtd = proc_create("mtd", 0, NULL, &mtd_proc_ops);
 
@@ -1260,11 +1230,7 @@ static int __init init_mtd(void)
 out_procfs:
 	if (proc_mtd)
 		remove_proc_entry("mtd", NULL);
-err_bdi3:
-	bdi_destroy(&mtd_bdi_ro_mappable);
-err_bdi2:
-	bdi_destroy(&mtd_bdi_unmappable);
-err_bdi1:
+err_bdi:
 	class_unregister(&mtd_class);
 err_reg:
 	pr_err("Error registering mtd class or bdi: %d\n", ret);
@@ -1277,9 +1243,7 @@ static void __exit cleanup_mtd(void)
 	if (proc_mtd)
 		remove_proc_entry("mtd", NULL);
 	class_unregister(&mtd_class);
-	bdi_destroy(&mtd_bdi_unmappable);
-	bdi_destroy(&mtd_bdi_ro_mappable);
-	bdi_destroy(&mtd_bdi_rw_mappable);
+	bdi_destroy(&mtd_bdi);
 }
 
 module_init(init_mtd);
diff --git a/drivers/mtd/mtdpart.c b/drivers/mtd/mtdpart.c
index a3e3a7d..e779de3 100644
--- a/drivers/mtd/mtdpart.c
+++ b/drivers/mtd/mtdpart.c
@@ -378,7 +378,6 @@ static struct mtd_part *allocate_partition(struct mtd_info *master,
 
 	slave->mtd.name = name;
 	slave->mtd.owner = master->owner;
-	slave->mtd.backing_dev_info = master->backing_dev_info;
 
 	/* NOTE:  we don't arrange MTDs as a tree; it'd be error-prone
 	 * to have the same data be in two different partitions.
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index a3367bf..d5b149c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -987,7 +987,7 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	if (err)
 		goto out_free;
 	lsi->lsi_flags |= LSI_BDI_INITIALIZED;
-	lsi->lsi_bdi.capabilities = BDI_CAP_MAP_COPY;
+	lsi->lsi_bdi.capabilities = 0;
 	err = ll_bdi_register(&lsi->lsi_bdi);
 	if (err)
 		goto out_free;
diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index 6894b08..620d934 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -335,7 +335,7 @@ struct p9_fid *v9fs_session_init(struct v9fs_session_info *v9ses,
 	}
 	init_rwsem(&v9ses->rename_sem);
 
-	rc = bdi_setup_and_register(&v9ses->bdi, "9p", BDI_CAP_MAP_COPY);
+	rc = bdi_setup_and_register(&v9ses->bdi, "9p");
 	if (rc) {
 		kfree(v9ses->aname);
 		kfree(v9ses->uname);
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index 2b60725..d142a24 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -106,7 +106,7 @@ struct afs_volume *afs_volume_lookup(struct afs_mount_params *params)
 	volume->cell		= params->cell;
 	volume->vid		= vlocation->vldb.vid[params->type];
 
-	ret = bdi_setup_and_register(&volume->bdi, "afs", BDI_CAP_MAP_COPY);
+	ret = bdi_setup_and_register(&volume->bdi, "afs");
 	if (ret)
 		goto error_bdi;
 
diff --git a/fs/aio.c b/fs/aio.c
index 1b7893e..6f13d3f 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -165,15 +165,6 @@ static struct vfsmount *aio_mnt;
 static const struct file_operations aio_ring_fops;
 static const struct address_space_operations aio_ctx_aops;
 
-/* Backing dev info for aio fs.
- * -no dirty page accounting or writeback happens
- */
-static struct backing_dev_info aio_fs_backing_dev_info = {
-	.name           = "aiofs",
-	.state          = 0,
-	.capabilities   = BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_MAP_COPY,
-};
-
 static struct file *aio_private_file(struct kioctx *ctx, loff_t nr_pages)
 {
 	struct qstr this = QSTR_INIT("[aio]", 5);
@@ -185,7 +176,7 @@ static struct file *aio_private_file(struct kioctx *ctx, loff_t nr_pages)
 
 	inode->i_mapping->a_ops = &aio_ctx_aops;
 	inode->i_mapping->private_data = ctx;
-	inode->i_mapping->backing_dev_info = &aio_fs_backing_dev_info;
+	inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
 	inode->i_size = PAGE_SIZE * nr_pages;
 
 	path.dentry = d_alloc_pseudo(aio_mnt->mnt_sb, &this);
@@ -230,9 +221,6 @@ static int __init aio_setup(void)
 	if (IS_ERR(aio_mnt))
 		panic("Failed to create aio fs mount.");
 
-	if (bdi_init(&aio_fs_backing_dev_info))
-		panic("Failed to init aio fs backing dev info.");
-
 	kiocb_cachep = KMEM_CACHE(kiocb, SLAB_HWCACHE_ALIGN|SLAB_PANIC);
 	kioctx_cachep = KMEM_CACHE(kioctx,SLAB_HWCACHE_ALIGN|SLAB_PANIC);
 
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 8c63419..afc4092 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1715,8 +1715,7 @@ static int setup_bdi(struct btrfs_fs_info *info, struct backing_dev_info *bdi)
 {
 	int err;
 
-	bdi->capabilities = BDI_CAP_MAP_COPY;
-	err = bdi_setup_and_register(bdi, "btrfs", BDI_CAP_MAP_COPY);
+	err = bdi_setup_and_register(bdi, "btrfs");
 	if (err)
 		return err;
 
diff --git a/fs/char_dev.c b/fs/char_dev.c
index 67b2007..ea06a3d 100644
--- a/fs/char_dev.c
+++ b/fs/char_dev.c
@@ -24,27 +24,6 @@
 
 #include "internal.h"
 
-/*
- * capabilities for /dev/mem, /dev/kmem and similar directly mappable character
- * devices
- * - permits shared-mmap for read, write and/or exec
- * - does not permit private mmap in NOMMU mode (can't do COW)
- * - no readahead or I/O queue unplugging required
- */
-struct backing_dev_info directly_mappable_cdev_bdi = {
-	.name = "char",
-	.capabilities	= (
-#ifdef CONFIG_MMU
-		/* permit private copies of the data to be taken */
-		BDI_CAP_MAP_COPY |
-#endif
-		/* permit direct mmap, for read, write or exec */
-		BDI_CAP_MAP_DIRECT |
-		BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP |
-		/* no writeback happens */
-		BDI_CAP_NO_ACCT_AND_WRITEBACK),
-};
-
 static struct kobj_map *cdev_map;
 
 static DEFINE_MUTEX(chrdevs_lock);
@@ -575,8 +554,6 @@ static struct kobject *base_probe(dev_t dev, int *part, void *data)
 void __init chrdev_init(void)
 {
 	cdev_map = kobj_map_init(base_probe, &chrdevs_lock);
-	if (bdi_init(&directly_mappable_cdev_bdi))
-		panic("Failed to init directly mappable cdev bdi");
 }
 
 
@@ -590,4 +567,3 @@ EXPORT_SYMBOL(cdev_del);
 EXPORT_SYMBOL(cdev_add);
 EXPORT_SYMBOL(__register_chrdev);
 EXPORT_SYMBOL(__unregister_chrdev);
-EXPORT_SYMBOL(directly_mappable_cdev_bdi);
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 2a772da..d3aa999 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3446,7 +3446,7 @@ cifs_mount(struct cifs_sb_info *cifs_sb, struct smb_vol *volume_info)
 	int referral_walks_count = 0;
 #endif
 
-	rc = bdi_setup_and_register(&cifs_sb->bdi, "cifs", BDI_CAP_MAP_COPY);
+	rc = bdi_setup_and_register(&cifs_sb->bdi, "cifs");
 	if (rc)
 		return rc;
 
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index b945410..82ec68b 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -183,7 +183,7 @@ static int coda_fill_super(struct super_block *sb, void *data, int silent)
 		goto unlock_out;
 	}
 
-	error = bdi_setup_and_register(&vc->bdi, "coda", BDI_CAP_MAP_COPY);
+	error = bdi_setup_and_register(&vc->bdi, "coda");
 	if (error)
 		goto unlock_out;
 
diff --git a/fs/configfs/configfs_internal.h b/fs/configfs/configfs_internal.h
index bd4a3c1..a315677 100644
--- a/fs/configfs/configfs_internal.h
+++ b/fs/configfs/configfs_internal.h
@@ -70,8 +70,6 @@ extern int configfs_is_root(struct config_item *item);
 
 extern struct inode * configfs_new_inode(umode_t mode, struct configfs_dirent *, struct super_block *);
 extern int configfs_create(struct dentry *, umode_t mode, int (*init)(struct inode *));
-extern int configfs_inode_init(void);
-extern void configfs_inode_exit(void);
 
 extern int configfs_create_file(struct config_item *, const struct configfs_attribute *);
 extern int configfs_make_dirent(struct configfs_dirent *,
diff --git a/fs/configfs/inode.c b/fs/configfs/inode.c
index 5946ad9..0ad6b4d 100644
--- a/fs/configfs/inode.c
+++ b/fs/configfs/inode.c
@@ -50,12 +50,6 @@ static const struct address_space_operations configfs_aops = {
 	.write_end	= simple_write_end,
 };
 
-static struct backing_dev_info configfs_backing_dev_info = {
-	.name		= "configfs",
-	.ra_pages	= 0,	/* No readahead */
-	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
-};
-
 static const struct inode_operations configfs_inode_operations ={
 	.setattr	= configfs_setattr,
 };
@@ -137,7 +131,7 @@ struct inode *configfs_new_inode(umode_t mode, struct configfs_dirent *sd,
 	if (inode) {
 		inode->i_ino = get_next_ino();
 		inode->i_mapping->a_ops = &configfs_aops;
-		inode->i_mapping->backing_dev_info = &configfs_backing_dev_info;
+		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
 		inode->i_op = &configfs_inode_operations;
 
 		if (sd->s_iattr) {
@@ -283,13 +277,3 @@ void configfs_hash_and_remove(struct dentry * dir, const char * name)
 	}
 	mutex_unlock(&dir->d_inode->i_mutex);
 }
-
-int __init configfs_inode_init(void)
-{
-	return bdi_init(&configfs_backing_dev_info);
-}
-
-void configfs_inode_exit(void)
-{
-	bdi_destroy(&configfs_backing_dev_info);
-}
diff --git a/fs/configfs/mount.c b/fs/configfs/mount.c
index f6c2858..da94e41 100644
--- a/fs/configfs/mount.c
+++ b/fs/configfs/mount.c
@@ -145,19 +145,13 @@ static int __init configfs_init(void)
 	if (!config_kobj)
 		goto out2;
 
-	err = configfs_inode_init();
-	if (err)
-		goto out3;
-
 	err = register_filesystem(&configfs_fs_type);
 	if (err)
-		goto out4;
+		goto out3;
 
 	return 0;
-out4:
-	pr_err("Unable to register filesystem!\n");
-	configfs_inode_exit();
 out3:
+	pr_err("Unable to register filesystem!\n");
 	kobject_put(config_kobj);
 out2:
 	kmem_cache_destroy(configfs_dir_cachep);
@@ -172,7 +166,6 @@ static void __exit configfs_exit(void)
 	kobject_put(config_kobj);
 	kmem_cache_destroy(configfs_dir_cachep);
 	configfs_dir_cachep = NULL;
-	configfs_inode_exit();
 }
 
 MODULE_AUTHOR("Oracle");
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index d9eb84b..1895d60 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -520,7 +520,7 @@ static struct dentry *ecryptfs_mount(struct file_system_type *fs_type, int flags
 		goto out;
 	}
 
-	rc = bdi_setup_and_register(&sbi->bdi, "ecryptfs", BDI_CAP_MAP_COPY);
+	rc = bdi_setup_and_register(&sbi->bdi, "ecryptfs");
 	if (rc)
 		goto out1;
 
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 9596550..fcc2e56 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -836,7 +836,7 @@ static int exofs_fill_super(struct super_block *sb, void *data, int silent)
 		goto free_sbi;
 	}
 
-	ret = bdi_setup_and_register(&sbi->bdi, "exofs", BDI_CAP_MAP_COPY);
+	ret = bdi_setup_and_register(&sbi->bdi, "exofs");
 	if (ret) {
 		EXOFS_DBGMSG("Failed to bdi_setup_and_register\n");
 		dput(sb->s_root);
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index e31e589..a699a3f 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -560,7 +560,7 @@ static int ncp_fill_super(struct super_block *sb, void *raw_data, int silent)
 	server = NCP_SBP(sb);
 	memset(server, 0, sizeof(*server));
 
-	error = bdi_setup_and_register(&server->bdi, "ncpfs", BDI_CAP_MAP_COPY);
+	error = bdi_setup_and_register(&server->bdi, "ncpfs");
 	if (error)
 		goto out_fput;
 
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index bbafbde..d1390b8d 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -33,8 +33,15 @@ static unsigned long ramfs_nommu_get_unmapped_area(struct file *file,
 						   unsigned long pgoff,
 						   unsigned long flags);
 static int ramfs_nommu_mmap(struct file *file, struct vm_area_struct *vma);
+	
+static unsigned ramfs_mmap_capabilities(struct file *file)
+{
+	return NOMMU_MAP_DIRECT | NOMMU_MAP_COPY | NOMMU_MAP_READ |
+		NOMMU_MAP_WRITE | NOMMU_MAP_EXEC;
+}
 
 const struct file_operations ramfs_file_operations = {
+	.mmap_capabilities	= ramfs_mmap_capabilities,
 	.mmap			= ramfs_nommu_mmap,
 	.get_unmapped_area	= ramfs_nommu_get_unmapped_area,
 	.read			= new_sync_read,
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index d365b1c..ad4d712 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -50,14 +50,6 @@ static const struct address_space_operations ramfs_aops = {
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 };
 
-static struct backing_dev_info ramfs_backing_dev_info = {
-	.name		= "ramfs",
-	.ra_pages	= 0,	/* No readahead */
-	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK |
-			  BDI_CAP_MAP_DIRECT | BDI_CAP_MAP_COPY |
-			  BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP,
-};
-
 struct inode *ramfs_get_inode(struct super_block *sb,
 				const struct inode *dir, umode_t mode, dev_t dev)
 {
@@ -67,7 +59,7 @@ struct inode *ramfs_get_inode(struct super_block *sb,
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
 		inode->i_mapping->a_ops = &ramfs_aops;
-		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
+		inode->i_mapping->backing_dev_info = &noop_backing_dev_info;
 		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
 		mapping_set_unevictable(inode->i_mapping);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
@@ -267,19 +259,9 @@ static struct file_system_type ramfs_fs_type = {
 int __init init_ramfs_fs(void)
 {
 	static unsigned long once;
-	int err;
 
 	if (test_and_set_bit(0, &once))
 		return 0;
-
-	err = bdi_init(&ramfs_backing_dev_info);
-	if (err)
-		return err;
-
-	err = register_filesystem(&ramfs_fs_type);
-	if (err)
-		bdi_destroy(&ramfs_backing_dev_info);
-
-	return err;
+	return register_filesystem(&ramfs_fs_type);
 }
 fs_initcall(init_ramfs_fs);
diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
index ea06c75..7da9e21 100644
--- a/fs/romfs/mmap-nommu.c
+++ b/fs/romfs/mmap-nommu.c
@@ -70,6 +70,15 @@ static int romfs_mmap(struct file *file, struct vm_area_struct *vma)
 	return vma->vm_flags & (VM_SHARED | VM_MAYSHARE) ? 0 : -ENOSYS;
 }
 
+static unsigned romfs_mmap_capabilities(struct file *file)
+{
+	struct mtd_info *mtd = file_inode(file)->i_sb->s_mtd;
+
+	if (!mtd)
+		return NOMMU_MAP_COPY;
+	return mtd_mmap_capabilities(mtd);
+}
+
 const struct file_operations romfs_ro_fops = {
 	.llseek			= generic_file_llseek,
 	.read			= new_sync_read,
@@ -77,4 +86,5 @@ const struct file_operations romfs_ro_fops = {
 	.splice_read		= generic_file_splice_read,
 	.mmap			= romfs_mmap,
 	.get_unmapped_area	= romfs_get_unmapped_area,
+	.mmap_capabilities	= romfs_mmap_capabilities,
 };
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 106bf20..ed93dc6 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2017,7 +2017,7 @@ static int ubifs_fill_super(struct super_block *sb, void *data, int silent)
 	 * Read-ahead will be disabled because @c->bdi.ra_pages is 0.
 	 */
 	c->bdi.name = "ubifs",
-	c->bdi.capabilities = BDI_CAP_MAP_COPY;
+	c->bdi.capabilities = 0;
 	err  = bdi_init(&c->bdi);
 	if (err)
 		goto out_close;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index e936cea..478f95d 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -114,7 +114,7 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		const char *fmt, ...);
 int bdi_register_dev(struct backing_dev_info *bdi, dev_t dev);
 void bdi_unregister(struct backing_dev_info *bdi);
-int __must_check bdi_setup_and_register(struct backing_dev_info *, char *, unsigned int);
+int __must_check bdi_setup_and_register(struct backing_dev_info *, char *);
 void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 			enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
@@ -228,42 +228,17 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_NO_ACCT_DIRTY:  Dirty pages shouldn't contribute to accounting
  * BDI_CAP_NO_WRITEBACK:   Don't write pages back
  * BDI_CAP_NO_ACCT_WB:     Don't automatically account writeback pages
- *
- * These flags let !MMU mmap() govern direct device mapping vs immediate
- * copying more easily for MAP_PRIVATE, especially for ROM filesystems.
- *
- * BDI_CAP_MAP_COPY:       Copy can be mapped (MAP_PRIVATE)
- * BDI_CAP_MAP_DIRECT:     Can be mapped directly (MAP_SHARED)
- * BDI_CAP_READ_MAP:       Can be mapped for reading
- * BDI_CAP_WRITE_MAP:      Can be mapped for writing
- * BDI_CAP_EXEC_MAP:       Can be mapped for execution
- *
  * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
-#define BDI_CAP_MAP_COPY	0x00000004
-#define BDI_CAP_MAP_DIRECT	0x00000008
-#define BDI_CAP_READ_MAP	0x00000010
-#define BDI_CAP_WRITE_MAP	0x00000020
-#define BDI_CAP_EXEC_MAP	0x00000040
-#define BDI_CAP_NO_ACCT_WB	0x00000080
-#define BDI_CAP_STABLE_WRITES	0x00000200
-#define BDI_CAP_STRICTLIMIT	0x00000400
-
-#define BDI_CAP_VMFLAGS \
-	(BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP)
+#define BDI_CAP_NO_ACCT_WB	0x00000004
+#define BDI_CAP_STABLE_WRITES	0x00000008
+#define BDI_CAP_STRICTLIMIT	0x00000010
 
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
 
-#if defined(VM_MAYREAD) && \
-	(BDI_CAP_READ_MAP != VM_MAYREAD || \
-	 BDI_CAP_WRITE_MAP != VM_MAYWRITE || \
-	 BDI_CAP_EXEC_MAP != VM_MAYEXEC)
-#error please change backing_dev_info::capabilities flags
-#endif
-
 extern struct backing_dev_info default_backing_dev_info;
 extern struct backing_dev_info noop_backing_dev_info;
 
diff --git a/include/linux/cdev.h b/include/linux/cdev.h
index fb45919..f876361 100644
--- a/include/linux/cdev.h
+++ b/include/linux/cdev.h
@@ -30,6 +30,4 @@ void cdev_del(struct cdev *);
 
 void cd_forget(struct inode *);
 
-extern struct backing_dev_info directly_mappable_cdev_bdi;
-
 #endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f90c028..7939a2e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1502,6 +1502,26 @@ struct block_device_operations;
 #define HAVE_COMPAT_IOCTL 1
 #define HAVE_UNLOCKED_IOCTL 1
 
+/*
+ * These flags let !MMU mmap() govern direct device mapping vs immediate
+ * copying more easily for MAP_PRIVATE, especially for ROM filesystems.
+ *
+ * NOMMU_MAP_COPY:	Copy can be mapped (MAP_PRIVATE)
+ * NOMMU_MAP_DIRECT:	Can be mapped directly (MAP_SHARED)
+ * NOMMU_MAP_READ:	Can be mapped for reading
+ * NOMMU_MAP_WRITE:	Can be mapped for writing
+ * NOMMU_MAP_EXEC:	Can be mapped for execution
+ */
+#define NOMMU_MAP_COPY		0x00000001
+#define NOMMU_MAP_DIRECT	0x00000008
+#define NOMMU_MAP_READ		VM_MAYREAD
+#define NOMMU_MAP_WRITE		VM_MAYWRITE
+#define NOMMU_MAP_EXEC		VM_MAYEXEC
+
+#define NOMMU_VMFLAGS \
+	(NOMMU_MAP_READ | NOMMU_MAP_WRITE | NOMMU_MAP_EXEC)
+
+
 struct iov_iter;
 
 struct file_operations {
@@ -1536,6 +1556,9 @@ struct file_operations {
 	long (*fallocate)(struct file *file, int mode, loff_t offset,
 			  loff_t len);
 	void (*show_fdinfo)(struct seq_file *m, struct file *f);
+#ifndef CONFIG_MMU
+	unsigned (*mmap_capabilities)(struct file *);
+#endif
 };
 
 struct inode_operations {
diff --git a/include/linux/mtd/mtd.h b/include/linux/mtd/mtd.h
index 031ff3a..3301c4c 100644
--- a/include/linux/mtd/mtd.h
+++ b/include/linux/mtd/mtd.h
@@ -408,4 +408,6 @@ static inline int mtd_is_bitflip_or_eccerr(int err) {
 	return mtd_is_bitflip(err) || mtd_is_eccerr(err);
 }
 
+unsigned mtd_mmap_capabilities(struct mtd_info *mtd);
+
 #endif /* __MTD_MTD_H__ */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 0ae0df5..16c6895 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -17,8 +17,6 @@ static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
 struct backing_dev_info default_backing_dev_info = {
 	.name		= "default",
 	.ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
-	.state		= 0,
-	.capabilities	= BDI_CAP_MAP_COPY,
 };
 EXPORT_SYMBOL_GPL(default_backing_dev_info);
 
@@ -513,13 +511,12 @@ EXPORT_SYMBOL(bdi_destroy);
  * For use from filesystems to quickly init and register a bdi associated
  * with dirty writeback
  */
-int bdi_setup_and_register(struct backing_dev_info *bdi, char *name,
-			   unsigned int cap)
+int bdi_setup_and_register(struct backing_dev_info *bdi, char *name)
 {
 	int err;
 
 	bdi->name = name;
-	bdi->capabilities = cap;
+	bdi->capabilities = 0;
 	err = bdi_init(bdi);
 	if (err)
 		return err;
diff --git a/mm/nommu.c b/mm/nommu.c
index b51eadf..13af96f3 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -946,9 +946,6 @@ static int validate_mmap_request(struct file *file,
 		return -EOVERFLOW;
 
 	if (file) {
-		/* validate file mapping requests */
-		struct address_space *mapping;
-
 		/* files must support mmap */
 		if (!file->f_op->mmap)
 			return -ENODEV;
@@ -957,28 +954,22 @@ static int validate_mmap_request(struct file *file,
 		 * - we support chardevs that provide their own "memory"
 		 * - we support files/blockdevs that are memory backed
 		 */
-		mapping = file->f_mapping;
-		if (!mapping)
-			mapping = file_inode(file)->i_mapping;
-
-		capabilities = 0;
-		if (mapping && mapping->backing_dev_info)
-			capabilities = mapping->backing_dev_info->capabilities;
-
-		if (!capabilities) {
+		if (file->f_op->mmap_capabilities) {
+			capabilities = file->f_op->mmap_capabilities(file);
+		} else {
 			/* no explicit capabilities set, so assume some
 			 * defaults */
 			switch (file_inode(file)->i_mode & S_IFMT) {
 			case S_IFREG:
 			case S_IFBLK:
-				capabilities = BDI_CAP_MAP_COPY;
+				capabilities = NOMMU_MAP_COPY;
 				break;
 
 			case S_IFCHR:
 				capabilities =
-					BDI_CAP_MAP_DIRECT |
-					BDI_CAP_READ_MAP |
-					BDI_CAP_WRITE_MAP;
+					NOMMU_MAP_DIRECT |
+					NOMMU_MAP_READ |
+					NOMMU_MAP_WRITE;
 				break;
 
 			default:
@@ -989,9 +980,9 @@ static int validate_mmap_request(struct file *file,
 		/* eliminate any capabilities that we can't support on this
 		 * device */
 		if (!file->f_op->get_unmapped_area)
-			capabilities &= ~BDI_CAP_MAP_DIRECT;
+			capabilities &= ~NOMMU_MAP_DIRECT;
 		if (!file->f_op->read)
-			capabilities &= ~BDI_CAP_MAP_COPY;
+			capabilities &= ~NOMMU_MAP_COPY;
 
 		/* The file shall have been opened with read permission. */
 		if (!(file->f_mode & FMODE_READ))
@@ -1010,29 +1001,29 @@ static int validate_mmap_request(struct file *file,
 			if (locks_verify_locked(file))
 				return -EAGAIN;
 
-			if (!(capabilities & BDI_CAP_MAP_DIRECT))
+			if (!(capabilities & NOMMU_MAP_DIRECT))
 				return -ENODEV;
 
 			/* we mustn't privatise shared mappings */
-			capabilities &= ~BDI_CAP_MAP_COPY;
+			capabilities &= ~NOMMU_MAP_COPY;
 		} else {
 			/* we're going to read the file into private memory we
 			 * allocate */
-			if (!(capabilities & BDI_CAP_MAP_COPY))
+			if (!(capabilities & NOMMU_MAP_COPY))
 				return -ENODEV;
 
 			/* we don't permit a private writable mapping to be
 			 * shared with the backing device */
 			if (prot & PROT_WRITE)
-				capabilities &= ~BDI_CAP_MAP_DIRECT;
+				capabilities &= ~NOMMU_MAP_DIRECT;
 		}
 
-		if (capabilities & BDI_CAP_MAP_DIRECT) {
-			if (((prot & PROT_READ)  && !(capabilities & BDI_CAP_READ_MAP))  ||
-			    ((prot & PROT_WRITE) && !(capabilities & BDI_CAP_WRITE_MAP)) ||
-			    ((prot & PROT_EXEC)  && !(capabilities & BDI_CAP_EXEC_MAP))
+		if (capabilities & NOMMU_MAP_DIRECT) {
+			if (((prot & PROT_READ)  && !(capabilities & NOMMU_MAP_READ))  ||
+			    ((prot & PROT_WRITE) && !(capabilities & NOMMU_MAP_WRITE)) ||
+			    ((prot & PROT_EXEC)  && !(capabilities & NOMMU_MAP_EXEC))
 			    ) {
-				capabilities &= ~BDI_CAP_MAP_DIRECT;
+				capabilities &= ~NOMMU_MAP_DIRECT;
 				if (flags & MAP_SHARED) {
 					printk(KERN_WARNING
 					       "MAP_SHARED not completely supported on !MMU\n");
@@ -1049,21 +1040,21 @@ static int validate_mmap_request(struct file *file,
 		} else if ((prot & PROT_READ) && !(prot & PROT_EXEC)) {
 			/* handle implication of PROT_EXEC by PROT_READ */
 			if (current->personality & READ_IMPLIES_EXEC) {
-				if (capabilities & BDI_CAP_EXEC_MAP)
+				if (capabilities & NOMMU_MAP_EXEC)
 					prot |= PROT_EXEC;
 			}
 		} else if ((prot & PROT_READ) &&
 			 (prot & PROT_EXEC) &&
-			 !(capabilities & BDI_CAP_EXEC_MAP)
+			 !(capabilities & NOMMU_MAP_EXEC)
 			 ) {
 			/* backing file is not executable, try to copy */
-			capabilities &= ~BDI_CAP_MAP_DIRECT;
+			capabilities &= ~NOMMU_MAP_DIRECT;
 		}
 	} else {
 		/* anonymous mappings are always memory backed and can be
 		 * privately mapped
 		 */
-		capabilities = BDI_CAP_MAP_COPY;
+		capabilities = NOMMU_MAP_COPY;
 
 		/* handle PROT_EXEC implication by PROT_READ */
 		if ((prot & PROT_READ) &&
@@ -1095,7 +1086,7 @@ static unsigned long determine_vm_flags(struct file *file,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags);
 	/* vm_flags |= mm->def_flags; */
 
-	if (!(capabilities & BDI_CAP_MAP_DIRECT)) {
+	if (!(capabilities & NOMMU_MAP_DIRECT)) {
 		/* attempt to share read-only copies of mapped file chunks */
 		vm_flags |= VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 		if (file && !(prot & PROT_WRITE))
@@ -1104,7 +1095,7 @@ static unsigned long determine_vm_flags(struct file *file,
 		/* overlay a shareable mapping on the backing device or inode
 		 * if possible - used for chardevs, ramfs/tmpfs/shmfs and
 		 * romfs/cramfs */
-		vm_flags |= VM_MAYSHARE | (capabilities & BDI_CAP_VMFLAGS);
+		vm_flags |= VM_MAYSHARE | (capabilities & NOMMU_VMFLAGS);
 		if (flags & MAP_SHARED)
 			vm_flags |= VM_SHARED;
 	}
@@ -1157,7 +1148,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	 * shared mappings on devices or memory
 	 * - VM_MAYSHARE will be set if it may attempt to share
 	 */
-	if (capabilities & BDI_CAP_MAP_DIRECT) {
+	if (capabilities & NOMMU_MAP_DIRECT) {
 		ret = vma->vm_file->f_op->mmap(vma->vm_file, vma);
 		if (ret == 0) {
 			/* shouldn't return success if we're not sharing */
@@ -1346,7 +1337,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 			if ((pregion->vm_pgoff != pgoff || rpglen != pglen) &&
 			    !(pgoff >= pregion->vm_pgoff && pgend <= rpgend)) {
 				/* new mapping is not a subset of the region */
-				if (!(capabilities & BDI_CAP_MAP_DIRECT))
+				if (!(capabilities & NOMMU_MAP_DIRECT))
 					goto sharing_violation;
 				continue;
 			}
@@ -1385,7 +1376,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 		 * - this is the hook for quasi-memory character devices to
 		 *   tell us the location of a shared mapping
 		 */
-		if (capabilities & BDI_CAP_MAP_DIRECT) {
+		if (capabilities & NOMMU_MAP_DIRECT) {
 			addr = file->f_op->get_unmapped_area(file, addr, len,
 							     pgoff, flags);
 			if (IS_ERR_VALUE(addr)) {
@@ -1397,10 +1388,10 @@ unsigned long do_mmap_pgoff(struct file *file,
 				 * the mapping so we'll have to attempt to copy
 				 * it */
 				ret = -ENODEV;
-				if (!(capabilities & BDI_CAP_MAP_COPY))
+				if (!(capabilities & NOMMU_MAP_COPY))
 					goto error_just_free;
 
-				capabilities &= ~BDI_CAP_MAP_DIRECT;
+				capabilities &= ~NOMMU_MAP_DIRECT;
 			} else {
 				vma->vm_start = region->vm_start = addr;
 				vma->vm_end = region->vm_end = addr + len;
@@ -1411,7 +1402,7 @@ unsigned long do_mmap_pgoff(struct file *file,
 	vma->vm_region = region;
 
 	/* set up the mapping
-	 * - the region is filled in if BDI_CAP_MAP_DIRECT is still set
+	 * - the region is filled in if NOMMU_MAP_DIRECT is still set
 	 */
 	if (file && vma->vm_flags & VM_SHARED)
 		ret = do_mmap_shared_file(vma);
diff --git a/security/security.c b/security/security.c
index 18b35c6..a0442b2 100644
--- a/security/security.c
+++ b/security/security.c
@@ -726,16 +726,15 @@ static inline unsigned long mmap_prot(struct file *file, unsigned long prot)
 		return prot | PROT_EXEC;
 	/*
 	 * ditto if it's not on noexec mount, except that on !MMU we need
-	 * BDI_CAP_EXEC_MMAP (== VM_MAYEXEC) in this case
+	 * NOMMU_MAP_EXEC (== VM_MAYEXEC) in this case
 	 */
 	if (!(file->f_path.mnt->mnt_flags & MNT_NOEXEC)) {
 #ifndef CONFIG_MMU
-		unsigned long caps = 0;
-		struct address_space *mapping = file->f_mapping;
-		if (mapping && mapping->backing_dev_info)
-			caps = mapping->backing_dev_info->capabilities;
-		if (!(caps & BDI_CAP_EXEC_MAP))
-			return prot;
+		if (file->f_op->mmap_capabilities) {
+			unsigned caps = file->f_op->mmap_capabilities(file);
+			if (!(caps & NOMMU_MAP_EXEC))
+				return prot;
+		}
 #endif
 		return prot | PROT_EXEC;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
