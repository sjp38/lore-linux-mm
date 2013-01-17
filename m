Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6C37A6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 19:53:18 -0500 (EST)
Date: Thu, 17 Jan 2013 09:53:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage
 is unset
Message-ID: <20130117005314.GB18669@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-2-git-send-email-minchan@kernel.org>
 <20130116134155.18092f1a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130116134155.18092f1a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Jan 16, 2013 at 01:41:55PM -0800, Andrew Morton wrote:
> On Wed,  9 Jan 2013 15:21:13 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> >
> 
> This changelog is quite hard to understand :(
> 
> > Recently, Luigi reported there are lots of free swap space when
> > OOM happens. It's easily reproduced on zram-over-swap, where
> > many instance of memory hogs are running and laptop_mode is enabled.
> > 
> > Luigi reported there was no problem when he disabled laptop_mode.
> > The problem when I investigate problem is following as.
> > 
> > try_to_free_pages disable may_writepage if laptop_mode is enabled.
> > shrink_page_list adds lots of anon pages in swap cache by
> > add_to_swap, which makes pages Dirty and rotate them to head of
> > inactive LRU without pageout. If it is repeated, inactive anon LRU
> > is full of Dirty and SwapCache pages.
> 
> "Dirty and SwapCache" is ambigious.  Does it mean "dirty pages and
> swapcache pages" or does it mean "dirty swapcache pages".  The latter,
> I expect.

Yeb.

> 
> > 
> > In case of that, isolate_lru_pages fails because it try to isolate
> > clean page due to may_writepage == 0.
> > 
> > The may_writepage could be 1 only if total_scanned is higher than
> > writeback_threshold in do_try_to_free_pages but unfortunately,
> > VM can't isolate anon pages from inactive anon lru list by
> > above reason and we already reclaimed all file-backed pages.
> > So it ends up OOM killing.
> 
> Here, please expand upon "by above reason".  Explain here exactly why
> scanning is unsuccessful.

Let me try again ;)

============================  &< ============================

Recently, Luigi reported there are lots of free swap space when
OOM happens. It's easily reproduced on zram-over-swap, where
many instance of memory hogs are running and laptop_mode is enabled.
He said there was no problem when he disabled laptop_mode.

The problem when I investigate problem is following as.

Assumption for easy explanation: There are no page cache page in system
because they all are already reclaimed.

1. try_to_free_pages disable may_writepage when laptop_mode is enabled.
2. shrink_inactive_list isolates victim pages from inactive anon lru list.
3. shrink_page_list adds them to swapcache via add_to_swap but it doesn't
   pageout because sc->may_writepage is 0 so the page is rotated back into
   inactive anon lru list. The add_to_swap made the page Dirty by SetPageDirty.
4. 3 couldn't reclaim any pages so do_try_to_free_pages increase priority and
   retry reclaim with higher priority.
5. shrink_inactlive_list try to isolate victim pages from inactive anon lru list
   but got failed because it try to isolate pages with ISOLATE_CLEAN mode but
   inactive anon lru list is full of dirty pages by 3 so it just returns
   without  any reclaim progress.
6. do_try_to_free_pages doesn't set may_write due to zero total_scanned.
   Because sc->nr_scanned is increased by shrink_page_list but we don't call
   shrink_page_list in 5 due to short of isolated pages.

Above loop is continued until OOM happens.
The problem didn't happen before [1] was merged because old logic's isolatation
in shrink_inactive_list was successful and tried to call shrink_page_list
to pageout them but it still ends up failed to page out by may_writepage.
But important point is that sc->nr_scanned was increased althoug we couldn't
swap out them so do_try_to_free_pages could set may_writepages.
So this patch need to go stable tree althoug it's a band-aid.
Then, for latest linus tree, we should fix laptop_mode's fundamental
problem.

[1] f80c067[mm: zone_reclaim: make isolate_lru_page() filter-aware]

> 
> > This patch prevents to add a page to swap cache unnecessary when
> > may_writepage is unset so anoymous lru list isn't full of
> > Dirty/Swapcache page. So VM can isolate pages from anon lru list,
> > which ends up setting may_writepage to 1 and could swap out
> > anon lru pages. When OOM triggers, I confirmed swap space was full.
> > 
> > ...
> >
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -780,6 +780,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		if (PageAnon(page) && !PageSwapCache(page)) {
> >  			if (!(sc->gfp_mask & __GFP_IO))
> >  				goto keep_locked;
> > +			if (!sc->may_writepage)
> > +				goto keep_locked;
> >  			if (!add_to_swap(page))
> >  				goto activate_locked;
> >  			may_enter_fs = 1;
> 
> Needs a comment explaining why we bale out in this case, please.


Okay. How about this?

/*
 * There is no point to add a page to swap cache if we can't swap out.
 */

> 
> If I'm understanding it correctly, this change causes the kernel to
> move less anonymous memory onto the inactive anon LRU and thereby

No. The amount of inactive anon LRU is same. Patch just prevent to add
page to swapcache unnecessary.

> causes the scanner to be more successful in locating clean swapcache
> pages on that list?  But that makes no sense, because from your
> description it appears the intent of the patch is to use *more* swap.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
