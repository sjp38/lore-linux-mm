Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 7B1CA6B0071
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 01:12:59 -0500 (EST)
Date: Wed, 28 Nov 2012 15:12:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: another allocation livelock with zram
Message-ID: <20121128061257.GA24735@blaptop>
References: <CAA25o9T8cBhuFnesnxHDsv3PmV8tiHKoLz0dGQeUSCvtpBBv3A@mail.gmail.com>
 <20121121012726.GA5121@bbox>
 <CAA25o9Q=qnmrZ5iyVcmKxDr+nO7J-o-z1X6QtiEdLdxZHCViBw@mail.gmail.com>
 <20121121135957.GB2084@barrios>
 <CAA25o9SeEM0RH1Ztt9aqjpAd50tzbf=0FUXuCOapZjBQuNRZEw@mail.gmail.com>
 <20121123054446.GB13626@bbox>
 <CAA25o9Rbt17E9vNP=J0rkfGnu=YQPhZpeUA+nnaHNRWht0M05w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9Rbt17E9vNP=J0rkfGnu=YQPhZpeUA+nnaHNRWht0M05w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Bryan Freed <bfreed@google.com>

On Mon, Nov 26, 2012 at 05:00:26PM -0800, Luigi Semenzato wrote:
> Still no measurable progress on this one, but some new information.
> To recapitulate:
> 
> --- vanilla 3.4 kernel + hacky min_filelist_kbytes patch + Minchan's
> patch below:
> 
> >> > --- a/mm/vmscan.c
> >> > +++ b/mm/vmscan.c
> >> > @@ -2101,7 +2101,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
> >> >                         continue;
> >> >                 if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> >> >                         continue;
> >> > -               if (!zone->all_unreclaimable)
> >> > +               if (zone->pages_scanned < zone_reclaimable_pages(zone) * 6)
> >> >                         return false;
> >> >         }
> 
> --- no longer running the Chrome browser; instead, running this
> synthetic load: several instances of a process that allocates 200MB,
> then touches some subset of its pages in an endless loop.  The
> process's data segment compresses well (10:1).
> 
> --- running the load on two similar systems: one ARM-based, the other
> x86-based.  Both systems run the same kernel and the same image
> (different but equivalent configurations).  Both have 2 GB RAM.
> 
> On the x86 system, the mm behaves as expected.  All 3 Gb of the zram
> device are consumed before OOM-kills happen.
> 
> On the ARM system, OOM kills start happening when there are still
> about 2.1 GB of swap available.  Because the compression ratio is so
> good, the zram disk is only using 100 to 150 MB.
> 
> The systems are pretty similar.  The x86 device has a rotating disk,
> vs. SSD on the ARM device.  This could affect the speed of paging in
> code, but the program is very small so I don't think that's a factor.
> 
> There are no messages from zram in the log.
> 
> It could be either an ARM bug, or maybe the bug is on both systems,
> and the performance behavior on ARM is different enough to expose it.

The scenario I can imagine is by kswapd.
Did you tried to move wakeup_all_kswapd to rebalance below?

The reason why I guess so is direct reclaim which caused by zram page
allocation is normally GFP_NOIO. It has big limits to reclaim pages,
for instance, it can't page out dirty pages and swap out of anon pages
for avoding deadlock so scanning rate of LRU would be high easily for 
finding easy-reclaimable pages(ie, clean page, likely code). Even, you
used min_filelist_kbytes, which prevent to reclaim clean pages which
are only reclaimable pages in case of GFP_NOIO.

High scanning speed without freeing the page would be short cut to OOM load.

> 
> I will continue trying to figure out why kswapd isn't more proactive on ARM.

Just for the hint. I'm not sure it's really problem.
Historically, kswapd had problems about balancing of zones,
(ex, size of zones for balancing) and it was not too long that ARM started
to use multiple zones with big RAM.

> 
> Thanks!
> Luigi
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
