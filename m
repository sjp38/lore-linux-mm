Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF8F7900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 19:52:30 -0400 (EDT)
Received: by pzk32 with SMTP id 32so1691540pzk.14
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:52:29 -0700 (PDT)
Date: Sat, 16 Apr 2011 08:52:22 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110415235222.GA18694@mtj.dyndns.org>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
 <alpine.DEB.2.00.1104131148070.20908@router.home>
 <20110413185618.GA3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131521050.25812@router.home>
 <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home>
 <20110414211522.GE21397@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151235350.8055@router.home>
 <20110415182734.GB15916@mtj.dyndns.org>
 <alpine.DEB.2.00.1104151440070.8055@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104151440070.8055@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello, Christoph.

On Fri, Apr 15, 2011 at 02:43:15PM -0500, Christoph Lameter wrote:
> On Sat, 16 Apr 2011, Tejun Heo wrote:
> 
> > > +			new = 0;
> > > +		}
> > > +#ifdef CONFIG_PREEMPT
> > > +	} while (this_cpu_cmpxchg(*fbc->counters, count, new) != count);
> > > +#else
> > > +	} while (0);
> > > +	this_cpu_write(*fbc->counters, new);
> > > +#endif
> >
> > Eeeek, no.  If you want to do the above, please put it in a separate
> > inline function with sufficient comment.
> 
> That would not work well with the control flow.

It doesn't have to be that way.  ie.

	static inline bool pcnt_add_cmpxchg(counter, count, new)
	{
		/* blah blah */
	#ifdef PREEMPT
		return this_cpu_cmpxchg() == count;
	#else
		this_cpu_write();
		return true;
	#endif
	}

	void __percpu_counter_add(...)
	{
		...
		do {
			...
		} while (!pcnt_add_cmpxchg(counter, count, new))
		...
	}

It's the same thing but ifdef'd "} while()"'s are just too ugly.

> Just leave the cmpxchg for both cases? That would make the function
> irq safe as well!

Maybe, I don't know.  On x86, it shouldn't be a problem on both 32 and
64bit.  Even on archs which lack local cmpxchg, preemption flips are
cheap anyway so yeah maybe.

> > > +	if (unlikely(overflow)) {
> > >  		spin_lock(&fbc->lock);
> > > -		fbc->count += count;
> > > -		__this_cpu_write(*fbc->counters, 0);
> > > +		fbc->count += overflow;
> > >  		spin_unlock(&fbc->lock);
> >
> > Why put this outside and use yet another branch?
> 
> Because that way we do not need preempt enable/disable. The cmpxchg is
> used to update the per cpu counter in the slow case as well. All that is
> left then is to add the count to the global counter.
> 
> The branches are not an issue since they are forward branches over one
> (after converting to an atomic operation) or two instructions each. A
> possible stall is only possible in case of the cmpxchg failing.

It's slow path and IMHO it's needlessly complex.  I really don't care
whether the counter is reloaded once more or the task gets migrated to
another cpu before spin_lock() and ends up flushing local counter on a
cpu where it isn't strictly necessary.  Let's keep it simple.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
