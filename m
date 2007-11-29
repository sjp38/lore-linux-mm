Date: Thu, 29 Nov 2007 14:45:21 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 14/19] Use page_cache_xxx in ext2
Message-ID: <20071129034521.GV119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.567317218@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011147.567317218@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:06PM -0800, Christoph Lameter wrote:
> Use page_cache_xxx functions in fs/ext2/*
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  fs/ext2/dir.c |   40 +++++++++++++++++++++++-----------------
>  1 file changed, 23 insertions(+), 17 deletions(-)
> 
> Index: linux-2.6/fs/ext2/dir.c
> ===================================================================
> --- linux-2.6.orig/fs/ext2/dir.c	2007-11-26 17:45:29.155116723 -0800
> +++ linux-2.6/fs/ext2/dir.c	2007-11-26 18:15:08.660772219 -0800
> @@ -63,7 +63,8 @@ static inline void ext2_put_page(struct 
>  
>  static inline unsigned long dir_pages(struct inode *inode)
>  {
> -	return (inode->i_size+PAGE_CACHE_SIZE-1)>>PAGE_CACHE_SHIFT;
> +	return (inode->i_size+page_cache_size(inode->i_mapping)-1)>>
> +			page_cache_shift(inode->i_mapping);
>  }

	return page_cache_next(inode->mapping, inode->i_size);
>  
>  /*
> @@ -74,10 +75,11 @@ static unsigned
>  ext2_last_byte(struct inode *inode, unsigned long page_nr)
>  {
>  	unsigned last_byte = inode->i_size;
> +	struct address_space *mapping = inode->i_mapping;
>  
> -	last_byte -= page_nr << PAGE_CACHE_SHIFT;
> -	if (last_byte > PAGE_CACHE_SIZE)
> -		last_byte = PAGE_CACHE_SIZE;
> +	last_byte -= page_nr << page_cache_shift(mapping);

	last_byte -= page_cache_pos(mapping, page_nr, 0);

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
