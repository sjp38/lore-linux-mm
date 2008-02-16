Date: Fri, 15 Feb 2008 19:37:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-Id: <20080215193719.262c03a1.akpm@linux-foundation.org>
In-Reply-To: <20080215064932.371510599@sgi.com>
References: <20080215064859.384203497@sgi.com>
	<20080215064932.371510599@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008 22:49:00 -0800 Christoph Lameter <clameter@sgi.com> wrote:

> MMU notifiers are used for hardware and software that establishes
> external references to pages managed by the Linux kernel. These are
> page table entriews or tlb entries or something else that allows
> hardware (such as DMA engines, scatter gather devices, networking,
> sharing of address spaces across operating system boundaries) and
> software (Virtualization solutions such as KVM, Xen etc) to
> access memory managed by the Linux kernel.
> 
> The MMU notifier will notify the device driver that subscribes to such
> a notifier that the VM is going to do something with the memory
> mapped by that device. The device must then drop references for the
> indicated memory area. The references may be reestablished later.
> 
> The notification scheme is much better than the current schemes of
> avoiding the danger of the VM removing pages that are externally
> mapped. We currently either mlock pages used for RDMA, XPmem etc
> in memory or increase the refcount to pin the pages. Increasing
> the refcount makes it impossible for the VM to reclaim the page.
> 
> Mlock causes problems with reclaim and may lead to OOM if too many
> pages are pinned in memory. It is also incorrect in terms what the POSIX
> specificies for what role mlock should play. Mlock does *not* pin pages in
> memory. Mlock just means do not allow the page to be moved to swap.
> 
> Linux can move pages in memory (for example through the page migration
> mechanism). These pages can be moved even if they are mlocked(!!!!).
> The current approach of page pinning in use by RDMA etc is conceptually
> broken but there are currently no other easy solutions.
> 
> The alternate of increasing the page count to pin pages is also not
> that enticing since there will be continual attempts to reclaim
> or migrate these pages.
> 
> The solution here allows us to finally fix this issue by requiring
> such devices to subscribe to a notification chain that will allow
> them to work without pinning. The VM gains control of its memory again
> and the memory that has external references can be managed like regular
> memory.
> 
> This patch: Core portion
> 

What is the status of getting infiniband to use this facility?

How important is this feature to KVM?

To xpmem?

Which other potential clients have been identified and how important it it
to those?


> Index: linux-2.6/Documentation/mmu_notifier/README
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/Documentation/mmu_notifier/README	2008-02-14 22:27:19.000000000 -0800
> @@ -0,0 +1,105 @@
> +Linux MMU Notifiers
> +-------------------
> +
> +MMU notifiers are used for hardware and software that establishes
> +external references to pages managed by the Linux kernel. These are
> +page table entriews or tlb entries or something else that allows
> +hardware (such as DMA engines, scatter gather devices, networking,
> +sharing of address spaces across operating system boundaries) and
> +software (Virtualization solutions such as KVM, Xen etc) to
> +access memory managed by the Linux kernel.
> +
> +The MMU notifier will notify the device driver that subscribes to such
> +a notifier that the VM is going to do something with the memory
> +mapped by that device. The device must then drop references for the
> +indicated memory area. The references may be reestablished later.
> +
> +The notification scheme is much better than the current schemes of
> +dealing with the danger of the VM removing pages.
> +We currently mlock pages used for RDMA, XPmem etc in memory or
> +increase the refcount of the pages.
> +
> +Both cause problems with reclaim and may lead to OOM if too many
> +pages are pinned in memory. Mlock is also incorrect in terms of the POSIX
> +specification of the role of mlock. Mlock does *not* pin pages in
> +memory. It just does not allow the page to be moved to swap.
> +The page refcount is used to track current users of a page struct.
> +Artificially inflating the refcount means that the VM cannot track
> +down all references to a page. It will not be able to reclaim or
> +move a page. However, the core code will try again and again because
> +the assumption is that an elevated refcount is a temporary situation.
> +
> +Linux can move pages in memory (for example through the page migration
> +mechanism). These pages can be moved even if they are mlocked(!!!!).
> +So the current approach in use by RDMA etc etc is conceptually broken
> +but there are currently no other easy solutions.
> +
> +The solution here allows us to finally fix this issue by requiring
> +such devices to subscribe to a notification chain that will allow
> +them to work without pinning.
> +
> +The notifier chains provide two callback mechanisms. The
> +first one is required for any device that establishes external mappings.
> +The second (rmap) mechanism is required if a device needs to be
> +able to sleep when invalidating references. Sleeping may be necessary
> +if we are mapping across a network or to different Linux instances
> +in the same address space.

