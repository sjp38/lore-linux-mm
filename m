Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFEE6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:14:26 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1675496eek.29
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:14:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si7601602eef.352.2014.04.24.03.14.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 03:14:24 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:14:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/6] x86: mm: trace tlb flushes
Message-ID: <20140424101419.GS23991@suse.de>
References: <20140421182418.81CF7519@viggo.jf.intel.com>
 <20140421182425.93E696A3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140421182425.93E696A3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com

On Mon, Apr 21, 2014 at 11:24:25AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> We don't have any good way to figure out what kinds of flushes
> are being attempted.  Right now, we can try to use the vm
> counters, but those only tell us what we actually did with the
> hardware (one-by-one vs full) and don't tell us what was actually
> _requested_.
> 

And when enabled they are a penalty even for those that don't care.

> This allows us to select out "interesting" TLB flushes that we
> might want to optimize (like the ranged ones) and ignore the ones
> that we have very little control over (the ones at context
> switch).
> 
> Also, since we have a pair of tracepoint calls in
> flush_tlb_mm_range(), we can time the deltas between them to make
> sure that we got the "invlpg vs. global flush" balance correct in
> practice.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/arch/x86/include/asm/mmu_context.h |    6 +++++
>  b/arch/x86/mm/tlb.c                  |   12 +++++++++--
>  b/include/linux/mm_types.h           |   10 +++++++++
>  b/include/trace/events/tlb.h         |   37 +++++++++++++++++++++++++++++++++++
>  b/mm/Makefile                        |    2 -
>  b/mm/trace_tlb.c                     |   12 +++++++++++
>  6 files changed, 76 insertions(+), 3 deletions(-)
> 
> diff -puN arch/x86/include/asm/mmu_context.h~tlb-trace-flushes arch/x86/include/asm/mmu_context.h
> --- a/arch/x86/include/asm/mmu_context.h~tlb-trace-flushes	2014-04-21 11:10:35.519867746 -0700
> +++ b/arch/x86/include/asm/mmu_context.h	2014-04-21 11:10:35.527868108 -0700
> @@ -3,6 +3,10 @@
>  
>  #include <asm/desc.h>
>  #include <linux/atomic.h>
> +#include <linux/mm_types.h>
> +
> +#include <trace/events/tlb.h>
> +
>  #include <asm/pgalloc.h>
>  #include <asm/tlbflush.h>
>  #include <asm/paravirt.h>
> @@ -44,6 +48,7 @@ static inline void switch_mm(struct mm_s
>  
>  		/* Re-load page tables */
>  		load_cr3(next->pgd);
> +		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
>  
>  		/* Stop flush ipis for the previous mm */
>  		cpumask_clear_cpu(cpu, mm_cpumask(prev));
> @@ -71,6 +76,7 @@ static inline void switch_mm(struct mm_s
>  			 * to make sure to use no freed page tables.
>  			 */
>  			load_cr3(next->pgd);
> +			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
>  			load_LDT_nolock(&next->context);
>  		}
>  	}
> diff -puN arch/x86/mm/tlb.c~tlb-trace-flushes arch/x86/mm/tlb.c
> --- a/arch/x86/mm/tlb.c~tlb-trace-flushes	2014-04-21 11:10:35.520867791 -0700
> +++ b/arch/x86/mm/tlb.c	2014-04-21 11:10:35.528868153 -0700
> @@ -14,6 +14,8 @@
>  #include <asm/uv/uv.h>
>  #include <linux/debugfs.h>
>  
> +#include <trace/events/tlb.h>
> +
>  DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate)
>  			= { &init_mm, 0, };
>  
> @@ -49,6 +51,7 @@ void leave_mm(int cpu)
>  	if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
>  		cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
>  		load_cr3(swapper_pg_dir);
> +		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
>  	}
>  }
>  EXPORT_SYMBOL_GPL(leave_mm);
> @@ -105,9 +108,10 @@ static void flush_tlb_func(void *info)
>  
>  	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
>  	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
> -		if (f->flush_end == TLB_FLUSH_ALL)
> +		if (f->flush_end == TLB_FLUSH_ALL) {
>  			local_flush_tlb();
> -		else if (!f->flush_end)
> +			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
> +		} else if (!f->flush_end)
>  			__flush_tlb_single(f->flush_start);
>  		else {
>  			unsigned long addr;

Why is only the TLB_FLUSH_ALL case traced here and not the single flush
or range of flushes? __native_flush_tlb_single() doesn't have a trace
point so I worry we are missing visibility on this part in particular
this part.

                        while (addr < f->flush_end) {
                                __flush_tlb_single(addr);
                                addr += PAGE_SIZE;
                        }

> @@ -152,7 +156,9 @@ void flush_tlb_current_task(void)
>  	preempt_disable();
>  
>  	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> +	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>  	local_flush_tlb();
> +	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN_DONE, TLB_FLUSH_ALL);
>  	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
>  		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
>  	preempt_enable();

