Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC396B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:03:12 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7CHXXY9027489
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:33:33 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7CI39un3113190
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:03:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7CI39si012480
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:03:09 -0400
Date: Fri, 12 Aug 2011 11:03:08 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812180308.GN2395@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812165749.GA29086@redhat.com>
 <20110812170823.GM7959@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812170823.GM7959@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <jweiner@redhat.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 07:08:23PM +0200, Andrea Arcangeli wrote:
> On Fri, Aug 12, 2011 at 06:57:49PM +0200, Johannes Weiner wrote:
> > I understand you want to be careful with the promises you make in the
> > API.  How about not even exposing the check for whether a grace period
> > elapsed, but instead provide a specialized synchronize_rcu()?
> > 
> > Something like
> > 
> > 	void synchronize_rcu_with(rcu_time_t time)
> > 
> > that only promises all readers from the specified time are finished.
> > 
> > [ And synchronize_rcu() would be equivalent to
> >   synchronize_rcu_with(rcu_current_time()) if I am not mistaken. ]
> > 
> > Then you wouldn't need to worry about how the return value of
> > rcu_cookie_gp_elapsed() might be interpreted, could freely implement
> > it equal to synchronize_rcu() on TINY_RCU, the false positives with
> > small cookies would not be about correctness but merely performance.
> > 
> > And it should still be all that which the THP case requires.
> > 
> > Would that work?
> 
> rcu_time_t would still be an unsigned long long like I suggested?

NACK.  I really really really don't want to have to deal with time
synchronization issues.  ;-)

"Yes, your memory was corrupted due to the CPU's clocks going slightly
out of synchronization."  Thank you, but no thank you!

> About the false positives thing, I failed to see how it's ever
> possible to return only false positives and never false negatives when
> cookie and internal counter are not of the same size (and cookie has
> no enough bits to ever tell if it overflowed or not).

Easy.  I say "yes" if I can prove based on the counter values that an RCU
grace period elapsed, and "no" if there is any uncertainty.  Any overflow
means lots of RCU grace periods, and so if the counters haven't changed
enough, I just say "no".  I might be saying "no" wrongly on overflow,
but that is the safe mistake to make.

> I think rcu_generation_t is more appropriate because it's not time but
> a generation/sequence counter.

Sounds like a better name than the rcu_cookie_t I was thinking of,
so happy to steal your naming idea.  ;-)

> The ideally the comparison check would be just an inline function
> reading 2 longs in reverse order in 32bit and comparing it with the
> stable value we have in page[1]->something_low and
> page[1]->something_high , so skipping an external call sounds better
> to me, but the above should also work.

The current #include structure forces an external call for
TREE_RCU and TREE_PREEMPT_RCU, but TINY_RCU and TINY_PREEMPT_RCU
can have an inlined call.

Here are my current thoughts on API:

	void rcu_get_gp_cookie(rcu_generation_t *rgp);

		Fills in the pointed-to RCU generation information.
		The information is opaque, and is currently a pair
		of unsigned longs (but could change in the future,
		for example, it might turn out that only one is
		required, etc.).

	bool rcu_cookie_gp_elapsed(rcu_generation_t *rgp);

		Given a pointer to RCU generation information previously
		filled in, returns true if it can prove that at least
		one RCU grace period has elapsed since then.

Seem reasonable?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
