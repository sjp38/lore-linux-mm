Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AF5F78D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:33:03 -0400 (EDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110421190807.GK15988@htj.dyndns.org>
References: <alpine.DEB.2.00.1104151440070.8055@router.home>
	 <20110415235222.GA18694@mtj.dyndns.org>
	 <alpine.DEB.2.00.1104180930580.23207@router.home>
	 <20110421144300.GA22898@htj.dyndns.org>
	 <20110421145837.GB22898@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211243350.5741@router.home>
	 <20110421180159.GF15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211308300.5741@router.home>
	 <20110421183727.GG15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211350310.5741@router.home>
	 <20110421190807.GK15988@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Apr 2011 10:33:00 +0800
Message-ID: <1303439580.3981.241.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-04-22 at 03:08 +0800, Tejun Heo wrote:
> Hello,
> 
> On Thu, Apr 21, 2011 at 01:54:51PM -0500, Christoph Lameter wrote:
> > Well again there is general fuzziness here and we are trying to make the
> > best of it without compromising performance too much. Shaohua's numbers
> > indicate that removing the lock is very advantagous. More over we do the
> > same thing in other places.
> 
> The problem with Shaohua's numbers is that it's a pessimistic test
> case with too low batch count.  If an optimization improves such
> situations without compromising funcitionality or introducing too much
> complexity, sure, why not?  But I'm not sure that's the case here.
> 
> > Actually its good to make the code paths for vmstats and percpu counters
> > similar. That is what this does too.
> > 
> > Preempt enable/disable in any function that is supposedly fast is
> > something bad that can be avoided with these patches as well.
> 
> If you really wanna push the _sum() fuziness change, the only way to
> do that would be auditing all the current users and making sure that
> it won't affect any of them.  It really doesn't matter what vmstat is
> doing.  They're different users.
> 
> And, no matter what, that's a separate issue from the this_cpu hot
> path optimizations and should be done separately.  So, _please_ update
> this_cpu patch so that it doesn't change the slow path semantics.
in the original implementation, a updater can change several times too,
it can update the count from -(batch -1) to (batch -1) without holding
the lock. so we always have batch*num_cpus*2 deviate

if we really worry about _sum deviates too much. can we do something
like this:
percpu_counter_sum
{
again:
	sum=0
	old = atomic64_read(&fbc->counter)
	for_each_online_cpu()
		sum += per cpu counter
	new = atomic64_read(&fbc->counter)
	if (new - old > batch * num_cpus || old - new > batch * num_cpus)
		goto again;
	return new + sum;
}
in this way we limited the deviate to number of concurrent updater. This
doesn't make _sum too slow too, because we have the batch * num_cpus
check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
