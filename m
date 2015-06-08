Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 693306B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 18:38:16 -0400 (EDT)
Received: by payr10 with SMTP id r10so877507pay.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 15:38:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qm2si6081193pac.57.2015.06.08.15.38.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 15:38:15 -0700 (PDT)
Date: Mon, 8 Jun 2015 15:38:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: Send one IPI per CPU to TLB flush multiple
 pages that were recently unmapped
Message-Id: <20150608153813.dbadaceffe316d09ee9f2446@linux-foundation.org>
In-Reply-To: <1433767854-24408-3-git-send-email-mgorman@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
	<1433767854-24408-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon,  8 Jun 2015 13:50:53 +0100 Mel Gorman <mgorman@suse.de> wrote:

> An IPI is sent to flush remote TLBs when a page is unmapped that was
> recently accessed by other CPUs. There are many circumstances where this
> happens but the obvious one is kswapd reclaiming pages belonging to a
> running process as kswapd and the task are likely running on separate CPUs.
> 
> On small machines, this is not a significant problem but as machine
> gets larger with more cores and more memory, the cost of these IPIs can
> be high. This patch uses a structure similar in principle to a pagevec
> to collect a list of PFNs and CPUs that require flushing. It then sends
> one IPI per CPU that was mapping any of those pages to flush the list of
> PFNs. A new TLB flush helper is required for this and one is added for
> x86. Other architectures will need to decide if batching like this is both
> safe and worth the memory overhead. Specifically the requirement is;
> 
> 	If a clean page is unmapped and not immediately flushed, the
> 	architecture must guarantee that a write to that page from a CPU
> 	with a cached TLB entry will trap a page fault.
> 
> This is essentially what the kernel already depends on but the window is
> much larger with this patch applied and is worth highlighting.
> 
> The impact of this patch depends on the workload as measuring any benefit
> requires both mapped pages co-located on the LRU and memory pressure. The
> case with the biggest impact is multiple processes reading mapped pages
> taken from the vm-scalability test suite. The test case uses NR_CPU readers
> of mapped files that consume 10*RAM.
> 
> vmscale on a 4-node machine with 64G RAM and 48 CPUs
>            4.1.0-rc6     4.1.0-rc6
>              vanilla batchunmap-v5
> User          577.35        618.60
> System       5927.06       4195.03
> Elapsed       162.21        121.31
> 
> The workload completed 25% faster with 29% less CPU time.
> 
> This is showing that the readers completed 25% with 30% less CPU time. From
> vmstats, it is known that the vanilla kernel was interrupted roughly 900K
> times per second during the steady phase of the test and the patched kernel
> was interrupts 180K times per second.
> 
> The impact is much lower on a small machine
> 
> vmscale on a 1-node machine with 8G RAM and 1 CPU
>            4.1.0-rc6     4.1.0-rc6
>              vanilla batchunmap-v5
> User           59.14         58.86
> System        109.15         83.78
> Elapsed        27.32         23.14
> 
> It's still a noticeable improvement with vmstat showing interrupts went
> from roughly 500K per second to 45K per second.

Looks nice.

> The patch will have no impact on workloads with no memory pressure or
> have relatively few mapped pages.

What benefit can we expect to see to any real-world userspace?

> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -175,6 +175,13 @@ extern struct task_group root_task_group;
>  # define INIT_NUMA_BALANCING(tsk)
>  #endif
>  
> +#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> +# define INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)				\
> +	.tlb_ubc = NULL,
> +#else
> +# define INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)
> +#endif
> +
>  #ifdef CONFIG_KASAN
>  # define INIT_KASAN(tsk)						\
>  	.kasan_depth = 1,
> @@ -257,6 +264,7 @@ extern struct task_group root_task_group;
>  	INIT_RT_MUTEXES(tsk)						\
>  	INIT_VTIME(tsk)							\
>  	INIT_NUMA_BALANCING(tsk)					\
> +	INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)				\
>  	INIT_KASAN(tsk)							\
>  }

We don't really need any of this - init_task starts up all-zero anyway.
Maybe it's useful for documentation reasons (dubious), but I bet we've
already missed fields.