Are the two tracepoints really useful? Are they fine enough to measure
the cost of the TLB flush? It misses the refill obviously but not much
we can do there.

> @@ -188,6 +194,7 @@ void flush_tlb_mm_range(struct mm_struct
>  	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
>  		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
>  
> +	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
>  	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
>  		base_pages_to_flush = TLB_FLUSH_ALL;
>  		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> @@ -199,6 +206,7 @@ void flush_tlb_mm_range(struct mm_struct
>  			__flush_tlb_single(addr);
>  		}
>  	}
> +	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN_DONE, base_pages_to_flush);
>  out:
>  	if (base_pages_to_flush == TLB_FLUSH_ALL) {
>  		start = 0UL;
> diff -puN include/linux/mm_types.h~tlb-trace-flushes include/linux/mm_types.h
> --- a/include/linux/mm_types.h~tlb-trace-flushes	2014-04-21 11:10:35.522867881 -0700
> +++ b/include/linux/mm_types.h	2014-04-21 11:10:35.529868198 -0700
> @@ -510,4 +510,14 @@ static inline void clear_tlb_flush_pendi
>  }
>  #endif
>  
> +enum tlb_flush_reason {
> +	TLB_FLUSH_ON_TASK_SWITCH,
> +	TLB_REMOTE_SHOOTDOWN,
> +	TLB_LOCAL_SHOOTDOWN,
> +	TLB_LOCAL_SHOOTDOWN_DONE,
> +	TLB_LOCAL_MM_SHOOTDOWN,
> +	TLB_LOCAL_MM_SHOOTDOWN_DONE,
> +	NR_TLB_FLUSH_REASONS,
> +};
> +

Bonus points if you use the string formatting similar to the reason field
int events/writeback.h. You do something like that already but there are
already helpers for use with __print_symbolic so you do not need to roll
your own version.

It should reduce the need to add trace_tlb.c if you include the header in
something like memory.c instead.

>  #endif /* _LINUX_MM_TYPES_H */
> diff -puN /dev/null include/trace/events/tlb.h
> --- /dev/null	2014-04-10 11:28:14.066815724 -0700
> +++ b/include/trace/events/tlb.h	2014-04-21 11:10:35.529868198 -0700
> @@ -0,0 +1,37 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM tlb
> +
> +#if !defined(_TRACE_TLB_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_TLB_H
> +
> +#include <linux/mm_types.h>
> +#include <linux/tracepoint.h>
> +
> +extern const char * const tlb_flush_reason_desc[];
> +
> +TRACE_EVENT(tlb_flush,
> +
> +	TP_PROTO(int reason, unsigned long pages),
> +	TP_ARGS(reason, pages),
> +
> +	TP_STRUCT__entry(
> +		__field(	  int, reason)
> +		__field(unsigned long,  pages)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->reason = reason;
> +		__entry->pages  = pages;
> +	),
> +
> +	TP_printk("pages: %ld reason: %d (%s)",
> +		__entry->pages,
> +		__entry->reason,
> +		tlb_flush_reason_desc[__entry->reason])
> +);
> +

I would also suggest you match the output formatting with writeback.h
which would look like

pages:%lu reason:%s

The raw format should still have the integer while the string formatting
would have something human readable. Instead

> +#endif /* _TRACE_TLB_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> +
> diff -puN mm/Makefile~tlb-trace-flushes mm/Makefile
> --- a/mm/Makefile~tlb-trace-flushes	2014-04-21 11:10:35.524867971 -0700
> +++ b/mm/Makefile	2014-04-21 11:10:35.530868243 -0700
> @@ -5,7 +5,7 @@
>  mmu-y			:= nommu.o
>  mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
>  			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
> -			   vmalloc.o pagewalk.o pgtable-generic.o
> +			   vmalloc.o pagewalk.o pgtable-generic.o trace_tlb.o
>  
>  ifdef CONFIG_CROSS_MEMORY_ATTACH
>  mmu-$(CONFIG_MMU)	+= process_vm_access.o
> diff -puN /dev/null mm/trace_tlb.c
> --- /dev/null	2014-04-10 11:28:14.066815724 -0700
> +++ b/mm/trace_tlb.c	2014-04-21 11:10:35.530868243 -0700
> @@ -0,0 +1,12 @@
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/tlb.h>
> +
> +const char * const tlb_flush_reason_desc[] = {
> +	__stringify(TLB_FLUSH_ON_TASK_SWITCH),
> +	__stringify(TLB_REMOTE_SHOOTDOWN),
> +	__stringify(TLB_LOCAL_SHOOTDOWN),
> +	__stringify(TLB_LOCAL_SHOOTDOWN_DONE),
> +	__stringify(TLB_LOCAL_MM_SHOOTDOWN),
> +	__stringify(TLB_LOCAL_MM_SHOOTDOWN_DONE),
> +};
> +
> _

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
