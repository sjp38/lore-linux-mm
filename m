Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id E92BF6B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 07:07:39 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so14164018wiw.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 04:07:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si2510273wij.93.2015.06.09.04.07.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 04:07:37 -0700 (PDT)
Date: Tue, 9 Jun 2015 12:07:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: Send one IPI per CPU to TLB flush multiple pages
 that were recently unmapped
Message-ID: <20150609110732.GR26425@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <1433767854-24408-3-git-send-email-mgorman@suse.de>
 <20150608153813.dbadaceffe316d09ee9f2446@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150608153813.dbadaceffe316d09ee9f2446@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 08, 2015 at 03:38:13PM -0700, Andrew Morton wrote:
> On Mon,  8 Jun 2015 13:50:53 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > An IPI is sent to flush remote TLBs when a page is unmapped that was
> > recently accessed by other CPUs. There are many circumstances where this
> > happens but the obvious one is kswapd reclaiming pages belonging to a
> > running process as kswapd and the task are likely running on separate CPUs.
> > 
> > On small machines, this is not a significant problem but as machine
> > gets larger with more cores and more memory, the cost of these IPIs can
> > be high. This patch uses a structure similar in principle to a pagevec
> > to collect a list of PFNs and CPUs that require flushing. It then sends
> > one IPI per CPU that was mapping any of those pages to flush the list of
> > PFNs. A new TLB flush helper is required for this and one is added for
> > x86. Other architectures will need to decide if batching like this is both
> > safe and worth the memory overhead. Specifically the requirement is;
> > 
> > 	If a clean page is unmapped and not immediately flushed, the
> > 	architecture must guarantee that a write to that page from a CPU
> > 	with a cached TLB entry will trap a page fault.
> > 
> > This is essentially what the kernel already depends on but the window is
> > much larger with this patch applied and is worth highlighting.
> > 
> > The impact of this patch depends on the workload as measuring any benefit
> > requires both mapped pages co-located on the LRU and memory pressure. The
> > case with the biggest impact is multiple processes reading mapped pages
> > taken from the vm-scalability test suite. The test case uses NR_CPU readers
> > of mapped files that consume 10*RAM.
> > 
> > vmscale on a 4-node machine with 64G RAM and 48 CPUs
> >            4.1.0-rc6     4.1.0-rc6
> >              vanilla batchunmap-v5
> > User          577.35        618.60
> > System       5927.06       4195.03
> > Elapsed       162.21        121.31
> > 
> > The workload completed 25% faster with 29% less CPU time.
> > 
> > This is showing that the readers completed 25% with 30% less CPU time. From
> > vmstats, it is known that the vanilla kernel was interrupted roughly 900K
> > times per second during the steady phase of the test and the patched kernel
> > was interrupts 180K times per second.
> > 
> > The impact is much lower on a small machine
> > 
> > vmscale on a 1-node machine with 8G RAM and 1 CPU
> >            4.1.0-rc6     4.1.0-rc6
> >              vanilla batchunmap-v5
> > User           59.14         58.86
> > System        109.15         83.78
> > Elapsed        27.32         23.14
> > 
> > It's still a noticeable improvement with vmstat showing interrupts went
> > from roughly 500K per second to 45K per second.
> 
> Looks nice.
> 
> > The patch will have no impact on workloads with no memory pressure or
> > have relatively few mapped pages.
> 
> What benefit can we expect to see to any real-world userspace?
> 

Only a small subset of workloads will see a benefit -- ones that mmap a
lot of data with working sets larger than the size of a node. Some
streaming media servers allegedly do this.

