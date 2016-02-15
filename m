Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA466B0253
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 05:50:26 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ho8so85233660pac.2
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 02:50:26 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v88si36663005pfi.243.2016.02.15.02.50.25
        for <linux-mm@kvack.org>;
        Mon, 15 Feb 2016 02:50:25 -0800 (PST)
Date: Mon, 15 Feb 2016 10:50:29 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC] Introduce atomic and per-cpu add-max and sub-min
 operations
Message-ID: <20160215105028.GB1748@arm.com>
References: <145544094056.28219.12239469516497703482.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145544094056.28219.12239469516497703482.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-arch@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, peterz@infradead.org, paulmck@linux.vnet.ibm.com

Adding Peter and Paul,

On Sun, Feb 14, 2016 at 12:09:00PM +0300, Konstantin Khlebnikov wrote:
> bool atomic_add_max(atomic_t *var, int add, int max);
> bool atomic_sub_min(atomic_t *var, int sub, int min);

What are the memory-ordering requirements for these? Do you also want
relaxed/acquire/release versions for the use-cases you outline?

One observation is that you provide no ordering guarantees if the
comparison fails, which is fine if that's what you want, but we should
probably write that down like we do for cmpxchg.

> bool this_cpu_add_max(var, add, max);
> bool this_cpu_sub_min(var, sub, min);
> 
> They add/subtract only if result will be not bigger than max/lower that min.
> Returns true if operation was done and false otherwise.
> 
> Inside they check that (add <= max - var) and (sub <= var - min). Signed
> operations work if all possible values fits into range which length fits
> into non-negative range of that type: 0..INT_MAX, INT_MIN+1..0, -1000..1000.
> Unsigned operations work if value always in valid range: min <= var <= max.
> Char and short automatically casts to int, they never overflows.
> 
> Patch adds the same for atomic_long_t, atomic64_t, local_t, local64_t.
> And unsigned variants: atomic_u32_add_max atomic_u32_sub_min for atomic_t,
> atomic_u64_add_max atomic_u64_sub_min for atomic64_t.
> 
> Patch comes with test which hopefully covers all possible cornercases,
> see CONFIG_ATOMIC64_SELFTEST and CONFIG_PERCPU_TEST.
> 
> All this allows to build any kind of counter in several lines:

Do you have another patch converting people over to these new atomics?

> - Simple atomic resource counter
> 
> atomic_t usage;
> int limit;
> 
> result = atomic_add_max(&usage, charge, limit);
> 
> atomic_sub(uncharge, &usage);
> 
> - Event counter with per-cpu batch
> 
> atomic_t events;
> DEFINE_PER_CPU(int, cpu_events);
> int batch;
> 
> if (!this_cpu_add_max(cpu_events, count, batch))
> 	atomic_add(this_cpu_xchg(cpu_events, 0) + count,  &events);
> 
> - Object counter with per-cpu part
> 
> atomic_t objects;
> DEFINE_PER_CPU(int, cpu_objects);
> int batch;
> 
> if (!this_cpu_add_max(cpu_objects, 1, batch))
> 	atomic_add(this_cpu_xchg(cpu_events, 0) + 1,  &objects);
> 
> if (!this_cpu_sub_min(cpu_objects, 1, -batch))
> 	atomic_add(this_cpu_xchg(cpu_events, 0) - 1,  &objects);
> 
> - Positive object counter with negative per-cpu parts
> 
> atomic_t objects;
> DEFINE_PER_CPU(int, cpu_objects);
> int batch;
> 
> if (!this_cpu_add_max(cpu_objects, 1, 0))
> 	atomic_add(this_cpu_xchg(cpu_events, -batch / 2) + 1,  &objects);
> 
> if (!this_cpu_sub_min(cpu_objects, 1, -batch))
> 	atomic_add(this_cpu_xchg(cpu_events, -batch / 2) - 1,  &objects);
> 
> - Resource counter with per-cpu precharge
> 
> atomic_t usage;
> int limit;
> DEFINE_PER_CPU(int, precharge);
> int batch;
> 
> result = this_cpu_sub_min(precharge, charge, 0);
> if (!result) {
> 	preempt_disable();
> 	charge += batch / 2 - __this_cpu_read(precharge);
> 	result = atomic_add_max(&usage, charge, limit);
> 	if (result)
> 		__this_cpu_write(precharge, batch / 2);
> 	preempt_enable();
> }
> 
> if (!this_cpu_add_max(precharge, uncharge, batch)) {
> 	preempt_disable();
> 	if (__this_cpu_read(precharge) > batch / 2) {
> 		uncharge += __this_cpu_read(precharge) - batch / 2;
> 		__this_cpu_write(precharge, batch / 2);
> 	}
> 	atomic_sub(uncharge, &usage);
> 	preempt_enable();
> }
> 
> - Each operation easily split into static-inline per-cpu fast-path and
>   atomic slow-path which could be hidden in separate function which
>   performs resource reclaim, logging, etc.
> - Types of global atomic part and per-cpu part might differs: for example
>   like in vmstat counters atomit_long_t global and s8 local part.
> - Resource could be counted upwards to the limit or downwards to the zero.
> - Bounds min=INT_MIN/max=INT_MAX could be used for catching und/overflows.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> ---
>  arch/x86/include/asm/local.h  |    2 +
>  include/asm-generic/local.h   |    2 +
>  include/asm-generic/local64.h |    4 ++
>  include/linux/atomic.h        |   52 +++++++++++++++++++++++++
>  include/linux/percpu-defs.h   |   56 +++++++++++++++++++++++++++
>  lib/atomic64_test.c           |   49 ++++++++++++++++++++++++
>  lib/percpu_test.c             |   84 +++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 249 insertions(+)

