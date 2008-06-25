Date: Wed, 25 Jun 2008 17:11:17 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Message-ID: <20080625131117.GA28136@2ka.mipt.ru>
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080625124121.839734708@szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, Jun 25, 2008 at 02:40:39PM +0200, Miklos Szeredi (miklos@szeredi.hu) wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> Clearing the uptodate page flag will cause page_cache_pipe_buf_confirm()
> to return -ENODATA if that page was in the buffer.  This in turn will cause
> splice() to return a short or zero count.
> 
> This manifested itself in rare I/O errors seen on nfs exported fuse
> filesystems.  This is because nfsd uses splice_direct_to_actor() to
> read files, and fuse uses invalidate_inode_pages2() to invalidate
> stale data on open.
> 
> Fix this by not clearing PG_uptodate on page invalidation.  This will
> result in the old, invalid page contents being copied.  But that's OK,
> the contents were valid at splice-in time (which is when the the
> "copy" was conceptually done).
> 
> I haven't done an audit of all code that checks the PG_uptodate flags,
> but I suspect, that this change won't have any harmful effects.  Most
> code checks page->mapping to see if the page was truncated or
> invalidated, before using it, and retries the find/read on the page if
> it wasn't.  The page_cache_pipe_buf_confirm() code is an exception in
> this regard.

What about writing path, when page is written after some previous write?
Like __block_prepare_write()?

> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
>  mm/truncate.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> Index: linux-2.6/mm/truncate.c
> ===================================================================
> --- linux-2.6.orig/mm/truncate.c	2008-06-24 20:49:25.000000000 +0200
> +++ linux-2.6/mm/truncate.c	2008-06-24 23:28:32.000000000 +0200
> @@ -356,7 +356,6 @@ invalidate_complete_page2(struct address
>  	BUG_ON(PagePrivate(page));
>  	__remove_from_page_cache(page);
>  	write_unlock_irq(&mapping->tree_lock);
> -	ClearPageUptodate(page);
>  	page_cache_release(page);	/* pagecache ref */
>  	return 1;
>  failed:

Don't do that, add new function instead which will do exactly that, if
you do need exactly this behaviour.

Also why isn't invalidate_complete_page() enough, if you want to have
that page to be half invalidated?

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
