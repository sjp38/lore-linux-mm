Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f53.google.com (mail-oa0-f53.google.com [209.85.219.53])
	by kanga.kvack.org (Postfix) with ESMTP id CC9A06B009C
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 14:11:50 -0500 (EST)
Received: by mail-oa0-f53.google.com with SMTP id o6so1331904oag.40
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 11:11:50 -0800 (PST)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id e6si2597156oen.127.2014.02.26.11.11.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 11:11:49 -0800 (PST)
Message-ID: <1393441904.25123.17.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 26 Feb 2014 11:11:44 -0800
In-Reply-To: <20140226112603.GA6732@suse.de>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	 <20140226112603.GA6732@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-02-26 at 11:26 +0000, Mel Gorman wrote:
> On Tue, Feb 25, 2014 at 10:16:46AM -0800, Davidlohr Bueso wrote:
> > 
> >  struct kioctx_table;
> >  struct mm_struct {
> > -	struct vm_area_struct * mmap;		/* list of VMAs */
> > +	struct vm_area_struct *mmap;		/* list of VMAs */
> >  	struct rb_root mm_rb;
> > -	struct vm_area_struct * mmap_cache;	/* last find_vma result */
> >  #ifdef CONFIG_MMU
> > +	u32 vmacache_seqnum;                   /* per-thread vmacache */
> 
> Why is this not a seqcount with a standard check for read_seqbegin()
> read_seqretry() when it gets updated?  It should have similar packing
> (unsigned int) unless lockdep is enabled but barries to the ordering
> of reads/writes to the counter are correct. There will be a performance
> impact for mmap intensive workloads invaliding the cache but they already
> are stuck behind mmap_sem for write anyway.

We need invalidations to be super fast. This alternative defeats the
purpose. If we bloat the caching with such things is simply not worth it
as the latency of find_vma() increases compared to mm->mmap_cache.

> 
> >  	unsigned long (*get_unmapped_area) (struct file *filp,
> >  				unsigned long addr, unsigned long len,
> >  				unsigned long pgoff, unsigned long flags);
> > +#else
> > +	struct vm_area_struct *vmacache;	/* last find_vma result */
> >  #endif
> >  	unsigned long mmap_base;		/* base of mmap area */
> >  	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index a781dec..09dd1ff 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -23,6 +23,7 @@ struct sched_param {
> >  #include <linux/errno.h>
> >  #include <linux/nodemask.h>
> >  #include <linux/mm_types.h>
> > +#include <linux/vmacache.h>
> >  #include <linux/preempt_mask.h>
> >  
> >  #include <asm/page.h>
> > @@ -1228,6 +1229,10 @@ struct task_struct {
> >  #ifdef CONFIG_COMPAT_BRK
> >  	unsigned brk_randomized:1;
> >  #endif
> > +#ifdef CONFIG_MMU
> > +	u32 vmacache_seqnum;
> > +	struct vm_area_struct *vmacache[VMACACHE_SIZE];
> > +#endif
> 
> Comment that this is a per-thread cache of a number of VMAs to cache
> lookups for workloads with poor locality.

ok

> 
> >  #if defined(SPLIT_RSS_COUNTING)
> >  	struct task_rss_stat	rss_stat;
> >  #endif
> > diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
> > new file mode 100644
> > index 0000000..4fb7841
> > --- /dev/null
> > +++ b/include/linux/vmacache.h
> > @@ -0,0 +1,24 @@
> > +#ifndef __LINUX_VMACACHE_H
> > +#define __LINUX_VMACACHE_H
> > +
> > +#include <linux/mm.h>
> > +
> > +#define VMACACHE_SIZE 4
> > +
> 
> Why 4?

Not too small, not too big. Testing showed it provided good enough
balance.

> 
> > +extern void vmacache_invalidate_all(void);
> > +
> > +static inline void vmacache_invalidate(struct mm_struct *mm)
> > +{
> > +	mm->vmacache_seqnum++;
> > +
> > +	/* deal with overflows */
> > +	if (unlikely(mm->vmacache_seqnum == 0))
> > +		vmacache_invalidate_all();
> > +}
> 
> Why does an overflow require that all vmacaches be invalidated globally?
> The cache is invalid in the event of a simple mismatch, overflow is
> unimportant and I do not see why one mm seqcount overflowing would
> affect every thread in the system.

Yes, this is only affects threads sharing the same mm, updating it.

> > +
> > +extern void vmacache_update(struct mm_struct *mm, unsigned long addr,
> > +			    struct vm_area_struct *newvma);
> > +extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> > +					    unsigned long addr);
> > +
> > +#endif /* __LINUX_VMACACHE_H */
> > diff --git a/kernel/debug/debug_core.c b/kernel/debug/debug_core.c
> > index 334b398..fefc055 100644
> > --- a/kernel/debug/debug_core.c
> > +++ b/kernel/debug/debug_core.c
> > @@ -224,10 +224,12 @@ static void kgdb_flush_swbreak_addr(unsigned long addr)
> >  	if (!CACHE_FLUSH_IS_SAFE)
> >  		return;
> >  
> > -	if (current->mm && current->mm->mmap_cache) {
> > -		flush_cache_range(current->mm->mmap_cache,
> > +#ifndef CONFIG_MMU
> > +	if (current->mm && current->mm->vmacache) {
> > +		flush_cache_range(current->mm->vmacache,
> >  				  addr, addr + BREAK_INSTR_SIZE);
> >  	}
> > +#endif
> 
> What's this CONFIG_MMU check about? It looks very suspicious.

This was part of the ugliness of two different schemes for different
configs. This is also out the window and v3 will provide per-thread
caching for both setups.

> 
> >  	/* Force flush instruction cache if it was outside the mm */
> >  	flush_icache_range(addr, addr + BREAK_INSTR_SIZE);
> >  }
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index a17621c..14396bf 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -363,7 +363,12 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
> >  
> >  	mm->locked_vm = 0;
> >  	mm->mmap = NULL;
> > -	mm->mmap_cache = NULL;
> > +	mm->vmacache_seqnum = oldmm->vmacache_seqnum + 1;
> > +
> 
> This is going to be an unrelated mm, why not just set it to 0 and ignore
> the oldmm values entirely?

Yep, that will be in v3.

> 
> > +	/* deal with overflows */
> > +	if (unlikely(mm->vmacache_seqnum == 0))
> > +		vmacache_invalidate_all();
> > +
> 
> Same comments about the other global invalidation apply.
> 
> >  	mm->map_count = 0;
> >  	cpumask_clear(mm_cpumask(mm));
> >  	mm->mm_rb = RB_ROOT;
> > diff --git a/mm/Makefile b/mm/Makefile
> > index 310c90a..2bb5b6a 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
> > @@ -5,7 +5,7 @@
> >  mmu-y			:= nommu.o
> >  mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
> >  			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
> > -			   vmalloc.o pagewalk.o pgtable-generic.o
> > +			   vmalloc.o pagewalk.o pgtable-generic.o vmacache.o
> >  
> >  ifdef CONFIG_CROSS_MEMORY_ATTACH
> >  mmu-$(CONFIG_MMU)	+= process_vm_access.o
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 20ff0c3..dfd7fe7 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -681,8 +681,9 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	prev->vm_next = next = vma->vm_next;
> >  	if (next)
> >  		next->vm_prev = prev;
> > -	if (mm->mmap_cache == vma)
> > -		mm->mmap_cache = prev;
> > +
> > +	/* Kill the cache */
> > +	vmacache_invalidate(mm);
> 
> Why not
> 
> if (mm->mmap_cache == vma)
> 	vmacache_update(mm, vma->vm_start, prev)
> 
> or seeing as there was no actual hit just
> 
> 	vmacache_update(mm, vma->vm_start, NULL)
> 

That would cost more than just incrementing the seqnum. Saving cycles is
paramount here.

> >  }
> >  
> >  /*
> > @@ -1989,34 +1990,33 @@ EXPORT_SYMBOL(get_unmapped_area);
> >  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
> >  struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> >  {
> > -	struct vm_area_struct *vma = NULL;
> > +	struct rb_node *rb_node;
> > +	struct vm_area_struct *vma;
> >  
> >  	/* Check the cache first. */
> > -	/* (Cache hit rate is typically around 35%.) */
> > -	vma = ACCESS_ONCE(mm->mmap_cache);
> > -	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
> > -		struct rb_node *rb_node;
> > +	vma = vmacache_find(mm, addr);
> > +	if (likely(vma))
> > +		return vma;
> >  
> > -		rb_node = mm->mm_rb.rb_node;
> > -		vma = NULL;
> > +	rb_node = mm->mm_rb.rb_node;
> > +	vma = NULL;
> >  
> > -		while (rb_node) {
> > -			struct vm_area_struct *vma_tmp;
> > -
> > -			vma_tmp = rb_entry(rb_node,
> > -					   struct vm_area_struct, vm_rb);
> > -
> > -			if (vma_tmp->vm_end > addr) {
> > -				vma = vma_tmp;
> > -				if (vma_tmp->vm_start <= addr)
> > -					break;
> > -				rb_node = rb_node->rb_left;
> > -			} else
> > -				rb_node = rb_node->rb_right;
> > -		}
> > -		if (vma)
> > -			mm->mmap_cache = vma;
> > +	while (rb_node) {
> > +		struct vm_area_struct *tmp;
> > +
> > +		tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> > +
> > +		if (tmp->vm_end > addr) {
> > +			vma = tmp;
> > +			if (tmp->vm_start <= addr)
> > +				break;
> > +			rb_node = rb_node->rb_left;
> > +		} else
> > +			rb_node = rb_node->rb_right;
> >  	}
> > +
> > +	if (vma)
> > +		vmacache_update(mm, addr, vma);
> >  	return vma;
> >  }
> >  
> > @@ -2388,7 +2388,9 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	} else
> >  		mm->highest_vm_end = prev ? prev->vm_end : 0;
> >  	tail_vma->vm_next = NULL;
> > -	mm->mmap_cache = NULL;		/* Kill the cache. */
> > +
> > +	/* Kill the cache */
> > +	vmacache_invalidate(mm);
> >  }
> >  
> >  /*
> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index 8740213..c2d1b92 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -776,8 +776,8 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
> >  	protect_vma(vma, 0);
> >  
> >  	mm->map_count--;
> > -	if (mm->mmap_cache == vma)
> > -		mm->mmap_cache = NULL;
> > +	if (mm->vmacache == vma)
> > +		mm->vmacache = NULL;
> >  
> >  	/* remove the VMA from the mapping */
> >  	if (vma->vm_file) {
> > @@ -825,7 +825,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> >  	struct vm_area_struct *vma;
> >  
> >  	/* check the cache first */
> > -	vma = ACCESS_ONCE(mm->mmap_cache);
> > +	vma = ACCESS_ONCE(mm->vmacache);
> >  	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> >  		return vma;
> >  
> > @@ -835,7 +835,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> >  		if (vma->vm_start > addr)
> >  			return NULL;
> >  		if (vma->vm_end > addr) {
> > -			mm->mmap_cache = vma;
> > +			mm->vmacache = vma;
> >  			return vma;
> >  		}
> >  	}
> > @@ -874,7 +874,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
> >  	unsigned long end = addr + len;
> >  
> >  	/* check the cache first */
> > -	vma = mm->mmap_cache;
> > +	vma = mm->vmacache;
> >  	if (vma && vma->vm_start == addr && vma->vm_end == end)
> >  		return vma;
> >  
> > @@ -886,7 +886,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
> >  		if (vma->vm_start > addr)
> >  			return NULL;
> >  		if (vma->vm_end == end) {
> > -			mm->mmap_cache = vma;
> > +			mm->vmacache = vma;
> >  			return vma;
> >  		}
> >  	}
> > diff --git a/mm/vmacache.c b/mm/vmacache.c
> > new file mode 100644
> > index 0000000..d577ad3
> > --- /dev/null
> > +++ b/mm/vmacache.c
> > @@ -0,0 +1,69 @@
> > +#include <linux/sched.h>
> > +#include <linux/vmacache.h>
> > +
> > +void vmacache_invalidate_all(void)
> > +{
> > +	struct task_struct *g, *p;
> > +
> > +	rcu_read_lock();
> > +	for_each_process_thread(g, p) {
> > +		/*
> > +		 * Only flush the vmacache pointers as the
> > +		 * mm seqnum is already set and curr's will
> > +		 * be set upon invalidation when the next
> > +		 * lookup is done.
> > +		 */
> > +		memset(p->vmacache, 0, sizeof(p->vmacache));
> > +	}
> > +	rcu_read_unlock();
> > +}
> > +
> 
> Still don't get why this is necessary :(
> 
> 
> > +static bool vmacache_valid(struct mm_struct *mm)
> > +{
> > +	struct task_struct *curr = current;
> > +
> > +	if (mm != curr->mm)
> > +		return false;
> > +
> > +	if (mm->vmacache_seqnum != curr->vmacache_seqnum) {
> > +		/*
> > +		 * First attempt will always be invalid, initialize the
> > +		 * new cache for this task here.
> > +		 */
> > +		curr->vmacache_seqnum = mm->vmacache_seqnum;
> > +		memset(curr->vmacache, 0, sizeof(curr->vmacache));
> > +		return false;
> > +	}
> > +	return true;
> > +}
> 
> So if you converted to a standard seqcount, it would simply be a case that
> instread of a retry loop that you'd return false without looping.
> 
> > +
> > +struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> > +				     unsigned long addr)
> > +
> > +{
> > +	int i;
> > +
> > +	if (!vmacache_valid(mm))
> > +		return NULL;
> > +
> > +	for (i = 0; i < VMACACHE_SIZE; i++) {
> > +		struct vm_area_struct *vma = current->vmacache[i];
> > +
> > +		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> > +			return vma;
> > +	}
> > +
> > +	return NULL;
> > +}
> 
> vmacache_update does a hashed lookup but the find does a linear search.
> I expect this is necessary because the hashing address could have been
> anywhere in the VMA as could the lookup. It's obvious but no harm in
> adding a comment.
> 
> > +
> > +void vmacache_update(struct mm_struct *mm, unsigned long addr,
> > +		     struct vm_area_struct *newvma)
> > +{
> > +	/*
> > +	 * Hash based on the page number. Provides a good
> > +	 * hit rate for workloads with good locality and
> > +	 * those with random accesses as well.
> > +	 */
> > +	int idx = (addr >> PAGE_SHIFT) & 3;
> > +	current->vmacache[idx] = newvma;
> > +}
> 
> The changelog claims this is LRU. Where is the LRU? It looks more a
> pseudo-random replacement policy.

Fair enough, although it could be considered a sort of LRU on the page
num.

> Nothing wrong with that as such, LRU
> might take longer to calculate than is worthwhile.

Yes, a formal LRU was considered but keeping it sorted just caused too
much overhead.

> 
> 3 looks wrong here. Should be & (VMACACHE_SIZE-1) and then either
> express VMACACHE_SIZE in terms of a shift or hope someone does not set
> it to 5 and wonder what went wrong.

Yes.

> I see you calculated hit rates for your changelog. How about adding
> tracepoints for vmacache_find() hit and misses in a follow-up patch so it
> can be recalculated with ftrace without debugging patches?

I was planning on a follow up patch to add some vmstat counters, which
is what I used for this patch, for some debug config. I can look into
tracepoints instead.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
