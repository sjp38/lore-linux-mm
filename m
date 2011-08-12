Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6C6156B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:52:14 -0400 (EDT)
Date: Fri, 12 Aug 2011 19:52:06 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812175206.GB29086@redhat.com>
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
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

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

Do we even need to make this fixed?  It can be unsigned long long for
now, but I could imagine leaving it up to the user depending how much
space she is able/willing to invest to save time:

	void synchronize_rcu_with(unsigned long time, unsigned int bits)
	{
		if (generation_counter & ((1 << bits) - 1) == time)
			synchronize_rcu();
	}

If you have only 3 bits to store the time, you will synchronize
falsely to every 8th phase.  Better than nothing, right?

> About the false positives thing, I failed to see how it's ever
> possible to return only false positives and never false negatives when
> cookie and internal counter are not of the same size (and cookie has
> no enough bits to ever tell if it overflowed or not).

I don't see how.  Even with one bit for the time stamp you get every
second generation right :-)

> I think rcu_generation_t is more appropriate because it's not time but
> a generation/sequence counter.

I intentionally chose a vague name as the unit should be irrelevant to
the outside world.  But I don't feel strongly about this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
