Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 32FE06B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 15:16:27 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so5945444qcs.14
        for <linux-mm@kvack.org>; Mon, 17 Sep 2012 12:16:26 -0700 (PDT)
Date: Mon, 17 Sep 2012 12:15:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Does swap_set_page_dirty() calling ->set_page_dirty() make
 sense?
In-Reply-To: <20120917163518.GD9150@quack.suse.cz>
Message-ID: <alpine.LSU.2.00.1209171204100.6720@eggly.anvils>
References: <20120917163518.GD9150@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, 17 Sep 2012, Jan Kara wrote:
> 
>   I tripped over a crash in reiserfs which happened due to PageSwapCache
> page being passed to reiserfs_set_page_dirty(). Now it's not that hard to
> make reiserfs_set_page_dirty() check that case but I really wonder: Does it
> make sense to call mapping->a_ops->set_page_dirty() for a PageSwapCache
> page? The page is going to be written via direct IO so from the POV of the
> filesystem there's no need for any dirtiness tracking. Also there are
> several ->set_page_dirty() implementations which will spectacularly crash
> because they do things like page->mapping->host, or call
> __set_page_dirty_buffers() which expects buffer heads in page->private.
> Or what is the reason for calling filesystem's set_page_dirty() function?

This is a question for Mel, really: it used not to call the filesystem.

But my reading of the 3.6 code says that it still will not call the
filesystem, unless the filesystem (only nfs) provides a swap_activate
method, which should be the only case in which SWP_FILE gets set.
And I rather think Mel does want to use the filesystem set_page_dirty
in that case.  Am I misreading?

Did you see this on a vanilla kernel?  Or is it possible that you have
a private patch merged in, with something else sharing the SWP_FILE bit
(defined in include/linux/swap.h) by mistake?

Hugh

> [PATCH] mm: Remove swap_set_page_dirty()
> 
> It doesn't make much sense to call filesystem's ->set_page_dirty() method for
> PageSwapCache page. It will be written through direct IO so filesystem doesn't
> care about its dirtiness and several filesystems actually don't count with such
> pages getting into their ->set_page_dirty() functions.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/page_io.c    |   12 ------------
>  mm/swap_state.c |    2 +-
>  2 files changed, 1 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 78eee32..8520a4f 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -278,15 +278,3 @@ int swap_readpage(struct page *page)
>  out:
>  	return ret;
>  }
> -
> -int swap_set_page_dirty(struct page *page)
> -{
> -	struct swap_info_struct *sis = page_swap_info(page);
> -
> -	if (sis->flags & SWP_FILE) {
> -		struct address_space *mapping = sis->swap_file->f_mapping;
> -		return mapping->a_ops->set_page_dirty(page);
> -	} else {
> -		return __set_page_dirty_no_writeback(page);
> -	}
> -}
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 0cb36fb..01852cd 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -27,7 +27,7 @@
>   */
>  static const struct address_space_operations swap_aops = {
>  	.writepage	= swap_writepage,
> -	.set_page_dirty	= swap_set_page_dirty,
> +	.set_page_dirty	= set_page_dirty_no_writeback,
>  	.migratepage	= migrate_page,
>  };
>  
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
