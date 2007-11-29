Date: Thu, 29 Nov 2007 14:34:59 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 10/19] Use page_cache_xxx in fs/buffer.c
Message-ID: <20071129033459.GT119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011146.563342672@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011146.563342672@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:02PM -0800, Christoph Lameter wrote:
> @@ -914,10 +914,11 @@ struct buffer_head *alloc_page_buffers(s
>  {
>  	struct buffer_head *bh, *head;
>  	long offset;
> +	unsigned int page_size = page_cache_size(page->mapping);
>  
>  try_again:
>  	head = NULL;
> -	offset = PAGE_SIZE;
> +	offset = page_size;
>  	while ((offset -= size) >= 0) {
>  		bh = alloc_buffer_head(GFP_NOFS);
>  		if (!bh)

We don't really need a temporary variable here....

>  	lblock = (i_size_read(inode)+blocksize-1) >> inode->i_blkbits;
>  	bh = head;
>  	nr = 0;
> @@ -2213,16 +2218,16 @@ int cont_expand_zero(struct file *file, 
>  	unsigned zerofrom, offset, len;
>  	int err = 0;
>  
> -	index = pos >> PAGE_CACHE_SHIFT;
> -	offset = pos & ~PAGE_CACHE_MASK;
> +	index = page_cache_index(mapping, pos);
> +	offset = page_cache_offset(mapping, pos);
>  
> -	while (index > (curidx = (curpos = *bytes)>>PAGE_CACHE_SHIFT)) {
> -		zerofrom = curpos & ~PAGE_CACHE_MASK;
> +	while (index > (curidx = page_cache_index(mapping, (curpos = *bytes)))) {
> +		zerofrom = page_cache_offset(mapping, curpos);

That doesn't get any prettier. Perhaps:

	while (index > (curidx = page_cache_index(mapping, *bytes))) {
		curpos = *bytes;
		zerofrom = page_cache_offset(mapping, curpos);

> @@ -2356,20 +2362,22 @@ block_page_mkwrite(struct vm_area_struct
>  	unsigned long end;
>  	loff_t size;
>  	int ret = -EINVAL;
> +	struct address_space *mapping;
>  
>  	lock_page(page);
> +	mapping = page->mapping;
>  	size = i_size_read(inode);
> -	if ((page->mapping != inode->i_mapping) ||
> +	if ((mapping != inode->i_mapping) ||
>  	    (page_offset(page) > size)) {

Should check (page_cache_pos(mapping, page->index, 0) > size)

> @@ -2607,9 +2616,10 @@ EXPORT_SYMBOL(nobh_write_end);
>  int nobh_writepage(struct page *page, get_block_t *get_block,
>  			struct writeback_control *wbc)
>  {
> -	struct inode * const inode = page->mapping->host;
> +	struct address_space *mapping = page->mapping;
> +	struct inode * const inode = mapping->host;
>  	loff_t i_size = i_size_read(inode);
> -	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
> +	const pgoff_t end_index = page_cache_offset(mapping, i_size);

	const pgoff_t end_index = page_cache_index(mapping, i_size);


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
