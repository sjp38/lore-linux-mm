Date: Thu, 29 Nov 2007 15:01:41 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 10/19] Use page_cache_xxx in fs/buffer.c
Message-ID: <20071129040141.GA119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011146.563342672@sgi.com> <20071129033459.GT119954183@sgi.com> <Pine.LNX.4.64.0711281947110.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711281947110.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 07:48:08PM -0800, Christoph Lameter wrote:
> On Thu, 29 Nov 2007, David Chinner wrote:
> 
> > > -	while (index > (curidx = (curpos = *bytes)>>PAGE_CACHE_SHIFT)) {
> > > -		zerofrom = curpos & ~PAGE_CACHE_MASK;
> > > +	while (index > (curidx = page_cache_index(mapping, (curpos = *bytes)))) {
> > > +		zerofrom = page_cache_offset(mapping, curpos);
> > 
> > That doesn't get any prettier. Perhaps:
> > 
> > 	while (index > (curidx = page_cache_index(mapping, *bytes))) {
> > 		curpos = *bytes;
> > 		zerofrom = page_cache_offset(mapping, curpos);
> 
> Results in a gcc warning about the possible use of an unitialized 
> variable.

fmeh.

> How about this?
> 
> 
> fs/buffer.c enhancements and fixes
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/buffer.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> Index: mm/fs/buffer.c
> ===================================================================
> --- mm.orig/fs/buffer.c	2007-11-28 19:39:23.606383803 -0800
> +++ mm/fs/buffer.c	2007-11-28 19:46:10.238382715 -0800
> @@ -914,11 +914,10 @@ struct buffer_head *alloc_page_buffers(s
>  {
>  	struct buffer_head *bh, *head;
>  	long offset;
> -	unsigned int page_size = page_cache_size(page->mapping);
>  
>  try_again:
>  	head = NULL;
> -	offset = page_size;
> +	offset = page_cache_size(page->mapping);
>  	while ((offset -= size) >= 0) {
>  		bh = alloc_buffer_head(GFP_NOFS);
>  		if (!bh)
> @@ -2221,7 +2220,8 @@ int cont_expand_zero(struct file *file, 
>  	index = page_cache_index(mapping, pos);
>  	offset = page_cache_offset(mapping, pos);
>  
> -	while (index > (curidx = page_cache_index(mapping, (curpos = *bytes)))) {
> +	while (curpos = *bytes, curidx = page_cache_index(mapping, curpos),
> +			index > curidx) {
>  		zerofrom = page_cache_offset(mapping, curpos);
>  		if (zerofrom & (blocksize-1)) {
>  			*bytes |= (blocksize-1);
> @@ -2368,7 +2368,7 @@ block_page_mkwrite(struct vm_area_struct
>  	mapping = page->mapping;
>  	size = i_size_read(inode);
>  	if ((mapping != inode->i_mapping) ||
> -	    (page_offset(page) > size)) {
> +	    (page_cache_pos(mapping, page->index, 0) > size)) {
>  		/* page got truncated out from underneath us */
>  		goto out_unlock;
>  	}

Works for me.

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
