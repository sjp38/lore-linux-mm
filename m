Date: Fri, 2 Feb 2007 13:24:40 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070202192440.GE16722@waste.org>
References: <20070128142925.df2f4dce.akpm@osdl.org> <1170063848.6189.121.camel@twins> <45BE9FE8.4080603@mbligh.org> <20070129174118.0e922ab3.akpm@osdl.org> <45BEA41A.6020209@mbligh.org> <20070129181557.d4d17dd0.akpm@osdl.org> <20070131004436.GS44411608@melbourne.sgi.com> <20070130171132.7be3b054.akpm@osdl.org> <20070131032224.GV44411608@melbourne.sgi.com> <20070202120511.GA25714@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070202120511.GA25714@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 02, 2007 at 12:05:11PM +0000, Christoph Hellwig wrote:
> On Wed, Jan 31, 2007 at 02:22:24PM +1100, David Chinner wrote:
> > > Yup.  Even better, use clear_highpage().
> > 
> > For even more goodness, clearmem_highpage_flush() does exactly
> > the right thing for partial page zeroing ;)
> 
> Note that there are tons of places in buffer.c that could use
> clearmem_highpage_flush().  See the so far untested patch below:
> 

You probably need s/memclear/clearmem/g..
 
> Index: linux-2.6/fs/buffer.c
> ===================================================================
> --- linux-2.6.orig/fs/buffer.c	2007-02-02 12:53:51.000000000 +0100
> +++ linux-2.6/fs/buffer.c	2007-02-02 12:59:42.000000000 +0100
> @@ -1858,13 +1858,8 @@
>  		if (block_start >= to)
>  			break;
>  		if (buffer_new(bh)) {
> -			void *kaddr;
> -
>  			clear_buffer_new(bh);
> -			kaddr = kmap_atomic(page, KM_USER0);
> -			memset(kaddr+block_start, 0, bh->b_size);
> -			flush_dcache_page(page);
> -			kunmap_atomic(kaddr, KM_USER0);
> +			memclear_highpage_flush(page, block_start, bh->b_size);
>  			set_buffer_uptodate(bh);
>  			mark_buffer_dirty(bh);
>  		}
> @@ -1952,10 +1947,8 @@
>  					SetPageError(page);
>  			}
>  			if (!buffer_mapped(bh)) {
> -				void *kaddr = kmap_atomic(page, KM_USER0);
> -				memset(kaddr + i * blocksize, 0, blocksize);
> -				flush_dcache_page(page);
> -				kunmap_atomic(kaddr, KM_USER0);
> +				memclear_highpage_flush(page, i * blocksize,
> +							blocksize);
>  				if (!err)
>  					set_buffer_uptodate(bh);
>  				continue;
> @@ -2098,7 +2091,6 @@
>  	long status;
>  	unsigned zerofrom;
>  	unsigned blocksize = 1 << inode->i_blkbits;
> -	void *kaddr;
>  
>  	while(page->index > (pgpos = *bytes>>PAGE_CACHE_SHIFT)) {
>  		status = -ENOMEM;
> @@ -2120,10 +2112,8 @@
>  						PAGE_CACHE_SIZE, get_block);
>  		if (status)
>  			goto out_unmap;
> -		kaddr = kmap_atomic(new_page, KM_USER0);
> -		memset(kaddr+zerofrom, 0, PAGE_CACHE_SIZE-zerofrom);
> -		flush_dcache_page(new_page);
> -		kunmap_atomic(kaddr, KM_USER0);
> +		memclear_highpage_flush(page, zerofrom,
> +					PAGE_CACHE_SIZE - zerofrom);
>  		generic_commit_write(NULL, new_page, zerofrom, PAGE_CACHE_SIZE);
>  		unlock_page(new_page);
>  		page_cache_release(new_page);
> @@ -2150,10 +2140,7 @@
>  	if (status)
>  		goto out1;
>  	if (zerofrom < offset) {
> -		kaddr = kmap_atomic(page, KM_USER0);
> -		memset(kaddr+zerofrom, 0, offset-zerofrom);
> -		flush_dcache_page(page);
> -		kunmap_atomic(kaddr, KM_USER0);
> +		memclear_highpage_flush(page, zerofrom, offset - zerofrom);
>  		__block_commit_write(inode, page, zerofrom, offset);
>  	}
>  	return 0;
> @@ -2368,10 +2355,7 @@
>  	 * Error recovery is pretty slack.  Clear the page and mark it dirty
>  	 * so we'll later zero out any blocks which _were_ allocated.
>  	 */
> -	kaddr = kmap_atomic(page, KM_USER0);
> -	memset(kaddr, 0, PAGE_CACHE_SIZE);
> -	flush_dcache_page(page);
> -	kunmap_atomic(kaddr, KM_USER0);
> +	memclear_highpage_flush(page, 0, PAGE_CACHE_SIZE);
>  	SetPageUptodate(page);
>  	set_page_dirty(page);
>  	return ret;
> @@ -2405,7 +2389,6 @@
>  	loff_t i_size = i_size_read(inode);
>  	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
>  	unsigned offset;
> -	void *kaddr;
>  	int ret;
>  
>  	/* Is the page fully inside i_size? */
> @@ -2436,10 +2419,7 @@
>  	 * the  page size, the remaining memory is zeroed when mapped, and
>  	 * writes to that region are not written out to the file."
>  	 */
> -	kaddr = kmap_atomic(page, KM_USER0);
> -	memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
> -	flush_dcache_page(page);
> -	kunmap_atomic(kaddr, KM_USER0);
> +	memclear_highpage_flush(page, offset, PAGE_CACHE_SIZE - offset);
>  out:
>  	ret = mpage_writepage(page, get_block, wbc);
>  	if (ret == -EAGAIN)
> @@ -2460,7 +2440,6 @@
>  	unsigned to;
>  	struct page *page;
>  	const struct address_space_operations *a_ops = mapping->a_ops;
> -	char *kaddr;
>  	int ret = 0;
>  
>  	if ((offset & (blocksize - 1)) == 0)
> @@ -2474,10 +2453,7 @@
>  	to = (offset + blocksize) & ~(blocksize - 1);
>  	ret = a_ops->prepare_write(NULL, page, offset, to);
>  	if (ret == 0) {
> -		kaddr = kmap_atomic(page, KM_USER0);
> -		memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
> -		flush_dcache_page(page);
> -		kunmap_atomic(kaddr, KM_USER0);
> +		memclear_highpage_flush(page, offset, PAGE_CACHE_SIZE - offset);
>  		set_page_dirty(page);
>  	}
>  	unlock_page(page);
> @@ -2498,7 +2474,6 @@
>  	struct inode *inode = mapping->host;
>  	struct page *page;
>  	struct buffer_head *bh;
> -	void *kaddr;
>  	int err;
>  
>  	blocksize = 1 << inode->i_blkbits;
> @@ -2552,11 +2527,7 @@
>  			goto unlock;
>  	}
>  
> -	kaddr = kmap_atomic(page, KM_USER0);
> -	memset(kaddr + offset, 0, length);
> -	flush_dcache_page(page);
> -	kunmap_atomic(kaddr, KM_USER0);
> -
> +	memclear_highpage_flush(page, offset, length);
>  	mark_buffer_dirty(bh);
>  	err = 0;
>  
> @@ -2577,7 +2548,6 @@
>  	loff_t i_size = i_size_read(inode);
>  	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
>  	unsigned offset;
> -	void *kaddr;
>  
>  	/* Is the page fully inside i_size? */
>  	if (page->index < end_index)
> @@ -2603,10 +2573,7 @@
>  	 * the  page size, the remaining memory is zeroed when mapped, and
>  	 * writes to that region are not written out to the file."
>  	 */
> -	kaddr = kmap_atomic(page, KM_USER0);
> -	memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
> -	flush_dcache_page(page);
> -	kunmap_atomic(kaddr, KM_USER0);
> +	memclear_highpage_flush(page, offset, PAGE_CACHE_SIZE - offset);
>  	return __block_write_full_page(inode, page, get_block, wbc);
>  }
>  
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
