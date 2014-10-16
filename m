Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3FF6B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 06:28:52 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id w7so2515132lbi.22
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:28:52 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id yg7si33943585lbb.133.2014.10.16.03.28.44
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 03:28:51 -0700 (PDT)
Date: Thu, 16 Oct 2014 12:28:26 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 10/21] dax,ext2: Replace xip_truncate_page with
 dax_truncate_page
Message-ID: <20141016102826.GH19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-11-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-11-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25-Sep-2014 04:33:27 PM, Matthew Wilcox wrote:
> It takes a get_block parameter just like nobh_truncate_page() and
> block_truncate_page()
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  fs/dax.c           | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  fs/ext2/inode.c    |  2 +-
>  include/linux/fs.h |  4 ++--
>  mm/filemap_xip.c   | 40 ----------------------------------------
>  4 files changed, 47 insertions(+), 43 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index ac5d3a6..6801be7 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -460,3 +460,47 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  	return result;
>  }
>  EXPORT_SYMBOL_GPL(dax_fault);
> +
> +/**
> + * dax_truncate_page - handle a partial page being truncated in a DAX file
> + * @inode: The file being truncated
> + * @from: The file offset that is being truncated to
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * Similar to block_truncate_page(), this function can be called by a
> + * filesystem when it is truncating an DAX file to handle the partial page.
> + *
> + * We work in terms of PAGE_CACHE_SIZE here for commonality with
> + * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
> + * took care of disposing of the unnecessary blocks.  Even if the filesystem
> + * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
> + * since the file might be mmaped.
> + */
> +int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
> +{
> +	struct buffer_head bh;
> +	pgoff_t index = from >> PAGE_CACHE_SHIFT;
> +	unsigned offset = from & (PAGE_CACHE_SIZE-1);
> +	unsigned length = PAGE_CACHE_ALIGN(from) - from;

nits: unsigned -> unsigned int (I'm starting to think that FS code
perhaps has different coding style than kernel/ core code)

> +	int err;
> +
> +	/* Block boundary? Nothing to do */
> +	if (!length)
> +		return 0;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	bh.b_size = PAGE_CACHE_SIZE;
> +	err = get_block(inode, index, &bh, 0);
> +	if (err < 0)
> +		return err;
> +	if (buffer_written(&bh)) {
> +		void *addr;

missing newline.

Other than that:

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Thanks,

Mathieu

> +		err = dax_get_addr(&bh, &addr, inode->i_blkbits);
> +		if (err < 0)
> +			return err;
> +		memset(addr + offset, 0, length);
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(dax_truncate_page);
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 52978b8..5ac0a34 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -1210,7 +1210,7 @@ static int ext2_setsize(struct inode *inode, loff_t newsize)
>  	inode_dio_wait(inode);
>  
>  	if (IS_DAX(inode))
> -		error = xip_truncate_page(inode->i_mapping, newsize);
> +		error = dax_truncate_page(inode, newsize, ext2_get_block);
>  	else if (test_opt(inode->i_sb, NOBH))
>  		error = nobh_truncate_page(inode->i_mapping,
>  				newsize, ext2_get_block);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 338f04b..eee848d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2492,7 +2492,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
>  #ifdef CONFIG_FS_XIP
>  int dax_clear_blocks(struct inode *, sector_t block, long size);
> -extern int xip_truncate_page(struct address_space *mapping, loff_t from);
> +int dax_truncate_page(struct inode *, loff_t from, get_block_t);
>  ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
>  		loff_t, get_block_t, dio_iodone_t, int flags);
>  int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
> @@ -2503,7 +2503,7 @@ static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
>  	return 0;
>  }
>  
> -static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
> +static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
>  {
>  	return 0;
>  }
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> index 9dd45f3..6316578 100644
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -21,43 +21,3 @@
>  #include <asm/tlbflush.h>
>  #include <asm/io.h>
>  
> -/*
> - * truncate a page used for execute in place
> - * functionality is analog to block_truncate_page but does use get_xip_mem
> - * to get the page instead of page cache
> - */
> -int
> -xip_truncate_page(struct address_space *mapping, loff_t from)
> -{
> -	pgoff_t index = from >> PAGE_CACHE_SHIFT;
> -	unsigned offset = from & (PAGE_CACHE_SIZE-1);
> -	unsigned blocksize;
> -	unsigned length;
> -	void *xip_mem;
> -	unsigned long xip_pfn;
> -	int err;
> -
> -	BUG_ON(!mapping->a_ops->get_xip_mem);
> -
> -	blocksize = 1 << mapping->host->i_blkbits;
> -	length = offset & (blocksize - 1);
> -
> -	/* Block boundary? Nothing to do */
> -	if (!length)
> -		return 0;
> -
> -	length = blocksize - length;
> -
> -	err = mapping->a_ops->get_xip_mem(mapping, index, 0,
> -						&xip_mem, &xip_pfn);
> -	if (unlikely(err)) {
> -		if (err == -ENODATA)
> -			/* Hole? No need to truncate */
> -			return 0;
> -		else
> -			return err;
> -	}
> -	memset(xip_mem + offset, 0, length);
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(xip_truncate_page);
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
