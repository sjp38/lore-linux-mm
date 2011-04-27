Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 364C89000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 01:43:32 -0400 (EDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110426121011.GD878@htj.dyndns.org>
References: <alpine.DEB.2.00.1104180930580.23207@router.home>
	 <20110421144300.GA22898@htj.dyndns.org>
	 <20110421145837.GB22898@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211243350.5741@router.home>
	 <20110421180159.GF15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211308300.5741@router.home>
	 <20110421183727.GG15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211350310.5741@router.home>
	 <20110421190807.GK15988@htj.dyndns.org>
	 <1303439580.3981.241.camel@sli10-conroe>
	 <20110426121011.GD878@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 13:43:29 +0800
Message-ID: <1303883009.3981.316.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2011-04-26 at 20:10 +0800, Tejun Heo wrote:
> Hello, please pardon delay (and probably bad temper).  I'm still sick
> & slow.
no problem.

> On Fri, Apr 22, 2011 at 10:33:00AM +0800, Shaohua Li wrote:
> > > And, no matter what, that's a separate issue from the this_cpu hot
> > > path optimizations and should be done separately.  So, _please_ update
> > > this_cpu patch so that it doesn't change the slow path semantics.
> >
> > in the original implementation, a updater can change several times too,
> > it can update the count from -(batch -1) to (batch -1) without holding
> > the lock. so we always have batch*num_cpus*2 deviate
> 
> That would be a pathelogical case but, even then, after the change the
> number becomes much higher as it becomes a function of batch *
> num_updaters, right?
I don't understand the difference between batch * num_updaters and batch
* num_cpus except preempt. So the only problem here is _add should have
preempt disabled? I agree preempt can make deviation worse.
except the preempt issue, are there other concerns against the atomic
convert? in the preempt disabled case, before/after the atomic convert
the deviation is the same (batch*num_cpus)

> I'll try to re-summarize my concerns as my communications don't seem
> to be getting through very well these few days (likely my fault).
> 
> The biggest issue I have with the change is that with the suggested
> changes, the devaition seen by _sum becomes much less predictable.
> _sum can't be accurate.  It never was and never will be, but the
> deviations have been quite predictable regardless of @batch.  It's
> dependent only on the number and frequency of concurrent updaters.
> 
> If concurrent updates aren't very frequent and numerous, the caller is
> guaranteed to get a result which deviates only by quite small margin.
> If concurrent updates are very frequent and numerous, the caller
> natuarally can't expect a very accurate result.
> 
> However, after the change, especially with high @batch count, the
> result may deviate significantly even with low frequency concurrent
> updates.  @batch deviations won't happen often but will happen once in
> a while, which is just nasty and makes the API much less useful and
> those occasional deviations can cause sporadic erratic behaviors -
> e.g. filesystems use it for free block accounting.  It's actually used
> for somewhat critical decision making.
> 
> If it were in the fast path, sure, we might and plan for slower
> contingencies where accuracy is more important, but we're talking
> about slow path already - it's visiting each per-cpu area for $DEITY's
> sake, so the tradeoff doesn't make a lot of sense to me.
> 
> > if we really worry about _sum deviates too much. can we do something
> > like this:
> > percpu_counter_sum
> > {
> > again:
> > 	sum=0
> > 	old = atomic64_read(&fbc->counter)
> > 	for_each_online_cpu()
> > 		sum += per cpu counter
> > 	new = atomic64_read(&fbc->counter)
> > 	if (new - old > batch * num_cpus || old - new > batch * num_cpus)
> > 		goto again;
> > 	return new + sum;
> > }
> > in this way we limited the deviate to number of concurrent updater. This
> > doesn't make _sum too slow too, because we have the batch * num_cpus
> > check.
> 
> I don't really worry about _sum performance.  It's a quite slow path
> and most of the cost is from causing cacheline bounces anyway.  That
> said, I don't see how the above would help the deviation problem.
> Let's say an updater reset per cpu counter but got preempted before
> updating the global counter.  What differences does it make to check
> fbc->counter before & after like above?
yes, this is a problem. Again I don't mind to disable preempt in _add.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
