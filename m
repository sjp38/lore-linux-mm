Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BA0796B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:28:02 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7CH3s8I001953
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:03:54 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7CHRxMp249100
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:27:59 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7CHRwgm019625
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:27:59 -0400
Date: Fri, 12 Aug 2011 10:27:58 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812172758.GL2395@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812164325.GK7959@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812164325.GK7959@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 06:43:25PM +0200, Andrea Arcangeli wrote:
> On Fri, Aug 12, 2011 at 09:08:13AM -0700, Paul E. McKenney wrote:
> > It should not be hard.  I already have an API for rcutorture testing
> > use, but it is not appropriate for your use because it is unsynchronized.
> 
> Sounds good.
> 
> > We need to be careful with what I give you and how you interpret it.
> > The most effective approach would be for me to give you an API that
> > filled in a cookie given a pointer to one, then another API that took
> > pointers to a pair of cookies and returned saying whether or not a
> > grace period had elapsed.  You would do something like the following:
> 
> Even a raw number of events is ok, but it will work like a cookie.

Cookie would be best.  ;-)

> > 	rcu_get_gp_cookie(&pagep->rcucookie);
> > 	. . .
> > 
> > 	rcu_get_gp_cookie(&autovarcookie);
> > 	if (!rcu_cookie_gp_elapsed(&pagep->rcucookie, &autovarcookie))
> > 		synchronize_rcu();
> > 
> > So, how much space do I get for ->rcucookie?  By default, it is a pair
> > of unsigned longs, but I could live with as small as a single byte if
> > you didn't mind a high probability of false negatives (me telling you
> > to do a grace period despite 16 of them having happened in the meantime
> > due to overflow of a 4-bit field in the byte).
> 
> It could be 2 longs just fine (so it's 64bit on 32bit too and guarantees
> no false positive as it'll never overflow for the lifetime of the
> hardware), we've tons of free space to use in page[1-511].* .

Very good!!!  

> I'm currently unsure how the cookie can be allowed to be smaller than
> the real counter though. I don't see how is it possible.

Just put the low-order bits of the counter in the byte.  This could
cause rcu_cookie_gp_elapsed() to get confused, but the only possible
confusion would be for it to make you do synchronize_rcu() when it
wasn't necessary to do so.  This is a performance problem rather than
a correctness problem, though.

But the more bits you give me, the lower the probability of needless
calls to synchronize_rcu().

> > That covers TREE_RCU and TREE_PREEMPT_RCU, on to TINY_RCU and TINY_PREEMPT_RCU.
> > 
> > TINY_RCU will require more thought, as it doesn't bother counting grace
> > periods.  Ah, but in TINY_RCU, synchronize_rcu() is free, so I simply
> > make rcu_cookie_gp_elapsed() always return false.
> 
> Yes it'll surely be safe for us, on UP we have no race and in fact
> get_page_unless_zero isn't even called in the speculative lookup in UP. With
> the code above you could return always true with TINY_RCU and skip the
> call.

Or maybe I make rcu_cookie_gp_elapsed() take only one cookie and
compare it to the current cookie.  This would save a bit of code in
the TINY cases:

	rcu_get_gp_cookie(&pagep->rcucookie);
	. . .

	if (!rcu_cookie_gp_elapsed(&pagep->rcucookie))
		synchronize_rcu();

The compiler should then be able to recognize synchronize_rcu() as dead
code in the TINY case.

The main downside of this approach is that you couldn't check for two
past points having a grace period between them, but I don't see a use
case for this right offhand.

> > OK, TINY_PREEMPT_RCU...  It doesn't count grace periods, either.  But it
> > is able to reliably detect if there are any RCU readers in flight,
> > and there normally won't be, so synchronize_rcu() is again free in the
> > common case.  And no, I don't want to count grace periods as this would
> > increase the memory footprint.  And the whole point of TINY_PREEMPT_RCU
> > is to be tiny, after all.  ;-)
> 
> Ok so it returns always false, and synchronize_rcu is always called,
> but it will normally do nothing there.

Sounds good.

> > If you need SRCU, you are out of luck until I get my act together and
> > merge it in with the other RCU implementations, which might be awhile
> > still.
> 
> Good luck because we don't need SRCU, we just need a synchronize_rcu
> vs rcu_read_lock.

Whew!  ;-)

> > For TREE_*RCU, the calls to rcu_get_gp_cookie() will cost you a lock
> > round trip.  I am hoping to be able to use the counters stored in the
> > rcu_data structure, which means that I would need to disable preemption
> > and re-enable it.  Or maybe disable and re-enable irqs instead, not yet
> > sure which.  This might require me to be conservative and make
> > rcu_cookie_gp_elapsed() unless two grace periods have elapsed.  Things
> > get a bit tricky -- yes, I could just use the global counters, but that
> > would mean that rcu_get_gp_cookie() would need to acquire a global lock,
> > and I suspect that you intend to invoke it too often for that to be
> > a winning strategy.
> 
> It is invoked at every page allocation, there are some locks taken
> there already but they're per-mm (mm->page_table_lock). I'd be nice if
> we could run it without taking locks.

OK, so I should try hard to make rcu_get_gp_cookie() access the per-CPU
rcu_data structure, then.

How long would there normally be between recording the cookie and
checking for the need for a grace period?  One disk access?  One HZ?
Something else?

> If we make it a raw unsigned long long we read it in order (first lower
> bits, then higher bits on 32bit) and store it in the opposite
> direction (first increment the higher part, then increment the lower
> part or reset it to 0), can't we avoid all the locks and worst case we
> get a false positive when we compare?

If I can make use of the values in the per-CPU rcu_data structure, no
locks are required.  Might need to disable preemption and/or interrupts,
but nothing beyond that.

> > Thoughts?  And how many bits do I get for the cookie?
> 
> As many as you want.

Woo-hoo!!!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