You may want something in Documentation/ too.

> diff --git a/include/linux/atomic.h b/include/linux/atomic.h
> index 301de78d65f7..06b12a60645b 100644
> --- a/include/linux/atomic.h
> +++ b/include/linux/atomic.h
> @@ -561,4 +561,56 @@ static inline void atomic64_andnot(long long i, atomic64_t *v)
>  
>  #include <asm-generic/atomic-long.h>
>  
> +/*
> + * atomic_add_max - add unless result will be bugger that max

Freudian slip? ;)

> + * @var:  pointer of type atomic_t
> + * @add:  value to add
> + * @max:  maximum result
> + *
> + * Atomic value must be already lower or equal to max before call.
> + * The function returns true if operation was done and false otherwise.
> + */
> +
> +/*
> + * atomic_sub_min - subtract unless result will be lower than min
> + * @var:  pointer of type atomic_t
> + * @sub:  value to subtract
> + * @min:  minimal result
> + *
> + * Atomic value must be already bigger or equal to min before call.
> + * The function returns true if operation was done and false otherwise.
> + */
> +
> +#define ATOMIC_MINMAX_OP(nm, at, type)					\
> +static inline bool nm##_add_max(at##_t *var, type add, type max)	\
> +{									\
> +	type val = at##_read(var);					\
> +	while (likely(add <= max - val)) {				\
> +		type old = at##_cmpxchg(var, val, val + add);		\
> +		if (likely(old == val))					\
> +			return true;					\
> +		val = old;						\
> +	}								\
> +	return false;							\
> +}									\
> +									\
> +static inline bool nm##_sub_min(at##_t *var, type sub, type min)	\
> +{									\
> +	type val = at##_read(var);					\
> +	while (likely(sub <= val - min)) {				\
> +		type old = at##_cmpxchg(var, val, val - sub);		\
> +		if (likely(old == val))					\
> +			return true;					\
> +		val = old;						\
> +	}								\
> +	return false;							\
> +}
> +
> +ATOMIC_MINMAX_OP(atomic, atomic, int)
> +ATOMIC_MINMAX_OP(atomic_long, atomic_long, long)
> +ATOMIC_MINMAX_OP(atomic64, atomic64, long long)
> +
> +ATOMIC_MINMAX_OP(atomic_u32, atomic, unsigned)
> +ATOMIC_MINMAX_OP(atomic_u64, atomic64, unsigned long long)
> +
>  #endif /* _LINUX_ATOMIC_H */
> diff --git a/include/linux/percpu-defs.h b/include/linux/percpu-defs.h
> index 8f16299ca068..113ebff1cecf 100644
> --- a/include/linux/percpu-defs.h
> +++ b/include/linux/percpu-defs.h
> @@ -371,6 +371,48 @@ do {									\
>  } while (0)
>  
>  /*
> + * Add unless result will be bigger than max.
> + * Returns true if operantion was done.

Typo (which is copy-pasted elsewhere too).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
