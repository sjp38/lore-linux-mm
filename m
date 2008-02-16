Date: Sat, 16 Feb 2008 11:21:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080215193719.262c03a1.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802161103101.25573@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.371510599@sgi.com>
 <20080215193719.262c03a1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008, Andrew Morton wrote:

> What is the status of getting infiniband to use this facility?

Well we are talking about this it seems.
> 
> How important is this feature to KVM?

Andrea can answer this.

> To xpmem?

Without this feature we are stuck with page pinning by increasing 
refcounts which leads to endless lru scanning and other misbehavior. Also 
applications that use XPmem will not be able to swap or be able to use 
things like remap.
 
> Which other potential clients have been identified and how important it it
> to those?

It is likely important to various DMA engines, framebuffers devices etc 
etc. Seems to be a generally useful feature.


> > +The notifier chains provide two callback mechanisms. The
> > +first one is required for any device that establishes external mappings.
> > +The second (rmap) mechanism is required if a device needs to be
> > +able to sleep when invalidating references. Sleeping may be necessary
> > +if we are mapping across a network or to different Linux instances
> > +in the same address space.
> 
> I'd have thought that a major reason for sleeping would be to wait for IO
> to complete.  Worth mentioning here?

Right.

> Why is that "easy"?  I's have thought that it would only be easy if the
> driver happened to be using those same locks for its own purposes. 
> Otherwise it is "awkward"?

Its relatively easy because it is tied directly to a process and can use
external tlb shootdown / external page table clearing directly. The other 
method requires an rmap in the device driver where it can lookup the 
processes that are mapping the page.
 
> > +The invalidation mechanism for a range (*invalidate_range_begin/end*) is
> > +called most of the time without any locks held. It is only called with
> > +locks held for file backed mappings that are truncated. A flag indicates
> > +in which mode we are. A driver can use that mechanism to f.e.
> > +delay the freeing of the pages during truncate until no locks are held.
> 
> That sucks big time.  What do we need to do to make get the callback
> functions called in non-atomic context?

We would have to drop the inode_mmap_lock. Could be done with some minor 
work.

> > +Pages must be marked dirty if dirty bits are found to be set in
> > +the external ptes during unmap.
> 
> That sentence is too vague.  Define "marked dirty"?

Call set_page_dirty().

> > +The *release* method is called when a Linux process exits. It is run before
> 
> We'd conventionally use a notation such as "->release()" here, rather than
> the asterisks.

Ok.

> 
> > +the pages and mappings of a process are torn down and gives the device driver
> > +a chance to zap all the external mappings in one go.
> 
> I assume what you mean here is that ->release() is called during exit()
> when the final reference to an mm is being dropped.

Right.

> > +An example for a code that can be used to build a notifier mechanism into
> > +a device driver can be found in the file
> > +Documentation/mmu_notifier/skeleton.c
> 
> Should that be in samples/?

Oh. We have that?

> > +The mmu_rmap_notifier adds another invalidate_page() callout that is called
> > +*before* the Linux rmaps are walked. At that point only the page lock is
> > +held. The invalidate_page() function must walk the driver rmaps and evict
> > +all the references to the page.
> 
> What happens if it cannot do so?

The page is not reclaimed if we were called from try_to_unmap(). From 
page_mkclean() we must always evict the page to switch off the write 
protect bit.

> > +There is no process information available before the rmaps are consulted.
> 
> Not sure what that sentence means.  I guess "available to the core VM"?

At that point we only have the page. We do not know which processes map 
the page. In order to find out we need to take a spinlock.


> > +The notifier mechanism can therefore not be attached to an mm_struct. Instead
> > +it is a global callback list. Having to perform a callback for each and every
> > +page that is reclaimed would be inefficient. Therefore we add an additional
> > +page flag: PageRmapExternal().
> 
> How many page flags are left?

30 or so. Its only available on 64bit.

> Is this feature important enough to justfy consumption of another one?
> 
> > Only pages that are marked with this bit can
> > +be exported and the rmap callbacks will only be performed for pages marked
> > +that way.
> 
> "exported": new term, unclear what it means.

Something external to the kernel references the page.

> > +The required additional Page flag is only availabe in 64 bit mode and
> > +therefore the mmu_rmap_notifier portion is not available on 32 bit platforms.
> 
> whoa.  Is that good?  You just made your feature unavailable on the great
> majority of Linux systems.

rmaps are usually used by complex drivers that are typically used in large 
systems.

> > + * Notifier functions for hardware and software that establishes external
> > + * references to pages of a Linux system. The notifier calls ensure that
> > + * external mappings are removed when the Linux VM removes memory ranges
> > + * or individual pages from a process.
> 
> So the callee cannot fail.  hm.  If it can't block, it's likely screwed in
> that case.  In other cases it might be screwed anyway.  I suspect we'll
> need to be able to handle callee failure.

Probably.

> 
> > + * These fall into two classes:
> > + *
> > + * 1. mmu_notifier
> > + *
> > + * 	These are callbacks registered with an mm_struct. If pages are
> > + * 	removed from an address space then callbacks are performed.
> 
> "to be removed", I guess.  It's called before the page is actually removed?

Its called after the pte was cleared while holding the pte lock.

> > + * 	The invalidate_range_start/end callbacks can be performed in contexts
> > + * 	where sleeping is allowed or in atomic contexts. A flag is passed
> > + * 	to indicate an atomic context.
> 
> We generally would prefer separate callbacks, rather than a unified
> callback with a mode flag.

