Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 008106B0069
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 04:29:59 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v23so7241191pgc.4
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 01:29:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l13si1007345pgq.315.2017.10.01.01.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 01:29:57 -0700 (PDT)
Date: Sun, 1 Oct 2017 01:29:55 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 1/5] cramfs: direct memory access support
Message-ID: <20171001082955.GA17116@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-2-nicolas.pitre@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927233224.31676-2-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>, linux-mtd@lists.infradead.org, devicetree@vger.kernel.org

On Wed, Sep 27, 2017 at 07:32:20PM -0400, Nicolas Pitre wrote:
> To distinguish between both access types, the cramfs_physmem filesystem
> type must be specified when using a memory accessible cramfs image, and
> the physaddr argument must provide the actual filesystem image's physical
> memory location.

Sorry, but this still is a complete no-go.  A physical address is not a
proper interface.  You still need to have some interface for your NOR nand
or DRAM.  - usually that would be a mtd driver, but if you have a good
reason why that's not suitable for you (and please explain it well)
we'll need a little OF or similar layer to bind a thin driver.

> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> Tested-by: Chris Brandt <chris.brandt@renesas.com>
> ---
>  fs/cramfs/Kconfig |  29 +++++-
>  fs/cramfs/inode.c | 264 +++++++++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 241 insertions(+), 52 deletions(-)
> 
> diff --git a/fs/cramfs/Kconfig b/fs/cramfs/Kconfig
> index 11b29d491b..5b4e0b7e13 100644
> --- a/fs/cramfs/Kconfig
> +++ b/fs/cramfs/Kconfig
> @@ -1,6 +1,5 @@
>  config CRAMFS
>  	tristate "Compressed ROM file system support (cramfs) (OBSOLETE)"
> -	depends on BLOCK
>  	select ZLIB_INFLATE
>  	help
>  	  Saying Y here includes support for CramFs (Compressed ROM File
> @@ -20,3 +19,31 @@ config CRAMFS
>  	  in terms of performance and features.
>  
>  	  If unsure, say N.
> +
> +config CRAMFS_BLOCKDEV
> +	bool "Support CramFs image over a regular block device" if EXPERT
> +	depends on CRAMFS && BLOCK
> +	default y
> +	help
> +	  This option allows the CramFs driver to load data from a regular
> +	  block device such a disk partition or a ramdisk.
> +
> +config CRAMFS_PHYSMEM
> +	bool "Support CramFs image directly mapped in physical memory"
> +	depends on CRAMFS
> +	default y if !CRAMFS_BLOCKDEV
> +	help
> +	  This option allows the CramFs driver to load data directly from
> +	  a linear adressed memory range (usually non volatile memory
> +	  like flash) instead of going through the block device layer.
> +	  This saves some memory since no intermediate buffering is
> +	  necessary.
> +
> +	  The filesystem type for this feature is "cramfs_physmem".
> +	  The location of the CramFs image in memory is board
> +	  dependent. Therefore, if you say Y, you must know the proper
> +	  physical address where to store the CramFs image and specify
> +	  it using the physaddr=0x******** mount option (for example:
> +	  "mount -t cramfs_physmem -o physaddr=0x100000 none /mnt").
> +
> +	  If unsure, say N.
> diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
> index 7919967488..19f464a214 100644
> --- a/fs/cramfs/inode.c
> +++ b/fs/cramfs/inode.c
> @@ -24,6 +24,7 @@
>  #include <linux/mutex.h>
>  #include <uapi/linux/cramfs_fs.h>
>  #include <linux/uaccess.h>
> +#include <linux/io.h>
>  
>  #include "internal.h"
>  
> @@ -36,6 +37,8 @@ struct cramfs_sb_info {
>  	unsigned long blocks;
>  	unsigned long files;
>  	unsigned long flags;
> +	void *linear_virt_addr;
> +	phys_addr_t linear_phys_addr;
>  };
>  
>  static inline struct cramfs_sb_info *CRAMFS_SB(struct super_block *sb)
> @@ -140,6 +143,9 @@ static struct inode *get_cramfs_inode(struct super_block *sb,
>   * BLKS_PER_BUF*PAGE_SIZE, so that the caller doesn't need to
>   * worry about end-of-buffer issues even when decompressing a full
>   * page cache.
> + *
> + * Note: This is all optimized away at compile time when
> + *       CONFIG_CRAMFS_BLOCKDEV=n.
>   */
>  #define READ_BUFFERS (2)
>  /* NEXT_BUFFER(): Loop over [0..(READ_BUFFERS-1)]. */
> @@ -160,10 +166,10 @@ static struct super_block *buffer_dev[READ_BUFFERS];
>  static int next_buffer;
>  
>  /*
> - * Returns a pointer to a buffer containing at least LEN bytes of
> - * filesystem starting at byte offset OFFSET into the filesystem.
> + * Populate our block cache and return a pointer from it.
>   */
> -static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned int len)
> +static void *cramfs_blkdev_read(struct super_block *sb, unsigned int offset,
> +				unsigned int len)
>  {
>  	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
>  	struct page *pages[BLKS_PER_BUF];
> @@ -239,7 +245,39 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
>  	return read_buffers[buffer] + offset;
>  }
>  
> -static void cramfs_kill_sb(struct super_block *sb)
> +/*
> + * Return a pointer to the linearly addressed cramfs image in memory.
> + */
> +static void *cramfs_direct_read(struct super_block *sb, unsigned int offset,
> +				unsigned int len)
> +{
> +	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
> +
> +	if (!len)
> +		return NULL;
> +	if (len > sbi->size || offset > sbi->size - len)
> +	       return page_address(ZERO_PAGE(0));
> +	return sbi->linear_virt_addr + offset;
> +}
> +
> +/*
> + * Returns a pointer to a buffer containing at least LEN bytes of
> + * filesystem starting at byte offset OFFSET into the filesystem.
> + */
> +static void *cramfs_read(struct super_block *sb, unsigned int offset,
> +			 unsigned int len)
> +{
> +	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
> +
> +	if (IS_ENABLED(CONFIG_CRAMFS_PHYSMEM) && sbi->linear_virt_addr)
> +		return cramfs_direct_read(sb, offset, len);
> +	else if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV))
> +		return cramfs_blkdev_read(sb, offset, len);
> +	else
> +		return NULL;
> +}
> +
> +static void cramfs_blkdev_kill_sb(struct super_block *sb)
>  {
>  	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
>  
> @@ -247,6 +285,16 @@ static void cramfs_kill_sb(struct super_block *sb)
>  	kfree(sbi);
>  }
>  
> +static void cramfs_physmem_kill_sb(struct super_block *sb)
> +{
> +	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
> +
> +	if (sbi->linear_virt_addr)
> +		memunmap(sbi->linear_virt_addr);
> +	kill_anon_super(sb);
> +	kfree(sbi);
> +}
> +
>  static int cramfs_remount(struct super_block *sb, int *flags, char *data)
>  {
>  	sync_filesystem(sb);
> @@ -254,34 +302,24 @@ static int cramfs_remount(struct super_block *sb, int *flags, char *data)
>  	return 0;
>  }
>  
> -static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
> +static int cramfs_read_super(struct super_block *sb,
> +			     struct cramfs_super *super, int silent)
>  {
> -	int i;
> -	struct cramfs_super super;
> +	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
>  	unsigned long root_offset;
> -	struct cramfs_sb_info *sbi;
> -	struct inode *root;
> -
> -	sb->s_flags |= MS_RDONLY;
> -
> -	sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
> -	if (!sbi)
> -		return -ENOMEM;
> -	sb->s_fs_info = sbi;
>  
> -	/* Invalidate the read buffers on mount: think disk change.. */
> -	mutex_lock(&read_mutex);
> -	for (i = 0; i < READ_BUFFERS; i++)
> -		buffer_blocknr[i] = -1;
> +	/* We don't know the real size yet */
> +	sbi->size = PAGE_SIZE;
>  
>  	/* Read the first block and get the superblock from it */
> -	memcpy(&super, cramfs_read(sb, 0, sizeof(super)), sizeof(super));
> +	mutex_lock(&read_mutex);
> +	memcpy(super, cramfs_read(sb, 0, sizeof(*super)), sizeof(*super));
>  	mutex_unlock(&read_mutex);
>  
>  	/* Do sanity checks on the superblock */
> -	if (super.magic != CRAMFS_MAGIC) {
> +	if (super->magic != CRAMFS_MAGIC) {
>  		/* check for wrong endianness */
> -		if (super.magic == CRAMFS_MAGIC_WEND) {
> +		if (super->magic == CRAMFS_MAGIC_WEND) {
>  			if (!silent)
>  				pr_err("wrong endianness\n");
>  			return -EINVAL;
> @@ -289,10 +327,10 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
>  
>  		/* check at 512 byte offset */
>  		mutex_lock(&read_mutex);
> -		memcpy(&super, cramfs_read(sb, 512, sizeof(super)), sizeof(super));
> +		memcpy(super, cramfs_read(sb, 512, sizeof(*super)), sizeof(*super));
>  		mutex_unlock(&read_mutex);
> -		if (super.magic != CRAMFS_MAGIC) {
> -			if (super.magic == CRAMFS_MAGIC_WEND && !silent)
> +		if (super->magic != CRAMFS_MAGIC) {
> +			if (super->magic == CRAMFS_MAGIC_WEND && !silent)
>  				pr_err("wrong endianness\n");
>  			else if (!silent)
>  				pr_err("wrong magic\n");
> @@ -301,34 +339,34 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
>  	}
>  
>  	/* get feature flags first */
> -	if (super.flags & ~CRAMFS_SUPPORTED_FLAGS) {
> +	if (super->flags & ~CRAMFS_SUPPORTED_FLAGS) {
>  		pr_err("unsupported filesystem features\n");
>  		return -EINVAL;
>  	}
>  
>  	/* Check that the root inode is in a sane state */
> -	if (!S_ISDIR(super.root.mode)) {
> +	if (!S_ISDIR(super->root.mode)) {
>  		pr_err("root is not a directory\n");
>  		return -EINVAL;
>  	}
>  	/* correct strange, hard-coded permissions of mkcramfs */
> -	super.root.mode |= (S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
> +	super->root.mode |= (S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
>  
> -	root_offset = super.root.offset << 2;
> -	if (super.flags & CRAMFS_FLAG_FSID_VERSION_2) {
> -		sbi->size = super.size;
> -		sbi->blocks = super.fsid.blocks;
> -		sbi->files = super.fsid.files;
> +	root_offset = super->root.offset << 2;
> +	if (super->flags & CRAMFS_FLAG_FSID_VERSION_2) {
> +		sbi->size = super->size;
> +		sbi->blocks = super->fsid.blocks;
> +		sbi->files = super->fsid.files;
>  	} else {
>  		sbi->size = 1<<28;
>  		sbi->blocks = 0;
>  		sbi->files = 0;
>  	}
> -	sbi->magic = super.magic;
> -	sbi->flags = super.flags;
> +	sbi->magic = super->magic;
> +	sbi->flags = super->flags;
>  	if (root_offset == 0)
>  		pr_info("empty filesystem");
> -	else if (!(super.flags & CRAMFS_FLAG_SHIFTED_ROOT_OFFSET) &&
> +	else if (!(super->flags & CRAMFS_FLAG_SHIFTED_ROOT_OFFSET) &&
>  		 ((root_offset != sizeof(struct cramfs_super)) &&
>  		  (root_offset != 512 + sizeof(struct cramfs_super))))
>  	{
> @@ -336,9 +374,18 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
>  		return -EINVAL;
>  	}
>  
> +	return 0;
> +}
> +
> +static int cramfs_finalize_super(struct super_block *sb,
> +				 struct cramfs_inode *cramfs_root)
> +{
> +	struct inode *root;
> +
>  	/* Set it all up.. */
> +	sb->s_flags |= MS_RDONLY;
>  	sb->s_op = &cramfs_ops;
> -	root = get_cramfs_inode(sb, &super.root, 0);
> +	root = get_cramfs_inode(sb, cramfs_root, 0);
>  	if (IS_ERR(root))
>  		return PTR_ERR(root);
>  	sb->s_root = d_make_root(root);
> @@ -347,6 +394,92 @@ static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
>  	return 0;
>  }
>  
> +static int cramfs_blkdev_fill_super(struct super_block *sb, void *data, int silent)
> +{
> +	struct cramfs_sb_info *sbi;
> +	struct cramfs_super super;
> +	int i, err;
> +
> +	sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
> +	if (!sbi)
> +		return -ENOMEM;
> +	sb->s_fs_info = sbi;
> +
> +	/* Invalidate the read buffers on mount: think disk change.. */
> +	for (i = 0; i < READ_BUFFERS; i++)
> +		buffer_blocknr[i] = -1;
> +
> +	err = cramfs_read_super(sb, &super, silent);
> +	if (err)
> +		return err;
> +	return cramfs_finalize_super(sb, &super.root);
> +}
> +
> +static int cramfs_physmem_fill_super(struct super_block *sb, void *data, int silent)
> +{
> +	struct cramfs_sb_info *sbi;
> +	struct cramfs_super super;
> +	char *p;
> +	int err;
> +
> +	sbi = kzalloc(sizeof(struct cramfs_sb_info), GFP_KERNEL);
> +	if (!sbi)
> +		return -ENOMEM;
> +	sb->s_fs_info = sbi;
> +
> +	/*
> +	 * The physical location of the cramfs image is specified as
> +	 * a mount parameter.  This parameter is mandatory for obvious
> +	 * reasons.  Some validation is made on the phys address but this
> +	 * is not exhaustive and we count on the fact that someone using
> +	 * this feature is supposed to know what he/she's doing.
> +	 */
> +	if (!data || !(p = strstr((char *)data, "physaddr="))) {
> +		pr_err("unknown physical address for linear cramfs image\n");
> +		return -EINVAL;
> +	}
> +	sbi->linear_phys_addr = memparse(p + 9, NULL);
> +	if (!sbi->linear_phys_addr) {
> +		pr_err("bad value for cramfs image physical address\n");
> +		return -EINVAL;
> +	}
> +	if (sbi->linear_phys_addr & (PAGE_SIZE-1)) {
> +		pr_err("physical address %pap for linear cramfs isn't aligned to a page boundary\n",
> +			&sbi->linear_phys_addr);
> +		return -EINVAL;
> +	}
> +
> +	/*
> +	 * Map only one page for now.  Will remap it when fs size is known.
> +	 * Although we'll only read from it, we want the CPU cache to
> +	 * kick in for the higher throughput it provides, hence MEMREMAP_WB.
> +	 */
> +	pr_info("checking physical address %pap for linear cramfs image\n", &sbi->linear_phys_addr);
> +	sbi->linear_virt_addr = memremap(sbi->linear_phys_addr, PAGE_SIZE,
> +					 MEMREMAP_WB);
> +	if (!sbi->linear_virt_addr) {
> +		pr_err("ioremap of the linear cramfs image failed\n");
> +		return -ENOMEM;
> +	}
> +
> +	err = cramfs_read_super(sb, &super, silent);
> +	if (err)
> +		return err;
> +
> +	/* Remap the whole filesystem now */
> +	pr_info("linear cramfs image appears to be %lu KB in size\n",
> +		sbi->size/1024);
> +	memunmap(sbi->linear_virt_addr);
> +	sbi->linear_virt_addr = memremap(sbi->linear_phys_addr, sbi->size,
> +					 MEMREMAP_WB);
> +	if (!sbi->linear_virt_addr) {
> +		pr_err("ioremap of the linear cramfs image failed\n");
> +		return -ENOMEM;
> +	}
> +
> +	return cramfs_finalize_super(sb, &super.root);
> +}
> +
>  static int cramfs_statfs(struct dentry *dentry, struct kstatfs *buf)
>  {
>  	struct super_block *sb = dentry->d_sb;
> @@ -573,38 +706,67 @@ static const struct super_operations cramfs_ops = {
>  	.statfs		= cramfs_statfs,
>  };
>  
> -static struct dentry *cramfs_mount(struct file_system_type *fs_type,
> -	int flags, const char *dev_name, void *data)
> +static struct dentry *cramfs_blkdev_mount(struct file_system_type *fs_type,
> +				int flags, const char *dev_name, void *data)
> +{
> +	return mount_bdev(fs_type, flags, dev_name, data, cramfs_blkdev_fill_super);
> +}
> +
> +static struct dentry *cramfs_physmem_mount(struct file_system_type *fs_type,
> +				int flags, const char *dev_name, void *data)
>  {
> -	return mount_bdev(fs_type, flags, dev_name, data, cramfs_fill_super);
> +	return mount_nodev(fs_type, flags, data, cramfs_physmem_fill_super);
>  }
>  
>  static struct file_system_type cramfs_fs_type = {
>  	.owner		= THIS_MODULE,
>  	.name		= "cramfs",
> -	.mount		= cramfs_mount,
> -	.kill_sb	= cramfs_kill_sb,
> +	.mount		= cramfs_blkdev_mount,
> +	.kill_sb	= cramfs_blkdev_kill_sb,
>  	.fs_flags	= FS_REQUIRES_DEV,
>  };
> +
> +static struct file_system_type cramfs_physmem_fs_type = {
> +	.owner		= THIS_MODULE,
> +	.name		= "cramfs_physmem",
> +	.mount		= cramfs_physmem_mount,
> +	.kill_sb	= cramfs_physmem_kill_sb,
> +};
> +
> +#ifdef CONFIG_CRAMFS_BLOCKDEV
>  MODULE_ALIAS_FS("cramfs");
> +#endif
> +#ifdef CONFIG_CRAMFS_PHYSMEM
> +MODULE_ALIAS_FS("cramfs_physmem");
> +#endif
>  
>  static int __init init_cramfs_fs(void)
>  {
>  	int rv;
>  
> -	rv = cramfs_uncompress_init();
> -	if (rv < 0)
> -		return rv;
> -	rv = register_filesystem(&cramfs_fs_type);
> -	if (rv < 0)
> -		cramfs_uncompress_exit();
> -	return rv;
> +	if ((rv = cramfs_uncompress_init()) < 0)
> +		goto err0;
> +	if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV) &&
> +	    (rv = register_filesystem(&cramfs_fs_type)) < 0)
> +		goto err1;
> +	if (IS_ENABLED(CONFIG_CRAMFS_PHYSMEM) &&
> +	    (rv = register_filesystem(&cramfs_physmem_fs_type)) < 0)
> +		goto err2;
> +	return 0;
> +
> +err2:	if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV))
> +		unregister_filesystem(&cramfs_fs_type);
> +err1:	cramfs_uncompress_exit();
> +err0:	return rv;
>  }
>  
>  static void __exit exit_cramfs_fs(void)
>  {
>  	cramfs_uncompress_exit();
> -	unregister_filesystem(&cramfs_fs_type);
> +	if (IS_ENABLED(CONFIG_CRAMFS_BLOCKDEV))
> +		unregister_filesystem(&cramfs_fs_type);
> +	if (IS_ENABLED(CONFIG_CRAMFS_PHYSMEM))
> +		unregister_filesystem(&cramfs_physmem_fs_type);
>  }
>  
>  module_init(init_cramfs_fs)
> -- 
> 2.9.5
> 
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
