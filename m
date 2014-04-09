Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC756B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 06:15:19 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id w61so2215337wes.18
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 03:15:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id db6si2489015wib.25.2014.04.09.03.15.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 03:15:16 -0700 (PDT)
Date: Wed, 9 Apr 2014 12:15:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 18/22] xip: Add xip_zero_page_range
Message-ID: <20140409101512.GL32103@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <5a87acda8c3e4d2b7ea5dd1249fcbf8be23b9645.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a87acda8c3e4d2b7ea5dd1249fcbf8be23b9645.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun 23-03-14 15:08:44, Matthew Wilcox wrote:
> This new function allows us to support hole-punch for XIP files by zeroing
> a partial page, as opposed to the xip_truncate_page() function which can
> only truncate to the end of the page.  Reimplement xip_truncate_page() as
> a macro that calls xip_zero_page_range().
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> [ported to 3.13-rc2]
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
  Two comments below...

...
> diff --git a/fs/dax.c b/fs/dax.c
> index 45a0a41..2d6b4bc 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
...
> @@ -491,11 +494,16 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
>  	if (buffer_written(&bh)) {
>  		void *addr;
>  		err = dax_get_addr(inode, &bh, &addr);
> -		if (err)
> +		if (err < 0)
>  			return err;
> +		/*
> +		 * ext4 sometimes asks to zero past the end of a block.  It
> +		 * really just wants to zero to the end of the block.
> +		 */
  Then we should really fix ext4 I believe...

> +		length = min_t(unsigned, length, PAGE_CACHE_SIZE - offset);
>  		memset(addr + offset, 0, length);
>  	}
>  
>  	return 0;
>  }
> -EXPORT_SYMBOL_GPL(dax_truncate_page);
> +EXPORT_SYMBOL_GPL(dax_zero_page_range);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index bff394d..d0381ab 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2521,6 +2521,7 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
>  #ifdef CONFIG_FS_DAX
>  int dax_clear_blocks(struct inode *, sector_t block, long size);
> +int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
>  int dax_truncate_page(struct inode *, loff_t from, get_block_t);
>  ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, const struct iovec *,
>  		loff_t, unsigned segs, get_block_t, dio_iodone_t, int flags);
> @@ -2532,7 +2533,8 @@ static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
>  	return 0;
>  }
>  
> -static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
> +static inline int dax_zero_page_range(struct inode *inode, loff_t from,
> +						unsigned len, get_block_t gb)
>  {
>  	return 0;
>  }
> @@ -2545,6 +2547,11 @@ static inline ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
>  }
>  #endif
>  
> +/* Can't be a function because PAGE_CACHE_SIZE is defined in pagemap.h */
> +#define dax_truncate_page(inode, from, get_block)	\
> +	dax_zero_page_range(inode, from, PAGE_CACHE_SIZE, get_block)
                                         ^^^^
This should be (PAGE_CACHE_SIZE - (from & (PAGE_CACHE_SIZE - 1))), shouldn't it?

> +
> +
>  #ifdef CONFIG_BLOCK
>  typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