>
> ...
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1289,6 +1289,16 @@ enum perf_event_task_context {
>  	perf_nr_task_contexts,
>  };
>  
> +/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
> +#define BATCH_TLBFLUSH_SIZE 32UL
> +
> +/* Track pages that require TLB flushes */
> +struct tlbflush_unmap_batch {
> +	struct cpumask cpumask;
> +	unsigned long nr_pages;
> +	unsigned long pfns[BATCH_TLBFLUSH_SIZE];

Why are we storing pfn's rather than page*'s?

I'm trying to get my head around what's actually in this structure.

Each thread has one of these, lazily allocated <under circumstances>. 
The cpumask field contains a mask of all the CPUs which have done
<something>.  The careful reader will find mm_struct.cpu_vm_mask_var
and will wonder why it didn't need documenting, sigh.

Wanna fill in the blanks?  As usual, understanding the data structure
is the key to understanding the design, so it's worth a couple of
paragraphs.  With this knowledge, the reader may understand why
try_to_unmap_flush() has preempt_disable() protection but
set_tlb_ubc_flush_pending() doesn't need it!

> +};
> +
>  struct task_struct {
>  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
>  	void *stack;
>
> ...
>
> @@ -581,6 +583,90 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>  	return address;
>  }
>  
> +#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> +static void percpu_flush_tlb_batch_pages(void *data)
> +{
> +	struct tlbflush_unmap_batch *tlb_ubc = data;
> +	int i;

Anally speaking, this should be unsigned long (in which case it
shouldn't be called `i'!).  Or make tlbflush_unmap_batch.nr_pages int. 
But int is signed, which is silly.  Whatever ;)


> +	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
> +	for (i = 0; i < tlb_ubc->nr_pages; i++)
> +		flush_local_tlb_addr(tlb_ubc->pfns[i] << PAGE_SHIFT);
> +}
> +
> +/*
> + * Flush TLB entries for recently unmapped pages from remote CPUs. It is
> + * important that if a PTE was dirty when it was unmapped that it's flushed

s/important that/important /

> + * before any IO is initiated on the page to prevent lost writes. Similarly,
> + * it must be flushed before freeing to prevent data leakage.
> + */
> +void try_to_unmap_flush(void)
> +{
> +	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
> +	int cpu;
> +
> +	if (!tlb_ubc || !tlb_ubc->nr_pages)
> +		return;
> +
> +	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, tlb_ubc->nr_pages);
> +
> +	preempt_disable();
> +	cpu = smp_processor_id();

get_cpu()

> +	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
> +		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
> +
> +	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids) {
> +		smp_call_function_many(&tlb_ubc->cpumask,
> +			percpu_flush_tlb_batch_pages, (void *)tlb_ubc, true);
> +	}
> +	cpumask_clear(&tlb_ubc->cpumask);
> +	tlb_ubc->nr_pages = 0;
> +	preempt_enable();

put_cpu()

> +}
>
> ...
>
> +/*
> + * Returns true if the TLB flush should be deferred to the end of a batch of
> + * unmap operations to reduce IPIs.
> + */
> +static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
> +{
> +	bool should_defer = false;
> +
> +	if (!current->tlb_ubc || !(flags & TTU_BATCH_FLUSH))
> +		return false;
> +
> +	/* If remote CPUs need to be flushed then defer batch the flush */
> +	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
> +		should_defer = true;
> +	put_cpu();

What did the get_cpu() protect?

> +	return should_defer;
> +}
> +#else
> +static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
> +		struct page *page)
> +{
> +}
> +
>
> ...
>
> +#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> +/*
> + * Allocate the control structure for batch TLB flushing. An allocation
> + * failure is harmless as the reclaimer will send IPIs where necessary.
> + */
> +static void alloc_tlb_ubc(void)
> +{
> +	if (!current->tlb_ubc)
> +		current->tlb_ubc = kzalloc(sizeof(struct tlbflush_unmap_batch),
> +						GFP_KERNEL | __GFP_NOWARN);

A GFP_KERNEL allocation from deep within page reclaim?  Seems imprudent
if only from a stack-usage POV.

> +}
> +#else
> +static inline void alloc_tlb_ubc(void)
> +{
> +}
> +#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
