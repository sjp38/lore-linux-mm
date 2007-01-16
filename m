Subject: Re: [patch 6/10] mm: be sure to trim blocks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070113011255.9449.33228.sendpatchset@linux.site>
References: <20070113011159.9449.4327.sendpatchset@linux.site>
	 <20070113011255.9449.33228.sendpatchset@linux.site>
Content-Type: text/plain
Date: Tue, 16 Jan 2007 18:36:24 +0100
Message-Id: <1168968985.5975.30.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-01-13 at 04:25 +0100, Nick Piggin wrote:
> If prepare_write fails with AOP_TRUNCATED_PAGE, or if commit_write fails, then
> we may have failed the write operation despite prepare_write having
> instantiated blocks past i_size. Fix this, and consolidate the trimming into
> one place.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c
> +++ linux-2.6/mm/filemap.c
> @@ -1911,22 +1911,9 @@ generic_file_buffered_write(struct kiocb
>  		}
>  
>  		status = a_ops->prepare_write(file, page, offset, offset+bytes);
> -		if (unlikely(status)) {
> -			loff_t isize = i_size_read(inode);
> +		if (unlikely(status))
> +			goto fs_write_aop_error;
>  
> -			if (status != AOP_TRUNCATED_PAGE)
> -				unlock_page(page);
> -			page_cache_release(page);
> -			if (status == AOP_TRUNCATED_PAGE)
> -				continue;
> -			/*
> -			 * prepare_write() may have instantiated a few blocks
> -			 * outside i_size.  Trim these off again.
> -			 */
> -			if (pos + bytes > isize)
> -				vmtruncate(inode, isize);
> -			break;
> -		}
>  		if (likely(nr_segs == 1))
>  			copied = filemap_copy_from_user(page, offset,
>  							buf, bytes);
> @@ -1935,10 +1922,9 @@ generic_file_buffered_write(struct kiocb
>  						cur_iov, iov_offset, bytes);
>  		flush_dcache_page(page);
>  		status = a_ops->commit_write(file, page, offset, offset+bytes);
> -		if (status == AOP_TRUNCATED_PAGE) {
> -			page_cache_release(page);
> -			continue;
> -		}
> +		if (unlikely(status))
> +			goto fs_write_aop_error;
> +

I don't think this is correct, see how status >= 0 is used a few lines
downwards. Perhaps something along the lines of an
is_positive_aop_return() to test on?

>  		if (likely(copied > 0)) {
>  			if (!status)
>  				status = copied;
> @@ -1969,6 +1955,25 @@ generic_file_buffered_write(struct kiocb
>  			break;
>  		balance_dirty_pages_ratelimited(mapping);
>  		cond_resched();
> +		continue;
> +
> +fs_write_aop_error:
> +		if (status != AOP_TRUNCATED_PAGE)
> +			unlock_page(page);
> +		page_cache_release(page);
> +
> +		/*
> +		 * prepare_write() may have instantiated a few blocks
> +		 * outside i_size.  Trim these off again. Don't need
> +		 * i_size_read because we hold i_mutex.
> +		 */
> +		if (pos + bytes > inode->i_size)
> +			vmtruncate(inode, inode->i_size);
> +		if (status == AOP_TRUNCATED_PAGE)
> +			continue;
> +		else
> +			break;
> +
>  	} while (count);
>  	*ppos = pos;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
