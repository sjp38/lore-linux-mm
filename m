Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B0CBF6B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 23:03:30 -0500 (EST)
Date: Fri, 11 Jan 2013 13:03:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage
 is unset
Message-ID: <20130111040328.GA6183@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-2-git-send-email-minchan@kernel.org>
 <20130109161854.67412dcc.akpm@linux-foundation.org>
 <20130110020347.GA14685@blaptop>
 <CAA25o9TjXNCpLHAyowboAxZrnQZmNmJOevDgA-zq4kA1K-PHXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9TjXNCpLHAyowboAxZrnQZmNmJOevDgA-zq4kA1K-PHXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi Luigi,

On Thu, Jan 10, 2013 at 03:24:21PM -0800, Luigi Semenzato wrote:
> For what it's worth, I tested this patch on my 3.4 kernel, and it works as
> advertised.  Here's my setup.
> 
> - 2 GB RAM
> - a 3 GB zram disk for swapping
> - start one "hog" process per second (each hog process mallocs and touches
> 200 MB of memory).
> - watch /proc/meminfo
> 
> 1. I verified that the problem still exists on my current 3.4 kernel.  With
> laptop_mode = 2, hog processes are oom-killed when about 1.8-1.9 (out of 3)
> GB of swap space are still left
> 
> 2. I double-checked that the problem does not exist with laptop_mode = 0:
> hog processes are oom-killed when swap space is exhausted (with good
> approximation).
> 
> 3. I added the two-line patch, put back laptop_mode = 2, and verified that
> hog processes are oom-killed when swap space is exhausted, same as case 2.
> 
> Let me know if I can run any more tests for you, and thanks for all the
> support so far!

Thanks very much! But it seems Andrew doesn't like this version.
I will discuss more with him and ask again with confimred version to you.

Thanks, again.!

FYI)
After I resolves this issue, will dive into min_filelist_kbytes patch. :)
> 
> 
> 
> On Wed, Jan 9, 2013 at 6:03 PM, Minchan Kim <minchan@kernel.org> wrote:
> 
> > Hi Andrew,
> >
> > On Wed, Jan 09, 2013 at 04:18:54PM -0800, Andrew Morton wrote:
> > > On Wed,  9 Jan 2013 15:21:13 +0900
> > > Minchan Kim <minchan@kernel.org> wrote:
> > >
> > > > Recently, Luigi reported there are lots of free swap space when
> > > > OOM happens. It's easily reproduced on zram-over-swap, where
> > > > many instance of memory hogs are running and laptop_mode is enabled.
> > > >
> > > > Luigi reported there was no problem when he disabled laptop_mode.
> > > > The problem when I investigate problem is following as.
> > > >
> > > > try_to_free_pages disable may_writepage if laptop_mode is enabled.
> > > > shrink_page_list adds lots of anon pages in swap cache by
> > > > add_to_swap, which makes pages Dirty and rotate them to head of
> > > > inactive LRU without pageout. If it is repeated, inactive anon LRU
> > > > is full of Dirty and SwapCache pages.
> > > >
> > > > In case of that, isolate_lru_pages fails because it try to isolate
> > > > clean page due to may_writepage == 0.
> > > >
> > > > The may_writepage could be 1 only if total_scanned is higher than
> > > > writeback_threshold in do_try_to_free_pages but unfortunately,
> > > > VM can't isolate anon pages from inactive anon lru list by
> > > > above reason and we already reclaimed all file-backed pages.
> > > > So it ends up OOM killing.
> > > >
> > > > This patch prevents to add a page to swap cache unnecessary when
> > > > may_writepage is unset so anoymous lru list isn't full of
> > > > Dirty/Swapcache page. So VM can isolate pages from anon lru list,
> > > > which ends up setting may_writepage to 1 and could swap out
> > > > anon lru pages. When OOM triggers, I confirmed swap space was full.
> > > >
> > > > ...
> > > >
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -780,6 +780,8 @@ static unsigned long shrink_page_list(struct
> > list_head *page_list,
> > > >             if (PageAnon(page) && !PageSwapCache(page)) {
> > > >                     if (!(sc->gfp_mask & __GFP_IO))
> > > >                             goto keep_locked;
> > > > +                   if (!sc->may_writepage)
> > > > +                           goto keep_locked;
> > > >                     if (!add_to_swap(page))
> > > >                             goto activate_locked;
> > > >                     may_enter_fs = 1;
> > >
> > > I'm not really getting it, and the description is rather hard to follow
> > :(
> >
> > It seems I don't have a talent about description. :(
> > I hope it would be better this year. :)
> >
> > >
> > > We should be adding anon pages to swapcache even when laptop_mode is
> > > set.  And we should be writing them to swap as well, then reclaiming
> > > them.  The only thing laptop_mode shouild do is make the disk spin up
> > > less frequently - that doesn't mean "not at all"!
> >
> > So it seems your rationale is that let's save power in only system has
> > enough memory so let's remove may_writepage in reclaim path?
> >
> > If it is, I love it because I didn't see any number about power saving
> > through reclaiming throttling(But surely there was reason to add it)
> > and not sure it works well during long time because we have tweaked
> > reclaim part too many.
> >
> > >
> > > So something seems screwed up here and the patch looks like a
> > > heavy-handed workaround.  Why aren't these anon pages getting written
> > > out in laptop_mode?
> >
> > Don't know. It was there long time and I don't want to screw it up.
> > If we decide paging out in reclaim path regardless of laptop_mode,
> > it makes the problem easy without ugly workaround.
> >
> > Remove may_writepage? If it's too agressive, we can remove it in only
> > direct reclaim path.
> >
> > >
> > >
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
