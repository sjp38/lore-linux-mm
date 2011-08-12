Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7069A6B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:13:43 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7CHeEtc030967
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:40:14 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7CID9Cg145336
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:13:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7CID8vo026197
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:13:09 -0400
Date: Fri, 12 Aug 2011 11:13:06 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812181306.GO2395@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812165749.GA29086@redhat.com>
 <20110812170823.GM7959@redhat.com>
 <20110812175206.GB29086@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812175206.GB29086@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 07:52:06PM +0200, Johannes Weiner wrote:
> On Fri, Aug 12, 2011 at 07:08:23PM +0200, Andrea Arcangeli wrote:
> > On Fri, Aug 12, 2011 at 06:57:49PM +0200, Johannes Weiner wrote:
> > > I understand you want to be careful with the promises you make in the
> > > API.  How about not even exposing the check for whether a grace period
> > > elapsed, but instead provide a specialized synchronize_rcu()?
> > > 
> > > Something like
> > > 
> > > 	void synchronize_rcu_with(rcu_time_t time)
> > > 
> > > that only promises all readers from the specified time are finished.
> > > 
> > > [ And synchronize_rcu() would be equivalent to
> > >   synchronize_rcu_with(rcu_current_time()) if I am not mistaken. ]
> > > 
> > > Then you wouldn't need to worry about how the return value of
> > > rcu_cookie_gp_elapsed() might be interpreted, could freely implement
> > > it equal to synchronize_rcu() on TINY_RCU, the false positives with
> > > small cookies would not be about correctness but merely performance.
> > > 
> > > And it should still be all that which the THP case requires.
> > > 
> > > Would that work?
> > 
> > rcu_time_t would still be an unsigned long long like I suggested?
> 
> Do we even need to make this fixed?  It can be unsigned long long for
> now, but I could imagine leaving it up to the user depending how much
> space she is able/willing to invest to save time:
> 
> 	void synchronize_rcu_with(unsigned long time, unsigned int bits)
> 	{
> 		if (generation_counter & ((1 << bits) - 1) == time)
> 			synchronize_rcu();
> 	}

This is indeed more convenient for this particular use case, but suppose
that the caller instead wanted to use call_rcu()?  The API I am currently
proposing allows either synchronize_rcu() or call_rcu() to be used.  In
addition, it allows alternative algorithms, for example:

	rcu_get_gp_cookie(&wherever);

	...

	if (rcu_cookie_gp_elapsed(&wherever))
		p = old_pointer;  /* now safe to re-use. */
	else
		p = kmalloc( ... );  /* can't re-use, so get new memory. */

> If you have only 3 bits to store the time, you will synchronize
> falsely to every 8th phase.  Better than nothing, right?

;-)

> > About the false positives thing, I failed to see how it's ever
> > possible to return only false positives and never false negatives when
> > cookie and internal counter are not of the same size (and cookie has
> > no enough bits to ever tell if it overflowed or not).
> 
> I don't see how.  Even with one bit for the time stamp you get every
> second generation right :-)

I probably need at least two or three bits to account for grace-period
slew, at least if we want to avoid grabbing a global lock each time
one of these APIs is invoked.

> > I think rcu_generation_t is more appropriate because it's not time but
> > a generation/sequence counter.
> 
> I intentionally chose a vague name as the unit should be irrelevant to
> the outside world.  But I don't feel strongly about this.

Yep, different RCU implementations will need different data in the
rcu_generation_t.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
