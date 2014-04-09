Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CC0266B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 05:59:23 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id b13so2232498wgh.5
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 02:59:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si788587wiy.82.2014.04.09.02.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 02:59:21 -0700 (PDT)
Date: Wed, 9 Apr 2014 11:59:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 15/22] Remove CONFIG_EXT2_FS_XIP and rename
 CONFIG_FS_XIP to CONFIG_FS_DAX
Message-ID: <20140409095918.GG32103@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <ff35fb6b662af013eddeb295a01258b42ccaa5ae.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ff35fb6b662af013eddeb295a01258b42ccaa5ae.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:41, Matthew Wilcox wrote:
> The fewer Kconfig options we have the better.  Use the generic
> CONFIG_FS_DAX to enable XIP support in ext2 as well as in the core.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

BTW: Its really only 2KB of code?

								Honza
> ---
>  fs/Kconfig         | 21 ++++++++++++++-------
>  fs/Makefile        |  2 +-
>  fs/ext2/Kconfig    | 11 -----------
>  fs/ext2/ext2.h     |  2 +-
>  fs/ext2/file.c     |  4 ++--
>  fs/ext2/super.c    |  4 ++--
>  include/linux/fs.h |  4 ++--
>  7 files changed, 22 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 7385e54..620ab73 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -13,13 +13,6 @@ if BLOCK
>  source "fs/ext2/Kconfig"
>  source "fs/ext3/Kconfig"
>  source "fs/ext4/Kconfig"
> -
> -config FS_XIP
> -# execute in place
> -	bool
> -	depends on EXT2_FS_XIP
> -	default y
> -
>  source "fs/jbd/Kconfig"
>  source "fs/jbd2/Kconfig"
>  
> @@ -40,6 +33,20 @@ source "fs/ocfs2/Kconfig"
>  source "fs/btrfs/Kconfig"
>  source "fs/nilfs2/Kconfig"
>  
> +config FS_DAX
> +	bool "Direct Access support"
> +	depends on MMU
> +	help
> +	  Direct Access (DAX) can be used on memory-backed block devices.
> +	  If the block device supports DAX and the filesystem supports DAX,
> +	  then you can avoid using the pagecache to buffer I/Os.  Turning
> +	  on this option will compile in support for DAX; you will need to
> +	  mount the filesystem using the -o xip option.
> +
> +	  If you do not have a block device that is capable of using this,
> +	  or if unsure, say N.  Saying Y will increase the size of the kernel
> +	  by about 2kB.
> +
>  endif # BLOCK
>  
>  # Posix ACL utility routines
> diff --git a/fs/Makefile b/fs/Makefile
> index 2f194cd..b7e0a13 100644
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -29,7 +29,7 @@ obj-$(CONFIG_SIGNALFD)		+= signalfd.o
>  obj-$(CONFIG_TIMERFD)		+= timerfd.o
>  obj-$(CONFIG_EVENTFD)		+= eventfd.o
>  obj-$(CONFIG_AIO)               += aio.o
> -obj-$(CONFIG_FS_XIP)		+= dax.o
> +obj-$(CONFIG_FS_DAX)		+= dax.o
>  obj-$(CONFIG_FILE_LOCKING)      += locks.o
>  obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
>  obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
> diff --git a/fs/ext2/Kconfig b/fs/ext2/Kconfig
> index 14a6780..c634874e 100644
> --- a/fs/ext2/Kconfig
> +++ b/fs/ext2/Kconfig
> @@ -42,14 +42,3 @@ config EXT2_FS_SECURITY
>  
>  	  If you are not using a security module that requires using
>  	  extended attributes for file security labels, say N.
> -
> -config EXT2_FS_XIP
> -	bool "Ext2 execute in place support"
> -	depends on EXT2_FS && MMU
> -	help
> -	  Execute in place can be used on memory-backed block devices. If you
> -	  enable this option, you can select to mount block devices which are
> -	  capable of this feature without using the page cache.
> -
> -	  If you do not use a block device that is capable of using this,
> -	  or if unsure, say N.
> diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
> index 5ecf570..b30c3bd 100644
> --- a/fs/ext2/ext2.h
> +++ b/fs/ext2/ext2.h
> @@ -380,7 +380,7 @@ struct ext2_inode {
>  #define EXT2_MOUNT_NO_UID32		0x000200  /* Disable 32-bit UIDs */
>  #define EXT2_MOUNT_XATTR_USER		0x004000  /* Extended user attributes */
>  #define EXT2_MOUNT_POSIX_ACL		0x008000  /* POSIX Access Control Lists */
> -#ifdef CONFIG_FS_XIP
> +#ifdef CONFIG_FS_DAX
>  #define EXT2_MOUNT_XIP			0x010000  /* Execute in place */
>  #else
>  #define EXT2_MOUNT_XIP			0
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index e3ce10d..ae7f000 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -25,7 +25,7 @@
>  #include "xattr.h"
>  #include "acl.h"
>  
> -#ifdef CONFIG_EXT2_FS_XIP
> +#ifdef CONFIG_FS_DAX
>  static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	return dax_fault(vma, vmf, ext2_get_block);
> @@ -109,7 +109,7 @@ const struct file_operations ext2_file_operations = {
>  	.splice_write	= generic_file_splice_write,
>  };
>  
> -#ifdef CONFIG_EXT2_FS_XIP
> +#ifdef CONFIG_FS_DAX
>  const struct file_operations ext2_xip_file_operations = {
>  	.llseek		= generic_file_llseek,
>  	.read		= do_sync_read,
> diff --git a/fs/ext2/super.c b/fs/ext2/super.c
> index 752ccb4..fdcacf7 100644
> --- a/fs/ext2/super.c
> +++ b/fs/ext2/super.c
> @@ -287,7 +287,7 @@ static int ext2_show_options(struct seq_file *seq, struct dentry *root)
>  		seq_puts(seq, ",grpquota");
>  #endif
>  
> -#if defined(CONFIG_EXT2_FS_XIP)
> +#ifdef CONFIG_FS_DAX
>  	if (sbi->s_mount_opt & EXT2_MOUNT_XIP)
>  		seq_puts(seq, ",xip");
>  #endif
> @@ -549,7 +549,7 @@ static int parse_options(char *options, struct super_block *sb)
>  			break;
>  #endif
>  		case Opt_xip:
> -#ifdef CONFIG_EXT2_FS_XIP
> +#ifdef CONFIG_FS_DAX
>  			set_opt (sbi->s_mount_opt, XIP);
>  #else
>  			ext2_msg(sb, KERN_INFO, "xip option not supported");
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index aeab3fda..bff394d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1681,7 +1681,7 @@ struct super_operations {
>  #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
>  #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
>  #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
> -#ifdef CONFIG_FS_XIP
> +#ifdef CONFIG_FS_DAX
>  #define IS_DAX(inode)		((inode)->i_flags & S_DAX)
>  #else
>  #define IS_DAX(inode)		0
> @@ -2519,7 +2519,7 @@ extern loff_t fixed_size_llseek(struct file *file, loff_t offset,
>  extern int generic_file_open(struct inode * inode, struct file * filp);
>  extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
> -#ifdef CONFIG_FS_XIP
> +#ifdef CONFIG_FS_DAX
>  int dax_clear_blocks(struct inode *, sector_t block, long size);
>  int dax_truncate_page(struct inode *, loff_t from, get_block_t);
>  ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
