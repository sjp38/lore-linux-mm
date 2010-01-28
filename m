Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D599D6B0083
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 17:38:05 -0500 (EST)
Date: Thu, 28 Jan 2010 23:36:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 31] transparent hugepage core
Message-ID: <20100128223653.GL1217@random.random>
References: <patchbomb.1264689194@v2.random>
 <ac9bbf9e2c95840eb237.1264689219@v2.random>
 <20100128175753.GF7139@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128175753.GF7139@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <hch@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 05:57:54PM +0000, Mel Gorman wrote:
> It occurs to me that this infrastructure should be reusable to make allow
> optional swapping of hugetlbfs. I haven't investigated the possibility properly
> but it should be doable as a mount option with maybe a boot-parameter for
> shared memory.

I thought it was higher prio to back tmpfs with this which is mounted
by default and used by more apps automatically. I'm not sure if it
makes sense to back hugetlbfs with this given the extra length it went
to avoid the regular VM fault paths while getting closer and closer in
features to the default VM paths but I'm not against it either, just a
thought.

> As I write this, I haven't read the patch but I suspect the default will
> depend on how mmap_sem is used. For example, if "always" means that down_read
> is called for longer periods of time then workloads that mmap() heavily or
> otherwise depend on down_write could suffer.

Note, page fault time goes down from >5 sec to <2 sec with lockdep and
debug (otherwise it's only 50% faster). So mmap_sem hold time will be
lower with "always". COWs are the only corner case that is a bit
slower on my systems because I've 2M cache and that thrashes on 4M
copy per fault... So even for totally short lived, mmap_sem hold time
can decrease -33% and the app run 50% faster (or 100% faster with
lockdep) even without mmap_sem contention at all. But for other apps
the cache trashing may slow it down a bit.

The main reason for "always" default is to be sure everybody is
stressing it. It can also be merged in mainline with default
madvise/madvise/madvise, that is fine by me, for now it has to be
always > enabled. Leaving "always" as a default like in my laptop
where I'm writing this, isn't insane but it's not a 100% guaranteed
speedup always because of the cache trashing. We've also to change the
copy/clear_huge to use non temporal stores, that might help.

> I think that's the first time I've ever heard OOM handling described as
> "fine" :)

Eheeh ;)

> FWIW, having read the available papers on transparent support, I agree that
> prefault logic is unlikely to be a proven win. The complexity and overhead of
> prefaulting are guaranteed and easy to measure. The benefits due to huge page
> usage are a "maybe", harder to prove and depend on the workload and hardware.

Full agreement. My prototype benchmark results showed it's a very gray
area. I want something that runs userland as fast as it can get in the
best case, not just 10/20/30% faster with the only benefit that it
trashes less cache. Because even if it trashes cache less, it will
still trash more of it than with the default 4k page-size... and we
don't get enough benefit in return (notably zero tlb benefits). I want
the full benefit in return immediately and max speedup for the best
case, the worst case is still going to run slower even with
prefault. Plus we can disable it and selectively enable if one has l2
cache issues. And the complexity of the code isn't even remotely
comparable...

> Using hugetlbfs with huge pages is also recognised to have significant costs
> during startup which is faulting in pages larger than 4K. In benchmarking,
> it can show up as huge pages hurting performance if the benchmark is too
> short-lived.

We'll see how it goes with this one.

> Will need Documentation/ updates at some point explaining these flags
> and how they apply to the transparent_hugepage= boot parameter.

I expect admins to fiddle with /sysfs with boot time scripts,
transparent_hugepage= I intended it more for a =0 and similar lowlevel
usage if people can't boot or something, so I don't see a need of
documentation other than the =0 setting, but we can document it.

> It's not overly important but as these are flags, it would have been
> more readable to just define them as 1, 2, 4, 8 etc rather than using
> 1<<TRANSPARENT_HUGEPAGE_X in so many places. i.e. similar to how GFP
> flags are defined and used. I know you use test_bit on these later but
> it's not clear you need the locked checks and could just use
> "if (flags & whatever)"

