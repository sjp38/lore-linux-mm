Date: Fri, 6 Jun 2008 18:07:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-Id: <20080606180746.6c2b5288.akpm@linux-foundation.org>
In-Reply-To: <20080606202859.522708682@redhat.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.522708682@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 06 Jun 2008 16:28:55 -0400
Rik van Riel <riel@redhat.com> wrote:

> Originally
> From: Nick Piggin <npiggin@suse.de>
> 
> Against:  2.6.26-rc2-mm1
> 
> This patch:
> 
> 1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
>    stub version of the mlock/noreclaim APIs when it's
>    not configured.  Depends on [CONFIG_]NORECLAIM_LRU.

Oh sob.

akpm:/usr/src/25> find . -name '*.[ch]' | xargs grep CONFIG_NORECLAIM | wc -l
51

why oh why?  Must we really really do this to ourselves?  Cheerfully
unchangeloggedly?

> 2) add yet another page flag--PG_mlocked--to indicate that
>    the page is locked for efficient testing in vmscan and,
>    optionally, fault path.  This allows early culling of
>    nonreclaimable pages, preventing them from getting to
>    page_referenced()/try_to_unmap().  Also allows separate
>    accounting of mlock'd pages, as Nick's original patch
>    did.
> 
>    Note:  Nick's original mlock patch used a PG_mlocked
>    flag.  I had removed this in favor of the PG_noreclaim
>    flag + an mlock_count [new page struct member].  I
>    restored the PG_mlocked flag to eliminate the new
>    count field.  

How many page flags are left?  I keep on asking this and I end up
either a) not being told or b) forgetting.  I thought that we had
a whopping big comment somewhere which describes how all these
flags are allocated but I can't immediately locate it.

> 3) add the mlock/noreclaim infrastructure to mm/mlock.c,
>    with internal APIs in mm/internal.h.  This is a rework
>    of Nick's original patch to these files, taking into
>    account that mlocked pages are now kept on noreclaim
>    LRU list.
> 
> 4) update vmscan.c:page_reclaimable() to check PageMlocked()
>    and, if vma passed in, the vm_flags.  Note that the vma
>    will only be passed in for new pages in the fault path;
>    and then only if the "cull nonreclaimable pages in fault
>    path" patch is included.
> 
> 5) add try_to_unlock() to rmap.c to walk a page's rmap and
>    ClearPageMlocked() if no other vmas have it mlocked.  
>    Reuses as much of try_to_unmap() as possible.  This
>    effectively replaces the use of one of the lru list links
>    as an mlock count.  If this mechanism let's pages in mlocked
>    vmas leak through w/o PG_mlocked set [I don't know that it
>    does], we should catch them later in try_to_unmap().  One
>    hopes this will be rare, as it will be relatively expensive.
> 
> 6) Kosaki:  added munlock page table walk to avoid using
>    get_user_pages() for unlock.  get_user_pages() is unreliable
>    for some vma protections.
>    Lee:  modified to wait for in-flight migration to complete
>    to close munlock/migration race that could strand pages.

None of which is available on 32-bit machines.  That's pretty significant.


Do we do per-zone or global number-of-mlocked-pages accounting for
/proc/meminfo or /proc/vmstat, etc?  Seems not..

> --- linux-2.6.26-rc2-mm1.orig/mm/Kconfig	2008-06-06 16:05:15.000000000 -0400
> +++ linux-2.6.26-rc2-mm1/mm/Kconfig	2008-06-06 16:06:28.000000000 -0400
> @@ -215,3 +215,17 @@ config NORECLAIM_LRU
>  	  may be non-reclaimable because:  they are locked into memory, they
>  	  are anonymous pages for which no swap space exists, or they are anon
>  	  pages that are expensive to unmap [long anon_vma "related vma" list.]
> +
> +config NORECLAIM_MLOCK
> +	bool "Exclude mlock'ed pages from reclaim"
> +	depends on NORECLAIM_LRU
> +	help
> +	  Treats mlock'ed pages as no-reclaimable.  Removing these pages from
> +	  the LRU [in]active lists avoids the overhead of attempting to reclaim
> +	  them.  Pages marked non-reclaimable for this reason will become
> +	  reclaimable again when the last mlock is removed.
> +	  when no swap space exists.  Removing these pages from the LRU lists
> +	  avoids the overhead of attempting to reclaim them.  Pages marked
> +	  non-reclaimable for this reason will become reclaimable again when/if
> +	  sufficient swap space is added to the system.

