Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 428A48D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 05:31:03 -0400 (EDT)
Date: Thu, 31 Mar 2011 10:30:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110331093053.GB3876@csn.ul.ie>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
 <20110330161716.GA3876@csn.ul.ie>
 <20110330164906.GE12265@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110330164906.GE12265@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

On Wed, Mar 30, 2011 at 06:49:06PM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> On Wed, Mar 30, 2011 at 05:17:16PM +0100, Mel Gorman wrote:
> > Andy Whitcroft also posted patches ages ago that were related to lumpy reclaim
> > which would capture high-order pages being reclaimed for the exclusive use
> > of the reclaimer. It was never shown to be necessary though. I'll read this
> > thread in a bit because I'm curious to see why it came up now.
> 
> Ok ;).
> 
> About lumpy I wouldn't spend too much on lumpy,

I hadn't intended to but the context of the capture patches was lumpy so
it'd be the starting point for anyone looking at the old patches.  If someone
wanted to go in that direction, it would need to be adapted for compaction,
reclaim/compaction and reclaim.

> I'd rather spend on
> other issues like the one you mentioned on lru ordering, and
> compaction (compaction in kswapd has still an unknown solution, my
> last attempt failed and we backed off to no compaction in kswapd which
> is safe but doesn't help for GFP_ATOMIC order > 0).
> 

Agreed. It may also be worth a quick discussion on *how* people are currently
evauating their reclaim-related changes be it via tracepoints, systemtap,
a patched kernel or indirect measures such as faults.

> Lumpy should go away in a few releases IIRC.
> 
> > I think we should be very wary of conflating OOM latency, reclaim latency and
> > allocation latency as they are very different things with different causes.
> 
> I think it's better to stick to successful allocation latencies only
> here, or at most -ENOMEM from order > 0 which normally never happens
> with compaction (not the time it takes before declaring OOM and
> triggering the oom killer).
> 

Sounds reasonable. I could discuss briefly the scripts I use based on ftrace
that dump out highorder allocation latencies as it might be useful to others
if this is the area they are looking at.

> > I'd prefer to see OOM-related issues treated as a separate-but-related
> > problem if possible so;
> > 
> > 1. LRU ordering - are we aging pages properly or recycling through the
> >    list too aggressively? The high_wmark*8 change made recently was
> >    partially about list rotations and the associated cost so it might
> >    be worth listing out whatever issues people are currently aware of.
> > 2. LRU ordering - dirty pages at the end of the LRU. Are we still going
> >    the right direction on this or is it still a shambles?
> > 3. Compaction latency, other issues (IRQ disabling latency was the last
> >    one I'm aware of)
> > 4. OOM killing and OOM latency - Whole load of churn going on in there.
> 
> I prefer it too. The OOM killing is already covered in OOM topic from
> Hugh, and we can add "OOM detection latency" to it.
> 

Also sounds good to me.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
