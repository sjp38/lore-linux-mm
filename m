Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BF5C5900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 04:32:46 -0400 (EDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1304008533.3360.88.camel@edumazet-laptop>
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
	 <1304006345.3360.72.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104281116270.18213@router.home>
	 <1304008533.3360.88.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Apr 2011 16:32:43 +0800
Message-ID: <1304065963.3981.600.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-04-29 at 00:35 +0800, Eric Dumazet wrote:
> Le jeudi 28 avril 2011 A  11:17 -0500, Christoph Lameter a A(C)crit :
> > On Thu, 28 Apr 2011, Eric Dumazet wrote:
> > 
> > > > If _sum() notices seqcount was changed too much, restart the loop.
> > 
> > This does not address the issue of cpus adding batch -1 while the
> > loop is going on.
> 
> 
> Yes, it does, I left the needed changes to write side as an exercice ;)
> 
> 
> For example, based on current linux-2.6 code
> 
> 
> void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
> {
>         s64 count;
> 
>         preempt_disable();
>         count = __this_cpu_read(*fbc->counters) + amount;
>         if (count >= batch || count <= -batch) {
>                 spin_lock(&fbc->lock);
> 		fbc->seqcount++;
>                 fbc->count += count;
>                 __this_cpu_write(*fbc->counters, 0);
>                 spin_unlock(&fbc->lock);
>         } else {
>                 __this_cpu_write(*fbc->counters, count);
>         }
>         preempt_enable();
> }
yep, this can resolve Tejun's concern. The problem is how do you
determine maxfuzzy. This can mislead user too. Because in the worst
case, the deviation is num_cpu*batch. If a user uses a small maxfuzzy
and expect the max deviation is maxfuzzy, he actually will get a bigger
deviation in worst case.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
