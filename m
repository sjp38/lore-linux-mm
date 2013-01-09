Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 68CD16B004D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 01:22:38 -0500 (EST)
Date: Wed, 9 Jan 2013 15:22:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: swap out anonymous page regardless of laptop_mode
Message-ID: <20130109062236.GA26185@blaptop>
References: <20130108075327.GB4714@blaptop>
 <CAA25o9R2FvO+Ngqg2eHFDVEpVmUtnTn1A_VJf58FtbAZM=92og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9R2FvO+Ngqg2eHFDVEpVmUtnTn1A_VJf58FtbAZM=92og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

Hi Luigi,

On Tue, Jan 08, 2013 at 05:20:25PM -0800, Luigi Semenzato wrote:
> No problem at all---as I mentioned, we stopped using laptop_mode, so
> this is no longer an issue for us.
> 
> I should be able to test the patch for you in the next 2-3 days.  I
> will let you know if I run into problems.

Right now, I sent new version. I think it's better than this patch.
Could you test new version instead of this?

Thanks!

> 
> Thanks!
> Luigi
> 
> On Mon, Jan 7, 2013 at 11:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hi Luigi,
> >
> > Sorry for really really late response.
> > Today I have a time to look at this problem and it seems to found the problem.
> > By your help, I can reprocude this problem easily on my KVM machine and this
> > patch solves the problem.
> >
> > Could you test below patch? Although this patch is based on recent mmotm,
> > I guess you can apply it easily to 3.4.
> >
> > From f74fdf644bec3e7875d245154db953b47b6c9594 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Tue, 8 Jan 2013 16:23:31 +0900
> > Subject: [PATCH] mm: swap out anonymous page regardless of laptop_mode
> >
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
> >
> > In case of that, isolate_lru_pages fails because it try to isolate
> > clean page due to may_writepage == 0.
> >
> > may_writepage could be 1 only if total_scanned is higher than
> > writeback_threshold in do_try_to_free_pages but unfortunately,
> > VM can't isolate anon pages from inactive anon lru list by
> > above reason and we already reclaimed all file-backed pages.
> > So it ends up OOM killing.
> >
> > This patch makes may_writepage could be set when shrink_inactive_list
> > encounters SwapCachePage from tail of inactive anon LRU.
> > What it means that anon LRU list is short and memory pressure
> > is severe so it would be better to swap out that pages by sacrificing
> > the power rather than OOM killing.
> >
> > Reported-by: Luigi Semenzato <semenzato@google.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/vmscan.c |   13 ++++++++++++-
> >  1 file changed, 12 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ff869d2..7397a6b 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1102,7 +1102,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >                 prefetchw_prev_lru_page(page, src, flags);
> >
> >                 VM_BUG_ON(!PageLRU(page));
> > -
> > +retry:
> >                 switch (__isolate_lru_page(page, mode)) {
> >                 case 0:
> >                         nr_pages = hpage_nr_pages(page);
> > @@ -1112,6 +1112,17 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >                         break;
> >
> >                 case -EBUSY:
> > +                       /*
> > +                        * If VM encounters PageSwapCache from inactive LRU,
> > +                        * it means we havd to swap out those pages regardless
> > +                        * of laptop_mode for preventing OOM kill.
> > +                        */
> > +                       if ((mode & ISOLATE_CLEAN) && PageSwapCache(page) &&
> > +                               !PageActive(page)) {
> > +                               mode &= ~ISOLATE_CLEAN;
> > +                               sc->may_writepage = 1;
> > +                               goto retry;
> > +                       }
> >                         /* else it is being freed elsewhere */
> >                         list_move(&page->lru, src);
> >                         continue;
> > --
> > 1.7.9.5
> >
> >
> > On Thu, Nov 29, 2012 at 11:31:46AM -0800, Luigi Semenzato wrote:
> >> Oh well, I found the problem, it's laptop_mode.  We keep it on by
> >> default.  When I turn it off, I can allocate as fast as I can, and no
> >> OOMs happen until swap is exhausted.
> >>
> >> I don't think this is a desirable behavior even for laptop_mode, so if
> >> anybody wants to help me debug it (or wants my help in debugging it)
> >> do let me know.
> >>
> >> Thanks!
> >> Luigi
> >>
> >> On Thu, Nov 29, 2012 at 10:46 AM, Luigi Semenzato <semenzato@google.com> wrote:
> >> > Minchan:
> >> >
> >> > I tried your suggestion to move the call to wake_all_kswapd from after
> >> > "restart:" to after "rebalance:".  The behavior is still similar, but
> >> > slightly improved.  Here's what I see.
> >> >
> >> > Allocating as fast as I can: 1.5 GB of the 3 GB of zram swap are used,
> >> > then OOM kills happen, and the system ends up with 1 GB swap used, 2
> >> > unused.
> >> >
> >> > Allocating 10 MB/s: some kills happen when only 1 to 1.5 GB are used,
> >> > and continue happening while swap fills up.  Eventually swap fills up
> >> > completely.  This is better than before (could not go past about 1 GB
> >> > of swap used), but there are too many kills too early.  I would like
> >> > to see no OOM kills until swap is full or almost full.
> >> >
> >> > Allocating 20 MB/s: almost as good as with 10 MB/s, but more kills
> >> > happen earlier, and not all swap space is used (400 MB free at the
> >> > end).
> >> >
> >> > This is with 200 processes using 20 MB each, and 2:1 compression ratio.
> >> >
> >> > So it looks like kswapd is still not aggressive enough in pushing
> >> > pages out.  What's the best way of changing that?  Play around with
> >> > the watermarks?
> >> >
> >> > Incidentally, I also tried removing the min_filelist_kbytes hacky
> >> > patch, but, as usual, the system thrashes so badly that it's
> >> > impossible to complete any experiment.  I set it to a lower minimum
> >> > amount of free file pages, 10 MB instead of the 50 MB which we use
> >> > normally, and I could run with some thrashing, but I got the same
> >> > results.
> >> >
> >> > Thanks!
> >> > Luigi
> >> >
> >> >
> >> > On Wed, Nov 28, 2012 at 4:31 PM, Luigi Semenzato <semenzato@google.com> wrote:
> >> >> I am beginning to understand why zram appears to work fine on our x86
> >> >> systems but not on our ARM systems.  The bottom line is that swapping
> >> >> doesn't work as I would expect when allocation is "too fast".
> >> >>
> >> >> In one of my tests, opening 50 tabs simultaneously in a Chrome browser
> >> >> on devices with 2 GB of RAM and a zram-disk of 3 GB (uncompressed), I
> >> >> was observing that on the x86 device all of the zram swap space was
> >> >> used before OOM kills happened, but on the ARM device I would see OOM
> >> >> kills when only about 1 GB (out of 3) was swapped out.
> >> >>
> >> >> I wrote a simple program to understand this behavior.  The program
> >> >> (called "hog") allocates memory and fills it with a mix of
> >> >> incompressible data (from /dev/urandom) and highly compressible data
> >> >> (1's, just to avoid zero pages) in a given ratio.  The memory is never
> >> >> touched again.
> >> >>
> >> >> It turns out that if I don't limit the allocation speed, I see
> >> >> premature OOM kills also on the x86 device.  If I limit the allocation
> >> >> to 10 MB/s, the premature OOM kills stop happening on the x86 device,
> >> >> but still happen on the ARM device.  If I further limit the allocation
> >> >> speed to 5 Mb/s, the premature OOM kills disappear also from the ARM
> >> >> device.
> >> >>
> >> >> I have noticed a few time constants in the MM whose value is not well
> >> >> explained, and I am wondering if the code is tuned for some ideal
> >> >> system that doesn't behave like ours (considering, for instance, that
> >> >> zram is much faster than swapping to a disk device, but it also uses
> >> >> more CPU).  If this is plausible, I am wondering if anybody has
> >> >> suggestions for changes that I could try out to obtain a better
> >> >> behavior with a higher allocation speed.
> >> >>
> >> >> Thanks!
> >> >> Luigi
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
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