The sentence "when no swap space exists." a) lacks capitalisation and
b) makes no sense.

The paramedics are caring for Aunt Tillie.

> Index: linux-2.6.26-rc2-mm1/mm/internal.h
> ===================================================================
> --- linux-2.6.26-rc2-mm1.orig/mm/internal.h	2008-06-06 16:05:15.000000000 -0400
> +++ linux-2.6.26-rc2-mm1/mm/internal.h	2008-06-06 16:06:28.000000000 -0400
> @@ -56,6 +56,17 @@ static inline unsigned long page_order(s
>  	return page_private(page);
>  }
>  
> +/*
> + * mlock all pages in this vma range.  For mmap()/mremap()/...
> + */
> +extern int mlock_vma_pages_range(struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end);
> +
> +/*
> + * munlock all pages in vma.   For munmap() and exit().
> + */
> +extern void munlock_vma_pages_all(struct vm_area_struct *vma);

I don't think it's desirable that interfaces be documented in two
places.  The documentation which you have at the definition site is
more complete than this, and is at the place where people will expect
to find it.


>  #ifdef CONFIG_NORECLAIM_LRU
>  /*
>   * noreclaim_migrate_page() called only from migrate_page_copy() to
> @@ -74,6 +85,65 @@ static inline void noreclaim_migrate_pag
>  }
>  #endif
>  
> +#ifdef CONFIG_NORECLAIM_MLOCK
> +/*
> + * Called only in fault path via page_reclaimable() for a new page
> + * to determine if it's being mapped into a LOCKED vma.
> + * If so, mark page as mlocked.
> + */
> +static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
> +{
> +	VM_BUG_ON(PageLRU(page));
> +
> +	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
> +		return 0;
> +
> +	SetPageMlocked(page);
> +	return 1;
> +}

bool?  If you like that sort of thing.  It makes sense here...

> +/*
> + * must be called with vma's mmap_sem held for read, and page locked.
> + */
> +extern void mlock_vma_page(struct page *page);
> +
> +/*
> + * Clear the page's PageMlocked().  This can be useful in a situation where
> + * we want to unconditionally remove a page from the pagecache -- e.g.,
> + * on truncation or freeing.
> + *
> + * It is legal to call this function for any page, mlocked or not.
> + * If called for a page that is still mapped by mlocked vmas, all we do
> + * is revert to lazy LRU behaviour -- semantics are not broken.
> + */
> +extern void __clear_page_mlock(struct page *page);
> +static inline void clear_page_mlock(struct page *page)
> +{
> +	if (unlikely(TestClearPageMlocked(page)))
> +		__clear_page_mlock(page);
> +}
> +
> +/*
> + * mlock_migrate_page - called only from migrate_page_copy() to
> + * migrate the Mlocked page flag
> + */

So maybe just nuke it and open-code those two lines in mm/migrate.c?

> +static inline void mlock_migrate_page(struct page *newpage, struct page *page)
> +{
> +	if (TestClearPageMlocked(page))
> +		SetPageMlocked(newpage);
> +}
> +
> +
> +#else /* CONFIG_NORECLAIM_MLOCK */
> +static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
> +{
> +	return 0;
> +}
> +static inline void clear_page_mlock(struct page *page) { }
> +static inline void mlock_vma_page(struct page *page) { }
> +static inline void mlock_migrate_page(struct page *new, struct page *old) { }

It would be neater if the arguments to the two versions of
mlock_migrate_page() had the same names.

