Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id DEDB66B0081
	for <linux-mm@kvack.org>; Fri, 18 May 2012 19:00:32 -0400 (EDT)
Date: Sat, 19 May 2012 01:00:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: read_pmd_atomic: fix 32bit PAE pmd walk vs
 pmd_populate SMP race condition
Message-ID: <20120518230028.GF32479@redhat.com>
References: <1337264036-28971-1-git-send-email-aarcange@redhat.com>
 <20120517123531.0c221023.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517123531.0c221023.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Petr Matousek <pmatouse@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Rik van Riel <riel@redhat.com>

Hi Andrew,

On Thu, May 17, 2012 at 12:35:31PM -0700, Andrew Morton wrote:
> On Thu, 17 May 2012 16:13:56 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > When holding the mmap_sem for reading, pmd_offset_map_lock should only
> > run on a pmd_t that has been read atomically from the pmdp
> > pointer, otherwise we may read only half of it leading to this crash.
> 
> Do you think this is serious enough to warrant backporting the fix into
> -stable?  The patch is pretty simple..

Considering it's simple it's probably worth backporting, it affects
only 32bit PAE kernels if there's more than 4G of ram installed.

> A couple of nits:
> 
> - read_pmd_atomic() should be called pmd_read_atomic() - check out
>   "grep pmd include/asm-generic/pgtable.h".
> 

Agreed.

I've also been wondering if _consistent would be better suffix.

> - A somewhat neat convention we use is to do
> 
> 	static inline void foo(...)
> 	{
> 		...
> 	}
> 	#define foo foo
> 
>   so then other code can do
> 
> 	#ifndef foo
> 	...
> 	#endif
> 
>   This avoids having to create (and remember!) a second identifier.

Ok, I assume from your reply the __HAVE_ARCH_WHATEVER is being
deprecated in favour of #define foo foo.

> > +/*
> > + * pte_offset_map_lock on 32bit PAE kernels was reading the pmd_t with
> > + * a "*pmdp" dereference done by gcc.
> 
> I spent some time trying to find exactly where pte_offset_map_lock does
> this dereference then gave up, because it shouldn't have been this
> hard!
> 
> Can we be specific here, so that others can more easily work out what's
> going on?

Sure. The problem has been reproduced in mincore here:

static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
			unsigned long addr, unsigned long end,
			unsigned char *vec)
{
	unsigned long next;
	spinlock_t *ptl;
	pte_t *ptep;

	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);

[..]
		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
			mincore_unmapped_range(vma, addr, next, vec);
		else
			mincore_pte_range(vma, pmd, addr, next, vec);

or 3.3 version:

                if (pmd_none_or_clear_bad(pmd))
			mincore_unmapped_range(vma, addr, next, vec);
		else
			mincore_pte_range(vma, pmd, addr, next, vec);

So pmd_none_or_clear_bad does:

static inline int pmd_none_or_clear_bad(pmd_t *pmd)
{
	if (pmd_none(*pmd))
		return 1;
	if (unlikely(pmd_bad(*pmd))) {
		pmd_clear_bad(pmd);
		return 1;
	}
	return 0;
}

With 3.4 there's pmd_none_or_trans_huge_or_clear_bad instead, and it's
identical with THP=n, so let's assume THP=n here, it's not related to
THP anyway. It was reproduced with THP=n at build time.

static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
{
	pmd_t pmdval = *pmd;
	/*
	 * The barrier will stabilize the pmdval in a register or on
	 * the stack so that it will stop changing under the code.
	 */
#ifdef CONFIG_TRANSPARENT_HUGEPAGE
	barrier();
#endif
	if (pmd_none(pmdval))
		return 1;
	if (unlikely(pmd_bad(pmdval))) {
		if (!pmd_trans_huge(pmdval))
			pmd_clear_bad(pmd);
		return 1;
	}
	return 0;
}


This is all inline, so pmd_none_or_.... reads *pmd just one and cache
it in register or local stack. mincore_pte_range is static and used
just one so gcc can decide to inline it too.

So when the pmd_offset_map_lock runs on top it does:

#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
({							\
	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
	pte_t *__pte = pte_offset_map(pmd, address);	\
	*(ptlp) = __ptl;				\
	spin_lock(__ptl);				\
	__pte;						\
})

