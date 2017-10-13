Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9CC6B026B
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 16:09:27 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r18so7042812qkh.9
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:09:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r44sor1349870qtj.112.2017.10.13.13.09.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 13:09:25 -0700 (PDT)
Date: Fri, 13 Oct 2017 16:09:23 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v6 1/4] cramfs: direct memory access support
In-Reply-To: <20171013175208.GI21978@ZenIV.linux.org.uk>
Message-ID: <nycvar.YSQ.7.76.1710131532291.1750@knanqh.ubzr>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org> <20171012061613.28705-2-nicolas.pitre@linaro.org> <20171013172934.GG21978@ZenIV.linux.org.uk> <nycvar.YSQ.7.76.1710131332360.1718@knanqh.ubzr> <20171013175208.GI21978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

On Fri, 13 Oct 2017, Al Viro wrote:

> OK...  I wonder if it should simply define stubs for kill_mtd_super(),
> mtd_unpoint() and kill_block_super() in !CONFIG_MTD and !CONFIG_BLOCK
> cases.  mount_mtd() and mount_bdev() as well - e.g.  mount_bdev()
> returning ERR_PTR(-ENODEV) and kill_block_super() being simply BUG()
> in !CONFIG_BLOCK case.  Then cramfs_kill_sb() would be
> 	if (sb->s_mtd) {
> 		if (sbi->mtd_point_size)
> 			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
> 		kill_mtd_super(sb);
> 	} else {
> 		kill_block_super(sb);
> 	}
> 	kfree(sbi);

Well... Stubs have to be named differently or they conflict with 
existing declarations. At that point that makes for more lines of code 
compared to the current patch and the naming indirection makes it less 
obvious when reading the code. Alternatively I could add those stubs in 
the corresponding header files and #ifdef the existing declarations 
away. That might look somewhat less cluttered in the main code but it 
also hides what is actually going on and left me unconvinced. And I'm 
not sure this is worth it in the end given this is not a common 
occurrence in the kernel either.

Still, I've rearanged it slightly and fixed the null deref you spotted 
earlier. Latest patch below:

----- >8
Subject: [PATCH] cramfs: direct memory access support

Small embedded systems typically execute the kernel code in place (XIP)
directly from flash to save on precious RAM usage. This patch adds to
cramfs the ability to consume filesystem data directly from flash as
well. Cramfs is particularly well suited to this feature as it is very
simple with low RAM usage, and with this feature it is possible to use
it with no block device support and consequently even lower RAM usage.

This patch was inspired by a similar patch from Shane Nay dated 17 years
ago that used to be very popular in embedded circles but never made it
into mainline. This is a cleaned-up implementation that uses far fewer
ifdef's and gets the actual memory location for the filesystem image
via MTD at run time. In the context of small IoT deployments, this
functionality has become relevant and useful again.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Tested-by: Chris Brandt <chris.brandt@renesas.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>

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
index 7919967488..bcdccb7a82 100644
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
+ * Populate our block cache and return a pointer to it.
  */
-static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned int len)
+static void *cramfs_blkdev_read(struct super_block *sb, unsigned int offset,
+				unsigned int len)
 {
 	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
 	struct page *pages[BLKS_PER_BUF];
@@ -239,11 +247,49 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
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
+	if (IS_ENABLED(CCONFIG_CRAMFS_MTD) && sb->s_mtd) {
+		if (sbi && sbi->mtd_point_size)
+			mtd_unpoint(sb->s_mtd, 0, sbi->mtd_point_size);
+		kill_mtd_super(sb);
+	} else if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV) && sb->s_bdev) {
+		kill_block_super(sb);
+	}
 	kfree(sbi);
 }
 
@@ -254,34 +300,24 @@ static int cramfs_remount(struct super_block *sb, int *flags, char *data)
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
@@ -289,10 +325,12 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 
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
@@ -301,34 +339,34 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
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
@@ -336,9 +374,18 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
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
@@ -347,10 +394,79 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
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
@@ -573,10 +689,22 @@ static const struct super_operations cramfs_ops = {
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
