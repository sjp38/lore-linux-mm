Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id E64596B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 08:15:09 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so2701003lab.41
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 05:15:09 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id it2si34536109lac.40.2014.10.16.05.15.07
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 05:15:07 -0700 (PDT)
Date: Thu, 16 Oct 2014 14:14:46 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 12/21] vfs: Remove get_xip_mem
Message-ID: <20141016121446.GJ19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-13-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-13-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25-Sep-2014 04:33:29 PM, Matthew Wilcox wrote:
> All callers of get_xip_mem() are now gone.  Remove checks for it,
> initialisers of it, documentation of it and the only implementation of it.
> Also remove mm/filemap_xip.c as it is now empty.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  Documentation/filesystems/Locking |  3 ---
>  fs/exofs/inode.c                  |  1 -
>  fs/ext2/inode.c                   |  1 -
>  fs/ext2/xip.c                     | 45 ---------------------------------------
>  fs/ext2/xip.h                     |  3 ---
>  fs/open.c                         |  5 +----
>  include/linux/fs.h                |  2 --
>  mm/Makefile                       |  1 -
>  mm/fadvise.c                      |  6 ++++--
>  mm/filemap_xip.c                  | 23 --------------------
>  mm/madvise.c                      |  2 +-
>  11 files changed, 6 insertions(+), 86 deletions(-)
>  delete mode 100644 mm/filemap_xip.c
> 
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> index f1997e9..226ccc3 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -197,8 +197,6 @@ prototypes:
>  	int (*releasepage) (struct page *, int);
>  	void (*freepage)(struct page *);
>  	int (*direct_IO)(int, struct kiocb *, struct iov_iter *iter, loff_t offset);
> -	int (*get_xip_mem)(struct address_space *, pgoff_t, int, void **,
> -				unsigned long *);
>  	int (*migratepage)(struct address_space *, struct page *, struct page *);
>  	int (*launder_page)(struct page *);
>  	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
> @@ -223,7 +221,6 @@ invalidatepage:		yes
>  releasepage:		yes
>  freepage:		yes
>  direct_IO:
> -get_xip_mem:					maybe
>  migratepage:		yes (both)
>  launder_page:		yes
>  is_partially_uptodate:	yes
> diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
> index 3f9cafd..c408a53 100644
> --- a/fs/exofs/inode.c
> +++ b/fs/exofs/inode.c
> @@ -985,7 +985,6 @@ const struct address_space_operations exofs_aops = {
>  	.direct_IO	= exofs_direct_IO,
>  
>  	/* With these NULL has special meaning or default is not exported */
> -	.get_xip_mem	= NULL,
>  	.migratepage	= NULL,
>  	.launder_page	= NULL,
>  	.is_partially_uptodate = NULL,
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 5ac0a34..59d6c7d 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -894,7 +894,6 @@ const struct address_space_operations ext2_aops = {
>  
>  const struct address_space_operations ext2_aops_xip = {
>  	.bmap			= ext2_bmap,
> -	.get_xip_mem		= ext2_get_xip_mem,
>  	.direct_IO		= ext2_direct_IO,
>  };
>  
> diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
> index 8cfca3a..132d4da 100644
> --- a/fs/ext2/xip.c
> +++ b/fs/ext2/xip.c
> @@ -13,35 +13,6 @@
>  #include "ext2.h"
>  #include "xip.h"
>  
> -static inline long __inode_direct_access(struct inode *inode, sector_t block,
> -				void **kaddr, unsigned long *pfn, long size)
> -{
> -	struct block_device *bdev = inode->i_sb->s_bdev;
> -	sector_t sector = block * (PAGE_SIZE / 512);
> -	return bdev_direct_access(bdev, sector, kaddr, pfn, size);
> -}
> -
> -static inline int
> -__ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
> -		   sector_t *result)
> -{
> -	struct buffer_head tmp;
> -	int rc;
> -
> -	memset(&tmp, 0, sizeof(struct buffer_head));
> -	tmp.b_size = 1 << inode->i_blkbits;
> -	rc = ext2_get_block(inode, pgoff, &tmp, create);
> -	*result = tmp.b_blocknr;
> -
> -	/* did we get a sparse block (hole in the file)? */
> -	if (!tmp.b_blocknr && !rc) {
> -		BUG_ON(create);
> -		rc = -ENODATA;
> -	}
> -
> -	return rc;
> -}
> -
>  void ext2_xip_verify_sb(struct super_block *sb)
>  {
>  	struct ext2_sb_info *sbi = EXT2_SB(sb);
> @@ -54,19 +25,3 @@ void ext2_xip_verify_sb(struct super_block *sb)
>  			     "not supported by bdev");
>  	}
>  }
> -
> -int ext2_get_xip_mem(struct address_space *mapping, pgoff_t pgoff, int create,
> -				void **kmem, unsigned long *pfn)
> -{
> -	long rc;
> -	sector_t block;
> -
> -	/* first, retrieve the sector number */
> -	rc = __ext2_get_block(mapping->host, pgoff, create, &block);
> -	if (rc)
> -		return rc;
> -
> -	/* retrieve address of the target data */
> -	rc = __inode_direct_access(mapping->host, block, kmem, pfn, PAGE_SIZE);
> -	return (rc < 0) ? rc : 0;
> -}
> diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
> index b2592f2..e7b9f0a 100644
> --- a/fs/ext2/xip.h
> +++ b/fs/ext2/xip.h
> @@ -12,10 +12,7 @@ static inline int ext2_use_xip (struct super_block *sb)
>  	struct ext2_sb_info *sbi = EXT2_SB(sb);
>  	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
>  }
> -int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
> -				void **, unsigned long *);
>  #else
>  #define ext2_xip_verify_sb(sb)			do { } while (0)
>  #define ext2_use_xip(sb)			0
> -#define ext2_get_xip_mem			NULL
>  #endif
> diff --git a/fs/open.c b/fs/open.c
> index d6fd3ac..ca68e47 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -655,11 +655,8 @@ int open_check_o_direct(struct file *f)
>  {
>  	/* NB: we're sure to have correct a_ops only after f_op->open */
>  	if (f->f_flags & O_DIRECT) {
> -		if (!f->f_mapping->a_ops ||
> -		    ((!f->f_mapping->a_ops->direct_IO) &&
> -		    (!f->f_mapping->a_ops->get_xip_mem))) {
> +		if (!f->f_mapping->a_ops || !f->f_mapping->a_ops->direct_IO)

Why is it OK to remove the check for get_xip_mem callback here, rather
than replacing it with a IS_DAX check like the rest of this patch does ?
I'm probably missing something.

Thanks,

Mathieu

>  			return -EINVAL;
> -		}
>  	}
>  	return 0;
>  }
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index eee848d..d73db11 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -349,8 +349,6 @@ struct address_space_operations {
>  	int (*releasepage) (struct page *, gfp_t);
>  	void (*freepage)(struct page *);
>  	ssize_t (*direct_IO)(int, struct kiocb *, struct iov_iter *iter, loff_t offset);
> -	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
> -						void **, unsigned long *);
>  	/*
>  	 * migrate the contents of a page to the specified target. If
>  	 * migrate_mode is MIGRATE_ASYNC, it must not block.
> diff --git a/mm/Makefile b/mm/Makefile
> index 632ae77..b2c7623 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -47,7 +47,6 @@ obj-$(CONFIG_SLUB) += slub.o
>  obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
>  obj-$(CONFIG_FAILSLAB) += failslab.o
>  obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
> -obj-$(CONFIG_FS_XIP) += filemap_xip.o
>  obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index 3bcfd81..1f1925f 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -28,6 +28,7 @@
>  SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>  {
>  	struct fd f = fdget(fd);
> +	struct inode *inode;
>  	struct address_space *mapping;
>  	struct backing_dev_info *bdi;
>  	loff_t endbyte;			/* inclusive */
> @@ -39,7 +40,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>  	if (!f.file)
>  		return -EBADF;
>  
> -	if (S_ISFIFO(file_inode(f.file)->i_mode)) {
> +	inode = file_inode(f.file);
> +	if (S_ISFIFO(inode->i_mode)) {
>  		ret = -ESPIPE;
>  		goto out;
>  	}
> @@ -50,7 +52,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>  		goto out;
>  	}
>  
> -	if (mapping->a_ops->get_xip_mem) {
> +	if (IS_DAX(inode)) {
>  		switch (advice) {
>  		case POSIX_FADV_NORMAL:
>  		case POSIX_FADV_RANDOM:
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> deleted file mode 100644
> index 6316578..0000000
> --- a/mm/filemap_xip.c
> +++ /dev/null
> @@ -1,23 +0,0 @@
> -/*
> - *	linux/mm/filemap_xip.c
> - *
> - * Copyright (C) 2005 IBM Corporation
> - * Author: Carsten Otte <cotte@de.ibm.com>
> - *
> - * derived from linux/mm/filemap.c - Copyright (C) Linus Torvalds
> - *
> - */
> -
> -#include <linux/fs.h>
> -#include <linux/pagemap.h>
> -#include <linux/export.h>
> -#include <linux/uio.h>
> -#include <linux/rmap.h>
> -#include <linux/mmu_notifier.h>
> -#include <linux/sched.h>
> -#include <linux/seqlock.h>
> -#include <linux/mutex.h>
> -#include <linux/gfp.h>
> -#include <asm/tlbflush.h>
> -#include <asm/io.h>
> -
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 0938b30..1611ebf 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -236,7 +236,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	if (!file)
>  		return -EBADF;
>  
> -	if (file->f_mapping->a_ops->get_xip_mem) {
> +	if (IS_DAX(file_inode(file))) {
>  		/* no bad return value, but ignore advice */
>  		return 0;
>  	}
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