test_bit as lockless and as out of order as (flag & whatever). So only
the setting of the default value is annoying, but all other places
testing it are already as efficient and as short as possible I
think. The writing of the bits has to be atomic right now, and it's
faster than having to take locks (but writing is not important and
extremely rare this is why it's a read_mostly).

> Should these be defined by the architecture? I ask because your patch notes
> that architectures supporting huge pages at levels other than the PMD will
> have issues. On IA-64 for example, HPAGE_SHIFT can be set as a kernel boot
> parameter.
> 
> That said, these definitions work for the architecture that *is* supported.

There is no risk because nothing is going to ever use HPAGE_PMD_* if
TRANSPARENT_HUGEPAGE is not set. So as long as it builds... It's not
inside #ifdef because of this:

		next = pmd_addr_end(addr, end);
		if (pmd_trans_huge(*pmd)) {
			if (next-addr != HPAGE_PMD_SIZE)
				split_huge_page_vma(vma, pmd);
			else if (zap_huge_pmd(tlb, vma, pmd)) {
				(*zap_work)--;
				continue;
			}
			/* fall through */
		}

but pmd_trans_huge is defined to 0 at compile time, so HPAGE_PMD_SIZE
can be random. I guess I'll change it to this to avoid any possible
future risk:

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -42,11 +42,11 @@ extern pmd_t *page_check_address_pmd(str
 				     unsigned long address,
 				     enum page_check_address_pmd_flag flag);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define HPAGE_PMD_SHIFT HPAGE_SHIFT
 #define HPAGE_PMD_MASK HPAGE_MASK
 #define HPAGE_PMD_SIZE HPAGE_SIZE
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define transparent_hugepage_enabled(__vma)				\
 	(transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG) ||	\
 	 (transparent_hugepage_flags &				\
@@ -116,6 +116,10 @@ static inline int PageTransCompound(stru
 	return PageCompound(page);
 }
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define HPAGE_PMD_SHIFT ({ BUG(); 0; })
+#define HPAGE_PMD_MASK ({ BUG(); 0; })
+#define HPAGE_PMD_SIZE ({ BUG(); 0; })
+
 #define transparent_hugepage_enabled(__vma) 0
 #define transparent_hugepage_defrag(__vma) 0
 #define transparent_hugepage_debug_cow() 0


> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +#define transparent_hugepage_enabled(__vma)				\
> > +	(transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG) ||	\
> > +	 (transparent_hugepage_flags &				\
> > +	  (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&		\
> > +	  (__vma)->vm_flags & VM_HUGEPAGE))
> > +#define transparent_hugepage_defrag(__vma)			       \
> > +	(transparent_hugepage_flags &				       \
> > +	 (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG) ||		       \
> > +	 (transparent_hugepage_flags &				       \
> > +	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG) &&	       \
> > +	  (__vma)->vm_flags & VM_HUGEPAGE))
> > +#ifdef CONFIG_DEBUG_VM
> > +#define transparent_hugepage_debug_cow()				\
> > +	(transparent_hugepage_flags &					\
> > +	 (1<<TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG))
> > +#else /* CONFIG_DEBUG_VM */
> > +#define transparent_hugepage_debug_cow() 0
> > +#endif /* CONFIG_DEBUG_VM */
> > +
> > +extern unsigned long transparent_hugepage_flags;
> > +extern int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> > +			  pmd_t *dst_pmd, pmd_t *src_pmd,
> > +			  struct vm_area_struct *vma,
> > +			  unsigned long addr, unsigned long end);
> > +extern int handle_pte_fault(struct mm_struct *mm,
> > +			    struct vm_area_struct *vma, unsigned long address,
> > +			    pte_t *pte, pmd_t *pmd, unsigned int flags);
> > +extern void __split_huge_page_mm(struct mm_struct *mm, unsigned long address,
> > +				 pmd_t *pmd);
> > +extern void __split_huge_page_vma(struct vm_area_struct *vma, pmd_t *pmd);
> > +extern int split_huge_page(struct page *page);
> > +#define split_huge_page_mm(__mm, __addr, __pmd)				\
> > +	do {								\
> > +		if (unlikely(pmd_trans_huge(*(__pmd))))			\
> > +			__split_huge_page_mm(__mm, __addr, __pmd);	\
> > +	}  while (0)
> 
> I'm not sure what the current popular thing is but ...
> 
> __pmd is using in this #define twice. Hypothetically, if the third
> parameter passed to this function had side-effects (e.g. pmd++), then
> the expectation of the caller is that it happens once but in reality it
> happens twice due to the use of #define.
> 
> For this reason, I prefer to see static inlines instead of #defines where
> parameters appear more than once. Just because you do not have stupid
> callers doesn't mean that someone else will add one for you in the
> future.

