Date: Fri, 2 Feb 2007 15:53:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-Id: <20070202155311.e4f57985.akpm@linux-foundation.org>
In-Reply-To: <20070129082030.23584.72376.sendpatchset@linux.site>
References: <20070129081905.23584.97878.sendpatchset@linux.site>
	<20070129082030.23584.72376.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 11:33:03 +0100 (CET)
Nick Piggin <npiggin@suse.de> wrote:

> Modify the core write() code so that it won't take a pagefault while holding a
> lock on the pagecache page. There are a number of different deadlocks possible
> if we try to do such a thing:
> 
> 1.  generic_buffered_write
> 2.   lock_page
> 3.    prepare_write
> 4.     unlock_page+vmtruncate
> 5.     copy_from_user
> 6.      mmap_sem(r)
> 7.       handle_mm_fault
> 8.        lock_page (filemap_nopage)
> 9.    commit_write
> 10.  unlock_page
> 
> a. sys_munmap / sys_mlock / others
> b.  mmap_sem(w)
> c.   make_pages_present
> d.    get_user_pages
> e.     handle_mm_fault
> f.      lock_page (filemap_nopage)
> 
> 2,8	- recursive deadlock if page is same
> 2,8;2,8	- ABBA deadlock is page is different
> 2,6;b,f	- ABBA deadlock if page is same
> 
> The solution is as follows:
> 1.  If we find the destination page is uptodate, continue as normal, but use
>     atomic usercopies which do not take pagefaults and do not zero the uncopied
>     tail of the destination. The destination is already uptodate, so we can
>     commit_write the full length even if there was a partial copy: it does not
>     matter that the tail was not modified, because if it is dirtied and written
>     back to disk it will not cause any problems (uptodate *means* that the
>     destination page is as new or newer than the copy on disk).
> 
> 1a. The above requires that fault_in_pages_readable correctly returns access
>     information, because atomic usercopies cannot distinguish between
>     non-present pages in a readable mapping, from lack of a readable mapping.
> 
> 2.  If we find the destination page is non uptodate, unlock it (this could be
>     made slightly more optimal), then find and pin the source page with
>     get_user_pages. Relock the destination page and continue with the copy.
>     However, instead of a usercopy (which might take a fault), copy the data
>     via the kernel address space.
> 

Oh what a mess we're making :(

Unfortunately, write() into a non-uptodate page is very much the common
case.  We've always tried to avoid doing a pte-walk in the write() path to
fix this bug.  Careful performance testing is needed here so we can assess
the impact.  For threaded applications, simply the taking of mmap_sem might
be the biggest problem.

And I can't think of any tricks we can play to avoid doing the pte-walk in
most cases.  For example, we don't yet have a page to run page_mapped()
against.

>  			break;
>  		}
>  
> +		/*
> +		 * non-uptodate pages cannot cope with short copies, and we
> +		 * cannot take a pagefault with the destination page locked.
> +		 * So pin the source page to copy it.
> +		 */
> +		if (!PageUptodate(page)) {
> +			unlock_page(page);
> +
> +			bytes = min(bytes, PAGE_CACHE_SIZE -
> +				     ((unsigned long)buf & ~PAGE_CACHE_MASK));
> +
> +			/*
> +			 * Cannot get_user_pages with a page locked for the
> +			 * same reason as we can't take a page fault with a
> +			 * page locked (as explained below).
> +			 */
> +			down_read(&current->mm->mmap_sem);
> +			status = get_user_pages(current, current->mm,
> +					(unsigned long)buf & PAGE_CACHE_MASK, 1,
> +					0, 0, &src_page, NULL);
> +			up_read(&current->mm->mmap_sem);
> +			if (status != 1) {
> +				page_cache_release(page);
> +				break;
> +			}
> +
> +			lock_page(page);
> +			if (!page->mapping) {

Hopefully this can't happen?  If it can, who went and took our page off the
mapping?  Reclaim?  The elevated page_count will prevent that?

> +				unlock_page(page);
> +				page_cache_release(page);
> +				page_cache_release(src_page);
> +				continue;
> +			}
> +
> +		}
> +
>  		status = a_ops->prepare_write(file, page, offset, offset+bytes);
>  		if (unlikely(status))
>  			goto fs_write_aop_error;
>  
> -		copied = filemap_copy_from_user(page, offset,
> +		if (!src_page) {
> +			/*
> +			 * Must not enter the pagefault handler here, because
> +			 * we hold the page lock, so we might recursively
> +			 * deadlock on the same lock, or get an ABBA deadlock
> +			 * against a different lock, or against the mmap_sem
> +			 * (which nests outside the page lock).  So increment
> +			 * preempt count, and use _atomic usercopies.
> +			 *
> +			 * The page is uptodate so we are OK to encounter a
> +			 * short copy: if unmodified parts of the page are
> +			 * marked dirty and written out to disk, it doesn't
> +			 * really matter.
> +			 */
> +			pagefault_disable();
> +			copied = filemap_copy_from_user_atomic(page, offset,
>  					cur_iov, nr_segs, iov_offset, bytes);
> +			pagefault_enable();
> +		} else {
> +			char *src, *dst;
> +			src = kmap(src_page);
> +			dst = kmap(page);
> +			memcpy(dst + offset,
> +				src + ((unsigned long)buf & ~PAGE_CACHE_MASK),
> +				bytes);
> +			kunmap(page);
> +			kunmap(src_page);
> +			copied = bytes;
> +		}

As you say, we don't want to do this: taking two kmap()s at the same time
leaves us vulnerable to kmap() deadlocks: we deadlock when there are 512
tasks (LAST_PKMAP) each holding one kmap, and all waiting for someone else
to give one back.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
