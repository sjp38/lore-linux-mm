Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5AAA46B009C
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 06:26:09 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so1535880wes.16
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:26:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cc14si990125wib.54.2014.02.26.03.26.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 03:26:07 -0800 (PST)
Date: Wed, 26 Feb 2014 11:26:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm: per-thread vma caching
Message-ID: <20140226112603.GA6732@suse.de>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 25, 2014 at 10:16:46AM -0800, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
> 
> This patch is a continuation of efforts trying to optimize find_vma(),
> avoiding potentially expensive rbtree walks to locate a vma upon faults.
> The original approach (https://lkml.org/lkml/2013/11/1/410), where the
> largest vma was also cached, ended up being too specific and random, thus
> further comparison with other approaches were needed. There are two things
> to consider when dealing with this, the cache hit rate and the latency of
> find_vma(). Improving the hit-rate does not necessarily translate in finding
> the vma any faster, as the overhead of any fancy caching schemes can be too
> high to consider.
> 
> We currently cache the last used vma for the whole address space, which
> provides a nice optimization, reducing the total cycles in find_vma() by up
> to 250%, for workloads with good locality. On the other hand, this simple
> scheme is pretty much useless for workloads with poor locality. Analyzing
> ebizzy runs shows that, no matter how many threads are running, the
> mmap_cache hit rate is less than 2%, and in many situations below 1%.
> 
> The proposed approach is to keep the current cache and adding a small, per
> thread, LRU cache. By keeping the mm->mmap_cache, programs with large heaps
> or good locality can benefit by not having to deal with an additional cache
> when the hit rate is good enough. Concretely, the following results are seen
> on an 80 core, 8 socket x86-64 box:
> 
> 1) System bootup: Most programs are single threaded, so the per-thread scheme
> does improve ~50% hit rate by just adding a few more slots to the cache.
> 
> +----------------+----------+------------------+
> | caching scheme | hit-rate | cycles (billion) |
> +----------------+----------+------------------+
> | baseline       | 50.61%   | 19.90            |
> | patched        | 73.45%   | 13.58            |
> +----------------+----------+------------------+
> 
> 2) Kernel build: This one is already pretty good with the current approach
> as we're dealing with good locality.
> 
> +----------------+----------+------------------+
> | caching scheme | hit-rate | cycles (billion) |
> +----------------+----------+------------------+
> | baseline       | 75.28%   | 11.03            |
> | patched        | 88.09%   | 9.31             |
> +----------------+----------+------------------+
> 
> 3) Oracle 11g Data Mining (4k pages): Similar to the kernel build workload.
> 
> +----------------+----------+------------------+
> | caching scheme | hit-rate | cycles (billion) |
> +----------------+----------+------------------+
> | baseline       | 70.66%   | 17.14            |
> | patched        | 91.15%   | 12.57            |
> +----------------+----------+------------------+
> 
> 4) Ebizzy: There's a fair amount of variation from run to run, but this
> approach always shows nearly perfect hit rates, while baseline is just
> about non-existent. The amounts of cycles can fluctuate between anywhere
> from ~60 to ~116 for the baseline scheme, but this approach reduces it
> considerably. For instance, with 80 threads:
> 
> +----------------+----------+------------------+
> | caching scheme | hit-rate | cycles (billion) |
> +----------------+----------+------------------+
> | baseline       | 1.06%    | 91.54            |
> | patched        | 99.97%   | 14.18            |
> +----------------+----------+------------------+
> 
> Systems with !CONFIG_MMU get to keep the current logic.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
> Changes from v1 (https://lkml.org/lkml/2014/2/21/8): 
> - Removed the per-mm cache for CONFIG_MMU, only having the 
>   per thread approach.
> 
> - Since lookups are always performed before updates, only 
>   invalidate when searching for a vma. Simplify the updating.
> 
> - Hash based on the page# instead of the remaining two bits 
>   of the offset, results show that both methods are pretty 
>   much identical for hit-rates.
> 
> Please note that nommu and unicore32 arch are *untested*.
> Thanks.
> 
>  arch/unicore32/include/asm/mmu_context.h | 10 ++++-
>  fs/proc/task_mmu.c                       |  2 +-
>  include/linux/mm_types.h                 |  6 ++-
>  include/linux/sched.h                    |  5 +++
>  include/linux/vmacache.h                 | 24 +++++++++++
>  kernel/debug/debug_core.c                |  6 ++-
>  kernel/fork.c                            |  7 +++-
>  mm/Makefile                              |  2 +-
>  mm/mmap.c                                | 54 +++++++++++++------------
>  mm/nommu.c                               | 12 +++---
>  mm/vmacache.c                            | 69 ++++++++++++++++++++++++++++++++
>  11 files changed, 157 insertions(+), 40 deletions(-)
>  create mode 100644 include/linux/vmacache.h
>  create mode 100644 mm/vmacache.c
> 
> diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
> index fb5e4c6..c571759 100644
> --- a/arch/unicore32/include/asm/mmu_context.h
> +++ b/arch/unicore32/include/asm/mmu_context.h
> @@ -56,6 +56,14 @@ switch_mm(struct mm_struct *prev, struct mm_struct *next,
>  #define deactivate_mm(tsk, mm)	do { } while (0)
>  #define activate_mm(prev, next)	switch_mm(prev, next, NULL)
>  
> +static inline void __vmacache_invalidate(struct mm_struct *mm)
> +{
> +#ifdef CONFIG_MMU
> +	vmacache_invalidate(mm);
> +#else
> +	mm->vmacache = NULL;
> +#endif
> +}

Unusual to see foo() being the internal helper and __foo() being the
inlined wrapped. Not wrong, it just does not match expectation.

>  /*
>   * We are inserting a "fake" vma for the user-accessible vector page so
>   * gdb and friends can get to it through ptrace and /proc/<pid>/mem.
> @@ -73,7 +81,7 @@ do { \
>  		else \
>  			mm->mmap = NULL; \
>  		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
> -		mm->mmap_cache = NULL; \
> +		__vmacache_invalidate(mm); \
>  		mm->map_count--; \
>  		remove_vma(high_vma); \
>  	} \
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index fb52b54..231c836 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -152,7 +152,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
>  
>  	/*
>  	 * We remember last_addr rather than next_addr to hit with
> -	 * mmap_cache most of the time. We have zero last_addr at
> +	 * vmacache most of the time. We have zero last_addr at
>  	 * the beginning and also after lseek. We will have -1 last_addr
>  	 * after the end of the vmas.
>  	 */
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 290901a..e8b90b0 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -342,13 +342,15 @@ struct mm_rss_stat {
>  
>  struct kioctx_table;
>  struct mm_struct {
> -	struct vm_area_struct * mmap;		/* list of VMAs */
> +	struct vm_area_struct *mmap;		/* list of VMAs */
>  	struct rb_root mm_rb;
> -	struct vm_area_struct * mmap_cache;	/* last find_vma result */
>  #ifdef CONFIG_MMU
> +	u32 vmacache_seqnum;                   /* per-thread vmacache */

Why is this not a seqcount with a standard check for read_seqbegin()
read_seqretry() when it gets updated?  It should have similar packing
(unsigned int) unless lockdep is enabled but barries to the ordering
of reads/writes to the counter are correct. There will be a performance
impact for mmap intensive workloads invaliding the cache but they already
are stuck behind mmap_sem for write anyway.

>  	unsigned long (*get_unmapped_area) (struct file *filp,
>  				unsigned long addr, unsigned long len,
>  				unsigned long pgoff, unsigned long flags);
> +#else
> +	struct vm_area_struct *vmacache;	/* last find_vma result */
>  #endif
>  	unsigned long mmap_base;		/* base of mmap area */
>  	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index a781dec..09dd1ff 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -23,6 +23,7 @@ struct sched_param {
>  #include <linux/errno.h>
>  #include <linux/nodemask.h>
>  #include <linux/mm_types.h>
> +#include <linux/vmacache.h>
>  #include <linux/preempt_mask.h>
>  
>  #include <asm/page.h>
> @@ -1228,6 +1229,10 @@ struct task_struct {
>  #ifdef CONFIG_COMPAT_BRK
>  	unsigned brk_randomized:1;
>  #endif
> +#ifdef CONFIG_MMU
> +	u32 vmacache_seqnum;
> +	struct vm_area_struct *vmacache[VMACACHE_SIZE];
> +#endif

Comment that this is a per-thread cache of a number of VMAs to cache
lookups for workloads with poor locality.

>  #if defined(SPLIT_RSS_COUNTING)
>  	struct task_rss_stat	rss_stat;
>  #endif
> diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
> new file mode 100644
> index 0000000..4fb7841
> --- /dev/null
> +++ b/include/linux/vmacache.h
> @@ -0,0 +1,24 @@
> +#ifndef __LINUX_VMACACHE_H
> +#define __LINUX_VMACACHE_H
> +
> +#include <linux/mm.h>
> +
> +#define VMACACHE_SIZE 4
> +

Why 4?

> +extern void vmacache_invalidate_all(void);
> +
> +static inline void vmacache_invalidate(struct mm_struct *mm)
> +{
> +	mm->vmacache_seqnum++;
> +
> +	/* deal with overflows */
> +	if (unlikely(mm->vmacache_seqnum == 0))
> +		vmacache_invalidate_all();
> +}

Why does an overflow require that all vmacaches be invalidated globally?
The cache is invalid in the event of a simple mismatch, overflow is
unimportant and I do not see why one mm seqcount overflowing would
affect every thread in the system.

> +
> +extern void vmacache_update(struct mm_struct *mm, unsigned long addr,
> +			    struct vm_area_struct *newvma);
> +extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> +					    unsigned long addr);
> +
> +#endif /* __LINUX_VMACACHE_H */
> diff --git a/kernel/debug/debug_core.c b/kernel/debug/debug_core.c
> index 334b398..fefc055 100644
> --- a/kernel/debug/debug_core.c
> +++ b/kernel/debug/debug_core.c
> @@ -224,10 +224,12 @@ static void kgdb_flush_swbreak_addr(unsigned long addr)
>  	if (!CACHE_FLUSH_IS_SAFE)
>  		return;
>  
> -	if (current->mm && current->mm->mmap_cache) {
> -		flush_cache_range(current->mm->mmap_cache,
> +#ifndef CONFIG_MMU
> +	if (current->mm && current->mm->vmacache) {
> +		flush_cache_range(current->mm->vmacache,
>  				  addr, addr + BREAK_INSTR_SIZE);
>  	}
> +#endif

What's this CONFIG_MMU check about? It looks very suspicious.

>  	/* Force flush instruction cache if it was outside the mm */
>  	flush_icache_range(addr, addr + BREAK_INSTR_SIZE);
>  }
> diff --git a/kernel/fork.c b/kernel/fork.c
> index a17621c..14396bf 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -363,7 +363,12 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  
>  	mm->locked_vm = 0;
>  	mm->mmap = NULL;
> -	mm->mmap_cache = NULL;
> +	mm->vmacache_seqnum = oldmm->vmacache_seqnum + 1;
> +

This is going to be an unrelated mm, why not just set it to 0 and ignore
the oldmm values entirely?

> +	/* deal with overflows */
> +	if (unlikely(mm->vmacache_seqnum == 0))
> +		vmacache_invalidate_all();
> +

Same comments about the other global invalidation apply.

>  	mm->map_count = 0;
>  	cpumask_clear(mm_cpumask(mm));
>  	mm->mm_rb = RB_ROOT;
> diff --git a/mm/Makefile b/mm/Makefile
> index 310c90a..2bb5b6a 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -5,7 +5,7 @@
>  mmu-y			:= nommu.o
>  mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
>  			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
> -			   vmalloc.o pagewalk.o pgtable-generic.o
> +			   vmalloc.o pagewalk.o pgtable-generic.o vmacache.o
>  
>  ifdef CONFIG_CROSS_MEMORY_ATTACH
>  mmu-$(CONFIG_MMU)	+= process_vm_access.o
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 20ff0c3..dfd7fe7 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -681,8 +681,9 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
>  	prev->vm_next = next = vma->vm_next;
>  	if (next)
>  		next->vm_prev = prev;
> -	if (mm->mmap_cache == vma)
> -		mm->mmap_cache = prev;
> +
> +	/* Kill the cache */
> +	vmacache_invalidate(mm);

Why not

if (mm->mmap_cache == vma)
	vmacache_update(mm, vma->vm_start, prev)

or seeing as there was no actual hit just

	vmacache_update(mm, vma->vm_start, NULL)

>  }
>  
>  /*
> @@ -1989,34 +1990,33 @@ EXPORT_SYMBOL(get_unmapped_area);
>  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
>  struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>  {
> -	struct vm_area_struct *vma = NULL;
> +	struct rb_node *rb_node;
> +	struct vm_area_struct *vma;
>  
>  	/* Check the cache first. */
> -	/* (Cache hit rate is typically around 35%.) */
> -	vma = ACCESS_ONCE(mm->mmap_cache);
> -	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
> -		struct rb_node *rb_node;
> +	vma = vmacache_find(mm, addr);
> +	if (likely(vma))
> +		return vma;
>  
> -		rb_node = mm->mm_rb.rb_node;
> -		vma = NULL;
> +	rb_node = mm->mm_rb.rb_node;
> +	vma = NULL;
>  
> -		while (rb_node) {
> -			struct vm_area_struct *vma_tmp;
> -
> -			vma_tmp = rb_entry(rb_node,
> -					   struct vm_area_struct, vm_rb);
> -
> -			if (vma_tmp->vm_end > addr) {
> -				vma = vma_tmp;
> -				if (vma_tmp->vm_start <= addr)
> -					break;
> -				rb_node = rb_node->rb_left;
> -			} else
> -				rb_node = rb_node->rb_right;
> -		}
> -		if (vma)
> -			mm->mmap_cache = vma;
> +	while (rb_node) {
> +		struct vm_area_struct *tmp;
> +
> +		tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> +
> +		if (tmp->vm_end > addr) {
> +			vma = tmp;
> +			if (tmp->vm_start <= addr)
> +				break;
> +			rb_node = rb_node->rb_left;
> +		} else
> +			rb_node = rb_node->rb_right;
>  	}
> +
> +	if (vma)
> +		vmacache_update(mm, addr, vma);
>  	return vma;
>  }
>  
> @@ -2388,7 +2388,9 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>  	} else
>  		mm->highest_vm_end = prev ? prev->vm_end : 0;
>  	tail_vma->vm_next = NULL;
> -	mm->mmap_cache = NULL;		/* Kill the cache. */
> +
> +	/* Kill the cache */
> +	vmacache_invalidate(mm);
>  }
>  
>  /*
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 8740213..c2d1b92 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -776,8 +776,8 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
>  	protect_vma(vma, 0);
>  
>  	mm->map_count--;
> -	if (mm->mmap_cache == vma)
> -		mm->mmap_cache = NULL;
> +	if (mm->vmacache == vma)
> +		mm->vmacache = NULL;
>  
>  	/* remove the VMA from the mapping */
>  	if (vma->vm_file) {
> @@ -825,7 +825,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>  	struct vm_area_struct *vma;
>  
>  	/* check the cache first */
> -	vma = ACCESS_ONCE(mm->mmap_cache);
> +	vma = ACCESS_ONCE(mm->vmacache);
>  	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
>  		return vma;
>  
> @@ -835,7 +835,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>  		if (vma->vm_start > addr)
>  			return NULL;
>  		if (vma->vm_end > addr) {
> -			mm->mmap_cache = vma;
> +			mm->vmacache = vma;
>  			return vma;
>  		}
>  	}
> @@ -874,7 +874,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
>  	unsigned long end = addr + len;
>  
>  	/* check the cache first */
> -	vma = mm->mmap_cache;
> +	vma = mm->vmacache;
>  	if (vma && vma->vm_start == addr && vma->vm_end == end)
>  		return vma;
>  
> @@ -886,7 +886,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
>  		if (vma->vm_start > addr)
>  			return NULL;
>  		if (vma->vm_end == end) {
> -			mm->mmap_cache = vma;
> +			mm->vmacache = vma;
>  			return vma;
>  		}
>  	}
> diff --git a/mm/vmacache.c b/mm/vmacache.c
> new file mode 100644
> index 0000000..d577ad3
> --- /dev/null
> +++ b/mm/vmacache.c
> @@ -0,0 +1,69 @@
> +#include <linux/sched.h>
> +#include <linux/vmacache.h>
> +
> +void vmacache_invalidate_all(void)
> +{
> +	struct task_struct *g, *p;
> +
> +	rcu_read_lock();
> +	for_each_process_thread(g, p) {
> +		/*
> +		 * Only flush the vmacache pointers as the
> +		 * mm seqnum is already set and curr's will
> +		 * be set upon invalidation when the next
> +		 * lookup is done.
> +		 */
> +		memset(p->vmacache, 0, sizeof(p->vmacache));
> +	}
> +	rcu_read_unlock();
> +}
> +

Still don't get why this is necessary :(


> +static bool vmacache_valid(struct mm_struct *mm)
> +{
> +	struct task_struct *curr = current;
> +
> +	if (mm != curr->mm)
> +		return false;
> +
> +	if (mm->vmacache_seqnum != curr->vmacache_seqnum) {
> +		/*
> +		 * First attempt will always be invalid, initialize the
> +		 * new cache for this task here.
> +		 */
> +		curr->vmacache_seqnum = mm->vmacache_seqnum;
> +		memset(curr->vmacache, 0, sizeof(curr->vmacache));
> +		return false;
> +	}
> +	return true;
> +}

So if you converted to a standard seqcount, it would simply be a case that
instread of a retry loop that you'd return false without looping.

> +
> +struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> +				     unsigned long addr)
> +
> +{
> +	int i;
> +
> +	if (!vmacache_valid(mm))
> +		return NULL;
> +
> +	for (i = 0; i < VMACACHE_SIZE; i++) {
> +		struct vm_area_struct *vma = current->vmacache[i];
> +
> +		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> +			return vma;
> +	}
> +
> +	return NULL;
> +}

vmacache_update does a hashed lookup but the find does a linear search.
I expect this is necessary because the hashing address could have been
anywhere in the VMA as could the lookup. It's obvious but no harm in
adding a comment.

> +
> +void vmacache_update(struct mm_struct *mm, unsigned long addr,
> +		     struct vm_area_struct *newvma)
> +{
> +	/*
> +	 * Hash based on the page number. Provides a good
> +	 * hit rate for workloads with good locality and
> +	 * those with random accesses as well.
> +	 */
> +	int idx = (addr >> PAGE_SHIFT) & 3;
> +	current->vmacache[idx] = newvma;
> +}

The changelog claims this is LRU. Where is the LRU? It looks more a
pseudo-random replacement policy. Nothing wrong with that as such, LRU
might take longer to calculate than is worthwhile.

3 looks wrong here. Should be & (VMACACHE_SIZE-1) and then either
express VMACACHE_SIZE in terms of a shift or hope someone does not set
it to 5 and wonder what went wrong.

I see you calculated hit rates for your changelog. How about adding
tracepoints for vmacache_find() hit and misses in a follow-up patch so it
can be recalculated with ftrace without debugging patches?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
