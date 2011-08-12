Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BE7796B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:41:40 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7CHC1d0004949
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:12:01 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7CHfcsS213996
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:41:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7CHfbgK020283
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:41:38 -0400
Date: Fri, 12 Aug 2011 10:41:36 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812174136.GM2395@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812165749.GA29086@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812165749.GA29086@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 06:57:49PM +0200, Johannes Weiner wrote:
> On Fri, Aug 12, 2011 at 09:08:13AM -0700, Paul E. McKenney wrote:
> > On Fri, Aug 12, 2011 at 05:36:16PM +0200, Andrea Arcangeli wrote:
> > > On Tue, Aug 09, 2011 at 04:04:21AM -0700, Michel Lespinasse wrote:
> > > > - Use my proposed page count lock in order to avoid the race. One
> > > > would have to convert all get_page_unless_zero() sites to use it. I
> > > > expect the cost would be low but still measurable.
> > > 
> > > I didn't yet focus at your problem after we talked about it at MM
> > > summit, but I seem to recall I suggested there to just get to the head
> > > page and always take the lock on it. split_huge_page only works at 2M
> > > aligned pages, the rest you don't care about. Getting to the head page
> > > compound_lock should be always safe. And that will still scale
> > > incredibly better than taking the lru_lock for the whole zone (which
> > > would also work). And it seems the best way to stop split_huge_page
> > > without having to alter the put_page fast path when it works on head
> > > pages (the only thing that gets into put_page complex slow path is the
> > > release of tail pages after get_user_pages* so it'd be nice if
> > > put_page fast path still didn't need to take locks).
> > > 
> > > > - It'd be sweet if one could somehow record the time a THP page was
> > > > created, and wait for at least one RCU grace period *starting from the
> > > > recorded THP creation time* before splitting huge pages. In practice,
> > > > we would be very unlikely to have to wait since the grace period would
> > > > be already expired. However, I don't think RCU currently provides such
> > > > a mechanism - Paul, is this something that would seem easy to
> > > > implement or not ?
> > 
> > It should not be hard.  I already have an API for rcutorture testing
> > use, but it is not appropriate for your use because it is unsynchronized.
> > 
> > We need to be careful with what I give you and how you interpret it.
> > The most effective approach would be for me to give you an API that
> > filled in a cookie given a pointer to one, then another API that took
> > pointers to a pair of cookies and returned saying whether or not a
> > grace period had elapsed.  You would do something like the following:
> > 
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
> > 
> > That covers TREE_RCU and TREE_PREEMPT_RCU, on to TINY_RCU and TINY_PREEMPT_RCU.
> > 
> > TINY_RCU will require more thought, as it doesn't bother counting grace
> > periods.  Ah, but in TINY_RCU, synchronize_rcu() is free, so I simply
> > make rcu_cookie_gp_elapsed() always return false.
> > 
> > OK, TINY_PREEMPT_RCU...  It doesn't count grace periods, either.  But it
> > is able to reliably detect if there are any RCU readers in flight,
> > and there normally won't be, so synchronize_rcu() is again free in the
> > common case.  And no, I don't want to count grace periods as this would
> > increase the memory footprint.  And the whole point of TINY_PREEMPT_RCU
> > is to be tiny, after all.  ;-)
> 
> I understand you want to be careful with the promises you make in the
> API.  How about not even exposing the check for whether a grace period
> elapsed, but instead provide a specialized synchronize_rcu()?
> 
> Something like
> 
> 	void synchronize_rcu_with(rcu_time_t time)
> 
> that only promises all readers from the specified time are finished.
> 
> [ And synchronize_rcu() would be equivalent to
>   synchronize_rcu_with(rcu_current_time()) if I am not mistaken. ]
> 
> Then you wouldn't need to worry about how the return value of
> rcu_cookie_gp_elapsed() might be interpreted, could freely implement
> it equal to synchronize_rcu() on TINY_RCU, the false positives with
> small cookies would not be about correctness but merely performance.
> 
> And it should still be all that which the THP case requires.
> 
> Would that work?

I currently don't record the times at which past grace periods start
and finish, but you can think of the cookie I was proposing as being a
specialized timestamp that measures the passage of time in terms of the
number of grace periods that have started and finished.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
