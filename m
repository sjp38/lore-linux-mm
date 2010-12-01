Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3C4756B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 01:36:55 -0500 (EST)
Date: Tue, 30 Nov 2010 22:36:48 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Sudden and massive page cache eviction
Message-ID: <20101201063648.GA31793@hostway.ca>
References: <20101122161158.02699d10.akpm@linux-foundation.org> <1290501502.2390.7029.camel@nimitz> <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com> <1290529171.2390.7994.camel@nimitz> <AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com> <AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com> <AANLkTimo1BR=mSJ6wPQwrL4FDNv=_TfanPPTT7uWx7hQ@mail.gmail.com> <AANLkTi=yV02oY5AmNAYr+ZF0RUgVv8gkeP+D9_CcOfLi@mail.gmail.com> <20101125011848.GB29511@hostway.ca> <AANLkTi=V55NMaTejNnnmY8KCfWDmMvJ-rh-wJ_8ixNnf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=V55NMaTejNnnmY8KCfWDmMvJ-rh-wJ_8ixNnf@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Peter Sch??ller <scode@spotify.com>
Cc: Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!  Sorry, I didn't see your email until now.

On Thu, Nov 25, 2010 at 04:59:25PM +0100, Peter Sch??ller wrote:

> > Your page cache dents don't seem quite as big, so it may be something
> > else, but if it's the same problem we're seeing here, it seems to have to
> > do with when an order=3 new_slab allocation comes in to grows the kmalloc
> > slab cache for an __alloc_skb (network packet). ??This is normal even
> > without jumbo frames now. ??When there are no zones with order=3
> > zone_watermark_ok(), kswapd is woken, which frees things all over the
> > place to try to get zone_watermark_ok(order=3) to be happy.
> > We're seeing this throw out a huge number of pages, and we're seeing it
> > happen even with lots of memory free in the zone.
> 
> Is there some way to observe this directly (the amount evicted for low
> watermark reasons)?
> 
> If not, is logging/summing the return value of balance_pgdat() in
> kswapd() (mm/vmscan.c) be the way to accomplish this?

The way I could "see" it was with http://0x.ca/sim/ref/2.6.36/vmstat_dump
, which updates fast enough (if your terminal doesn't suck) to actually
see the 10 Hz wakeups and similar patterns.  pageoutrun goes up each time
balance_pgdat() passes the "loop_again" label.

Watching http://0x.ca/sim/ref/2.6.36/buddyinfo_dump at the same time
shows that while pageoutrun is increasing, Normal pages are being
allocated and freed all very quickly but not reaching the watermark,
and the other kswapd-related counters seem to show this.

> My understanding (and I am saying it just so that people can tell my
> if I'm wrong) is that what you're saying implies that kswapd keeps
> getting woken up in wakeup_kswapd() due to zone_watermark_ok(), but
> kswapd()'s invocation of balance_pgdat() is unable to bring levels
> above the low water mark but but evicted large amounts of data while
> trying?

Yes, though there are a couple of issues here.  See the "Free memory
never fully used, swapping" thread and Mel Gorman's comments/patches. 

His patches fix kswapd fighting the allocator for me, but I'm still
running into problems with what seems to be fragmentation making it
difficult for kswapd to meet the higher order watermarks after a few
days.  Even with everything in slub set order 0 except order 1 where
absolutely required is still seeming to result in lots of free memory
after a week or so of normal load.

> (For the ML record/others: I believe that was meant to be
> zone_watermark_ok(), not zone_pages_ok(). It's in mm/page_alloc.c)

Yes :)

> > Code here: http://0x.ca/sim/ref/2.6.36/buddyinfo_scroll
> 
> [snip output]
> 
> > So, kswapd was woken up at the line that ends in "!!!" there, because
> > free_pages(249) <= min(256), and so zone_watermark_ok() returned 0, when
> > an order=3 allocation came in.
> >
> > Maybe try out that script and see if you see something similar.
> 
> Thanks! That looks great. I'll try to set up data collection where
> this can be observed and then correlated with a graph and the
> vmstat/slabinfo that I just posted, the next time we see an eviction.
> 
> (For the record it triggers constantly on my desktop, but that is with
> 2.6.32 and I'm assuming it is due to differences in that kernel, so
> I'm not bothering investigating. It's not triggering constantly on the
> 2.6.26-rc6 kernel on the production system, and hopefully we can see
> it trigger during the evictions.)

Well, nothing seems to care about higher order watermarks unless
something atually tries to allocate from them, so if you don't have
any order-3 allocations, it's unlikely that it will be met after
you've filled free memory.  This isn't immediately obvious, because
zone_watermark_ok() works by subtracting free pages in _lower_ orders
from the total free pages in a zone.  So, it's the free blocks in the
specified order and _bigger_ that matter in buddyinfo.  Also,
min_free_kbytes and lowmem_reserve_ratio prevent all of the buddies
from being split even if _only_ order 0 allocations have ever occurred.

Anyway, how did it go?  Did you find anything interesting? :)

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
