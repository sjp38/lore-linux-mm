Date: Mon, 30 Aug 2004 08:41:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap
    partition
In-Reply-To: <20040829152820.715d137d.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0408300821170.13008-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, axboe@suse.de, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Aug 2004, Andrew Morton wrote:
> William Lee Irwin III <wli@holomorphy.com> wrote:
> >  On Sun, Aug 29, 2004 at 01:59:17PM -0700, Andrew Morton wrote:
> >  > The changlog wasn't that detailed ;)
> >  > But yes, it's the large nr_requests which is tripping up swapout.  I'm
> >  > assuming that when a process exits with its anonymous memory still under
> >  > swap I/O we're forgetting to actually free the pages when the I/O
> >  > completes.  So we end up with a ton of zero-ref swapcache pages on the LRU.
> >  > I assume.   Something odd's happening, that's for sure.
> > 
> >  Maybe we need to be checking for this in end_swap_bio_write() or
> >  rotate_reclaimable_page()?
> 
> Maybe.  I thought a get_page() in swap_writepage() and a put_page() in
> end_swap_bio_write() would cause the page to be freed.  But not.  It needs
> some actual real work done on it.

There are quite a few limitations on when page can be freed from SwapCache.
Involves locks you wouldn't want to take from just anywhere.  If the right
conditions don't happen to be met at the time a process exits, it's quite
normal for the SwapCache pages to hang around awhile, until eventually the
__delete_from_swap_cache towards the end of shrink_list removes them.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