I'd have thought that a major reason for sleeping would be to wait for IO
to complete.  Worth mentioning here?

> +mmu_notifier mechanism (for KVM/GRU etc)
> +----------------------------------------
> +Callbacks are registered with an mm_struct from a device driver using
> +mmu_notifier_register(). When the VM removes pages (or changes
> +permissions on pages etc) then callbacks are triggered.
> +
> +The invalidation function for a single page (*invalidate_page)

We already have an invalidatepage.  Ho hum.

> +is called with spinlocks (in particular the pte lock) held. This allow
> +for an easy implementation of external ptes that are on the local system.
>

Why is that "easy"?  I's have thought that it would only be easy if the
driver happened to be using those same locks for its own purposes. 
Otherwise it is "awkward"?

> +The invalidation mechanism for a range (*invalidate_range_begin/end*) is
> +called most of the time without any locks held. It is only called with
> +locks held for file backed mappings that are truncated. A flag indicates
> +in which mode we are. A driver can use that mechanism to f.e.
> +delay the freeing of the pages during truncate until no locks are held.

That sucks big time.  What do we need to do to make get the callback
functions called in non-atomic context?

> +Pages must be marked dirty if dirty bits are found to be set in
> +the external ptes during unmap.

That sentence is too vague.  Define "marked dirty"?

> +The *release* method is called when a Linux process exits. It is run before

We'd conventionally use a notation such as "->release()" here, rather than
the asterisks.

> +the pages and mappings of a process are torn down and gives the device driver
> +a chance to zap all the external mappings in one go.

I assume what you mean here is that ->release() is called during exit()
when the final reference to an mm is being dropped.

> +An example for a code that can be used to build a notifier mechanism into
> +a device driver can be found in the file
> +Documentation/mmu_notifier/skeleton.c

Should that be in samples/?

> +mmu_rmap_notifier mechanism (XPMEM etc)
> +---------------------------------------
> +The mmu_rmap_notifier allows the device driver to implement their own rmap

s/their/its/

> +and allows the device driver to sleep during page eviction. This is necessary
> +for complex drivers that f.e. allow the sharing of memory between processes
> +running on different Linux instances (typically over a network or in a
> +partitioned NUMA system).
> +
> +The mmu_rmap_notifier adds another invalidate_page() callout that is called
> +*before* the Linux rmaps are walked. At that point only the page lock is
> +held. The invalidate_page() function must walk the driver rmaps and evict
> +all the references to the page.

What happens if it cannot do so?

> +There is no process information available before the rmaps are consulted.

Not sure what that sentence means.  I guess "available to the core VM"?

> +The notifier mechanism can therefore not be attached to an mm_struct. Instead
> +it is a global callback list. Having to perform a callback for each and every
> +page that is reclaimed would be inefficient. Therefore we add an additional
> +page flag: PageRmapExternal().

How many page flags are left?

Is this feature important enough to justfy consumption of another one?

> Only pages that are marked with this bit can
> +be exported and the rmap callbacks will only be performed for pages marked
> +that way.

"exported": new term, unclear what it means.

> +The required additional Page flag is only availabe in 64 bit mode and
> +therefore the mmu_rmap_notifier portion is not available on 32 bit platforms.

whoa.  Is that good?  You just made your feature unavailable on the great
majority of Linux systems.

