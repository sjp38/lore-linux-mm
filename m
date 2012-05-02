Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3F0D36B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 12:24:09 -0400 (EDT)
Date: Wed, 2 May 2012 17:24:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/16] mm: allow PF_MEMALLOC from softirq context
Message-ID: <20120502162403.GE11435@suse.de>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de>
 <1334578624-23257-6-git-send-email-mgorman@suse.de>
 <20120501150813.657cd5c0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120501150813.657cd5c0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Tue, May 01, 2012 at 03:08:13PM -0700, Andrew Morton wrote:
> On Mon, 16 Apr 2012 13:16:52 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > This is needed to allow network softirq packet processing to make
> > use of PF_MEMALLOC.
> 
> hm, why?  You just added __GFP_MEMALLOC so we don't need to futz with
> PF_MEMALLOC?
> 

The number of call sites is a problem. In patch 12, PF_MEMALLOC is set
where required. For example it is set in __netif_receive_skb() before it
calls packet_type->func() which is a per-protocol receive function such
as net/ipv4/ip_input.c#ip_rcv(). To use __GFP_MEMALLOC, every allocation
on this path would need to check the skb and set the flag as appropriate
for every protocol. This would make a mess and seeing as it is needed for
every allocation it makes more sense to set PF_MEMALLOC.

> > Currently softirq context cannot use PF_MEMALLOC due to it not being
> > associated with a task, and therefore not having task flags to fiddle
> > with - thus the gfp to alloc flag mapping ignores the task flags when
> > in interrupts (hard or soft) context.
> > 
> > Allowing softirqs to make use of PF_MEMALLOC therefore requires some
> > trickery.  We basically borrow the task flags from whatever process
> > happens to be preempted by the softirq.
> > 
> > So we modify the gfp to alloc flags mapping to not exclude task flags
> > in softirq context, and modify the softirq code to save, clear and
> > restore the PF_MEMALLOC flag.
> > 
> > The save and clear, ensures the preempted task's PF_MEMALLOC flag
> > doesn't leak into the softirq. The restore ensures a softirq's
> > PF_MEMALLOC flag cannot leak back into the preempted process.
> > 
> > ...
> >
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1913,6 +1913,13 @@ static inline void rcu_copy_process(struct task_struct *p)
> >  
> >  #endif
> >  
> > +static inline void tsk_restore_flags(struct task_struct *p,
> > +				     unsigned long pflags, unsigned long mask)
> 
> The naming is poor.
> 
> p -> "tsk" or "task"
> pflags -> "old_flags"
> mask -> "flags"
> 

I went with orig_flags instead of old_flags so it reads as "restore the
original task flags".

> > +{
> > +	p->flags &= ~mask;
> > +	p->flags |= pflags & mask;
> > +}
> > +
> >  #ifdef CONFIG_SMP
> >  extern void do_set_cpus_allowed(struct task_struct *p,
> >  			       const struct cpumask *new_mask);
> > diff --git a/kernel/softirq.c b/kernel/softirq.c
> > index 671f959..d349caa 100644
> > --- a/kernel/softirq.c
> > +++ b/kernel/softirq.c
> > @@ -210,6 +210,8 @@ asmlinkage void __do_softirq(void)
> >  	__u32 pending;
> >  	int max_restart = MAX_SOFTIRQ_RESTART;
> >  	int cpu;
> > +	unsigned long pflags = current->flags;
> 
> "old_flags"
> 
> > +	current->flags &= ~PF_MEMALLOC;
> 
> The line before this one would be a suitable place for a comment!
> 

        /*
         * Mask out PF_MEMALLOC s current task context is borrowed for the
         * softirq. A softirq handled such as network RX might set PF_MEMALLOC
         * again if the socket is related to swap
         */

?

> >  	pending = local_softirq_pending();
> >  	account_system_vtime(current);
> > @@ -265,6 +267,7 @@ restart:
> >  
> >  	account_system_vtime(current);
> >  	__local_bh_enable(SOFTIRQ_OFFSET);
> > +	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> >  }
> >  
> > ...
> >

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
