Message-ID: <45A9AAAB.2090008@yahoo.com.au>
Date: Sun, 14 Jan 2007 14:59:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 10/10] mm: fix pagecache write deadlocks
References: <20070113011159.9449.4327.sendpatchset@linux.site> <20070113011334.9449.61323.sendpatchset@linux.site>
In-Reply-To: <20070113011334.9449.61323.sendpatchset@linux.site>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> @@ -1878,31 +1889,88 @@ generic_file_buffered_write(struct kiocb
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
> +			status = get_user_pages(current, current->mm,
> +					(unsigned long)buf & PAGE_CACHE_MASK, 1,
> +					0, 0, &src_page, NULL);

Thinko... get_user_pages needs to be called with mmap_sem held, obviously.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