> +#endif /* CONFIG_NORECLAIM_MLOCK */
>  
>  /*
>   * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
> Index: linux-2.6.26-rc2-mm1/mm/mlock.c
> ===================================================================
> --- linux-2.6.26-rc2-mm1.orig/mm/mlock.c	2008-05-15 11:20:15.000000000 -0400
> +++ linux-2.6.26-rc2-mm1/mm/mlock.c	2008-06-06 16:06:28.000000000 -0400
> @@ -8,10 +8,18 @@
>  #include <linux/capability.h>
>  #include <linux/mman.h>
>  #include <linux/mm.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#include <linux/pagemap.h>
>  #include <linux/mempolicy.h>
>  #include <linux/syscalls.h>
>  #include <linux/sched.h>
>  #include <linux/module.h>
> +#include <linux/rmap.h>
> +#include <linux/mmzone.h>
> +#include <linux/hugetlb.h>
> +
> +#include "internal.h"
>  
>  int can_do_mlock(void)
>  {
> @@ -23,17 +31,354 @@ int can_do_mlock(void)
>  }
>  EXPORT_SYMBOL(can_do_mlock);
>  
> +#ifdef CONFIG_NORECLAIM_MLOCK
> +/*
> + * Mlocked pages are marked with PageMlocked() flag for efficient testing
> + * in vmscan and, possibly, the fault path; and to support semi-accurate
> + * statistics.
> + *
> + * An mlocked page [PageMlocked(page)] is non-reclaimable.  As such, it will
> + * be placed on the LRU "noreclaim" list, rather than the [in]active lists.
> + * The noreclaim list is an LRU sibling list to the [in]active lists.
> + * PageNoreclaim is set to indicate the non-reclaimable state.
> + *
> + * When lazy mlocking via vmscan, it is important to ensure that the
> + * vma's VM_LOCKED status is not concurrently being modified, otherwise we
> + * may have mlocked a page that is being munlocked. So lazy mlock must take
> + * the mmap_sem for read, and verify that the vma really is locked
> + * (see mm/rmap.c).
> + */

That's a useful comment.

Where would the reader (and indeed the reviewer) go to find out about
"lazy mlocking"?  "grep -i 'lazy mlock' */*.c" doesn't work...

> +/*
> + *  LRU accounting for clear_page_mlock()
> + */
> +void __clear_page_mlock(struct page *page)
> +{
> +	VM_BUG_ON(!PageLocked(page));	/* for LRU islolate/putback */

typo

> +
> +	if (!isolate_lru_page(page)) {
> +		putback_lru_page(page);
> +	} else {
> +		/*
> +		 * Try hard not to leak this page ...
> +		 */
> +		lru_add_drain_all();
> +		if (!isolate_lru_page(page))
> +			putback_lru_page(page);
> +	}
> +}

