Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EFB786B0029
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:48:54 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2770971wwi.26
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:48:52 -0700 (PDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1104281017240.16323@router.home>
References: <20110427102034.GE31015@htj.dyndns.org>
	 <1303961284.3981.318.camel@sli10-conroe>
	 <20110428100938.GA10721@htj.dyndns.org>
	 <alpine.DEB.2.00.1104280904240.15775@router.home>
	 <20110428142331.GA16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104280935460.16323@router.home>
	 <20110428144446.GC16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104280951480.16323@router.home>
	 <20110428145657.GD16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104281003000.16323@router.home>
	 <20110428151203.GE16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104281017240.16323@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 17:48:46 +0200
Message-ID: <1304005726.3360.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Shaohua Li <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Le jeudi 28 avril 2011 A  10:22 -0500, Christoph Lameter a A(C)crit :
> On Thu, 28 Apr 2011, Tejun Heo wrote:
> 
> > It seems like we can split hairs all day long about the similarities
> > and differences with atomics, so let's forget about atomics for now.
> 
> Ok good idea. So you accept that per cpu counters are inevitably fuzzy and
> that the result cannot be relied upon in the same way as on atomics?
> 
> > I don't like any update having possibility of causing @batch jumps in
> > _sum() result.  That severely limits the usefulness of hugely
> > expensive _sum() and the ability to scale @batch.  Not everything in
> > the world is vmstat.  Think about other _CURRENT_ use cases in
> > filesystems.
> 
> Of course you can cause jumps > batch. You are looping over 8 cpus and
> have done cpu 1 and 2 already. Then cpu 1 adds batch-1 to the local per
> cpu counter. cpu 2 increments its per cpu counter. When _sum returns we
> have deviation of batch.
> 
> In the worst case the deviation can increase to (NR_CPUS - 1) * (batch
> -1). That is for the current code!!!
> 
> The hugely expensive _sum() is IMHO pretty useless given the above. It is
> a function that is called with the *hope* of getting a more accurate
> result.
> 
> The only way to reduce the fuzziness is by reducing batch. But then you
> dont need the _sum function.
> 
> Either that or you need additional external synchronization by the
> subsystem that prevents updates.
> 
> 

We could add a seqcount (shared), and increment it each time one cpu
changes global count.

_sum() could get an additional parameter, the max number of allowed
changes during _sum() run.

If _sum() notices seqcount was changed too much, restart the loop.

s64 __percpu_counter_sum(struct percpu_counter *fbc, unsigned maxfuzzy)
{
	s64 ret;
	unsigned int oldseq, newseq;
	int cpu;
restart:
	oldseq = fbc->seqcount;
	smp_rmb();
	ret = fbc->count;
	for_each_online_cpu(cpu) {
		s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
		ret += *pcount;
	}
	smp_rmb()
	newseq = fbc->count;
	if (newseq - oldseq >= maxfuzzy)
		goto restart;
	return ret;
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