We could drop the inode_mmap_lock when doing truncate. That would make 
this work but its a kind of invasive thing for the VM.

> > +struct mmu_notifier_ops {
> > +	/*
> > +	 * The release notifier is called when no other execution threads
> > +	 * are left. Synchronization is not necessary.
> 
> "and the mm is about to be destroyed"?

Right.

> > +	/*
> > +	 * invalidate_range_begin() and invalidate_range_end() must be paired.
> > +	 *
> > +	 * Multiple invalidate_range_begin/ends may be nested or called
> > +	 * concurrently.
> 
> Under what circumstances would they be nested?

Hmmmm.. Right they cannot be nested. Multiple processors can have 
invalidates() concurrently in progress.

> > That is legit. However, no new external references
> 
> references to what?

To the ranges that are in the process of being invalidated.

> > +	 * invalidate_range_begin() must clear all references in the range
> > +	 * and stop the establishment of new references.
> 
> and stop the establishment of new references within the range, I assume?

Right.
 
> If so, that's putting a heck of a lot of complexity into the driver, isn't
> it?  It needs to temporarily remember an arbitrarily large number of
> regions in this mm against which references may not be taken?

That is one implementation (XPmem does that). The other is to simply stop 
all references when any invalidate_range is in progress (KVM and GRU do 
that).


> > +	 * invalidate_range_end() reenables the establishment of references.
> 
> within the range?

Right.

> > +extern void mmu_notifier_release(struct mm_struct *mm);
> > +extern int mmu_notifier_age_page(struct mm_struct *mm,
> > +				 unsigned long address);
> 
> There's the mysterious age_page again.

Andrea put this in to check the reference status of a page. It functions 
like the accessed bit.

> > +static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
> > +{
> > +	INIT_HLIST_HEAD(&mnh->head);
> > +}
> > +
> > +#define mmu_notifier(function, mm, args...)				\
> > +	do {								\
> > +		struct mmu_notifier *__mn;				\
> > +		struct hlist_node *__n;					\
> > +									\
> > +		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
> > +			rcu_read_lock();				\
> > +			hlist_for_each_entry_rcu(__mn, __n,		\
> > +					     &(mm)->mmu_notifier.head,	\
> > +					     hlist)			\
> > +				if (__mn->ops->function)		\
> > +					__mn->ops->function(__mn,	\
> > +							    mm,		\
> > +							    args);	\
> > +			rcu_read_unlock();				\
> > +		}							\
> > +	} while (0)
> 
> The macro references its args more than once.  Anyone who does
> 
> 	mmu_notifier(function, some_function_which_has_side_effects())
> 
> will get a surprise.  Use temporaries.

Ok.

> > +#define mmu_notifier(function, mm, args...)				\
> > +	do {								\
> > +		if (0) {						\
> > +			struct mmu_notifier *__mn;			\
> > +									\
> > +			__mn = (struct mmu_notifier *)(0x00ff);		\
> > +			__mn->ops->function(__mn, mm, args);		\
> > +		};							\
> > +	} while (0)
> 
> That's a bit weird.  Can't we do the old
> 
> 	(void)function;
> 	(void)mm;
> 
> trick?  Or make it a staic inline function?

Static inline wont allow the checking of the parameters.

(void) may be a good thing here.

> > +config MMU_NOTIFIER
> > +	def_bool y
> > +	bool "MMU notifier, for paging KVM/RDMA"
> 
> Why is this not selectable?  The help seems a bit brief.
> 
> Does this cause 32-bit systems to drag in a bunch of code they're not
> allowed to ever use?

I have selected it a number of times. We could make that a bit longer 
right.


> > +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> > +		hlist_for_each_entry_safe(mn, n, t,
> > +					  &mm->mmu_notifier.head, hlist) {
> > +			hlist_del_init(&mn->hlist);
> > +			if (mn->ops->release)
> > +				mn->ops->release(mn, mm);
> 
> We do this a lot, but back in the old days people didn't like optional
> callbacks which can be NULL.  If we expect that mmu_notifier_ops.release is
> usually implemented, the just unconditionally call it and require that all
> clients implement it.  Perhaps provide an exported-to-modules stuv in core
> kernel for clients which didn't want to implement ->release().

Ok.

> > +{
> > +	struct mmu_notifier *mn;
> > +	struct hlist_node *n;
> > +	int young = 0;
> > +
> > +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> > +		rcu_read_lock();
> > +		hlist_for_each_entry_rcu(mn, n,
> > +					  &mm->mmu_notifier.head, hlist) {
> > +			if (mn->ops->age_page)
> > +				young |= mn->ops->age_page(mn, mm, address);
> > +		}
> > +		rcu_read_unlock();
> > +	}
> > +
> > +	return young;
> > +}
> 
> should the rcu_read_lock() cover the hlist_empty() test?
> 
> This function looks like it was tossed in at the last minute.  It's
> mysterious, undocumented, poorly commented, poorly named.  A better name
> would be one which has some correlation with the return value.
> 
> Because anyone who looks at some code which does
> 
> 	if (mmu_notifier_age_page(mm, address))
> 		...
> 
> has to go and reverse-engineer the implementation of
> mmu_notifier_age_page() to work out under which circumstances the "..."
> will be executed.  But this should be apparent just from reading the callee
> implementation.
> 
> This function *really* does need some documentation.  What does it *mean*
> when the ->age_page() from some of the notifiers returned "1" and the
> ->age_page() from some other notifiers returned zero?  Dunno.

Andrea: Could you provide some more detail here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