When I review code I often come across stuff which I don't understand
(at least, which I don't understand sufficiently easily).  So I'll ask
questions, and I do think the best way in which those questions should
be answered is by adding a code comment to fix the problem for ever.

When I look at the isolate_lru_page()-failed cases above I wonder what
just happened.  We now have a page which is still on the LRU (how did
it get there in the first place?). Well no.  I _think_ what happened is
that this function is using isolate_lru_page() and putback_lru_page()
to move a page off a now-inappropriate LRU list and to put it back onto
the proper one.  But heck, maybe I just don't know what this function
is doing at all?

If I _am_ right, and if the isolate_lru_page() _did_ fail (and under
what circumstances?) then...  what?  We now have a page which is on an
inappropriate LRU?  Why is this OK?  Do we handle it elsewhere?  How?

etc.

> +/*
> + * Mark page as mlocked if not already.
> + * If page on LRU, isolate and putback to move to noreclaim list.
> + */
> +void mlock_vma_page(struct page *page)
> +{
> +	BUG_ON(!PageLocked(page));
> +
> +	if (!TestSetPageMlocked(page) && !isolate_lru_page(page))
> +			putback_lru_page(page);
> +}

extra tab.

> +/*
> + * called from munlock()/munmap() path with page supposedly on the LRU.
> + *
> + * Note:  unlike mlock_vma_page(), we can't just clear the PageMlocked
> + * [in try_to_unlock()] and then attempt to isolate the page.  We must
> + * isolate the page() to keep others from messing with its noreclaim

page()?

> + * and mlocked state while trying to unlock.  However, we pre-clear the

"unlock"?  (See exhasperated comment against try_to_unlock(), below)

> + * mlocked state anyway as we might lose the isolation race and we might
> + * not get another chance to clear PageMlocked.  If we successfully
> + * isolate the page and try_to_unlock() detects other VM_LOCKED vmas
> + * mapping the page, it will restore the PageMlocked state, unless the page
> + * is mapped in a non-linear vma.  So, we go ahead and SetPageMlocked(),
> + * perhaps redundantly.
> + * If we lose the isolation race, and the page is mapped by other VM_LOCKED
> + * vmas, we'll detect this in vmscan--via try_to_unlock() or try_to_unmap()
> + * either of which will restore the PageMlocked state by calling
> + * mlock_vma_page() above, if it can grab the vma's mmap sem.
> + */

OK, you officially lost me here.  Two hours are up and I guess I need
to have another run at [patch 17/25]

I must say that having tried to absorb the above, my confidence in the
overall correctness of this code is not great.  Hopefully wrong, but
gee.

> +static void munlock_vma_page(struct page *page)
> +{
> +	BUG_ON(!PageLocked(page));
> +
> +	if (TestClearPageMlocked(page) && !isolate_lru_page(page)) {
> +		try_to_unlock(page);
> +		putback_lru_page(page);
> +	}
> +}
> +
> +/*
> + * mlock a range of pages in the vma.
> + *
> + * This takes care of making the pages present too.
> + *
> + * vma->vm_mm->mmap_sem must be held for write.
> + */
> +static int __mlock_vma_pages_range(struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	unsigned long addr = start;
> +	struct page *pages[16]; /* 16 gives a reasonable batch */
> +	int write = !!(vma->vm_flags & VM_WRITE);
> +	int nr_pages = (end - start) / PAGE_SIZE;
> +	int ret;
> +
> +	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
> +	VM_BUG_ON(start < vma->vm_start || end > vma->vm_end);
> +	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
> +
> +	lru_add_drain_all();	/* push cached pages to LRU */
> +
> +	while (nr_pages > 0) {
> +		int i;
> +
> +		cond_resched();
> +
> +		/*
> +		 * get_user_pages makes pages present if we are
> +		 * setting mlock.
> +		 */
> +		ret = get_user_pages(current, mm, addr,
> +				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> +				write, 0, pages, NULL);

Doesn't mlock already do a make_pages_present(), or did that get
removed and moved to here?

> +		/*
> +		 * This can happen for, e.g., VM_NONLINEAR regions before
> +		 * a page has been allocated and mapped at a given offset,
> +		 * or for addresses that map beyond end of a file.
> +		 * We'll mlock the the pages if/when they get faulted in.
> +		 */
> +		if (ret < 0)
> +			break;
> +		if (ret == 0) {
> +			/*
> +			 * We know the vma is there, so the only time
> +			 * we cannot get a single page should be an
> +			 * error (ret < 0) case.
> +			 */
> +			WARN_ON(1);
> +			break;
> +		}
> +
> +		lru_add_drain();	/* push cached pages to LRU */
> +
> +		for (i = 0; i < ret; i++) {
> +			struct page *page = pages[i];
> +
> +			/*
> +			 * page might be truncated or migrated out from under
> +			 * us.  Check after acquiring page lock.
> +			 */
> +			lock_page(page);
> +			if (page->mapping)
> +				mlock_vma_page(page);
> +			unlock_page(page);
> +			put_page(page);		/* ref from get_user_pages() */
> +
> +			/*
> +			 * here we assume that get_user_pages() has given us
> +			 * a list of virtually contiguous pages.
> +			 */

Good assumption, that ;)

> +			addr += PAGE_SIZE;	/* for next get_user_pages() */

Could be moved outside the loop I guess.

> +			nr_pages--;

Ditto.

> +		}
> +	}
> +
> +	lru_add_drain_all();	/* to update stats */
> +
> +	return 0;	/* count entire vma as locked_vm */
> +}
>
> ...
>
> +/*
> + * munlock a range of pages in the vma using standard page table walk.
> + *
> + * vma->vm_mm->mmap_sem must be held for write.
> + */
> +static void __munlock_vma_pages_range(struct vm_area_struct *vma,
> +			      unsigned long start, unsigned long end)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct munlock_page_walk mpw;
> +
> +	VM_BUG_ON(start & ~PAGE_MASK || end & ~PAGE_MASK);
> +	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
> +	VM_BUG_ON(start < vma->vm_start);
> +	VM_BUG_ON(end > vma->vm_end);
> +
> +	lru_add_drain_all();	/* push cached pages to LRU */
> +	mpw.vma = vma;
> +	(void)walk_page_range(mm, start, end, &munlock_page_walk, &mpw);

