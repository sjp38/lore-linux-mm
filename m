Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B45F26B005C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 01:40:53 -0400 (EDT)
Date: Sun, 26 Apr 2009 22:37:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix race between callers of read_cache_page_async and
 invalidate_inode_pages.
Message-Id: <20090426223744.72edc7f4.akpm@linux-foundation.org>
In-Reply-To: <18933.16534.862316.787808@notabene.brown>
References: <18933.16534.862316.787808@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Woodhouse <dwmw2@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 15:20:22 +1000 Neil Brown <neilb@suse.de> wrote:

> 
> 
> 
> Callers of read_cache_page_async typically wait for the page to become
> unlocked (wait_on_page_locked) and then test PageUptodate to see if
> the read was successful, or if there was an error.
> 
> This is wrong.
> 
> invalidate_inode_pages can cause an unlocked page to lose its
> PageUptodate flag at any time without implying a read error.

ow.

> As any read error will cause PageError to be set, it is much safer,
> and more idiomatic to test "PageError" than to test "!PageUptodate".
> 
> ...
>
> diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
> index dd3634e..573d582 100644
> --- a/fs/cramfs/inode.c
> +++ b/fs/cramfs/inode.c
> @@ -180,7 +180,7 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
>  		struct page *page = pages[i];
>  		if (page) {
>  			wait_on_page_locked(page);
> -			if (!PageUptodate(page)) {
> +			if (PageError(page)) {
>  				/* asynchronous error */
>  				page_cache_release(page);
>  				pages[i] = NULL;
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 379ff0b..9ff8093 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1770,7 +1770,7 @@ struct page *read_cache_page(struct address_space *mapping,
>  	if (IS_ERR(page))
>  		goto out;
>  	wait_on_page_locked(page);
> -	if (!PageUptodate(page)) {
> +	if (!PageError(page)) {
>  		page_cache_release(page);
>  		page = ERR_PTR(-EIO);
>  	}

hrm.  And where is it written that PageError() will remain inviolable
after it has been set?

A safer and more formal (albeit somewhat slower) fix would be to lock
the page and check its state under the lock.

y:/usr/src/linux-2.6.30-rc3> grep -r ClearPageError . | wc -l
21

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