> +An example of code to build a mmu_notifier mechanism with rmap capabilty
> +can be found in Documentation/mmu_notifier/skeleton_rmap.c
> +
> +February 9, 2008,
> +	Christoph Lameter <clameter@sgi.com
> +
> +Index: linux-2.6/include/linux/mm_types.h
> Index: linux-2.6/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm_types.h	2008-02-14 20:59:01.000000000 -0800
> +++ linux-2.6/include/linux/mm_types.h	2008-02-14 21:17:51.000000000 -0800
> @@ -159,6 +159,12 @@ struct vm_area_struct {
>  #endif
>  };
>  
> +struct mmu_notifier_head {
> +#ifdef CONFIG_MMU_NOTIFIER
> +	struct hlist_head head;
> +#endif
> +};
> +
>  struct mm_struct {
>  	struct vm_area_struct * mmap;		/* list of VMAs */
>  	struct rb_root mm_rb;
> @@ -228,6 +234,7 @@ struct mm_struct {
>  #ifdef CONFIG_CGROUP_MEM_CONT
>  	struct mem_cgroup *mem_cgroup;
>  #endif
> +	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
>  };
>  
>  #endif /* _LINUX_MM_TYPES_H */
> Index: linux-2.6/include/linux/mmu_notifier.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/include/linux/mmu_notifier.h	2008-02-14 22:42:28.000000000 -0800
> @@ -0,0 +1,180 @@
> +#ifndef _LINUX_MMU_NOTIFIER_H
> +#define _LINUX_MMU_NOTIFIER_H
> +
> +/*
> + * MMU motifier

typo

> + * Notifier functions for hardware and software that establishes external
> + * references to pages of a Linux system. The notifier calls ensure that
> + * external mappings are removed when the Linux VM removes memory ranges
> + * or individual pages from a process.

So the callee cannot fail.  hm.  If it can't block, it's likely screwed in
that case.  In other cases it might be screwed anyway.  I suspect we'll
need to be able to handle callee failure.

> + * These fall into two classes:
> + *
> + * 1. mmu_notifier
> + *
> + * 	These are callbacks registered with an mm_struct. If pages are
> + * 	removed from an address space then callbacks are performed.

"to be removed", I guess.  It's called before the page is actually removed?

> + * 	Spinlocks must be held in order to walk reverse maps. The
> + * 	invalidate_page() callbacks are performed with spinlocks held.

hm, yes, problem.   Permitting callee failure might be good enough.

> + * 	The invalidate_range_start/end callbacks can be performed in contexts
> + * 	where sleeping is allowed or in atomic contexts. A flag is passed
> + * 	to indicate an atomic context.

We generally would prefer separate callbacks, rather than a unified
callback with a mode flag.


> + *	Pages must be marked dirty if dirty bits are found to be set in
> + *	the external ptes.
> + */
> +
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +#include <linux/rcupdate.h>
> +#include <linux/mm_types.h>
> +
> +struct mmu_notifier_ops;
> +
> +struct mmu_notifier {
> +	struct hlist_node hlist;
> +	const struct mmu_notifier_ops *ops;
> +};
> +
> +struct mmu_notifier_ops {
> +	/*
> +	 * The release notifier is called when no other execution threads
> +	 * are left. Synchronization is not necessary.

"and the mm is about to be destroyed"?

> +	 */
> +	void (*release)(struct mmu_notifier *mn,
> +			struct mm_struct *mm);
> +
> +	/*
> +	 * age_page is called from contexts where the pte_lock is held
> +	 */
> +	int (*age_page)(struct mmu_notifier *mn,
> +			struct mm_struct *mm,
> +			unsigned long address);

This wasn't documented.

> +	/*
> +	 * invalidate_page is called from contexts where the pte_lock is held.
> +	 */
> +	void (*invalidate_page)(struct mmu_notifier *mn,
> +				struct mm_struct *mm,
> +				unsigned long address);
> +
> +	/*
> +	 * invalidate_range_begin() and invalidate_range_end() must be paired.
> +	 *
> +	 * Multiple invalidate_range_begin/ends may be nested or called
> +	 * concurrently.

Under what circumstances would they be nested?

> That is legit. However, no new external references

references to what?

> +	 * may be established as long as any invalidate_xxx is running or
> +	 * any invalidate_range_begin() and has not been completed through a

stray "and".

> +	 * corresponding call to invalidate_range_end().
> +	 *
> +	 * Locking within the notifier needs to serialize events correspondingly.
> +	 *
> +	 * invalidate_range_begin() must clear all references in the range
> +	 * and stop the establishment of new references.

and stop the establishment of new references within the range, I assume?

If so, that's putting a heck of a lot of complexity into the driver, isn't
it?  It needs to temporarily remember an arbitrarily large number of
regions in this mm against which references may not be taken?

> +	 * invalidate_range_end() reenables the establishment of references.

within the range?

> +	 * atomic indicates that the function is called in an atomic context.
> +	 * We can sleep if atomic == 0.
> +	 *
> +	 * invalidate_range_begin() must remove all external references.
> +	 * There will be no retries as with invalidate_page().
> +	 */
> +	void (*invalidate_range_begin)(struct mmu_notifier *mn,
> +				 struct mm_struct *mm,
> +				 unsigned long start, unsigned long end,
> +				 int atomic);
> +
> +	void (*invalidate_range_end)(struct mmu_notifier *mn,
> +				 struct mm_struct *mm,
> +				 unsigned long start, unsigned long end,
> +				 int atomic);
> +};
> +
> +#ifdef CONFIG_MMU_NOTIFIER
> +
> +/*
> + * Must hold the mmap_sem for write.
> + *
> + * RCU is used to traverse the list. A quiescent period needs to pass
> + * before the notifier is guaranteed to be visible to all threads
> + */
> +extern void mmu_notifier_register(struct mmu_notifier *mn,
> +				  struct mm_struct *mm);
> +
> +/*
> + * Must hold mmap_sem for write.
> + *
> + * A quiescent period needs to pass before the mmu_notifier structure
> + * can be released. mmu_notifier_release() will wait for a quiescent period
> + * after calling the ->release callback. So it is safe to call
> + * mmu_notifier_unregister from the ->release function.
> + */
> +extern void mmu_notifier_unregister(struct mmu_notifier *mn,
> +				    struct mm_struct *mm);
> +
> +
> +extern void mmu_notifier_release(struct mm_struct *mm);
> +extern int mmu_notifier_age_page(struct mm_struct *mm,
> +				 unsigned long address);

There's the mysterious age_page again.

> +static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
> +{
> +	INIT_HLIST_HEAD(&mnh->head);
> +}
> +
> +#define mmu_notifier(function, mm, args...)				\
> +	do {								\
> +		struct mmu_notifier *__mn;				\
> +		struct hlist_node *__n;					\
> +									\
> +		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
> +			rcu_read_lock();				\
> +			hlist_for_each_entry_rcu(__mn, __n,		\
> +					     &(mm)->mmu_notifier.head,	\
> +					     hlist)			\
> +				if (__mn->ops->function)		\
> +					__mn->ops->function(__mn,	\
> +							    mm,		\
> +							    args);	\
> +			rcu_read_unlock();				\
> +		}							\
> +	} while (0)

