Date: Fri, 2 Feb 2007 15:52:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/9] fs: libfs buffered write leak fix
Message-Id: <20070202155236.dae54aa2.akpm@linux-foundation.org>
In-Reply-To: <20070129081914.23584.23886.sendpatchset@linux.site>
References: <20070129081905.23584.97878.sendpatchset@linux.site>
	<20070129081914.23584.23886.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 11:31:46 +0100 (CET)
Nick Piggin <npiggin@suse.de> wrote:

> simple_prepare_write and nobh_prepare_write leak uninitialised kernel data.

They do?  Under what situation?

> Fix the former,

How?

> make a note of the latter. Several other filesystems seem
> to be iffy here, too.

Please, tell us what the bug is so that others have a chance of reviewing
and, if needed, fixing those other filesystems.

> --- linux-2.6.orig/fs/libfs.c
> +++ linux-2.6/fs/libfs.c
> @@ -327,32 +327,35 @@ int simple_readpage(struct file *file, s
>  int simple_prepare_write(struct file *file, struct page *page,
>  			unsigned from, unsigned to)
>  {
> -	if (!PageUptodate(page)) {
> -		if (to - from != PAGE_CACHE_SIZE) {
> -			void *kaddr = kmap_atomic(page, KM_USER0);
> -			memset(kaddr, 0, from);
> -			memset(kaddr + to, 0, PAGE_CACHE_SIZE - to);
> -			flush_dcache_page(page);
> -			kunmap_atomic(kaddr, KM_USER0);
> -		}
> +	if (PageUptodate(page))
> +		return 0;
> +
> +	if (to - from != PAGE_CACHE_SIZE) {
> +		clear_highpage(page);
> +		flush_dcache_page(page);
>  		SetPageUptodate(page);
>  	}

memclear_highpage_flush() is fashionable.

> ===================================================================
> --- linux-2.6.orig/fs/buffer.c
> +++ linux-2.6/fs/buffer.c
> @@ -2344,6 +2344,8 @@ int nobh_prepare_write(struct page *page
>  
>  	if (is_mapped_to_disk)
>  		SetPageMappedToDisk(page);
> +
> +	/* XXX: information leak vs read(2) */
>  	SetPageUptodate(page);
>  
>  	/*

That comment is too terse to be useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
