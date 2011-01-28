Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB3C48D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 19:26:57 -0500 (EST)
Date: Thu, 27 Jan 2011 16:26:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: Make vm_acct_memory scalable for large memory
 allocations
Message-Id: <20110127162626.8b38145b.akpm@linux-foundation.org>
In-Reply-To: <4D420A89.3050906@linux.intel.com>
References: <1296082319.2712.100.camel@schen9-DESK>
	<20110127153642.f022b51c.akpm@linux-foundation.org>
	<4D420A89.3050906@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jan 2011 16:15:05 -0800
Andi Kleen <ak@linux.intel.com> wrote:

> 
> > This seems like a pretty dumb test case.  We have 64 cores sitting in a
> > loop "allocating" 32MB of memory, not actually using that memory and
> > then freeing it up again.
> >
> > Any not-completely-insane application would actually _use_ the memory.
> > Which involves pagefaults, page allocations and much memory traffic
> > modifying the page contents.
> >
> > Do we actually care?
> 
> It's a bit like a poorly tuned malloc. From what I heard poorly tuned 
> mallocs are quite
> common in the field, also with lots of custom ones around.
> 
> While it would be good to tune them better the kernel should also have 
> reasonable performance
> for this case.
> 
> The poorly tuned malloc has other problems too, but this addresses at 
> least one
> of them.
> 
> Also I think Tim's patch is a general improvement to a somewhat dumb 
> code path.
> 

I guess another approach to this would be change the way in which we
decide to update the central counter.

At present we'll spill the per-cpu counter into the central counter
when the per-cpu counter exceeds some fixed threshold.  But that's
dumb, because the error factor is relatively large for small values of
the counter, and relatively small for large values of the counter.

So instead, we should spill the per-cpu counter into the central
counter when the per-cpu counter exceeds some proportion of the central
counter (eg, 1%?).  That way the inaccuracy is largely independent of
the counter value and the lock-taking frequency decreases for large
counter values.

And given that "large cpu count" and "lots of memory" correlate pretty
well, I suspect such a change would fix up the contention which is
being seen here without magical startup-time tuning heuristics.

This again will require moving the batch threshold into the counter
itself and also recalculating it when the central counter is updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
