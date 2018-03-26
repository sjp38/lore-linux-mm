Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1869E6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:57:42 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z5-v6so5322725plo.21
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:57:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n20si10614802pgc.508.2018.03.26.11.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 11:57:39 -0700 (PDT)
Date: Mon, 26 Mar 2018 14:57:35 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Message-ID: <20180326145735.57ba306b@gandalf.local.home>
In-Reply-To: <20180326085313.GA4016@andrea>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
	<20180325175004.28162-3-ynorov@caviumnetworks.com>
	<20180326085313.GA4016@andrea>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Mar 2018 10:53:13 +0200
Andrea Parri <andrea.parri@amarulasolutions.com> wrote:

> > --- a/kernel/smp.c
> > +++ b/kernel/smp.c
> > @@ -724,6 +724,30 @@ void kick_all_cpus_sync(void)
> >  }
> >  EXPORT_SYMBOL_GPL(kick_all_cpus_sync);
> >  
> > +/**
> > + * kick_active_cpus_sync - Force CPUs that are not in extended
> > + * quiescent state (idle or nohz_full userspace) sync by sending
> > + * IPI. Extended quiescent state CPUs will sync at the exit of
> > + * that state.
> > + */
> > +void kick_active_cpus_sync(void)
> > +{
> > +	int cpu;
> > +	struct cpumask kernel_cpus;
> > +
> > +	smp_mb();  
> 
> (A general remark only:)
> 
> checkpatch.pl should have warned about the fact that this barrier is
> missing an accompanying comment (which accesses are being "ordered",
> what is the pairing barrier, etc.).

He could have simply copied the comment above the smp_mb() for
kick_all_cpus_sync():

	/* Make sure the change is visible before we kick the cpus */

The kick itself is pretty much a synchronization primitive.

That is, you make some changes and then you need all CPUs to see it,
and you call: kick_active_cpus_synch(), which is the barrier to make
sure you previous changes are seen on all CPUS before you proceed
further. Note, the matching barrier is implicit in the IPI itself.

-- Steve


> 
> Moreover if, as your reply above suggested, your patch is relying on
> "implicit barriers" (something I would not recommend) then even more
> so you should comment on these requirements.
> 
> This could: (a) force you to reason about the memory ordering stuff,
> (b) easy the task of reviewing and adopting your patch, (c) easy the
> task of preserving those requirements (as implementations changes).
> 
>   Andrea
> 
> 
> > +
> > +	cpumask_clear(&kernel_cpus);
> > +	preempt_disable();
> > +	for_each_online_cpu(cpu) {
> > +		if (!rcu_eqs_special_set(cpu))
> > +			cpumask_set_cpu(cpu, &kernel_cpus);
> > +	}
> > +	smp_call_function_many(&kernel_cpus, do_nothing, NULL, 1);
> > +	preempt_enable();
> > +}
> > +EXPORT_SYMBOL_GPL(kick_active_cpus_sync);
> > +
> >  /**
> >   * wake_up_all_idle_cpus - break all cpus out of idle
> >   * wake_up_all_idle_cpus try to break all cpus which is in idle state even
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 324446621b3e..678d5dbd6f46 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3856,7 +3856,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
> >  	 * cpus, so skip the IPIs.
> >  	 */
> >  	if (prev)
> > -		kick_all_cpus_sync();
> > +		kick_active_cpus_sync();
> >  
> >  	check_irq_on();
> >  	cachep->batchcount = batchcount;
> > -- 
> > 2.14.1
> >   
