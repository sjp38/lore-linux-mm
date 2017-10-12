Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E097A6B0266
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 02:16:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 32so2953772qtp.3
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 23:16:46 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp2.pobox.com. [64.147.108.71])
        by mx.google.com with ESMTPS id 62si1333346qth.150.2017.10.11.23.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 23:16:44 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v6 1/4] cramfs: direct memory access support
Date: Thu, 12 Oct 2017 02:16:10 -0400
Message-Id: <20171012061613.28705-2-nicolas.pitre@linaro.org>
In-Reply-To: <20171012061613.28705-1-nicolas.pitre@linaro.org>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

Small embedded systems typically execute the kernel code in place (XIP)
directly from flash to save on precious RAM usage. This adds the ability
to consume filesystem data directly from flash to the cramfs filesystem
as well. Cramfs is particularly well suited to this feature as it is
very simple and its RAM usage is already very low, and with this feature
it is possible to use it with no block device support and even lower RAM
usage.

This patch was inspired by a similar patch from Shane Nay dated 17 years
ago that used to be very popular in embedded circles but never made it
into mainline. This is a cleaned-up implementation that uses far fewer
ifdef's and gets the actual memory location for the filesystem image
via MTD at run time. In the context of small IoT deployments, this
functionality has become relevant and useful again.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
---
 fs/cramfs/Kconfig |  30 +++++++-
 fs/cramfs/inode.c | 215 +++++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 202 insertions(+), 43 deletions(-)

diff --git a/fs/cramfs/Kconfig b/fs/cramfs/Kconfig
index 11b29d491b..ef86b06bc0 100644
--- a/fs/cramfs/Kconfig
+++ b/fs/cramfs/Kconfig
@@ -1,6 +1,5 @@
 config CRAMFS
 	tristate "Compressed ROM file system support (cramfs) (OBSOLETE)"
-	depends on BLOCK
 	select ZLIB_INFLATE
 	help
 	  Saying Y here includes support for CramFs (Compressed ROM File
@@ -20,3 +19,32 @@ config CRAMFS
 	  in terms of performance and features.
 
 	  If unsure, say N.
+
+config CRAMFS_BLOCKDEV
+	bool "Support CramFs image over a regular block device" if EXPERT
+	depends on CRAMFS && BLOCK
+	default y
+	help
+	  This option allows the CramFs driver to load data from a regular
+	  block device such a disk partition or a ramdisk.
+
+config CRAMFS_MTD
+	bool "Support CramFs image directly mapped in physical memory"
+	depends on CRAMFS && MTD
+	default y if !CRAMFS_BLOCKDEV
+	help
+	  This option allows the CramFs driver to load data directly from
+	  a linear adressed memory range (usually non volatile memory
+	  like flash) instead of going through the block device layer.
+	  This saves some memory since no intermediate buffering is
+	  necessary.
+
+	  The location of the CramFs image is determined by a
+	  MTD device capable of direct memory mapping e.g. from
+	  the 'physmap' map driver or a resulting MTD partition.
+	  For example, this would mount the cramfs image stored in
+	  the MTD partition named "xip_fs" on the /mnt mountpoint:
+
+	  mount -t cramfs mtd:xip_fs /mnt
+
+	  If unsure, say N.
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index 7919967488..321a1fe17e 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -19,6 +19,8 @@
 #include <linux/init.h>
 #include <linux/string.h>
 #include <linux/blkdev.h>
+#include <linux/mtd/mtd.h>
+#include <linux/mtd/super.h>
 #include <linux/slab.h>
 #include <linux/vfs.h>
 #include <linux/mutex.h>
@@ -36,6 +38,9 @@ struct cramfs_sb_info {
 	unsigned long blocks;
 	unsigned long files;
 	unsigned long flags;
+	void *linear_virt_addr;
+	resource_size_t linear_phys_addr;
+	size_t mtd_point_size;
 };
 
 static inline struct cramfs_sb_info *CRAMFS_SB(struct super_block *sb)
@@ -140,6 +145,9 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
  * BLKS_PER_BUF*PAGE_SIZE, so that the caller doesn't need to
  * worry about end-of-buffer issues even when decompressing a full
  * page cache.
+ *
+ * Note: This is all optimized away at compile time when
+ *       CONFIG_CRAMFS_BLOCKDEV=n.
  */
 #define READ_BUFFERS (2)
 /* NEXT_BUFFER(): Loop over [0..(READ_BUFFERS-1)]. */
@@ -160,10 +168,10 @@ static struct super_block *buffer_dev[READ_BUFFERS];
 static int next_buffer;
 
 /*
- * Returns a pointer to a buffer containing at least LEN bytes of
- * filesystem starting at byte offset OFFSET into the filesystem.
+ * Populate our block cache and return a pointer from it.
  */
-static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned int len)
+static void *cramfs_blkdev_read(struct super_block *sb, unsigned int offset,
+				unsigned int len)
 {
 	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
 	struct page *pages[BLKS_PER_BUF];
@@ -239,11 +247,52 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 	return read_buffers[buffer] + offset;
 }
 