Some numerical processing applications may hit this. Those that use glibc
for large buffers use mmap and if the application is larger than a NUMA
node, it'll need to be unmapped and flushed. Python/NumPY uses large
maps for large buffers (based on the paper "Doubling the Performance of
Python/Numpy with less than 100 SLOC"). Whether users of NumPY hit this
issue or not depends on whether kswapd is active.

Anecdotally, I'm aware from IRC of one user that is experimenting with
a large HTTP cache and a load generator that spent a lot of time sending
IPIs that was obvious from the profile. I asked weeks ago that they post
the results here which they promised they would but didn't. Unfortunately,
I don't know the persons real name to cc them. Rik might.

Anecdotally, I also believe that Intel hit this internally with some
internal workload but I'm basing this on idle comments at LSF/MM. However
they were unwilling or unable to describe exactly what the test does and
against what software.

I know this is more vague than you'd like. By and large, I'm relying on
the assumption that if we are reclaiming mapped pages from kswapd context
then sending one IPI per page is stupid.

> > --- a/include/linux/init_task.h
> > +++ b/include/linux/init_task.h
> > @@ -175,6 +175,13 @@ extern struct task_group root_task_group;
> >  # define INIT_NUMA_BALANCING(tsk)
> >  #endif
> >  
> > +#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> > +# define INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)				\
> > +	.tlb_ubc = NULL,
> > +#else
> > +# define INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)
> > +#endif
> > +
> >  #ifdef CONFIG_KASAN
> >  # define INIT_KASAN(tsk)						\
> >  	.kasan_depth = 1,
> > @@ -257,6 +264,7 @@ extern struct task_group root_task_group;
> >  	INIT_RT_MUTEXES(tsk)						\
> >  	INIT_VTIME(tsk)							\
> >  	INIT_NUMA_BALANCING(tsk)					\
> > +	INIT_TLBFLUSH_UNMAP_BATCH_CONTROL(tsk)				\
> >  	INIT_KASAN(tsk)							\
> >  }
> 
> We don't really need any of this - init_task starts up all-zero anyway.
> Maybe it's useful for documentation reasons (dubious), but I bet we've
> already missed fields.
> 

True. I'll look into removing it and make sure there is no adverse
impact.

> >
> > ...
> >
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1289,6 +1289,16 @@ enum perf_event_task_context {
> >  	perf_nr_task_contexts,
> >  };
> >  
> > +/* Matches SWAP_CLUSTER_MAX but refined to limit header dependencies */
> > +#define BATCH_TLBFLUSH_SIZE 32UL
> > +
> > +/* Track pages that require TLB flushes */
> > +struct tlbflush_unmap_batch {
> > +	struct cpumask cpumask;
> > +	unsigned long nr_pages;
> > +	unsigned long pfns[BATCH_TLBFLUSH_SIZE];
> 
> Why are we storing pfn's rather than page*'s?
> 

Because a page would require a page->pfn lookup within the IPI handler.
That will work but it's unnecessarily wasteful.

> I'm trying to get my head around what's actually in this structure.
> 
> Each thread has one of these, lazily allocated <under circumstances>. 
> The cpumask field contains a mask of all the CPUs which have done
> <something>.  The careful reader will find mm_struct.cpu_vm_mask_var
> and will wonder why it didn't need documenting, sigh.
> 
> Wanna fill in the blanks?  As usual, understanding the data structure
> is the key to understanding the design, so it's worth a couple of
> paragraphs.  With this knowledge, the reader may understand why
> try_to_unmap_flush() has preempt_disable() protection but
> set_tlb_ubc_flush_pending() doesn't need it!
> 

Is this any help?

struct tlbflush_unmap_batch {
        /*
         * Each bit set is a CPU that potentially has a TLB entry for one of
         * the PFNs being flushed. See set_tlb_ubc_flush_pending().
         */
        struct cpumask cpumask;

        /*
         * The number and list of pfns to be flushed. PFNs are tracked instead
         * of struct pages to avoid multiple page->pfn lookups by each CPU that
         * receives an IPI in percpu_flush_tlb_batch_pages
         */
        unsigned long nr_pages;
        unsigned long pfns[BATCH_TLBFLUSH_SIZE];

        /*
         * If true then the PTE was dirty when unmapped. The entry must be
         * flushed before IO is initiated or a stale TLB entry potentially
         * allows an update without redirtying the page.
         */
        bool writable;
};

> > +};
> > +
> >  struct task_struct {
> >  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
> >  	void *stack;
> >
> > ...
> >
> > @@ -581,6 +583,90 @@ vma_address(struct page *page, struct vm_area_struct *vma)
> >  	return address;
> >  }
> >  
> > +#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> > +static void percpu_flush_tlb_batch_pages(void *data)
> > +{
> > +	struct tlbflush_unmap_batch *tlb_ubc = data;
> > +	int i;
> 
> Anally speaking, this should be unsigned long (in which case it
> shouldn't be called `i'!).  Or make tlbflush_unmap_batch.nr_pages int. 
> But int is signed, which is silly.  Whatever ;)
> 