The macro references its args more than once.  Anyone who does

	mmu_notifier(function, some_function_which_has_side_effects())

will get a surprise.  Use temporaries.

> +#else /* CONFIG_MMU_NOTIFIER */
> +
> +/*
> + * Notifiers that use the parameters that they were passed so that the
> + * compiler does not complain about unused variables but does proper
> + * parameter checks even if !CONFIG_MMU_NOTIFIER.
> + * Macros generate no code.
> + */
> +#define mmu_notifier(function, mm, args...)				\
> +	do {								\
> +		if (0) {						\
> +			struct mmu_notifier *__mn;			\
> +									\
> +			__mn = (struct mmu_notifier *)(0x00ff);		\
> +			__mn->ops->function(__mn, mm, args);		\
> +		};							\
> +	} while (0)

That's a bit weird.  Can't we do the old

	(void)function;
	(void)mm;

trick?  Or make it a staic inline function?

> +static inline void mmu_notifier_register(struct mmu_notifier *mn,
> +						struct mm_struct *mm) {}
> +static inline void mmu_notifier_unregister(struct mmu_notifier *mn,
> +						struct mm_struct *mm) {}
> +static inline void mmu_notifier_release(struct mm_struct *mm) {}
> +static inline int mmu_notifier_age_page(struct mm_struct *mm,
> +				unsigned long address)
> +{
> +	return 0;
> +}
> +
> +static inline void mmu_notifier_head_init(struct mmu_notifier_head *mmh) {}
> +
> +#endif /* CONFIG_MMU_NOTIFIER */
> +
> +#endif /* _LINUX_MMU_NOTIFIER_H */
> Index: linux-2.6/mm/Kconfig
> ===================================================================
> --- linux-2.6.orig/mm/Kconfig	2008-02-14 20:59:01.000000000 -0800
> +++ linux-2.6/mm/Kconfig	2008-02-14 21:17:51.000000000 -0800
> @@ -193,3 +193,7 @@ config NR_QUICK
>  config VIRT_TO_BUS
>  	def_bool y
>  	depends on !ARCH_NO_VIRT_TO_BUS
> +
> +config MMU_NOTIFIER
> +	def_bool y
> +	bool "MMU notifier, for paging KVM/RDMA"

