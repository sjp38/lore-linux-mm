Date: Wed, 8 Mar 2006 09:48:24 +0100
From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: Re: [ck] Re: [PATCH] mm: yield during swap prefetching
Message-ID: <20060308084824.GA4193@rhlx01.fht-esslingen.de>
References: <200603081013.44678.kernel@kolivas.org> <20060307152636.1324a5b5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060307152636.1324a5b5.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Con Kolivas <kernel@kolivas.org>, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 07, 2006 at 03:26:36PM -0800, Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> >
> > Swap prefetching doesn't use very much cpu but spends a lot of time waiting on 
> > disk in uninterruptible sleep. This means it won't get preempted often even at 
> > a low nice level since it is seen as sleeping most of the time. We want to 
> > minimise its cpu impact so yield where possible.

> yield() really sucks if there are a lot of runnable tasks.  And the amount
> of CPU which that thread uses isn't likely to matter anyway.
> 
> I think it'd be better to just not do this.  Perhaps alter the thread's
> static priority instead?  Does the scheduler have a knob which can be used
> to disable a tasks's dynamic priority boost heuristic?

This problem occurs due to giving a priority boost to processes that are
sleeping a lot (e.g. in this case, I/O, from disk), right?
Forgive me my possibly less insightful comments, but maybe instead of adding
crude specific hacks (namely, yield()) to each specific problematic process as
it comes along (it just happens to be the swap prefetch thread this time)
there is a *general way* to give processes with lots of disk I/O sleeping
much smaller amounts of boost in order to get them preempted more often
in favour of an actually much more critical process (game)?
>From the discussion here it seems this problem is caused by a *general*
miscalculation of processes sleeping on disk I/O a lot.

Thus IMHO this problem should be solved in a general way if at all possible.

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
