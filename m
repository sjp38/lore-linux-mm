Date: Thu, 29 Nov 2007 14:03:14 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 18/19] Use page_cache_xxx for fs/xfs
Message-ID: <20071129030314.GR119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011148.509714554@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011148.509714554@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:10PM -0800, Christoph Lameter wrote:
> Use page_cache_xxx for fs/xfs
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  fs/xfs/linux-2.6/xfs_aops.c |   55 +++++++++++++++++++++++---------------------
>  fs/xfs/linux-2.6/xfs_lrw.c  |    4 +--
>  2 files changed, 31 insertions(+), 28 deletions(-)
> 
> Index: mm/fs/xfs/linux-2.6/xfs_aops.c
> ===================================================================
> --- mm.orig/fs/xfs/linux-2.6/xfs_aops.c	2007-11-28 12:25:38.768212813 -0800
> +++ mm/fs/xfs/linux-2.6/xfs_aops.c	2007-11-28 14:12:55.637977383 -0800
> @@ -75,7 +75,7 @@ xfs_page_trace(
>  	xfs_inode_t	*ip;
>  	bhv_vnode_t	*vp = vn_from_inode(inode);
>  	loff_t		isize = i_size_read(inode);
> -	loff_t		offset = page_offset(page);
> +	loff_t		offset = page_cache_offset(page->mapping);

That's not right. Should be

	loff_t		offset = page_cache_pos(page->mapping, page->index, 0);


> @@ -752,7 +752,8 @@ xfs_convert_page(
>  	int			bbits = inode->i_blkbits;
>  	int			len, page_dirty;
>  	int			count = 0, done = 0, uptodate = 1;
> - 	xfs_off_t		offset = page_offset(page);
> +	struct address_space	*map = inode->i_mapping;
> +	xfs_off_t		offset = page_cache_pos(map, page->index, 0);

But you got that one right ;)

> @@ -772,20 +773,20 @@ xfs_convert_page(
>  	 * Derivation:
>  	 *
>  	 * End offset is the highest offset that this page should represent.
> -	 * If we are on the last page, (end_offset & (PAGE_CACHE_SIZE - 1))
> -	 * will evaluate non-zero and be less than PAGE_CACHE_SIZE and
> +	 * If we are on the last page, (end_offset & page_cache_mask())
> +	 * will evaluate non-zero and be less than page_cache_size() and
>  	 * hence give us the correct page_dirty count. On any other page,
>  	 * it will be zero and in that case we need page_dirty to be the
>  	 * count of buffers on the page.
>  	 */
>  	end_offset = min_t(unsigned long long,
> -			(xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT,
> +			(xfs_off_t)(page->index + 1) << page_cache_shift(map),

			(xfs_off_t)page_cache_pos(map, page->index + 1, 0),

>  			i_size_read(inode));
>  
>  	len = 1 << inode->i_blkbits;
> -	p_offset = min_t(unsigned long, end_offset & (PAGE_CACHE_SIZE - 1),
> -					PAGE_CACHE_SIZE);
> -	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
> +	p_offset = min_t(unsigned long, page_cache_offset(map, end_offset),
> +					page_cache_size(map));

Hmmmm. p_offset = min(val & 4095, 4096)? I think that should just be:

	p_offset = page_cache_offset(map, end_offset);

> @@ -967,22 +970,22 @@ xfs_page_state_convert(
>  	 * Derivation:
>  	 *
>  	 * End offset is the highest offset that this page should represent.
> -	 * If we are on the last page, (end_offset & (PAGE_CACHE_SIZE - 1))
> -	 * will evaluate non-zero and be less than PAGE_CACHE_SIZE and
> -	 * hence give us the correct page_dirty count. On any other page,
> +	 * If we are on the last page, (page_cache_offset(mapping, end_offset))
> +	 * will evaluate non-zero and be less than page_cache_size(mapping)
> +	 * and hence give us the correct page_dirty count. On any other page,
>  	 * it will be zero and in that case we need page_dirty to be the
>  	 * count of buffers on the page.
>   	 */
>  	end_offset = min_t(unsigned long long,
> -			(xfs_off_t)(page->index + 1) << PAGE_CACHE_SHIFT, offset);
> +			(xfs_off_t)page_cache_pos(map, page->index + 1, 0), offset);

You got that one ;)

>  	len = 1 << inode->i_blkbits;
> -	p_offset = min_t(unsigned long, end_offset & (PAGE_CACHE_SIZE - 1),
> -					PAGE_CACHE_SIZE);
> -	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
> +	p_offset = min_t(unsigned long, page_cache_offset(map, end_offset),
> +					pagesize);

Again, that can be:

	p_offset = page_cache_offset(map, end_offset);

and you can kill the new temporary pagesize variable.

> @@ -1130,7 +1133,7 @@ xfs_page_state_convert(
>  
>  	if (ioend && iomap_valid) {
>  		offset = (iomap.iomap_offset + iomap.iomap_bsize - 1) >>
> -					PAGE_CACHE_SHIFT;
> +					page_cache_shift(map);

		offset = page_cache_index(map,
				(iomap.iomap_offset + iomap.iomap_bsize - 1));

> @@ -142,8 +142,8 @@ xfs_iozero(
>  		unsigned offset, bytes;
>  		void *fsdata;
>  
> -		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
> -		bytes = PAGE_CACHE_SIZE - offset;
> +		offset = page_cache_offset(mapping, pos); /* Within page */
> +		bytes = page_cache_size(mapping) - offset;

Kill the "within page" comment.

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
