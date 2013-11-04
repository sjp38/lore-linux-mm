Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F2A4E6B0035
	for <linux-mm@kvack.org>; Sun,  3 Nov 2013 23:20:19 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kq14so6425525pab.21
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 20:20:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id i8si443143paa.39.2013.11.03.20.20.18
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 20:20:18 -0800 (PST)
Message-ID: <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: cache largest vma
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 03 Nov 2013 20:20:10 -0800
In-Reply-To: <20131103101234.GB5330@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
	 <20131103101234.GB5330@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, 2013-11-03 at 11:12 +0100, Ingo Molnar wrote:
> * Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > While caching the last used vma already does a nice job avoiding
> > having to iterate the rbtree in find_vma, we can improve. After
> > studying the hit rate on a load of workloads and environments,
> > it was seen that it was around 45-50% - constant for a standard
> > desktop system (gnome3 + evolution + firefox + a few xterms),
> > and multiple java related workloads (including Hadoop/terasort),
> > and aim7, which indicates it's better than the 35% value documented
> > in the code.
> > 
> > By also caching the largest vma, that is, the one that contains
> > most addresses, there is a steady 10-15% hit rate gain, putting
> > it above the 60% region. This improvement comes at a very low
> > overhead for a miss. Furthermore, systems with !CONFIG_MMU keep
> > the current logic.
> > 
> > This patch introduces a second mmap_cache pointer, which is just
> > as racy as the first, but as we already know, doesn't matter in
> > this context. For documentation purposes, I have also added the
> > ACCESS_ONCE() around mm->mmap_cache updates, keeping it consistent
> > with the reads.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Michel Lespinasse <walken@google.com>
> > Cc: Ingo Molnar <mingo@kernel.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > ---
> > Please note that nommu and unicore32 arch are *untested*.
> > 
> > I also have a patch on top of this one that caches the most 
> > used vma, which adds another 8-10% hit rate gain, However,
> > since it does add a counter to the vma structure and we have
> > to do more logic in find_vma to keep track, I was hesitant about
> > the overhead. If folks are interested I can send that out as well.
> 
> Would be interesting to see.
> 
> Btw., roughly how many cycles/instructions do we save by increasing the 
> hit rate, in the typical case (for example during a kernel build)?

Good point. The IPC from perf stat doesn't show any difference with or
without the patch -- note that this is probably the least interesting
one as we already get a really nice hit rate with the single mmap_cache.
I have yet to try it on the other workloads.

