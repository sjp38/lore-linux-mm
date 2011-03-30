Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DD4D48D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 12:49:32 -0400 (EDT)
Date: Wed, 30 Mar 2011 18:49:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110330164906.GE12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
 <20110330161716.GA3876@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110330161716.GA3876@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

Hi Mel,

On Wed, Mar 30, 2011 at 05:17:16PM +0100, Mel Gorman wrote:
> Andy Whitcroft also posted patches ages ago that were related to lumpy reclaim
> which would capture high-order pages being reclaimed for the exclusive use
> of the reclaimer. It was never shown to be necessary though. I'll read this
> thread in a bit because I'm curious to see why it came up now.

Ok ;).

About lumpy I wouldn't spend too much on lumpy, I'd rather spend on
other issues like the one you mentioned on lru ordering, and
compaction (compaction in kswapd has still an unknown solution, my
last attempt failed and we backed off to no compaction in kswapd which
is safe but doesn't help for GFP_ATOMIC order > 0).

Lumpy should go away in a few releases IIRC.

> I think we should be very wary of conflating OOM latency, reclaim latency and
> allocation latency as they are very different things with different causes.

I think it's better to stick to successful allocation latencies only
here, or at most -ENOMEM from order > 0 which normally never happens
with compaction (not the time it takes before declaring OOM and
triggering the oom killer).

> I'd prefer to see OOM-related issues treated as a separate-but-related
> problem if possible so;
> 
> 1. LRU ordering - are we aging pages properly or recycling through the
>    list too aggressively? The high_wmark*8 change made recently was
>    partially about list rotations and the associated cost so it might
>    be worth listing out whatever issues people are currently aware of.
> 2. LRU ordering - dirty pages at the end of the LRU. Are we still going
>    the right direction on this or is it still a shambles?
> 3. Compaction latency, other issues (IRQ disabling latency was the last
>    one I'm aware of)
> 4. OOM killing and OOM latency - Whole load of churn going on in there.

I prefer it too. The OOM killing is already covered in OOM topic from
Hugh, and we can add "OOM detection latency" to it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
