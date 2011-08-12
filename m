Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CF36B6B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:06:05 -0400 (EDT)
Date: Fri, 12 Aug 2011 21:05:57 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812190557.GD29086@redhat.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
 <20110812160813.GF2395@linux.vnet.ibm.com>
 <20110812165749.GA29086@redhat.com>
 <20110812170823.GM7959@redhat.com>
 <20110812175206.GB29086@redhat.com>
 <20110812181306.GO2395@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812181306.GO2395@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 11:13:06AM -0700, Paul E. McKenney wrote:
> On Fri, Aug 12, 2011 at 07:52:06PM +0200, Johannes Weiner wrote:
> > On Fri, Aug 12, 2011 at 07:08:23PM +0200, Andrea Arcangeli wrote:
> > > On Fri, Aug 12, 2011 at 06:57:49PM +0200, Johannes Weiner wrote:
> > > > I understand you want to be careful with the promises you make in the
> > > > API.  How about not even exposing the check for whether a grace period
> > > > elapsed, but instead provide a specialized synchronize_rcu()?
> > > > 
> > > > Something like
> > > > 
> > > > 	void synchronize_rcu_with(rcu_time_t time)
> > > > 
> > > > that only promises all readers from the specified time are finished.
> > > > 
> > > > [ And synchronize_rcu() would be equivalent to
> > > >   synchronize_rcu_with(rcu_current_time()) if I am not mistaken. ]
> > > > 
> > > > Then you wouldn't need to worry about how the return value of
> > > > rcu_cookie_gp_elapsed() might be interpreted, could freely implement
> > > > it equal to synchronize_rcu() on TINY_RCU, the false positives with
> > > > small cookies would not be about correctness but merely performance.
> > > > 
> > > > And it should still be all that which the THP case requires.
> > > > 
> > > > Would that work?
> > > 
> > > rcu_time_t would still be an unsigned long long like I suggested?
> > 
> > Do we even need to make this fixed?  It can be unsigned long long for
> > now, but I could imagine leaving it up to the user depending how much
> > space she is able/willing to invest to save time:
> > 
> > 	void synchronize_rcu_with(unsigned long time, unsigned int bits)
> > 	{
> > 		if (generation_counter & ((1 << bits) - 1) == time)
> > 			synchronize_rcu();
> > 	}
> 
> This is indeed more convenient for this particular use case, but suppose
> that the caller instead wanted to use call_rcu()?

I don't quite understand.  call_rcu() will always schedule the
callbacks for execution after a grace period.  So the only use case I
can see--executing the callback ASAP as the required grace period has
already elapsed--would still require an extra argument to call_rcu()
for it to properly schedule the callback, no?  I.e.

	call_rcu_after(head, func, generation)

What am I missing that would make the existing call_rcu() useful in
combination with rcu_cookie_gp_elapsed()?

> The API I am currently proposing allows either synchronize_rcu() or
> call_rcu() to be used.  In addition, it allows alternative
> algorithms, for example:
> 
> 	rcu_get_gp_cookie(&wherever);
> 
> 	...
> 
> 	if (rcu_cookie_gp_elapsed(&wherever))
> 		p = old_pointer;  /* now safe to re-use. */
> 	else
> 		p = kmalloc( ... );  /* can't re-use, so get new memory. */

I have to admit that I am not imaginative enough right now to put this
in a real life scenario.  But it does look more flexible.

Though it must be made clear that it may never return true, so
anything essential (like _freeing_ old memory) may never rely on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
