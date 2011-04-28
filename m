Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B6BE96B0024
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:06:21 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2789205wwi.26
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:06:18 -0700 (PDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1304005726.3360.69.camel@edumazet-laptop>
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
	 <1304005726.3360.69.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 17:59:05 +0200
Message-ID: <1304006345.3360.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Shaohua Li <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Le jeudi 28 avril 2011 A  17:48 +0200, Eric Dumazet a A(C)crit :
> uld add a seqcount (shared), and increment it each time one cpu
> changes global count.
> 
> _sum() could get an additional parameter, the max number of allowed
> changes during _sum() run.
> 
> If _sum() notices seqcount was changed too much, restart the loop.
> 
> s64 __percpu_counter_sum(struct percpu_counter *fbc, unsigned maxfuzzy)
> {
> 	s64 ret;
> 	unsigned int oldseq, newseq;
> 	int cpu;
> restart:
> 	oldseq = fbc->seqcount;
> 	smp_rmb();
> 	ret = fbc->count;
> 	for_each_online_cpu(cpu) {
> 		s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
> 		ret += *pcount;
> 	}
> 	smp_rmb()
> 	newseq = fbc->count;

Sorry, it should be : 
	newseq = fbc->seqcount

> 	if (newseq - oldseq >= maxfuzzy)
> 		goto restart;
> 	return ret;
> }
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