+/*
+ * Return a pointer to the linearly addressed cramfs image in memory.
+ */
+static void *cramfs_direct_read(struct super_block *sb, unsigned int offset,
+				unsigned int len)
+{
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+
+	if (!len)
+		return NULL;
+	if (len > sbi->size || offset > sbi->size - len)
+		return page_address(ZERO_PAGE(0));
+	return sbi->linear_virt_addr + offset;
+}
+
+/*
+ * Returns a pointer to a buffer containing at least LEN bytes of
+ * filesystem starting at byte offset OFFSET into the filesystem.
+ */
+static void *cramfs_read(struct super_block *sb, unsigned int offset,
+			 unsigned int len)
+{
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+
+	if (IS_ENABLED(CONFIG_CRAMFS_MTD) && sbi->linear_virt_addr)
+		return cramfs_direct_read(sb, offset, len);
+	else if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV))
+		return cramfs_blkdev_read(sb, offset, len);
+	else
+		return NULL;
+}
+
 static void cramfs_kill_sb(struct super_block *sb)
 {
 	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
 
-	kill_block_super(sb);
+	if (IS_ENABLED(CCONFIG_CRAMFS_MTD)) {
+		if (sbi->mtd_point_size)
+			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
+		if (sb->s_mtd)
+			kill_mtd_super(sb);
+	}
+	if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV)) {
+		if (sb->s_bdev)
+			kill_block_super(sb);
+	}
 	kfree(sbi);
 }
 
@@ -254,34 +303,24 @@ static int cramfs_remount(struct super_block *sb, int *flags, char *data)
 	return 0;
 }
 
