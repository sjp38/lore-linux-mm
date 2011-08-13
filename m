Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F0E2B6B016C
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 00:19:10 -0400 (EDT)
Received: by ywm13 with SMTP id 13so2065934ywm.14
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:19:08 -0700 (PDT)
Date: Sat, 13 Aug 2011 13:18:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110813041859.GC1905@barrios-desktop>
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
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

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
> 
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
> 
> I'm currently unsure how the cookie can be allowed to be smaller than
> the real counter though. I don't see how is it possible.
> 
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
> 
> > OK, TINY_PREEMPT_RCU...  It doesn't count grace periods, either.  But it
> > is able to reliably detect if there are any RCU readers in flight,
> > and there normally won't be, so synchronize_rcu() is again free in the
> > common case.  And no, I don't want to count grace periods as this would
> > increase the memory footprint.  And the whole point of TINY_PREEMPT_RCU
> > is to be tiny, after all.  ;-)
> 
> Ok so it returns always false, and synchronize_rcu is always called,
> but it will normally do nothing there.
> 
> > If you need SRCU, you are out of luck until I get my act together and
> > merge it in with the other RCU implementations, which might be awhile
> > still.
> 
> Good luck because we don't need SRCU, we just need a synchronize_rcu
> vs rcu_read_lock.
> 
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

For the clarification, every page allocation? Really?
I guess you mean every page allocation for THP.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