problem is it won't all build without this, things like anon_vma
aren't defined. But you're right spotting that problem!

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -82,21 +82,24 @@ extern void __split_huge_page_vma(struct
 extern int split_huge_page(struct page *page);
 #define split_huge_page_mm(__mm, __addr, __pmd)				\
 	do {								\
-		if (unlikely(pmd_trans_huge(*(__pmd))))			\
-			__split_huge_page_mm(__mm, __addr, __pmd);	\
+		pmd_t ____pmd = __pmd;					\
+		if (unlikely(pmd_trans_huge(*(____pmd))))		\
+			__split_huge_page_mm(__mm, __addr, ____pmd);	\
 	}  while (0)
 #define split_huge_page_vma(__vma, __pmd)				\
 	do {								\
-		if (unlikely(pmd_trans_huge(*(__pmd))))			\
-			__split_huge_page_vma(__vma, __pmd);		\
+		pmd_t ____pmd = __pmd;					\
+		if (unlikely(pmd_trans_huge(*(____pmd))))		\
+			__split_huge_page_vma(__vma, ____pmd);		\
 	}  while (0)
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
+		pmd_t ____pmd = __pmd;					\
 		smp_mb();						\
 		spin_unlock_wait(&(__anon_vma)->lock);			\
 		smp_mb();						\
-		VM_BUG_ON(pmd_trans_splitting(*(__pmd)) ||		\
-			  pmd_trans_huge(*(__pmd)));			\
+		VM_BUG_ON(pmd_trans_splitting(*(____pmd)) ||		\
+			  pmd_trans_huge(*(____pmd)));			\
 	} while (0)
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)


> > +#define wait_split_huge_page(__anon_vma, __pmd)				\
> > +	do {								\
> > +		smp_mb();						\
> > +		spin_unlock_wait(&(__anon_vma)->lock);			\
> > +		smp_mb();						\
> > +		VM_BUG_ON(pmd_trans_splitting(*(__pmd)) ||		\
> > +			  pmd_trans_huge(*(__pmd)));			\
> > +	} while (0)
> 
> Barriers without comments are doomed to stupid questions. Can you add a
> comment on what this barrier is protecting against?

the reason is that spin_unlock_wait has nothing to do with
spin_unlock, it's a while loop on a casted volatile field, nothing in
assembly. So the cpu can move anything around it and it's almost
worthless without some memory barrier around.

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
 #define wait_split_huge_page(__anon_vma, __pmd)				\
 	do {								\
+		pmd_t ____pmd = __pmd;					\
+		/*							\
+		 * spin_unlock_wait() is just a loop in C and so the	\
+		 * CPU can reorder anything around it.			\
+		 */							\
 		smp_mb();						\
 		spin_unlock_wait(&(__anon_vma)->lock);			\
 		smp_mb();						\
-		VM_BUG_ON(pmd_trans_splitting(*(__pmd)) ||		\
-			  pmd_trans_huge(*(__pmd)));			\
+		VM_BUG_ON(pmd_trans_splitting(*(____pmd)) ||		\
+			  pmd_trans_huge(*(____pmd)));			\
 	} while (0)
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)