Why is this not selectable?  The help seems a bit brief.

Does this cause 32-bit systems to drag in a bunch of code they're not
allowed to ever use?

> Index: linux-2.6/mm/Makefile
> ===================================================================
> --- linux-2.6.orig/mm/Makefile	2008-02-14 20:59:01.000000000 -0800
> +++ linux-2.6/mm/Makefile	2008-02-14 21:17:51.000000000 -0800
> @@ -33,4 +33,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_SMP) += allocpercpu.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o
> +obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
>  
> Index: linux-2.6/mm/mmu_notifier.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/mm/mmu_notifier.c	2008-02-14 22:41:55.000000000 -0800
> @@ -0,0 +1,76 @@
> +/*
> + *  linux/mm/mmu_notifier.c
> + *
> + *  Copyright (C) 2008  Qumranet, Inc.
> + *  Copyright (C) 2008  SGI
> + *  		Christoph Lameter <clameter@sgi.com>
> + *
> + *  This work is licensed under the terms of the GNU GPL, version 2. See
> + *  the COPYING file in the top-level directory.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/mm.h>
> +#include <linux/mmu_notifier.h>
> +
> +/*
> + * No synchronization. This function can only be called when only a single
> + * process remains that performs teardown.
> + */
> +void mmu_notifier_release(struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n, *t;
> +
> +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> +		hlist_for_each_entry_safe(mn, n, t,
> +					  &mm->mmu_notifier.head, hlist) {
> +			hlist_del_init(&mn->hlist);
> +			if (mn->ops->release)
> +				mn->ops->release(mn, mm);

We do this a lot, but back in the old days people didn't like optional
callbacks which can be NULL.  If we expect that mmu_notifier_ops.release is
usually implemented, the just unconditionally call it and require that all
clients implement it.  Perhaps provide an exported-to-modules stuv in core
kernel for clients which didn't want to implement ->release().

> +		}
> +	}
> +}
> +
> +/*
> + * If no young bitflag is supported by the hardware, ->age_page can
> + * unmap the address and return 1 or 0 depending if the mapping previously
> + * existed or not.
> + */
> +int mmu_notifier_age_page(struct mm_struct *mm, unsigned long address)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +	int young = 0;
> +
> +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> +		rcu_read_lock();
> +		hlist_for_each_entry_rcu(mn, n,
> +					  &mm->mmu_notifier.head, hlist) {
> +			if (mn->ops->age_page)
> +				young |= mn->ops->age_page(mn, mm, address);
> +		}
> +		rcu_read_unlock();
> +	}
> +
> +	return young;
> +}

should the rcu_read_lock() cover the hlist_empty() test?

This function looks like it was tossed in at the last minute.  It's
mysterious, undocumented, poorly commented, poorly named.  A better name
would be one which has some correlation with the return value.

Because anyone who looks at some code which does

	if (mmu_notifier_age_page(mm, address))
		...

has to go and reverse-engineer the implementation of
mmu_notifier_age_page() to work out under which circumstances the "..."
will be executed.  But this should be apparent just from reading the callee
implementation.

This function *really* does need some documentation.  What does it *mean*
when the ->age_page() from some of the notifiers returned "1" and the
->age_page() from some other notifiers returned zero?  Dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