-static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
+static int cramfs_read_super(struct super_block *sb,
+			     struct cramfs_super *super, int silent)
 {
-	int i;
-	struct cramfs_super super;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
 	unsigned long root_offset;
-	struct cramfs_sb_info *sbi;
-	struct inode *root;
-
-	sb->s_flags |= MS_RDONLY;
-
-	sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
-	if (!sbi)
-		return -ENOMEM;
-	sb->s_fs_info = sbi;
 
-	/* Invalidate the read buffers on mount: think disk change.. */
-	mutex_lock(&read_mutex);
-	for (i = 0; i < READ_BUFFERS; i++)
-		buffer_blocknr[i] = -1;
+	/* We don't know the real size yet */
+	sbi->size = PAGE_SIZE;
 
 	/* Read the first block and get the superblock from it */
-	memcpy(&super, cramfs_read(sb, 0, sizeof(super)), sizeof(super));
+	mutex_lock(&read_mutex);
+	memcpy(super, cramfs_read(sb, 0, sizeof(*super)), sizeof(*super));
 	mutex_unlock(&read_mutex);
 
 	/* Do sanity checks on the superblock */
-	if (super.magic != CRAMFS_MAGIC) {
+	if (super->magic != CRAMFS_MAGIC) {
 		/* check for wrong endianness */
-		if (super.magic == CRAMFS_MAGIC_WEND) {
+		if (super->magic == CRAMFS_MAGIC_WEND) {
 			if (!silent)
 				pr_err("wrong endianness\n");
 			return -EINVAL;
@@ -289,10 +328,12 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 
 		/* check at 512 byte offset */
 		mutex_lock(&read_mutex);
-		memcpy(&super, cramfs_read(sb, 512, sizeof(super)), sizeof(super));
+		memcpy(super,
+		       cramfs_read(sb, 512, sizeof(*super)),
+		       sizeof(*super));
 		mutex_unlock(&read_mutex);
-		if (super.magic != CRAMFS_MAGIC) {
-			if (super.magic == CRAMFS_MAGIC_WEND && !silent)
+		if (super->magic != CRAMFS_MAGIC) {
+			if (super->magic == CRAMFS_MAGIC_WEND && !silent)
 				pr_err("wrong endianness\n");
 			else if (!silent)
 				pr_err("wrong magic\n");
@@ -301,34 +342,34 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 	}
 
 	/* get feature flags first */
-	if (super.flags & ~CRAMFS_SUPPORTED_FLAGS) {
+	if (super->flags & ~CRAMFS_SUPPORTED_FLAGS) {
 		pr_err("unsupported filesystem features\n");
 		return -EINVAL;
 	}
 
 	/* Check that the root inode is in a sane state */
-	if (!S_ISDIR(super.root.mode)) {
+	if (!S_ISDIR(super->root.mode)) {
 		pr_err("root is not a directory\n");
 		return -EINVAL;
 	}
 	/* correct strange, hard-coded permissions of mkcramfs */
-	super.root.mode |= (S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
+	super->root.mode |= 0555;
 
-	root_offset = super.root.offset << 2;
-	if (super.flags & CRAMFS_FLAG_FSID_VERSION_2) {
-		sbi->size = super.size;
-		sbi->blocks = super.fsid.blocks;
-		sbi->files = super.fsid.files;
+	root_offset = super->root.offset << 2;
+	if (super->flags & CRAMFS_FLAG_FSID_VERSION_2) {
+		sbi->size = super->size;
+		sbi->blocks = super->fsid.blocks;
+		sbi->files = super->fsid.files;
 	} else {
 		sbi->size = 1<<28;
 		sbi->blocks = 0;
 		sbi->files = 0;
 	}
-	sbi->magic = super.magic;
-	sbi->flags = super.flags;
+	sbi->magic = super->magic;
+	sbi->flags = super->flags;
 	if (root_offset == 0)
 		pr_info("empty filesystem");
-	else if (!(super.flags & CRAMFS_FLAG_SHIFTED_ROOT_OFFSET) &&
+	else if (!(super->flags & CRAMFS_FLAG_SHIFTED_ROOT_OFFSET) &&
 		 ((root_offset != sizeof(struct cramfs_super)) &&
 		  (root_offset != 512 + sizeof(struct cramfs_super))))
 	{
@@ -336,9 +377,18 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 		return -EINVAL;
 	}
 
+	return 0;
+}
+
+static int cramfs_finalize_super(struct super_block *sb,
+				 struct cramfs_inode *cramfs_root)
+{
+	struct inode *root;
+
 	/* Set it all up.. */
+	sb->s_flags |= MS_RDONLY;
 	sb->s_op = &cramfs_ops;
-	root = get_cramfs_inode(sb, &super.root, 0);
+	root = get_cramfs_inode(sb, cramfs_root, 0);
 	if (IS_ERR(root))
 		return PTR_ERR(root);
 	sb->s_root = d_make_root(root);
@@ -347,10 +397,79 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 	return 0;
 }
 
+static int cramfs_blkdev_fill_super(struct super_block *sb, void *data,
+				    int silent)
+{
+	struct cramfs_sb_info *sbi;
+	struct cramfs_super super;
+	int i, err;
+
+	sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
+	if (!sbi)
+		return -ENOMEM;
+	sb->s_fs_info = sbi;
+
+	/* Invalidate the read buffers on mount: think disk change.. */
+	for (i = 0; i < READ_BUFFERS; i++)
+		buffer_blocknr[i] = -1;
+
+	err = cramfs_read_super(sb, &super, silent);
+	if (err)
+		return err;
+	return cramfs_finalize_super(sb, &super.root);
+}
+
+static int cramfs_mtd_fill_super(struct super_block *sb, void *data,
+				 int silent)
+{
+	struct cramfs_sb_info *sbi;
+	struct cramfs_super super;
+	int err;
+
+	sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
+	if (!sbi)
+		return -ENOMEM;
+	sb->s_fs_info = sbi;
+
+	/* Map only one page for now.  Will remap it when fs size is known. */
+	err = mtd_point(sb->s_mtd, 0, PAGE_SIZE, &sbi->mtd_point_size,
+			&sbi->linear_virt_addr, &sbi->linear_phys_addr);
+	if (err || sbi->mtd_point_size != PAGE_SIZE) {
+		pr_err("unable to get direct memory access to mtd:%s\n",
+		       sb->s_mtd->name);
+		return err ? : -ENODATA;
+	}
+
+	pr_info("checking physical address %pap for linear cramfs image\n",
+		&sbi->linear_phys_addr);
+	err = cramfs_read_super(sb, &super, silent);
+	if (err)
+		return err;
+
+	/* Remap the whole filesystem now */
+	pr_info("linear cramfs image on mtd:%s appears to be %lu KB in size\n",
+		sb->s_mtd->name, sbi->size/1024);
+	mtd_unpoint(sb->s_mtd, 0, PAGE_SIZE);
+	err = mtd_point(sb->s_mtd, 0, sbi->size, &sbi->mtd_point_size,
+			&sbi->linear_virt_addr, &sbi->linear_phys_addr);
+	if (err || sbi->mtd_point_size != sbi->size) {
+		pr_err("unable to get direct memory access to mtd:%s\n",
+		       sb->s_mtd->name);
+		return err ? : -ENODATA;
+	}
+
+	return cramfs_finalize_super(sb, &super.root);
+}
+
 static int cramfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct super_block *sb = dentry->d_sb;
-	u64 id = huge_encode_dev(sb->s_bdev->bd_dev);
+	u64 id = 0;
+
+	if (sb->s_bdev)
+		id = huge_encode_dev(sb->s_bdev->bd_dev);
+	else if (sb->s_dev)
+		id = huge_encode_dev(sb->s_dev);
 
 	buf->f_type = CRAMFS_MAGIC;
 	buf->f_bsize = PAGE_SIZE;
@@ -573,10 +692,22 @@ static const struct super_operations cramfs_ops = {
 	.statfs		= cramfs_statfs,
 };
 
-static struct dentry *cramfs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static struct dentry *cramfs_mount(struct file_system_type *fs_type, int flags,
+				   const char *dev_name, void *data)
 {
-	return mount_bdev(fs_type, flags, dev_name, data, cramfs_fill_super);
+	struct dentry *ret = ERR_PTR(-ENOPROTOOPT);
+
+	if (IS_ENABLED(CONFIG_CRAMFS_MTD)) {
+		ret = mount_mtd(fs_type, flags, dev_name, data,
+				cramfs_mtd_fill_super);
+		if (!IS_ERR(ret))
+			return ret;
+	}
+	if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV)) {
+		ret = mount_bdev(fs_type, flags, dev_name, data,
+				 cramfs_blkdev_fill_super);
+	}
+	return ret;
 }
 
 static struct file_system_type cramfs_fs_type = {
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
