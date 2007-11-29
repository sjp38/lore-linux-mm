Date: Thu, 29 Nov 2007 15:06:59 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 14/19] Use page_cache_xxx in ext2
Message-ID: <20071129040659.GC119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.567317218@sgi.com> <20071129034521.GV119954183@sgi.com> <Pine.LNX.4.64.0711281955010.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711281955010.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 07:55:40PM -0800, Christoph Lameter wrote:
> ext2: Simplify some functions
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/ext2/dir.c |    9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> Index: mm/fs/ext2/dir.c
> ===================================================================
> --- mm.orig/fs/ext2/dir.c	2007-11-28 19:51:05.038882954 -0800
> +++ mm/fs/ext2/dir.c	2007-11-28 19:53:59.074132710 -0800
> @@ -63,8 +63,7 @@ static inline void ext2_put_page(struct 
>  
>  static inline unsigned long dir_pages(struct inode *inode)
>  {
> -	return (inode->i_size+page_cache_size(inode->i_mapping)-1)>>
> -			page_cache_shift(inode->i_mapping);
> +	return page_cache_next(inode->i_mapping, inode->i_size);
>  }

ok.

>  /*
> @@ -74,13 +73,9 @@ static inline unsigned long dir_pages(st
>  static unsigned
>  ext2_last_byte(struct inode *inode, unsigned long page_nr)
>  {
> -	unsigned last_byte = inode->i_size;
>  	struct address_space *mapping = inode->i_mapping;
>  
> -	last_byte -= page_nr << page_cache_shift(mapping);
> -	if (last_byte > page_cache_size(mapping))
> -		last_byte = page_cache_size(mapping);
> -	return last_byte;
> +	return inode->i_size - page_cache_pos(mapping, page_nr, 0);

I don't think that gives the same return value. The return value
is supposed to be clamped at a maximum of page_cache_size(mapping).

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