I can make it unsigned int which is a micro-optimisation for loop iterators
anyway.

> 
> > +	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
> > +	for (i = 0; i < tlb_ubc->nr_pages; i++)
> > +		flush_local_tlb_addr(tlb_ubc->pfns[i] << PAGE_SHIFT);
> > +}
> > +
> > +/*
> > + * Flush TLB entries for recently unmapped pages from remote CPUs. It is
> > + * important that if a PTE was dirty when it was unmapped that it's flushed
> 
> s/important that/important /
> 

Fixed.

> > + * before any IO is initiated on the page to prevent lost writes. Similarly,
> > + * it must be flushed before freeing to prevent data leakage.
> > + */
> > +void try_to_unmap_flush(void)
> > +{
> > +	struct tlbflush_unmap_batch *tlb_ubc = current->tlb_ubc;
> > +	int cpu;
> > +
> > +	if (!tlb_ubc || !tlb_ubc->nr_pages)
> > +		return;
> > +
> > +	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, tlb_ubc->nr_pages);
> > +
> > +	preempt_disable();
> > +	cpu = smp_processor_id();
> 
> get_cpu()
> 
> > +	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
> > +		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
> > +
> > +	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids) {
> > +		smp_call_function_many(&tlb_ubc->cpumask,
> > +			percpu_flush_tlb_batch_pages, (void *)tlb_ubc, true);
> > +	}
> > +	cpumask_clear(&tlb_ubc->cpumask);
> > +	tlb_ubc->nr_pages = 0;
> > +	preempt_enable();
> 
> put_cpu()
> 

Gack. Fixed.

> > +}
> >
> > ...
> >
> > +/*
> > + * Returns true if the TLB flush should be deferred to the end of a batch of
> > + * unmap operations to reduce IPIs.
> > + */
> > +static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
> > +{
> > +	bool should_defer = false;
> > +
> > +	if (!current->tlb_ubc || !(flags & TTU_BATCH_FLUSH))
> > +		return false;
> > +
> > +	/* If remote CPUs need to be flushed then defer batch the flush */
> > +	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
> > +		should_defer = true;
> > +	put_cpu();
> 
> What did the get_cpu() protect?
> 

To safely lookup the current running CPU number. smp_processor_id() is
potentially safe except in specific circumstances and I did not think
raw_smp_processor_id() was justified.

> > +	return should_defer;
> > +}
> > +#else
> > +static void set_tlb_ubc_flush_pending(struct mm_struct *mm,
> > +		struct page *page)
> > +{
> > +}
> > +
> >
> > ...
> >
> > +#ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> > +/*
> > + * Allocate the control structure for batch TLB flushing. An allocation
> > + * failure is harmless as the reclaimer will send IPIs where necessary.
> > + */
> > +static void alloc_tlb_ubc(void)
> > +{
> > +	if (!current->tlb_ubc)
> > +		current->tlb_ubc = kzalloc(sizeof(struct tlbflush_unmap_batch),
> > +						GFP_KERNEL | __GFP_NOWARN);
> 
> A GFP_KERNEL allocation from deep within page reclaim?  Seems imprudent
> if only from a stack-usage POV.
> 

When we call it, we are in PF_MEMALLOC context either set in the page
allocator from direct reclaim or because kswapd always sets it. This limits
the stack depth. It would be comparable to the depth we reach during normal
reclaim calling into shrink_page_list and everything below it so we should
be safe. Granted, the dependency on PF_MEMALLOC is not obvious at all.

> > +}
> > +#else
> > +static inline void alloc_tlb_ubc(void)
> > +{
> > +}
> > +#endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
> >
> > ...
> >
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
