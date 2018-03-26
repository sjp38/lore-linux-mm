Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEA2F6B000E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 04:53:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q10so4691391wre.6
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 01:53:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f184sor4530540wmd.3.2018.03.26.01.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 01:53:22 -0700 (PDT)
Date: Mon, 26 Mar 2018 10:53:13 +0200
From: Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH 2/2] smp: introduce kick_active_cpus_sync()
Message-ID: <20180326085313.GA4016@andrea>
References: <20180325175004.28162-1-ynorov@caviumnetworks.com>
 <20180325175004.28162-3-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180325175004.28162-3-ynorov@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Yury,

On Sun, Mar 25, 2018 at 08:50:04PM +0300, Yury Norov wrote:
> kick_all_cpus_sync() forces all CPUs to sync caches by sending broadcast IPI.
> If CPU is in extended quiescent state (idle task or nohz_full userspace), this
> work may be done at the exit of this state. Delaying synchronization helps to
> save power if CPU is in idle state and decrease latency for real-time tasks.
> 
> This patch introduces kick_active_cpus_sync() and uses it in mm/slab and arm64
> code to delay syncronization.
> 
> For task isolation (https://lkml.org/lkml/2017/11/3/589), IPI to the CPU running
> isolated task would be fatal, as it breaks isolation. The approach with delaying
> of synchronization work helps to maintain isolated state.
> 
> I've tested it with test from task isolation series on ThunderX2 for more than
> 10 hours (10k giga-ticks) without breaking isolation.
> 
> Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
> ---
>  arch/arm64/kernel/insn.c |  2 +-
>  include/linux/smp.h      |  2 ++
>  kernel/smp.c             | 24 ++++++++++++++++++++++++
>  mm/slab.c                |  2 +-
>  4 files changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> index 2718a77da165..9d7c492e920e 100644
> --- a/arch/arm64/kernel/insn.c
> +++ b/arch/arm64/kernel/insn.c
> @@ -291,7 +291,7 @@ int __kprobes aarch64_insn_patch_text(void *addrs[], u32 insns[], int cnt)
>  			 * synchronization.
>  			 */
>  			ret = aarch64_insn_patch_text_nosync(addrs[0], insns[0]);
> -			kick_all_cpus_sync();
> +			kick_active_cpus_sync();
>  			return ret;
>  		}
>  	}
> diff --git a/include/linux/smp.h b/include/linux/smp.h
> index 9fb239e12b82..27215e22240d 100644
> --- a/include/linux/smp.h
> +++ b/include/linux/smp.h
> @@ -105,6 +105,7 @@ int smp_call_function_any(const struct cpumask *mask,
>  			  smp_call_func_t func, void *info, int wait);
>  
>  void kick_all_cpus_sync(void);
> +void kick_active_cpus_sync(void);
>  void wake_up_all_idle_cpus(void);
>  
>  /*
> @@ -161,6 +162,7 @@ smp_call_function_any(const struct cpumask *mask, smp_call_func_t func,
>  }
>  
>  static inline void kick_all_cpus_sync(void) {  }
> +static inline void kick_active_cpus_sync(void) {  }
>  static inline void wake_up_all_idle_cpus(void) {  }
>  
>  #ifdef CONFIG_UP_LATE_INIT
> diff --git a/kernel/smp.c b/kernel/smp.c
> index 084c8b3a2681..0358d6673850 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -724,6 +724,30 @@ void kick_all_cpus_sync(void)
>  }
>  EXPORT_SYMBOL_GPL(kick_all_cpus_sync);
>  
> +/**
> + * kick_active_cpus_sync - Force CPUs that are not in extended
> + * quiescent state (idle or nohz_full userspace) sync by sending
> + * IPI. Extended quiescent state CPUs will sync at the exit of
> + * that state.
> + */
> +void kick_active_cpus_sync(void)
> +{
> +	int cpu;
> +	struct cpumask kernel_cpus;
> +
> +	smp_mb();

(A general remark only:)

checkpatch.pl should have warned about the fact that this barrier is
missing an accompanying comment (which accesses are being "ordered",
what is the pairing barrier, etc.).

Moreover if, as your reply above suggested, your patch is relying on
"implicit barriers" (something I would not recommend) then even more
so you should comment on these requirements.

This could: (a) force you to reason about the memory ordering stuff,
(b) easy the task of reviewing and adopting your patch, (c) easy the
task of preserving those requirements (as implementations changes).

  Andrea


> +
> +	cpumask_clear(&kernel_cpus);
> +	preempt_disable();
> +	for_each_online_cpu(cpu) {
> +		if (!rcu_eqs_special_set(cpu))
> +			cpumask_set_cpu(cpu, &kernel_cpus);
> +	}
> +	smp_call_function_many(&kernel_cpus, do_nothing, NULL, 1);
> +	preempt_enable();
> +}
> +EXPORT_SYMBOL_GPL(kick_active_cpus_sync);
> +
>  /**
>   * wake_up_all_idle_cpus - break all cpus out of idle
>   * wake_up_all_idle_cpus try to break all cpus which is in idle state even
> diff --git a/mm/slab.c b/mm/slab.c
> index 324446621b3e..678d5dbd6f46 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3856,7 +3856,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
>  	 * cpus, so skip the IPIs.
>  	 */
>  	if (prev)
> -		kick_all_cpus_sync();
> +		kick_active_cpus_sync();
>  
>  	check_irq_on();
>  	cachep->batchcount = batchcount;
> -- 
> 2.14.1
> 
