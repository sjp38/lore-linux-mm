Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B544F8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:54:55 -0400 (EDT)
Date: Thu, 21 Apr 2011 13:54:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110421183727.GG15988@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104211350310.5741@router.home>
References: <alpine.DEB.2.00.1104151235350.8055@router.home> <20110415182734.GB15916@mtj.dyndns.org> <alpine.DEB.2.00.1104151440070.8055@router.home> <20110415235222.GA18694@mtj.dyndns.org> <alpine.DEB.2.00.1104180930580.23207@router.home>
 <20110421144300.GA22898@htj.dyndns.org> <20110421145837.GB22898@htj.dyndns.org> <alpine.DEB.2.00.1104211243350.5741@router.home> <20110421180159.GF15988@htj.dyndns.org> <alpine.DEB.2.00.1104211308300.5741@router.home>
 <20110421183727.GG15988@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Thu, 21 Apr 2011, Tejun Heo wrote:

> > The interregnum is very short and since the counters are already fuzzy
> > this is tolerable. We do the same thing elsewhere for vmstats.
>
> We're talking about three different levels of fuzziness.
>
> 1. percpu_counter_sum() before the changes
>
> 	May deviate by the number of concurrent updaters and cacheline
> 	update latencies.

Not true. Any of the updaters may have done multiple updates by the time
we are through cycling through the list.

> 2. percpu_counter_sum() after the changes
>
> 	May deviate by multiples of @batch; however, the duration
> 	during which the deviation may be visible is brief (really?
> 	we're allowing preemption between local and global updates).

Well again there is general fuzziness here and we are trying to make the
best of it without compromising performance too much. Shaohua's numbers
indicate that removing the lock is very advantagous. More over we do the
same thing in other places.

> So, unless someone can show me that percpu_counter_sum() is
> unnecessary (ie. the differences between not only #1 and #2 but also
> between #1 and #3 are irrelevant), I don't think I'm gonna change the
> slow path.  It's silly to micro optimize slow path to begin with and
> I'm not gonna do that at the cost of subtle functionality change which
> can bite us in the ass in twisted ways.

Actually its good to make the code paths for vmstats and percpu counters
similar. That is what this does too.

Preempt enable/disable in any function that is supposedly fast is
something bad that can be avoided with these patches as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
