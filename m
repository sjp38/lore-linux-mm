Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id AED646B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 06:05:54 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so2560783lbi.9
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:05:53 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id ao5si34001878lbc.58.2014.10.16.03.05.52
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 03:05:52 -0700 (PDT)
Date: Thu, 16 Oct 2014 12:05:25 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 08/21] dax,ext2: Replace ext2_clear_xip_target with
 dax_clear_blocks
Message-ID: <20141016100525.GF19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-9-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-9-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25-Sep-2014 04:33:25 PM, Matthew Wilcox wrote:
> This is practically generic code; other filesystems will want to call
> it from other places, but there's nothing ext2-specific about it.
> 
> Make it a little more generic by allowing it to take a count of the number
> of bytes to zero rather than fixing it to a single page.  Thanks to Dave
> Hansen for suggesting that I need to call cond_resched() if zeroing more
> than one page.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  fs/dax.c           | 35 +++++++++++++++++++++++++++++++++++
>  fs/ext2/inode.c    |  8 +++++---
>  fs/ext2/xip.c      | 14 --------------
>  fs/ext2/xip.h      |  3 ---
>  include/linux/fs.h |  6 ++++++
>  5 files changed, 46 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 108c68e..02e226f 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -20,8 +20,43 @@
>  #include <linux/fs.h>
>  #include <linux/genhd.h>
>  #include <linux/mutex.h>
> +#include <linux/sched.h>
>  #include <linux/uio.h>
>  
> +int dax_clear_blocks(struct inode *inode, sector_t block, long size)
> +{
> +	struct block_device *bdev = inode->i_sb->s_bdev;
> +	sector_t sector = block << (inode->i_blkbits - 9);

Is there a define e.g. SECTOR_SHIFT rather than using this hardcoded "9"
value ?

> +
> +	might_sleep();
> +	do {
> +		void *addr;
> +		unsigned long pfn;
> +		long count;
> +
> +		count = bdev_direct_access(bdev, sector, &addr, &pfn, size);
> +		if (count < 0)
> +			return count;
> +		while (count > 0) {
> +			unsigned pgsz = PAGE_SIZE - offset_in_page(addr);

unsigned -> unsigned int

add a newline between variable declaration and following code.

> +			if (pgsz > count)
> +				pgsz = count;
> +			if (pgsz < PAGE_SIZE)
> +				memset(addr, 0, pgsz);
> +			else
> +				clear_page(addr);
> +			addr += pgsz;
> +			size -= pgsz;
> +			count -= pgsz;
> +			sector += pgsz / 512;

Also wondering about those 512 constants everywhere in the code
(including prior patches). Perhaps it calls for a SECTOR_SIZE define ?

> +			cond_resched();
> +		}
> +	} while (size);

Just to stay on the safe side, can we do while (size > 0) ? Just in case
an unforeseen issue makes size negative, and gets us in a very long loop.

Thanks,

Mathieu

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(dax_clear_blocks);
> +
>  static long dax_get_addr(struct buffer_head *bh, void **addr, unsigned blkbits)
>  {
>  	unsigned long pfn;
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 3ccd5fd..52978b8 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -733,10 +733,12 @@ static int ext2_get_blocks(struct inode *inode,
>  
>  	if (IS_DAX(inode)) {
>  		/*
> -		 * we need to clear the block
> +		 * block must be initialised before we put it in the tree
> +		 * so that it's not found by another thread before it's
> +		 * initialised
>  		 */
> -		err = ext2_clear_xip_target (inode,
> -			le32_to_cpu(chain[depth-1].key));
> +		err = dax_clear_blocks(inode, le32_to_cpu(chain[depth-1].key),
> +						1 << inode->i_blkbits);
>  		if (err) {
>  			mutex_unlock(&ei->truncate_mutex);
>  			goto cleanup;
> diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
> index bbc5fec..8cfca3a 100644
> --- a/fs/ext2/xip.c
> +++ b/fs/ext2/xip.c
> @@ -42,20 +42,6 @@ __ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
>  	return rc;
>  }
>  
> -int
> -ext2_clear_xip_target(struct inode *inode, sector_t block)
> -{
> -	void *kaddr;
> -	unsigned long pfn;
> -	long size;
> -
> -	size = __inode_direct_access(inode, block, &kaddr, &pfn, PAGE_SIZE);
> -	if (size < 0)
> -		return size;
> -	clear_page(kaddr);
> -	return 0;
> -}
> -
>  void ext2_xip_verify_sb(struct super_block *sb)
>  {
>  	struct ext2_sb_info *sbi = EXT2_SB(sb);
> diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
> index 29be737..b2592f2 100644
> --- a/fs/ext2/xip.h
> +++ b/fs/ext2/xip.h
> @@ -7,8 +7,6 @@
>  
>  #ifdef CONFIG_EXT2_FS_XIP
>  extern void ext2_xip_verify_sb (struct super_block *);
> -extern int ext2_clear_xip_target (struct inode *, sector_t);
> -
>  static inline int ext2_use_xip (struct super_block *sb)
>  {
>  	struct ext2_sb_info *sbi = EXT2_SB(sb);
> @@ -19,6 +17,5 @@ int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
>  #else
>  #define ext2_xip_verify_sb(sb)			do { } while (0)
>  #define ext2_use_xip(sb)			0
> -#define ext2_clear_xip_target(inode, chain)	0
>  #define ext2_get_xip_mem			NULL
>  #endif
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 45839e8..c04d371 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2490,11 +2490,17 @@ extern int generic_file_open(struct inode * inode, struct file * filp);
>  extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
>  #ifdef CONFIG_FS_XIP
> +int dax_clear_blocks(struct inode *, sector_t block, long size);
>  extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
>  extern int xip_truncate_page(struct address_space *mapping, loff_t from);
>  ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
>  		loff_t, get_block_t, dio_iodone_t, int flags);
>  #else
> +static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
> +{
> +	return 0;
> +}
> +
>  static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
>  {
>  	return 0;
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