> 
> That would be important to measure, so that we can get a ballpark figure 
> for the cost/benefit equation.
> 
> >  Documentation/vm/locking                 |  4 +-
> >  arch/unicore32/include/asm/mmu_context.h |  2 +-
> >  include/linux/mm.h                       | 13 ++++++
> >  include/linux/mm_types.h                 | 15 ++++++-
> >  kernel/debug/debug_core.c                | 17 +++++++-
> >  kernel/fork.c                            |  2 +-
> >  mm/mmap.c                                | 68 ++++++++++++++++++++------------
> >  7 files changed, 87 insertions(+), 34 deletions(-)
> > 
> > diff --git a/Documentation/vm/locking b/Documentation/vm/locking
> > index f61228b..b4e8154 100644
> > --- a/Documentation/vm/locking
> > +++ b/Documentation/vm/locking
> > @@ -42,8 +42,8 @@ The rules are:
> >     for mm B.
> >  
> >  The caveats are:
> > -1. find_vma() makes use of, and updates, the mmap_cache pointer hint.
> > -The update of mmap_cache is racy (page stealer can race with other code
> > +1. find_vma() makes use of, and updates, the mmap_cache pointers hint.
> > +The updates of mmap_cache is racy (page stealer can race with other code
> >  that invokes find_vma with mmap_sem held), but that is okay, since it 
> >  is a hint. This can be fixed, if desired, by having find_vma grab the
> >  page_table_lock.
> > diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
> > index fb5e4c6..38cc7fc 100644
> > --- a/arch/unicore32/include/asm/mmu_context.h
> > +++ b/arch/unicore32/include/asm/mmu_context.h
> > @@ -73,7 +73,7 @@ do { \
> >  		else \
> >  			mm->mmap = NULL; \
> >  		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
> > -		mm->mmap_cache = NULL; \
> > +		vma_clear_caches(mm);			\
> >  		mm->map_count--; \
> >  		remove_vma(high_vma); \
> >  	} \
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 8b6e55e..2c0f8ed 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1534,8 +1534,21 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
> >  	/* Ignore errors */
> >  	(void) __mm_populate(addr, len, 1);
> >  }
> > +
> > +static inline void vma_clear_caches(struct mm_struct *mm)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < NR_VMA_CACHES; i++)
> > +		mm->mmap_cache[i] = NULL;
> 
> Just curious: does GCC manage to open-code this as two stores of NULL?
> 
> > +}
> >  #else
> >  static inline void mm_populate(unsigned long addr, unsigned long len) {}
> > +
> > +static inline void vma_clear_caches(struct mm_struct *mm)
> 1> +{
> > +	mm->mmap_cache = NULL;
> > +}
> >  #endif
> >  
> >  /* These take the mm semaphore themselves */
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index d9851ee..7f92835 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -322,12 +322,23 @@ struct mm_rss_stat {
> >  	atomic_long_t count[NR_MM_COUNTERS];
> >  };
> >  
> > +
> > +#ifdef CONFIG_MMU
> > +enum {
> > +	VMA_LAST_USED, /* last find_vma result */
> > +	VMA_LARGEST,   /* vma that contains most address */
> > +	NR_VMA_CACHES
> > +};
> > +#endif
> > +
> >  struct kioctx_table;
> >  struct mm_struct {
> >  	struct vm_area_struct * mmap;		/* list of VMAs */
> >  	struct rb_root mm_rb;
> > -	struct vm_area_struct * mmap_cache;	/* last find_vma result */
> > -#ifdef CONFIG_MMU
> > +#ifndef CONFIG_MMU
> > +	struct vm_area_struct *mmap_cache;      /* last find_vma result */
> > +#else
> > +	struct vm_area_struct *mmap_cache[NR_VMA_CACHES];
> 
> I think the CONFIG_MMU assymetry in the data structure is rather ugly.
> 
> Why not make it a single-entry enum in the !CONFIG_MMU case? To the 
> compiler a single-entry array should be the same as a pointer field.
> 
> That would eliminate most of the related #ifdefs AFAICS.

Yes that's a lot better.

> 
> >  	unsigned long (*get_unmapped_area) (struct file *filp,
> >  				unsigned long addr, unsigned long len,
> >  				unsigned long pgoff, unsigned long flags);
> > diff --git a/kernel/debug/debug_core.c b/kernel/debug/debug_core.c
> > index 0506d44..d9d72e4 100644
> > --- a/kernel/debug/debug_core.c
> > +++ b/kernel/debug/debug_core.c
> > @@ -221,13 +221,26 @@ int __weak kgdb_skipexception(int exception, struct pt_regs *regs)
> >   */
> >  static void kgdb_flush_swbreak_addr(unsigned long addr)
> >  {
> > +	struct mm_struct *mm = current->mm;
> >  	if (!CACHE_FLUSH_IS_SAFE)
> >  		return;
> >  
> > -	if (current->mm && current->mm->mmap_cache) {
> > -		flush_cache_range(current->mm->mmap_cache,
> > +#ifdef CONFIG_MMU
> > +	if (mm) {
> > +		int i;
> > +
> > +		for (i = 0; i < NR_VMA_CACHES; i++)
> > +			if (mm->mmap_cache[i])
> > +				flush_cache_range(mm->mmap_cache[i],
> > +						  addr,
> > +						  addr + BREAK_INSTR_SIZE);
> 
> (Nit: please use curly braces for for such multi-line statements.)
> 
> > +	}
> > +#else
> > +	if (mm && mm->mmap_cache) {
> > +		flush_cache_range(mm->mmap_cache,
> >  				  addr, addr + BREAK_INSTR_SIZE);
> >  	}
> > +#endif
> 
> Btw., this #ifdef would be unified with my suggested data structure 
> variant as well.
> 
> >  	/* Force flush instruction cache if it was outside the mm */
> >  	flush_icache_range(addr, addr + BREAK_INSTR_SIZE);
> >  }
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 086fe73..7b92666 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -363,8 +363,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
> >  
> >  	mm->locked_vm = 0;
> >  	mm->mmap = NULL;
> > -	mm->mmap_cache = NULL;
> >  	mm->map_count = 0;
> > +	vma_clear_caches(mm);
> >  	cpumask_clear(mm_cpumask(mm));
> >  	mm->mm_rb = RB_ROOT;
> >  	rb_link = &mm->mm_rb.rb_node;
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 9d54851..29c3fc0 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -676,14 +676,17 @@ static inline void
> >  __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		struct vm_area_struct *prev)
> >  {
> > +	int i;
> >  	struct vm_area_struct *next;
> >  
> >  	vma_rb_erase(vma, &mm->mm_rb);
> >  	prev->vm_next = next = vma->vm_next;
> >  	if (next)
> >  		next->vm_prev = prev;
> > -	if (mm->mmap_cache == vma)
> > -		mm->mmap_cache = prev;
> > +
> > +	for (i = 0; i < NR_VMA_CACHES; i++)
> > +		if (mm->mmap_cache[i] == vma)
> > +			mm->mmap_cache[i] = prev;
> 
> (Nit: missing curly braces.)
> 
> Also, I don't think setting the cache value back to 'prev' is valid in the 
> VMA_LARGEST case. The likelihood that it's the second largest VMA is 
> remote.
> 
> The right action here would be to set it to NULL.
> 
> For VMA_LAST_USED setting it to 'prev' seems justified.
> 
> >  }
> >  
> >  /*
> > @@ -1972,34 +1975,47 @@ EXPORT_SYMBOL(get_unmapped_area);
> >  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
> >  struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
> >  {
> > +	unsigned long currlen = 0;
> 
> (Nit: I don't think 'currlen' really explains the role of the variable. 
> 'max_len' would be better?)
> 
> > +	struct rb_node *rb_node;
> >  	struct vm_area_struct *vma = NULL;
> >  
> > -	/* Check the cache first. */
> > -	/* (Cache hit rate is typically around 35%.) */
> > -	vma = ACCESS_ONCE(mm->mmap_cache);
> > -	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
> > -		struct rb_node *rb_node;
> > +	/* Check the cache first */
> > +	vma = ACCESS_ONCE(mm->mmap_cache[VMA_LAST_USED]);
> > +	if (vma && vma->vm_end > addr && vma->vm_start <= addr)
> > +		goto ret;
> >  
> > -		rb_node = mm->mm_rb.rb_node;
> > -		vma = NULL;
> > +	vma = ACCESS_ONCE(mm->mmap_cache[VMA_LARGEST]);
> > +	if (vma) {
> > +		if (vma->vm_end > addr && vma->vm_start <= addr)
> > +			goto ret;
> > +		currlen = vma->vm_end - vma->vm_start;
> > +	}
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
> > +	/* Bad cache! iterate rbtree */
> 
> (Nit: the cache is not 'bad', we just didn't hit it.)
> 
> > +	rb_node = mm->mm_rb.rb_node;
> > +	vma = NULL;
> > +
> > +	while (rb_node) {
> > +		struct vm_area_struct *vma_tmp;
> > +
> > +		vma_tmp = rb_entry(rb_node,
> > +				   struct vm_area_struct, vm_rb);
> 
> (Nit: in such cases a single, slightly-longer-than-80col line is IMHO a 
> better solution than such an artificial line-break.)
> 
> > +
> > +		if (vma_tmp->vm_end > addr) {
> > +			vma = vma_tmp;
> > +			if (vma_tmp->vm_start <= addr)
> > +				break;
> > +			rb_node = rb_node->rb_left;
> > +		} else
> > +			rb_node = rb_node->rb_right;
> 
> (Nit: unbalanced curly braces.)
> 
> > +	}
> > +
> > +	if (vma) {
> > +		ACCESS_ONCE(mm->mmap_cache[VMA_LAST_USED]) = vma;
> > +		if (vma->vm_end - vma->vm_start > currlen)
> > +			ACCESS_ONCE(mm->mmap_cache[VMA_LARGEST]) = vma;
> 
> Would it make sense to not update VMA_LAST_USED if VMA_LARGEST is set?
> 
> This would have the advantage of increasing the cache size to two, for the 
> common case where there's two vmas used most of the time.
> 
> To maximize the hit rate in the general case what we basically want to 
> have is an LRU cache, weighted by vma size.
> 
> Maybe by expressing it all in that fashion and looking at the hit rate at 
> 1, 2, 3 and 4 entries would give us equivalent (or better!) behavior than 
> your open-coded variant, with a better idea about how to size it 
> precisely.
> 
> Note that that approach would get rid of the VMA_LAST_USED/VMA_LARGEST 
> distinction in a natural fashion.
> 
> Obviously, if the LRU logic gets too complex then it probably won't bring 
> us any benefits compared to a primitive front-entry cache, so all this is 
> a delicate balance ... hence my previous question about 
> cycles/instructions saved by hitting the cache.

Will try this, thanks for the suggestions.

Btw, do you suggest using a high level tool such as perf for getting
this data or sprinkling get_cycles() in find_vma() -- I'd think that the
first isn't fine grained enough, while the later will probably variate a
lot from run to run but the ratio should be rather constant.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