Now thinking more I think the first smp_mb is unnecessary. Any code
that could read or write stuff before the spin_unlock_wait will be
even safer after it. All it matters is that the code _after_ the
spin_unlock_wait doesn't run before it. So I'll remove the first
smb_mb() of the two. I guess I was a little too paranoid but it's sure
better to have one more barrier than one less... eheh ;)

> I *think* it's because spin unlocking is not a barrier (although the exact
> details escape me) so presumably spin_unlock_wait() isn't one either. In
> this case, you have to be sure that reads/writes to that lock that occured
> since you called pmd_trans_splitting() have happened. Am I close?

Correct, spin_unlock would be a barrier that only prevents the stuff
up to go down, it doesn't prevent the pmd_trans to go up. In this case
spin_unlock_wait it's not a smp barrier at all.

> > +#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> > +#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> > +#if HPAGE_PMD_ORDER > MAX_ORDER
> > +#error "hugepages can't be allocated by the buddy allocator"
> > +#endif
> > +
> > +extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
> > +static inline int PageTransHuge(struct page *page)
> > +{
> > +	VM_BUG_ON(PageTail(page));
> > +	return PageHead(page);
> > +}
> > +#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> > +#define transparent_hugepage_enabled(__vma) 0
> > +#define transparent_hugepage_defrag(__vma) 0
> > +#define transparent_hugepage_debug_cow() 0
> > +
> > +#define transparent_hugepage_flags 0UL
> > +static inline int split_huge_page(struct page *page)
> > +{
> > +	return 0;
> > +}
> > +#define split_huge_page_mm(__mm, __addr, __pmd)	\
> > +	do { }  while (0)
> > +#define split_huge_page_vma(__vma, __pmd)	\
> > +	do { }  while (0)
> > +#define wait_split_huge_page(__anon_vma, __pmd)	\
> > +	do { } while (0)
> > +#define PageTransHuge(page) 0
> > +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> > +
> > +#endif /* _LINUX_HUGE_MM_H */
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -106,6 +106,9 @@ extern unsigned int kobjsize(const void 
> >  #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
> >  #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
> >  #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
> > +#if BITS_PER_LONG > 32
> > +#define VM_HUGEPAGE	0x100000000UL	/* MADV_HUGEPAGE marked this vma */
> > +#endif
> >  
> 
> #ifdef CONFIG_TRANSPARENT_HUGEPAGE ?
> 
> Because of the use of the page flag bits, I believe you are restricted to
> 64 bit anyway. 

I'm restricted to 32bit on x86. I expect in the future VM_ will get
added to 64bit only versions so I didn't want to pollute or make it
special with CONFIG_TRANSPARENT_HUGEPAGE. In addition this isn't
allocated as an enum so it's not like with an #ifdef I can save
anything (plus I fixed in 64bit space to avoid bothering anybody in
32bit space ;)

> > +#endif
> > +	return 0;
> > +}
> > +module_init(ksm_init)
> > +
> 
> ksm_init.... I'm not seeing the connection to KSM. I suspect you cut&pasted
> from ksm.c there and forgot to rename it. It's not important as the static
> avoids collisions but it looks odd.

