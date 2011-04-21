Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 980718D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:20:42 -0400 (EDT)
Date: Thu, 21 Apr 2011 13:20:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110421180159.GF15988@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104211308300.5741@router.home>
References: <alpine.DEB.2.00.1104141608300.19533@router.home> <20110414211522.GE21397@mtj.dyndns.org> <alpine.DEB.2.00.1104151235350.8055@router.home> <20110415182734.GB15916@mtj.dyndns.org> <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org> <alpine.DEB.2.00.1104180930580.23207@router.home> <20110421144300.GA22898@htj.dyndns.org> <20110421145837.GB22898@htj.dyndns.org> <alpine.DEB.2.00.1104211243350.5741@router.home>
 <20110421180159.GF15988@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Thu, 21 Apr 2011, Tejun Heo wrote:

> The only difference between the two is the level of fuziness.  The
> former deviates only by the number of concurrent updaters (and maybe
> cacheline update latencies) while the latter may deviate in multiples
> of @batch.

I dont think multiple times of batch is such a concern. Either the per cpu
counter is high or the overflow has been folded into the global counter.

The interregnum is very short and since the counters are already fuzzy
this is tolerable. We do the same thing elsewhere for vmstats.

> If you wanna say that the difference in the level of fuzziness is
> irrelevant, the first patch of this series should be removing
> percpu_counter_sum() before making any other changes.

percpu_counter_sum() is more accurate since it considers the per cpu
counters. That is vastly different.

> > The local counter increment was already decoupled before. The shifting of
> > the overflow into the global counter was also not serialized before.
>
> No, it wasn't.

>
> 	...
> 	if (count >= batch || count <= -batch) {
> 		spin_lock(&fbc->lock);
> 		fbc->count += count;
> 		__this_cpu_write(*fbc->counters, 0);
> 		spin_unlock(&fbc->lock);
> 	} else {
> 	...
>
> percpu_counter_sum() would see either both the percpu and global
> counters updated or un-updated.  It will never see local counter reset
> with global counter not updated yet.

Sure there is a slight race there and there is no way to avoid that race
without a lock.

> > There was no total accuracy before either.
>
> It's not about total accuracy.  It's about different levels of
> fuzziness.  If it can be shown that the different levels of fuzziness
> doesn't matter and thus percpu_counter_sum() can be removed, I'll be a
> happy camper.

percpu_counter_sum() is a totally different animal since it considers the
per cpu differentials but while it does that the per cpu differentials can
be updated. So the fuzziness is much lower than just looking at the global
counter for wich all sorts of counters differentials on multiple cpus can
be outstanding over long time periods.

Look at mm/vmstat.c. There is __inc_zone_state() which does an analogous
thing. and include/linux/vmstat.h:zone_page_state_snapshot() which is
analoguous to percpu_counter_sum().

In fact as far as I can tell the percpu_counter stuff was cribbed from
that one. What I did is the same process as in mm/vmstat.c:mod_state.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