which calls pte_offset_map:

#define pte_offset_map(dir, address)					\
	((pte_t *)page_address(pmd_page(*(dir))) + pte_index((address)))

Finally *dir (i.e. *pmd) is dereferenced, and if it picks the previous
value read in *pmd done by pmd_none_or_..., we're screwed because it
may have the high 32bit zero by mistake.

The bug is: the *pmd _read_ is not atomic. Making that atomic fixes
it. You also need bad luck that gcc decides to read the high part
before the low part, and to cache the *pmd read across an auto-inline.

                                // edx = PTE page table high address
0xc0507a84 <sys_mincore+564>:   mov    0x4(%edi),%edx
...
                                // eax = PTE page table low address
0xc0507a8e <sys_mincore+574>:   mov    (%edi),%eax

The race is against pmd_populate from a page fault. If the pmd is none
and we hold mmap_sem read mode (like mincore does) pmd_populate can
run under us (through the page fault).

All writes are atomic: pmd_populate (or set_pmd_at) will set the pmd
with an atomic 64bit write on 32bit PAE.

The race would be:

    mincore                     page fault
    =======                     =========
    read pmd.high
				pmd_populate 64bit atomic set
    read pmd.low -> non zero

So we end up with a *pmd that has the 64bit truncated by mistake, and
because it's non zero, it goes ahead crashing in pte_offset_map_lock.

If gcc decides to read *pmd twice (first in pmd_none_or_... and then
again above in pte_offset_map) the trouble is only with THP enabled,
because the second time we would read the correct pmd high bits too.

So this may have been hidden by gcc not caching *pmd
aggressively. Especially if gcc won't inline static functions (or make
assumptions on memory clobbered by static functions), it can't happen.

With THP enabled things are more complicated because the pmd can
return null, so with THP enabled we need a real 64bit atomic read,
looping like gup_fast does until a pmd.low/high stabilize, isn't safe
because we don't have irq disabled stopping the tlb flush of
MADV_DONTNEED.

> This all seems terribly subtle and fragile.

To make it simpler, and in turn more robust, we could just do an
atomic read for THP=n too. But this will require a cmpxchg8b for every
*pmd (one every 2m).

> > + */
> > +#ifndef CONFIG_TRANSPARENT_HUGEPAGE
> > +static inline pmd_t read_pmd_atomic(pmd_t *pmdp)
> > +{
> > +	pmdval_t ret;
> > +	u32 *tmp = (u32 *)pmdp;
> > +
> > +	ret = (pmdval_t) (*tmp);
> > +	if (ret) {
> > +		/*
> > +		 * If the low part is null, we must not read the high part
> > +		 * or we can end up with a partial pmd.
> 
> This is the core part of the fix, and I don't understand it :( What is
> the significance of the zeroness of the lower half of the pmdval_t? 
> How, exactly, does this prevent races?

The only transition we have to protect against in the above case is a
pmd going from pmd_none to !pmd_none.

So the idea is, read the low part of the pmd, if it's zero, don't even
bother the high part (all things holding mmap_sem in read mode aren't
accurate walks, if the high part wasn't zero we hit the race but we
don't care).

If instead the low part of the pmd is not zero, we memory barrier and
we read the high part. We're guaranteed the high part will be correct,
if we read it after pmd.low, because pmd_populate runs with an atomic
write. And with THP off holding the mmap_sem prevents a pmd to go away
or change from under us after it has been established (pagetables are
released or modified with mmap_sem in write mode).

> At a guess, I'd say that we're making three assumptions here:
> 
> a) that gcc will write lower-word-first when doing a 64-bit write

The assumption is that gcc will read the pmd.high before pmd.low, and
that will also cache the *pmd read.

All writes to pmds are already 64bit atomic.

> b) that a valid pmdval_t never has all zeroes in the lower 32 bits and

Correct.

> 
> c) that any code which this function is racing against will only
>    ever be writing to a pmdval_t which has the all-zeroes pattern.  ie:
>    that we never can race against code which is modifying an existing
>    pmdval_t.

Correct.

I'll resend with the cleanups if you agree.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