The (void) is un-kernely.

> +	lru_add_drain_all();	/* to update stats */
> +

random newline.

> +}
> +
> +#else /* CONFIG_NORECLAIM_MLOCK */
>
> ...
>
> +int mlock_vma_pages_range(struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end)
> +{
> +	int nr_pages = (end - start) / PAGE_SIZE;
> +	BUG_ON(!(vma->vm_flags & VM_LOCKED));
> +
> +	/*
> +	 * filter unlockable vmas
> +	 */
> +	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
> +		goto no_mlock;
> +
> +	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> +			is_vm_hugetlb_page(vma) ||
> +			vma == get_gate_vma(current))
> +		goto make_present;
> +
> +	return __mlock_vma_pages_range(vma, start, end);

Invert the `if' expression, remove the goto?

> +make_present:
> +	/*
> +	 * User mapped kernel pages or huge pages:
> +	 * make these pages present to populate the ptes, but
> +	 * fall thru' to reset VM_LOCKED--no need to unlock, and
> +	 * return nr_pages so these don't get counted against task's
> +	 * locked limit.  huge pages are already counted against
> +	 * locked vm limit.
> +	 */
> +	make_pages_present(start, end);
> +
> +no_mlock:
> +	vma->vm_flags &= ~VM_LOCKED;	/* and don't come back! */
> +	return nr_pages;		/* pages NOT mlocked */
> +}
> +
> +
>
> ...
>
> +#ifdef CONFIG_NORECLAIM_MLOCK
> +/**
> + * try_to_unlock - Check page's rmap for other vma's holding page locked.
> + * @page: the page to be unlocked.   will be returned with PG_mlocked
> + * cleared if no vmas are VM_LOCKED.

I think kerneldoc will barf over the newline in @page's description.

> + * Return values are:
> + *
> + * SWAP_SUCCESS	- no vma's holding page locked.
> + * SWAP_AGAIN	- page mapped in mlocked vma -- couldn't acquire mmap sem
> + * SWAP_MLOCK	- page is now mlocked.
> + */
> +int try_to_unlock(struct page *page)
> +{
> +	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
> +
> +	if (PageAnon(page))
> +		return try_to_unmap_anon(page, 1, 0);
> +	else
> +		return try_to_unmap_file(page, 1, 0);
> +}
> +#endif

OK, this function is clear as mud.  My first reaction was "what's wrong
with just doing unlock_page()?".  The term "unlock" is waaaaaaaaaaay
overloaded in this context and its use here was an awful decision.

Can we please come up with a more specific name and add some comments
which give the reader some chance of working out what it is that is
actually being unlocked?

>
> ...
>
> @@ -652,7 +652,6 @@ again:			remove_next = 1 + (end > next->
>   * If the vma has a ->close operation then the driver probably needs to release
>   * per-vma resources, so we don't attempt to merge those.
>   */
> -#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
>  
>  static inline int is_mergeable_vma(struct vm_area_struct *vma,
>  			struct file *file, unsigned long vm_flags)

hm, so the old definition of VM_SPECIAL managed to wedge itself between
is_mergeable_vma() and is_mergeable_vma()'s comment.  Had me confused
there.

pls remove the blank line between the comment and the start of
is_mergeable_vma() so people don't go sticking more things in there.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