Yep, not just that, the entire mm_slot allocation and hash is
cut-and-pasted, search for ksm ;). Now next thought should be to unify
it in a different common .c file. Luckily for me there's some little
difference between the two mm_slot implementations that gives me an
excuse for a cut-and-pasted version to save ram in the object size
unless somebody finds a way to shrink the size of the ksm mm_slot
which is unlikely because it works different and needs an rmap chain
(something I don't need here).

> > +static int __init setup_transparent_hugepage(char *str)
> > +{
> > +	if (!str)
> > +		return 0;
> > +	transparent_hugepage_flags = simple_strtoul(str, &str, 0);
> > +	return 1;
> > +}
> > +__setup("transparent_hugepage=", setup_transparent_hugepage);
> > +
> 
> The parameters are never sanity checked. This means that flags that should be
> mutually exclusive can be set at the same time. e.g.  TRANSPARENT_HUGEPAGE_FLAG
> and TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG.
> 
> I didn't check how important this is, but prehaps you should be using the
> same helper functions as used in sysfs.

I'm aware of that, my view is if you own the system you as well "cp
/dev/zero /dev/mem". If we want to make the API user friendly we
should support a more user friendly command line option than a
number. The important thing is that no app should use this thing, it's
meant for extreme cases only.

> > +static void prepare_pmd_huge_pte(pgtable_t pgtable,
> > +				 struct mm_struct *mm)
> > +{
> > +	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
> > +
> > +	/* FIFO */
> > +	if (!mm->pmd_huge_pte)
> > +		INIT_LIST_HEAD(&pgtable->lru);
> > +	else
> > +		list_add(&pgtable->lru, &mm->pmd_huge_pte->lru);
> > +	mm->pmd_huge_pte = pgtable;
> > +}
> > +
> > +static inline pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
> > +{
> > +	if (likely(vma->vm_flags & VM_WRITE))
> > +		pmd = pmd_mkwrite(pmd);
> > +	return pmd;
> > +}
> > +
> > +static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
> > +					struct vm_area_struct *vma,
> > +					unsigned long address, pmd_t *pmd,
> > +					struct page *page,
> > +					unsigned long haddr)
> > +{
> > +	int ret = 0;
> > +	pgtable_t pgtable;
> > +
> > +	VM_BUG_ON(!PageCompound(page));
> > +	pgtable = pte_alloc_one(mm, address);
> > +	if (unlikely(!pgtable)) {
> > +		put_page(page);
> > +		return VM_FAULT_OOM;
> > +	}
> > +
> > +	clear_huge_page(page, haddr, HPAGE_PMD_NR);
> > +	__SetPageUptodate(page);
> > +
> > +	/*
> > +	 * spin_lock() below is not the equivalent of smp_wmb(), so
> > +	 * this is needed to avoid the clear_huge_page writes to
> > +	 * become visible after the set_pmd_at() write.
> > +	 */
> > +	smp_wmb();
> > +
> 
> I'm not seeing the equivalent barrier in do_anonymous_page() between
> when the page is zero'd and the PTE inserted. What am I missing?

Good point. Only explanation I can find is page_add_new_anon_rmap that
already takes the zone_lru lock and is a full barrier.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -219,13 +219,6 @@ static int __do_huge_pmd_anonymous_page(
 	clear_huge_page(page, haddr, HPAGE_PMD_NR);
 	__SetPageUptodate(page);
 
-	/*
-	 * spin_lock() below is not the equivalent of smp_wmb(), so
-	 * this is needed to avoid the clear_huge_page writes to
-	 * become visible after the set_pmd_at() write.
-	 */
-	smp_wmb();
-
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_none(*pmd))) {
 		spin_unlock(&mm->page_table_lock);
@@ -236,6 +229,12 @@ static int __do_huge_pmd_anonymous_page(
 		entry = mk_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		entry = pmd_mkhuge(entry);
+		/*
+		 * The spinlocking to take the lru_lock inside
+		 * page_add_new_anon_rmap() acts as a full memory
+		 * barrier to be sure clear_huge_page writes become
+		 * visible after the set_pmd_at() write.
+		 */
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		prepare_pmd_huge_pte(pgtable, mm);


> > +	if (haddr >= vma->vm_start && haddr + HPAGE_PMD_SIZE <= vma->vm_end) {
> > +		if (unlikely(anon_vma_prepare(vma)))
> > +			return VM_FAULT_OOM;
> > +		page = alloc_hugepage(transparent_hugepage_defrag(vma));
> > +		if (unlikely(!page))
> > +			goto out;
> > +
> 
> Something to consider here performance-wise when transparent-hugepage is
> defaulted to "always".
> 
> alloc_hugepage() is potentially very expensive. You could enter direct
> reclaim, lumpy reclaim, wakeup kswapd etc. If you want to optimistically
> use huge pages, it might have less impact for !defrag to imply !__GFP_WAIT.
> On the other hand, if memory compaction is merged (my test machines are
> still tied up, hence no release since), one would be happy for it to compact,
> but not necessarily enter direct reclaim.
> 
> It's a tricky one.....

Agreed but I think gfp-atomic is basically never going to get anything
if there's cache. This shrinks a bit of cache every time and it won't
wakeup kswapd (if it does it's vm bug, kswapd should kick in only if
we break below the mid watermark or whatever equivalent hysteresis).

> > +	pages = kzalloc(sizeof(struct page *) * HPAGE_PMD_NR,
> > +			GFP_KERNEL);
> 
> Is kzalloc really necessary? It's fixed-size and you initialise it so
> why not just kmalloc()?

Nice optimization! I guess I improved the failure path, in some
ancient version it likely was needed.

> > +	if (unlikely(!new_page))
> > +		return do_huge_pmd_wp_page_fallback(mm, vma, address,
> > +						    pmd, orig_pmd, page, haddr);
> > +
> > +	copy_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
> > +	__SetPageUptodate(new_page);
> > +
> > +	/*
> > +	 * spin_lock() below is not the equivalent of smp_wmb(), so
> > +	 * this is needed to avoid the copy_huge_page writes to become
> > +	 * visible after the set_pmd_at() write.
> > +	 */
> > +	smp_wmb();
> > +
> 
> You do that here but not for the wp_page_fallback in the same type of
> setup. Can you point out the obvious thing I'm missing?

I'll remove it from here too.

Note that the fallback version has it, between the last set_pte_at and
the pmd_populate and that's needed I think (even page_remove_rmap only
does atomic_dec_and_test which won't call the barrier it in case it's
not reaching zero I think). The kfree I don't like to relay on it.

> > +static void __split_huge_page_refcount(struct page *page)
> > +{
> > +	int i;
> > +	unsigned long head_index = page->index;
> > +	struct zone *zone = page_zone(page);
> > +
> > +	/* prevent PageLRU to go away from under us, and freeze lru stats */
> 
> hmm, it's not a "now" thing but I suspect it would be preferable to isolate
> from the LRU, release the LRU lock, do what you need to do and then add the
> pages in batch back onto the LRU.

we can't isolate it from lru if it's already isolated but we've to be
able to split it anyway. Maybe we can chance it so that a hugepage is
always guaranteed to have PageLRU set, but split_huge_page has to take
the lru lock to add tail pages to the lru, and the way the VM isolates
the pages isn't friendly to it (to provide that guarantee I would have
to implement a split_huge_page that works inside the lru_lock, that
may be feasible). Having to enforce that guarantee looked more risky
at the moment, my version can handle inside or outside the lru equally
well but I'm not against changing it to enforce a hugepage is always
in lru.

> > +	spin_lock_irq(&zone->lru_lock);
> > +	compound_lock(page);
> > +
> > +	for (i = 1; i < HPAGE_PMD_NR; i++) {
> > +		struct page *page_tail = page + i;
> > +
> > +		/* tail_page->_count cannot change */
> > +		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
> > +		BUG_ON(page_count(page) <= 0);
> > +		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
> > +		BUG_ON(atomic_read(&page_tail->_count) <= 0);
> > +
> > +		/* after clearing PageTail the gup refcount can be released */
> > +		smp_mb();
> > +
> > +		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > +		page_tail->flags |= (page->flags &
> > +				     ((1L << PG_referenced) |
> > +				      (1L << PG_swapbacked) |
> > +				      (1L << PG_mlocked) |
> > +				      (1L << PG_uptodate)));
> > +		page_tail->flags |= (1L << PG_dirty);
> > +
> > +		/*
> > +		 * 1) clear PageTail before overwriting first_page
> > +		 * 2) clear PageTail before clearing PageHead for VM_BUG_ON
> > +		 */
> > +		smp_wmb();
> > +
> 
> You have the LRU taken with an interrupt-safe lock. Who else could be
> manipulating the struct page to make this barrier necessary?

This is the barrier where pagetail goes away before clearing
first_page (overrwitten by the next lines below). We discussed this in
other mail.

> 
> > +		/*
> > +		 * __split_huge_page_splitting() already set the
> > +		 * splitting bit in all pmd that could map this
> > +		 * hugepage, that will ensure no CPU can alter the
> > +		 * mapcount on the head page. The mapcount is only
> > +		 * accounted in the head page and it has to be
> > +		 * transferred to all tail pages in the below code. So
> > +		 * for this code to be safe, the split the mapcount
> > +		 * can't change. But that doesn't mean userland can't
> > +		 * keep changing and reading the page contents while
> > +		 * we transfer the mapcount, so the pmd splitting
> > +		 * status is achieved setting a reserved bit in the
> > +		 * pmd, not by clearing the present bit.
> > +		*/
> > +		BUG_ON(page_mapcount(page_tail));
> > +		page_tail->_mapcount = page->_mapcount;
> > +
> > +		BUG_ON(page_tail->mapping);
> > +		page_tail->mapping = page->mapping;
> > +
> > +		page_tail->index = ++head_index;
> > +
> > +		BUG_ON(!PageAnon(page_tail));
> > +		BUG_ON(!PageUptodate(page_tail));
> > +		BUG_ON(!PageDirty(page_tail));
> > +		BUG_ON(!PageSwapBacked(page_tail));
> > +
> > +		lru_add_page_tail(zone, page, page_tail);
> > +
> > +		put_page(page_tail);
> > +	}
> > +
> > +	ClearPageCompound(page);
> > +	compound_unlock(page);
> > +	spin_unlock_irq(&zone->lru_lock);
> > +
> > +	BUG_ON(page_count(page) <= 0);
> > +}
> > +	int mapcount, mapcount2;
> > +	struct vm_area_struct *vma;
> > +
> > +	BUG_ON(!PageHead(page));
> > +	BUG_ON(PageTail(page));
> > +
> > +	mapcount = 0;
> > +	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
> > +		unsigned long addr = vma_address(page, vma);
> > +		if (addr == -EFAULT)
> > +			continue;
> > +		mapcount += __split_huge_page_splitting(page, vma, addr);
> > +	}
> > +	BUG_ON(mapcount != page_mapcount(page));
> > +
> > +	__split_huge_page_refcount(page);
> > +
> > +	mapcount2 = 0;
> > +	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
> > +		unsigned long addr = vma_address(page, vma);
> > +		if (addr == -EFAULT)
> > +			continue;
> > +		mapcount2 += __split_huge_page_map(page, vma, addr);
> > +	}
> > +	BUG_ON(mapcount != mapcount2);
> > +}
> > +
> > +/* must run with mmap_sem to prevent vma to go away */
> 
> held for read?

read or write both ok, this is why I didn't specify it.

> Broadly speaking, this was a lot more understandable than I was expecting
> and I did not find any major snags or difficulties. However, I've also ran
> out of beans again so I'll be taking another break before moving onto the
> rest of the set :)

Awesome :).

Please start running #8 on your laptop or workstation or both ;) if
you've i915 set modeline=1 or KMS=y in .config, we need to track down
what leaves a pte_special on an anonymous vma (likely gem as it goes
away with modeline=0 but I don't see where). It has to be driver
related but it's not guaranteed that the bug also happens without my
patch. Kernel is stable even when khugepaged complains about this
pte_special every 10 sec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
