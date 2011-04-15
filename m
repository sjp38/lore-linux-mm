Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B152900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:43:19 -0400 (EDT)
Date: Fri, 15 Apr 2011 14:43:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110415182734.GB15916@mtj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104151440070.8055@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home> <alpine.DEB.2.00.1104131148070.20908@router.home> <20110413185618.GA3987@mtj.dyndns.org> <alpine.DEB.2.00.1104131521050.25812@router.home> <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home> <20110414211522.GE21397@mtj.dyndns.org> <alpine.DEB.2.00.1104151235350.8055@router.home> <20110415182734.GB15916@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Sat, 16 Apr 2011, Tejun Heo wrote:

> > +			new = 0;
> > +		}
> > +#ifdef CONFIG_PREEMPT
> > +	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
> > +#else
> > +	} while (0);
> > +	this_cpu_write(*fbc->counters, new);
> > +#endif
>
> Eeeek, no.  If you want to do the above, please put it in a separate
> inline function with sufficient comment.

That would not work well with the control flow. Just leave the cmpxchg for
both cases? That would make the function irq safe as well!

> > +	if (unlikely(overflow)) {
> >  		spin_lock(&fbc->lock);
> > -		fbc->count += count;
> > -		__this_cpu_write(*fbc->counters, 0);
> > +		fbc->count += overflow;
> >  		spin_unlock(&fbc->lock);
>
> Why put this outside and use yet another branch?

Because that way we do not need preempt enable/disable. The cmpxchg is
used to update the per cpu counter in the slow case as well. All that is
left then is to add the count to the global counter.

The branches are not an issue since they are forward branches over one
(after converting to an atomic operation) or two instructions each. A
possible stall is only possible in case of the cmpxchg failing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
