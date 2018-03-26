Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75B236B0009
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:45:13 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d37so10056061wrd.21
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 05:45:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j3si10113472edh.300.2018.03.26.05.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 05:45:11 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2QCaeD0095163
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:45:10 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gxycrvau8-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:45:10 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 26 Mar 2018 08:45:09 -0400
Date: Mon, 26 Mar 2018 05:45:55 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Reply-To: paulmck@linux.vnet.ibm.com
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
 <20180325192328.GI3675@linux.vnet.ibm.com>
 <20180325201154.icdcyl4nw2jootqq@yury-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180325201154.icdcyl4nw2jootqq@yury-thinkpad>
Message-Id: <20180326124555.GJ3675@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@kernel.org

On Sun, Mar 25, 2018 at 11:11:54PM +0300, Yury Norov wrote:
> On Sun, Mar 25, 2018 at 12:23:28PM -0700, Paul E. McKenney wrote:
> > On Sun, Mar 25, 2018 at 08:50:04PM +0300, Yury Norov wrote:
> > > kick_all_cpus_sync() forces all CPUs to sync caches by sending broadcast IPI.
> > > If CPU is in extended quiescent state (idle task or nohz_full userspace), this
> > > work may be done at the exit of this state. Delaying synchronization helps to
> > > save power if CPU is in idle state and decrease latency for real-time tasks.
> > > 
> > > This patch introduces kick_active_cpus_sync() and uses it in mm/slab and arm64
> > > code to delay syncronization.
> > > 
> > > For task isolation (https://lkml.org/lkml/2017/11/3/589), IPI to the CPU running
> > > isolated task would be fatal, as it breaks isolation. The approach with delaying
> > > of synchronization work helps to maintain isolated state.
> > > 
> > > I've tested it with test from task isolation series on ThunderX2 for more than
> > > 10 hours (10k giga-ticks) without breaking isolation.
> > > 
> > > Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> > > ---
> > >  arch/arm64/kernel/insn.c |  2 +-
> > >  include/linux/smp.h      |  2 ++
> > >  kernel/smp.c             | 24 ++++++++++++++++++++++++
> > >  mm/slab.c                |  2 +-
> > >  4 files changed, 28 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> > > index 2718a77da165..9d7c492e920e 100644
> > > --- a/arch/arm64/kernel/insn.c
> > > +++ b/arch/arm64/kernel/insn.c
> > > @@ -291,7 +291,7 @@ int __kprobes aarch64_insn_patch_text(void *addrs[], u32 insns[], int cnt)
> > >  			 * synchronization.
> > >  			 */
> > >  			ret = aarch64_insn_patch_text_nosync(addrs[0], insns[0]);
> > > -			kick_all_cpus_sync();
> > > +			kick_active_cpus_sync();
> > >  			return ret;
> > >  		}
> > >  	}
> > > diff --git a/include/linux/smp.h b/include/linux/smp.h
> > > index 9fb239e12b82..27215e22240d 100644
> > > --- a/include/linux/smp.h
> > > +++ b/include/linux/smp.h
> > > @@ -105,6 +105,7 @@ int smp_call_function_any(const struct cpumask *mask,
> > >  			  smp_call_func_t func, void *info, int wait);
> > > 
> > >  void kick_all_cpus_sync(void);
> > > +void kick_active_cpus_sync(void);
> > >  void wake_up_all_idle_cpus(void);
> > > 
> > >  /*
> > > @@ -161,6 +162,7 @@ smp_call_function_any(const struct cpumask *mask, smp_call_func_t func,
> > >  }
> > > 
> > >  static inline void kick_all_cpus_sync(void) {  }
> > > +static inline void kick_active_cpus_sync(void) {  }
> > >  static inline void wake_up_all_idle_cpus(void) {  }
> > > 
> > >  #ifdef CONFIG_UP_LATE_INIT
> > > diff --git a/kernel/smp.c b/kernel/smp.c
> > > index 084c8b3a2681..0358d6673850 100644
> > > --- a/kernel/smp.c
> > > +++ b/kernel/smp.c
> > > @@ -724,6 +724,30 @@ void kick_all_cpus_sync(void)
> > >  }
> > >  EXPORT_SYMBOL_GPL(kick_all_cpus_sync);
> > > 
> > > +/**
> > > + * kick_active_cpus_sync - Force CPUs that are not in extended
> > > + * quiescent state (idle or nohz_full userspace) sync by sending
> > > + * IPI. Extended quiescent state CPUs will sync at the exit of
> > > + * that state.
> > > + */
> > > +void kick_active_cpus_sync(void)
> > > +{
> > > +	int cpu;
> > > +	struct cpumask kernel_cpus;
> > > +
> > > +	smp_mb();
> > > +
> > > +	cpumask_clear(&kernel_cpus);
> > > +	preempt_disable();
> > > +	for_each_online_cpu(cpu) {
> > > +		if (!rcu_eqs_special_set(cpu))
> > 
> > If we get here, the CPU is not in a quiescent state, so we therefore
> > must IPI it, correct?
> > 
> > But don't you also need to define rcu_eqs_special_exit() so that RCU
> > can invoke it when it next leaves its quiescent state?  Or are you able
> > to ignore the CPU in that case?  (If you are able to ignore the CPU in
> > that case, I could give you a lower-cost function to get your job done.)
> > 
> > 							Thanx, Paul
> 
> What's actually needed for synchronization is issuing memory barrier on target
> CPUs before we start executing kernel code.
> 
> smp_mb() is implicitly called in smp_call_function*() path for it. In
> rcu_eqs_special_set() -> rcu_dynticks_eqs_exit() path, smp_mb__after_atomic()
> is called just before rcu_eqs_special_exit().
> 
> So I think, rcu_eqs_special_exit() may be left untouched. Empty
> rcu_eqs_special_exit() in new RCU path corresponds empty do_nothing() in old
> IPI path.
> 
> Or my understanding of smp_mb__after_atomic() is wrong? By default, 
> smp_mb__after_atomic() is just alias to smp_mb(). But some
> architectures define it differently. x86, for example, aliases it to
> just barrier() with a comment: "Atomic operations are already
> serializing on x86".
> 
> I was initially thinking that it's also fine to leave
> rcu_eqs_special_exit() empty in this case, but now I'm not sure...
> 
> Anyway, answering to your question, we shouldn't ignore quiescent
> CPUs, and rcu_eqs_special_set() path is really needed as it issues
> memory barrier on them.

An alternative approach would be for me to make something like this
and export it:

	bool rcu_cpu_in_eqs(int cpu)
	{
		struct rcu_dynticks *rdtp = &per_cpu(rcu_dynticks, cpu);
		int snap;

		smp_mb(); /* Obtain consistent snapshot, pairs with update. */
		snap = READ_ONCE(&rdtp->dynticks);
		smp_mb(); /* See above. */
		return !(snap & RCU_DYNTICK_CTRL_CTR);
	}

Then you could replace your use of rcu_cpu_in_eqs() above with
the new rcu_cpu_in_eqs().  This would avoid the RMW atomic, and, more
important, the unnecessary write to ->dynticks.

Or am I missing something?

							Thanx, Paul

> Yury
> 
> > > +			cpumask_set_cpu(cpu, &kernel_cpus);
> > > +	}
> > > +	smp_call_function_many(&kernel_cpus, do_nothing, NULL, 1);
> > > +	preempt_enable();
> > > +}
> > > +EXPORT_SYMBOL_GPL(kick_active_cpus_sync);
> > > +
> > >  /**
> > >   * wake_up_all_idle_cpus - break all cpus out of idle
> > >   * wake_up_all_idle_cpus try to break all cpus which is in idle state even
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index 324446621b3e..678d5dbd6f46 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -3856,7 +3856,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
> > >  	 * cpus, so skip the IPIs.
> > >  	 */
> > >  	if (prev)
> > > -		kick_all_cpus_sync();
> > > +		kick_active_cpus_sync();
> > > 
> > >  	check_irq_on();
> > >  	cachep->batchcount = batchcount;
> > > -- 
> > > 2.14.1
> > > 
> 
