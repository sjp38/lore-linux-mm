Date: Fri, 1 Feb 2008 00:28:42 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v5
Message-ID: <20080131232842.GQ7185@v2.random>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random> <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 12:18:54PM -0800, Christoph Lameter wrote:
> pt lock cannot serialize with invalidate_range since it is split. A range 
> requires locking for a series of ptes not only individual ones.

The lock I take already protects up to 512 ptes yes. I call
invalidate_pages only across a _single_ 4k pagetable filled at max
with 512 pte_t mapping virutal addresses in a 2M naturally aligned
virtual range.

There's no smp race even for >4 CPUS. Check it again! I never call
invalidate_pages _outside_ the PT lock specific for that 4k pagetable
(a single PT lock protects 512 pte_t, not only a single one!).

Perhaps if you called it PMD lock there would be no misunderstanding:

    spinlock_t *__ptl = pte_lockptr(mm, pmd);	 \

(the pt lock is a function of the pmd, pte_t not!)

> That may be okay. Have you checked all the arches that can provide their 
> own implementation of this macro? This is only going to work on arches 
> that use the generic implementation.

Obviously I checked them all yes, and this was much faster than hand
editing the .c files like you did indeed.

> This will require a callback on every(!) removal of a pte. A range 
> invalidate does not do any good since the callbacks are performed anyways. 
> Probably needlessly.
> 
> In addition you have the same issues with arches providing their own macro 
> here.

Yes, s390 is the only one.

> 
> > diff --git a/include/asm-s390/pgtable.h b/include/asm-s390/pgtable.h
> > --- a/include/asm-s390/pgtable.h
> > +++ b/include/asm-s390/pgtable.h
> > @@ -712,6 +712,7 @@ static inline pte_t ptep_clear_flush(str
> >  {
> >  	pte_t pte = *ptep;
> >  	ptep_invalidate(address, ptep);
> > +	mmu_notifier(invalidate_page, vma->vm_mm, address);
> >  	return pte;
> >  }
> >  
> 
> Ahh you found an additional arch. How about x86 code? There is one 
> override of these functions there as well.

There's no ptep_clear_flush override on x86 or I would have patched it
like I did to s390.

I had to change 2 lines instead of a single one, not such a big deal.

> > +	/*
> > +	 * invalidate_page[s] is called in atomic context
> > +	 * after any pte has been updated and before
> > +	 * dropping the PT lock required to update any Linux pte.
> > +	 * Once the PT lock will be released the pte will have its
> > +	 * final value to export through the secondary MMU.
> > +	 * Before this is invoked any secondary MMU is still ok
> > +	 * to read/write to the page previously pointed by the
> > +	 * Linux pte because the old page hasn't been freed yet.
> > +	 * If required set_page_dirty has to be called internally
> > +	 * to this method.
> > +	 */
> > +	void (*invalidate_page)(struct mmu_notifier *mn,
> > +				struct mm_struct *mm,
> > +				unsigned long address);
> 
> 
> > +	void (*invalidate_pages)(struct mmu_notifier *mn,
> > +				 struct mm_struct *mm,
> > +				 unsigned long start, unsigned long end);
> 
> What is the point of invalidate_pages? It cannot be serialized properly 
> and you do the invalidate_page() calles regardless. Is is some sort of 
> optimization?

It is already serialized 100% properly sorry.

> > +struct mmu_notifier_head {};
> > +
> > +#define mmu_notifier_register(mn, mm) do {} while(0)
> > +#define mmu_notifier_unregister(mn, mm) do {} while (0)
> > +#define mmu_notifier_release(mm) do {} while (0)
> > +#define mmu_notifier_age_page(mm, address) ({ 0; })
> > +#define mmu_notifier_head_init(mmh) do {} while (0)
> 
> Macros. We want functions there to be able to validate the parameters even 
> if !CONFIG_MMU_NOTIFIER.

If you want I can turn this into a static inline, it would already
work fine. Certainly this isn't a blocker for merging given most
people will have MMU_NOTIFIER=y and this speedup compilation a tiny
bit for the embedded.

> > +
> > +/*
> > + * Notifiers that use the parameters that they were passed so that the
> > + * compiler does not complain about unused variables but does proper
> > + * parameter checks even if !CONFIG_MMU_NOTIFIER.
> > + * Macros generate no code.
> > + */
> > +#define mmu_notifier(function, mm, args...)			       \
> > +	do {							       \
> > +		if (0) {					       \
> > +			struct mmu_notifier *__mn;		       \
> > +								       \
> > +			__mn = (struct mmu_notifier *)(0x00ff);	       \
> > +			__mn->ops->function(__mn, mm, args);	       \
> > +		};						       \
> > +	} while (0)
> > +
> > +#endif /* CONFIG_MMU_NOTIFIER */
> 
> Ok here you took the variant that checks parameters.

This is primarly to turn off the compiler warning, not to check the
parameters, but yes it should also checks the parameter types as a bonus.

> > @@ -1249,6 +1250,7 @@ static int remap_pte_range(struct mm_str
> >  {
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> > +	unsigned long start = addr;
> >  
> >  	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
> >  	if (!pte)
> > @@ -1260,6 +1262,7 @@ static int remap_pte_range(struct mm_str
> >  		pfn++;
> >  	} while (pte++, addr += PAGE_SIZE, addr != end);
> >  	arch_leave_lazy_mmu_mode();
> > +	mmu_notifier(invalidate_pages, mm, start, addr);
> >  	pte_unmap_unlock(pte - 1, ptl);
> >  	return 0;
> 
> You are under the wrong impression that you can use the pte lock to 
> serialize general access to ptes! Nope. ptelock only serialize access to 
> individual ptes. This is broken.

You are under the wrong impression that invalidate_page could be
called on a range that spawns over a region that isn't 2M naturally
aligned and <2M in size.

> > +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> > +		hlist_for_each_entry_safe(mn, n, tmp,
> > +					  &mm->mmu_notifier.head, hlist) {
> > +			hlist_del(&mn->hlist);
> 
> hlist_del_init?

This is a mess I've to say and I'm almost willing to return to a
_safe_rcu + and removing the autodisarming feature. KVM itself isn't
using mm_users but mm_count. then if somebody need to release the mn
inside ->relase they should mmu_notifier_unregister _inside_
->release and then call_rcu to release the mn (synchronize_rcu isn't
allowed inside ->release because of the rcu_spin_lock() that can't
schedule or it'll reach a quiescent point itself allowing the other
structures to be released.

> > @@ -71,6 +72,7 @@ static void change_pte_range(struct mm_s
> >  
> >  	} while (pte++, addr += PAGE_SIZE, addr != end);
> >  	arch_leave_lazy_mmu_mode();
> > +	mmu_notifier(invalidate_pages, mm, start, addr);
> >  	pte_unmap_unlock(pte - 1, ptl);
> >  }
> 
> Again broken serialization.

The above is perfectly fine too. If you have doubts and your
misunderstanding of my 100% SMP safe locking isn't immediately clear,
think about this, how could it be safe to modify 512 ptes with a
single lock, regardless of the mmu notifiers?

I appreciate the review! I hope my entirely bug free and
strightforward #v5 will strongly increase the probability of getting
this in sooner than later. If something else it shows the approach I
prefer to cover GRU/KVM 100%, leaving the overkill mutex locking
requirements only to the mmu notifier users that can't deal with the
scalar and finegrined and already-taken/trashed PT lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
