Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F5646B016A
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 13:08:30 -0400 (EDT)
Date: Fri, 12 Aug 2011 19:08:23 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110812170823.GM7959@redhat.com>
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
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 06:57:49PM +0200, Johannes Weiner wrote:
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

rcu_time_t would still be an unsigned long long like I suggested?

About the false positives thing, I failed to see how it's ever
possible to return only false positives and never false negatives when
cookie and internal counter are not of the same size (and cookie has
no enough bits to ever tell if it overflowed or not).

I think rcu_generation_t is more appropriate because it's not time but
a generation/sequence counter.

The ideally the comparison check would be just an inline function
reading 2 longs in reverse order in 32bit and comparing it with the
stable value we have in page[1]->something_low and
page[1]->something_high , so skipping an external call sounds better
to me, but the above should also work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
