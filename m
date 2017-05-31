Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCE26B0292
	for <linux-mm@kvack.org>; Tue, 30 May 2017 21:31:58 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x25so419609pgc.10
        for <linux-mm@kvack.org>; Tue, 30 May 2017 18:31:58 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 3si47195368plt.318.2017.05.30.18.31.56
        for <linux-mm@kvack.org>;
        Tue, 30 May 2017 18:31:57 -0700 (PDT)
Date: Wed, 31 May 2017 10:31:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: add counters for different page fault types
Message-ID: <20170531013153.GA6422@bbox>
References: <20170524194126.18040-1-semenzato@chromium.org>
 <20170525001915.GA14999@bbox>
 <CAA25o9SH=LSeeRAfHfMK0JyPuDfzLMMOvyXz5RZJ5taa3hybhw@mail.gmail.com>
 <20170526040622.GB17837@bbox>
 <CAA25o9QG=Juynu-8wAYvdY1t7YNGVtE10fav2u3S-DikuU=aMQ@mail.gmail.com>
 <20170529081525.GA8311@bbox>
 <CAA25o9Q0ewQyRe=VYOvx2M6FmOxwoRbLqOSmgxfDuJGuExCkQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9Q0ewQyRe=VYOvx2M6FmOxwoRbLqOSmgxfDuJGuExCkQg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Douglas Anderson <dianders@google.com>, Dmitry Torokhov <dtor@google.com>, Sonny Rao <sonnyrao@google.com>

Hello Luigi,

On Tue, May 30, 2017 at 11:41:37AM -0700, Luigi Semenzato wrote:
> On Mon, May 29, 2017 at 1:15 AM, Minchan Kim <minchan@kernel.org> wrote:
> 
> >> These numbers are from a Chromebook with a few dozen Chrome tabs and a
> >> couple of Android apps, and pretty heavy use of zram.
> >>
> >> pgpgin 4688863
> >> pgpgout 442052
> >> pswpin 353675
> >> pswpout 1072021
> >> ...
> >> pgfault 5564247
> >> pgmajfault 355758
> >> pgmajfault_s 6297
> >> pgmajfault_a 317645
> >> pgmajfault_f 31816
> >> pgmajfault_ax 8494
> >> pgmajfault_fx 13201
> >>
> >> where _s, _a, and _f are for shmem, anon, and file pages.
> >> (ax and fx are for the subset of executable pages---I was curious about that)
> >>
> >> So the numbers don't completely match:
> >> anon faults = 318,000
> >> swap ins = 354,000
> >>
> >> Any idea of what might explain the difference?
> >
> > Some of application call madvise(MADV_WILLNEED) for shmem or anon?
> 
> Thank you for the suggestion.  Nevertheless, the problem is that
> pgmajfault - pswpin is 2,000, which is far from the 32,000 major file
> faults, and figuring out where the difference comes from is not
> simple.  (Or is it, and I am just too lazy?  Often it's hard to tell
> :)

What's the your kernel version? IOW, What kernel version against
this patch? It helps to look at code more detail with your patch.

A possibility is shared memory(e.g., between parent and child by forking)
with concurrent page faulting.

do_swap_page
        page = lookup_swap_cache <- first swapcache miss
        if (!page) {
                page = swapin_readahead
                        read_swap_cache_async
                          return find_get_page(swapper_space,
                                          swp_offset(entry)); <- second hit
        }

In above case, it should be minor fault if it found the page in swapcache
but VM counts it as major fault. If you verify it's the problem,
we can fix it but 2000 is under 1% in your anon faults so I'm not sure
how it's significant if we consider lots of kernel stat is inaccurate
within noise level.

> 
> > Yes, it's doable but a thing we need to merge new stat is concrete
> > justification rather than "Having, Better. Why not?" approach.
> > In my testing, I just wanted to know just file vs anon LRU balancing
> > so it was out of my interest but you might have a reason to know it.
> > Then, you can send a patch with detailed changelog. :)
> 
> Yes I agree, I don't like adding random stats either "just in case
> they are useful".
> 
> For this stat, we too are interested in the balance between FILE and
> ANON faults, because a zram page fault costs us about 10us, but the
> latency from disk read to service the FILE fault is about 300us.  So
> we want to ensure we're tuning swappiness correctly (and by the way,
> we also apply another patch which allows swappiness values up to 200
> instead of the obsolete 100 limit).  We run experiments, but we're
> also collecting stats from the field (for the users that permit it),
> so we have applied this patch to all our kernels.
> 
> This is as full an explanation as I can give concisely, would this be enough?

That's one I had interested and for me, it was enough just PGMAJFAULT
- PSWPIN. With that, we can know file-backed page's major fault vs.
zram-swap backed page fault ratio. That was all I wanted to know and
no need to know how many portion was shmem : anonymous from zram-swap.

So, I think we need following justification to merge this stat.

1. Why PGMAJFAULT - PSWPIN is not enough for your interest?
2. Why do you need to identify shmem's fault in anon major fault?

> 
> So there is benefit for us in getting this level of detail from
> vmstat.  Of course it's not clear that the benefit extends to the
> greater community.  If it is deemed to not be sufficiently important
> to add those vmstat fields (3 more fields added to about 100, although
> we could just add 2 since pgmajfault = sum(pjmajfault_{a,f,s}) then we
> can maintain them separately for Chrome OS, and that will be fine.
> 
> Thanks!
> 
> 
> 
> >
> > Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
