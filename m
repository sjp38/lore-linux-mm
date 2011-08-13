Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B54DF6B016D
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:57:44 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p7D1XZcR031065
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:33:35 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7D1vhni2797778
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:57:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7D1vg8Y021671
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:57:43 -0400
Date: Fri, 12 Aug 2011 18:57:41 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110813015741.GZ2395@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812164325.GK7959@redhat.com>
 <20110812172758.GL2395@linux.vnet.ibm.com>
 <CANN689GmsnRXwuy2GGWQopic_68LbEiDGNzbJCTDAN=FvDKXJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CANN689GmsnRXwuy2GGWQopic_68LbEiDGNzbJCTDAN=FvDKXJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 04:45:59PM -0700, Michel Lespinasse wrote:
> On Fri, Aug 12, 2011 at 10:27 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > Or maybe I make rcu_cookie_gp_elapsed() take only one cookie and
> > compare it to the current cookie.  This would save a bit of code in
> > the TINY cases:
> >
> >        rcu_get_gp_cookie(&pagep->rcucookie);
> >        . . .
> >
> >        if (!rcu_cookie_gp_elapsed(&pagep->rcucookie))
> >                synchronize_rcu();
> 
> Agree this looks nicer that having the second cookie on the stack. As
> you said, this does not allow us to compare two past points in time,
> but I really don't see a use case for that.

And actually hand-writing the code got me the following API:

struct rcu_cookie;
void rcu_get_gp_cookie(struct rcu_cookie *rcp);
void rcu_gp_cookie_elapsed(struct rcu_cookie *rcp);

For TREE{_PREEMPT,}_RCU these are both external calls (#include hell
and all that).  For TINY{_PREEMPT,}_RCU they are both trivial inlineable
functions.

> > How long would there normally be between recording the cookie and
> > checking for the need for a grace period?  One disk access?  One HZ?
> > Something else?
> 
> I would expect >>10 seconds in the normal case ? I'm not sure how much
> lower this may get in adverse workloads. Andrea ?

>>10 seconds would be way more than enough to allow this to work well.
But if we are getting much below 100 milliseconds, we need to rethink
this.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
