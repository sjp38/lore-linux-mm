Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F52E6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:28:18 -0400 (EDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110427102034.GE31015@htj.dyndns.org>
References: <20110421145837.GB22898@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211243350.5741@router.home>
	 <20110421180159.GF15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211308300.5741@router.home>
	 <20110421183727.GG15988@htj.dyndns.org>
	 <alpine.DEB.2.00.1104211350310.5741@router.home>
	 <20110421190807.GK15988@htj.dyndns.org>
	 <1303439580.3981.241.camel@sli10-conroe>
	 <20110426121011.GD878@htj.dyndns.org>
	 <1303883009.3981.316.camel@sli10-conroe>
	 <20110427102034.GE31015@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 11:28:04 +0800
Message-ID: <1303961284.3981.318.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2011-04-27 at 18:20 +0800, Tejun Heo wrote:
> Hello, Shaohua.
> 
> On Wed, Apr 27, 2011 at 01:43:29PM +0800, Shaohua Li wrote:
> > > That would be a pathelogical case but, even then, after the change the
> > > number becomes much higher as it becomes a function of batch *
> > > num_updaters, right?
> >
> > I don't understand the difference between batch * num_updaters and batch
> > * num_cpus except preempt. So the only problem here is _add should have
> > preempt disabled? I agree preempt can make deviation worse.
> > except the preempt issue, are there other concerns against the atomic
> > convert? in the preempt disabled case, before/after the atomic convert
> > the deviation is the same (batch*num_cpus)
> 
> Yes, with preemption disabled, I think the patheological worst case
> wouldn't be too different.
> 
> > > I don't really worry about _sum performance.  It's a quite slow path
> > > and most of the cost is from causing cacheline bounces anyway.  That
> > > said, I don't see how the above would help the deviation problem.
> > > Let's say an updater reset per cpu counter but got preempted before
> > > updating the global counter.  What differences does it make to check
> > > fbc->counter before & after like above?
> >
> > yes, this is a problem. Again I don't mind to disable preempt in _add.
> 
> Okay, this communication failure isn't my fault.  Please re-read what
> I wrote before, my concern wasn't primarily about pathological worst
> case - if that many concurrent updates are happening && the counter
> needs to be accurate, it can't even use atomic counter.  It should be
> doing full exclusion around the counter and the associated operation
> _together_.
> 
> I'm worried about sporadic erratic behavior happening regardless of
> update frequency and preemption would contribute but isn't necessary
> for that to happen.
Ok, I misunderstood the mail you sent to Christoph, sorry. So you have
no problem about the atomic convert. I'll update the patch against base
tree, given the preemptless patch has problem.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
