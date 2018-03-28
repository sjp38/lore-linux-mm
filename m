Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDF996B0026
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:36:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c65so1439502pfa.5
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:36:23 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0058.outbound.protection.outlook.com. [104.47.37.58])
        by mx.google.com with ESMTPS id f22-v6si164888plr.257.2018.03.28.06.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 06:36:22 -0700 (PDT)
Date: Wed, 28 Mar 2018 16:36:05 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Message-ID: <20180328133605.u7pftfxpn3jbqire@yury-thinkpad>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
 <20180325192328.GI3675@linux.vnet.ibm.com>
 <20180325201154.icdcyl4nw2jootqq@yury-thinkpad>
 <20180326124555.GJ3675@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326124555.GJ3675@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@kernel.org

On Mon, Mar 26, 2018 at 05:45:55AM -0700, Paul E. McKenney wrote:
> On Sun, Mar 25, 2018 at 11:11:54PM +0300, Yury Norov wrote:
> > On Sun, Mar 25, 2018 at 12:23:28PM -0700, Paul E. McKenney wrote:
> > > On Sun, Mar 25, 2018 at 08:50:04PM +0300, Yury Norov wrote:
> > > > kick_all_cpus_sync() forces all CPUs to sync caches by sending broadcast IPI.
> > > > If CPU is in extended quiescent state (idle task or nohz_full userspace), this
> > > > work may be done at the exit of this state. Delaying synchronization helps to
> > > > save power if CPU is in idle state and decrease latency for real-time tasks.
> > > > 
> > > > This patch introduces kick_active_cpus_sync() and uses it in mm/slab and arm64
> > > > code to delay syncronization.
> > > > 
> > > > For task isolation (https://lkml.org/lkml/2017/11/3/589), IPI to the CPU running
> > > > isolated task would be fatal, as it breaks isolation. The approach with delaying
> > > > of synchronization work helps to maintain isolated state.
> > > > 
> > > > I've tested it with test from task isolation series on ThunderX2 for more than
> > > > 10 hours (10k giga-ticks) without breaking isolation.
> > > > 
> > > > Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> > > > ---
> > > >  arch/arm64/kernel/insn.c |  2 +-
> > > >  include/linux/smp.h      |  2 ++
> > > >  kernel/smp.c             | 24 ++++++++++++++++++++++++
> > > >  mm/slab.c                |  2 +-
> > > >  4 files changed, 28 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> > > > index 2718a77da165..9d7c492e920e 100644
> > > > --- a/arch/arm64/kernel/insn.c
> > > > +++ b/arch/arm64/kernel/insn.c
> > > > @@ -291,7 +291,7 @@ int __kprobes aarch64_insn_patch_text(void *addrs[], u32 insns[], int cnt)
> > > >  			 * synchronization.
> > > >  			 */
> > > >  			ret = aarch64_insn_patch_text_nosync(addrs[0], insns[0]);
> > > > -			kick_all_cpus_sync();
> > > > +			kick_active_cpus_sync();
> > > >  			return ret;
> > > >  		}
> > > >  	}
> > > > diff --git a/include/linux/smp.h b/include/linux/smp.h
> > > > index 9fb239e12b82..27215e22240d 100644
> > > > --- a/include/linux/smp.h
> > > > +++ b/include/linux/smp.h
> > > > @@ -105,6 +105,7 @@ int smp_call_function_any(const struct cpumask *mask,
> > > >  			  smp_call_func_t func, void *info, int wait);
> > > > 
> > > >  void kick_all_cpus_sync(void);
> > > > +void kick_active_cpus_sync(void);
> > > >  void wake_up_all_idle_cpus(void);
> > > > 
> > > >  /*
> > > > @@ -161,6 +162,7 @@ smp_call_function_any(const struct cpumask *mask, smp_call_func_t func,
> > > >  }
> > > > 
> > > >  static inline void kick_all_cpus_sync(void) {  }
> > > > +static inline void kick_active_cpus_sync(void) {  }
> > > >  static inline void wake_up_all_idle_cpus(void) {  }
> > > > 
> > > >  #ifdef CONFIG_UP_LATE_INIT
> > > > diff --git a/kernel/smp.c b/kernel/smp.c
> > > > index 084c8b3a2681..0358d6673850 100644
> > > > --- a/kernel/smp.c
> > > > +++ b/kernel/smp.c
> > > > @@ -724,6 +724,30 @@ void kick_all_cpus_sync(void)
> > > >  }
> > > >  EXPORT_SYMBOL_GPL(kick_all_cpus_sync);
> > > > 
> > > > +/**
> > > > + * kick_active_cpus_sync - Force CPUs that are not in extended
> > > > + * quiescent state (idle or nohz_full userspace) sync by sending
> > > > + * IPI. Extended quiescent state CPUs will sync at the exit of
> > > > + * that state.
> > > > + */
> > > > +void kick_active_cpus_sync(void)
> > > > +{
> > > > +	int cpu;
> > > > +	struct cpumask kernel_cpus;
> > > > +
> > > > +	smp_mb();
> > > > +
> > > > +	cpumask_clear(&kernel_cpus);
> > > > +	preempt_disable();
> > > > +	for_each_online_cpu(cpu) {
> > > > +		if (!rcu_eqs_special_set(cpu))
> > > 
> > > If we get here, the CPU is not in a quiescent state, so we therefore
> > > must IPI it, correct?
> > > 
> > > But don't you also need to define rcu_eqs_special_exit() so that RCU
> > > can invoke it when it next leaves its quiescent state?  Or are you able
> > > to ignore the CPU in that case?  (If you are able to ignore the CPU in
> > > that case, I could give you a lower-cost function to get your job done.)
> > > 
> > > 							Thanx, Paul
> > 
> > What's actually needed for synchronization is issuing memory barrier on target
> > CPUs before we start executing kernel code.
> > 
> > smp_mb() is implicitly called in smp_call_function*() path for it. In
> > rcu_eqs_special_set() -> rcu_dynticks_eqs_exit() path, smp_mb__after_atomic()
> > is called just before rcu_eqs_special_exit().
> > 
> > So I think, rcu_eqs_special_exit() may be left untouched. Empty
> > rcu_eqs_special_exit() in new RCU path corresponds empty do_nothing() in old
> > IPI path.
> > 
> > Or my understanding of smp_mb__after_atomic() is wrong? By default, 
> > smp_mb__after_atomic() is just alias to smp_mb(). But some
> > architectures define it differently. x86, for example, aliases it to
> > just barrier() with a comment: "Atomic operations are already
> > serializing on x86".
> > 
> > I was initially thinking that it's also fine to leave
> > rcu_eqs_special_exit() empty in this case, but now I'm not sure...
> > 
> > Anyway, answering to your question, we shouldn't ignore quiescent
> > CPUs, and rcu_eqs_special_set() path is really needed as it issues
> > memory barrier on them.
> 
> An alternative approach would be for me to make something like this
> and export it:
> 
> 	bool rcu_cpu_in_eqs(int cpu)
> 	{
> 		struct rcu_dynticks *rdtp = &per_cpu(rcu_dynticks, cpu);
> 		int snap;
> 
> 		smp_mb(); /* Obtain consistent snapshot, pairs with update. */
> 		snap = READ_ONCE(&rdtp->dynticks);
> 		smp_mb(); /* See above. */
> 		return !(snap & RCU_DYNTICK_CTRL_CTR);
> 	}
> 
> Then you could replace your use of rcu_cpu_in_eqs() above with

Did you mean replace rcu_eqs_special_set()?

> the new rcu_cpu_in_eqs().  This would avoid the RMW atomic, and, more
> important, the unnecessary write to ->dynticks.
> 
> Or am I missing something?
> 
> 							Thanx, Paul

This will not work because EQS CPUs will not be charged to call
smp_mb() on exit of EQS. 

Lets sync our understanding of IPI and RCU mechanisms.

Traditional IPI scheme looks like this:

CPU1:                                    CPU2:
touch shared resource();                 /* running any code */
smp_mb();
smp_call_function();          --->       handle_IPI()
                                         {
                                                 /* Make resource visible */
                                                 smp_mb();
                                                 do_nothing();
                                         }

And new RCU scheme for eqs CPUs looks like this:

CPU1:                                    CPU2:
touch shared resource();                /* Running EQS */
smp_mb();

if (RCU_DYNTICK_CTRL_CTR)
        set(RCU_DYNTICK_CTRL_MASK);     /* Still in EQS */
                                       
                                        /* And later */
                                        rcu_dynticks_eqs_exit()
                                        {
                                                if (RCU_DYNTICK_CTRL_MASK) {
                                                        /* Make resource visible */
                                                        smp_mb(); 
                                                        rcu_eqs_special_exit();
                                                }
                                        }

Is it correct?

Yury
