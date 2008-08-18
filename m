Subject: Re: [RFC PATCH for -mm 3/5] kill unnecessary locked_vm adjustment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080818164449.60CE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080813174122.E779.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1218808477.6373.49.camel@lts-notebook>
	 <20080818164449.60CE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 18 Aug 2008 16:56:06 -0400
Message-Id: <1219092966.6232.47.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-18 at 18:23 +0900, KOSAKI Motohiro wrote:
> Hi Lee-san,
> 
> Sorry for late responce.
> 
> I understand your intention.
> I agreed almost part of your explain, but I have few disagree points.
> 
> 
> > I'd like to drop this patch and keep the locked_vm adjustment.  It
> > should still handle the error conditions, as a negative 'adjustment'
> > from mlock_vma_pages_range() is handled correctly as an error code.
> > 
> > Now, why keep the adjustment?
> > 
> > First, I agree that locked_vm tracks amount of locked Virtual Memory, as
> > the name indicates.  IMO, this is not a useful metric.  I think what we
> > want to track IS the amount of physical memory locked down by the tasks.
> 
> hmmm..
> Sorry, disagreed.
> Various application assume current behavior.
> 
> So, I like adding to "locked physical memory" metrics, not replace.
> 
> 
> > However, this is difficult.  Consider that today, if one has called,
> > say, mlockall(MCL_FUTURE) and then you mmap() some large segment into
> > your address space more than once, you'll get charged for the locked_vm
> > each time you mmap() the same segment.  One can easily exceed the
> > rlimit, even when the actual amount of locked pages is less than the
> > limit.  But, as I say, this is difficult to fix efficiently and I don't
> > want to try to do that in the context of these patches.
> 
> Agreed.
> This is mmap()'s bug.
> 
> 
> > Now, taking the view that locked_vm counts VM_LOCKED vmas, note that we
> > do not set VM_LOCKED for those vmas where it does not make sense to
> > mlock the pages with SetPageMlocked().  That is, the "special" vmas,
> > that have the following flags:  VM_IO, VM_PFNMAP, VM_RESERVED,
> > VM_DONTEXPAND, and VM_HUGETLB -- all of the vmas that we filter out in
> > mlock_fixup().  
> >
> > Now, for vmas with VM_IO or VM_PFNMAP, we don't even attempt to
> > "make_pages_present()" because get_user_pages() will error out
> > immediately.  For the other types, we do make_pages_present() to avoid
> > future minor faults, but we don't set PageMlocked().  Because we don't
> > want to have to deal with these vmas during munmap() [including exit
> > processing] nor duplicate the vma filtering in that path, we don't set
> > the VM_LOCKED flags for these vmas.  Since the vma is not VM_LOCKED, we
> > don't want to count the memory as locked_vm.  
> >
> > For mlock[all](), we do the locked_vm accounting in mlock_fixup().  We
> > just don't count these vmas.  See the comments "don't set VM_LOCKED,
> > don't count" in the code.  However, mmap() does the locked_vm accounting
> > before calling mlock_vma_pages_range() [which replaces calls to
> > make_pages_present()].  To make mmap(MAP_LOCKED) behavior consistent
> > with mlock[all]() behavior, we return a "locked_vm" adjustment from
> > mlock_vma_pages_range().  For the filtered, special vmas, this is always
> > the size of the vma which mmap() has already added to locked_vm().  
> 
> Agreed.
> That is definitly bug. (and this isn't introduced by us)
> 
> but current implementation is slightly bad.
> 
> mlock_vma_pages_range()'s prototype is ..
> 
> 	int mlock_vma_pages_range(struct vm_area_struct *vma,
> 	                        unsigned long start, unsigned long end)
> 
>     ==> return type is int.
> 
> but sys_mlock()'s prototype is ..
> 
> 	asmlinkage long sys_mlock(unsigned long start, size_t len)
> 
>     ==> len argument's type is size_t.
> 
> So, this adjustment code can overflow easily.
> 
> maybe, mlock_vma_pages_range()'s type should be changed as bellow
> 
> 	int mlock_vma_pages_range(struct vm_area_struct *vma,
> 	                        unsigned long start, unsigned long end,
> 	                        unsigned long *locked_pages)
> 
> 
> but, I think this should do as another patch 
> because its bug isn't introduced by us, then it is another change.
> 
> 
> So, I like following order changing.
> 
> 1. remove current adjustment code from split-lru patch series
> 2. re-introduce it as another patch. (of cource, overflow problem should be fixed)
> 
> 
> > So, I'd like to keep the adjustment returned by mlock_vma_pages_range().
> > However, as you note, the internal function __mlock_vma_pages_range()
> > always returns non-positive values [in earlier versions of this series
> > it could return a positive, non-zero value but I decided that was not
> > appropriate].  It can, however, return an error code with your changes.
> > If we keep the locked_vm adjustment, as I propose here, then we need to
> > pass any return value from __mlock_vma_pages_range() via the "nr_pages"
> > variable which can contain an error code [< 0] as well as a locked_vm
> > adjustment [>= 0].
> >
> > IMO, we still have some issues in locked_vm accounting that needs to be
> > addressed.  E.g., when you attached a hugetlb shm segment, it is
> > automatically counted as locked_shm [tracked independently of locked_vm
> > in the user struct instead of mm -- go figure!].  However, when we
> > mmap() a hugetlbfs file, we don't automatically add this to locked_vm.
> > Maybe we should, but not as part of this patch series, I think.
> 
> Agreed.
> 
> > Does this make sense?
> > 
> > Maybe I need to explain the rationale better in the unevictable_lru
> > documentation.  I do discuss the behavior [locked_vm adjustment], but
> > maybe not enough rationale.
> 
> 
> Could you tell me your feeling about my concern?


OK, here's what I propose:

I'll regenerate the patches against the current mmotm, such that they
apply after the related patches.  After the patch
"/mmap-handle-mlocked-pages-during-map-remap-unmap.patch", we'll have
the following three patches:

1) back out the locked_vm changes from this patch, so that we can apply
as a separate patch.  This #1 patch can [should] be folded into the
"mmap-handle-mlocked-pages..." patch.  This is essentially your patch
3/5, reworked to fit into this location.
2) a new patch to handle the locked_vm accounting during mmap() to match
mlock() behavior and the state of VM_LOCKED flags.  Essentially, this
will restore the current behavior, with a separate patch description.
I'll also change the nr_pages type to long to alleviate your concern
about overflow.  [But note nr_pages != nr_bytes.]
3) your patch, 4/5, to fix the error return of mlock_fixup() when next
vma changes during mlock() with downgraded semaphore.

Next, I think that the Posix mlock() error return issue is separate from
the unevictable mlocked page handling, altho' it touches the same code.
So, I propose two more patches to apply atop 27-rc*-mmotm, as follows:

1) revert the change to make_pages_present() in memory.c and mlock.c
from the mainline to address the mlock() posix error return.
make_pages_present() is not just for mlock().  Altho' all other callers
ignore the return value, we have a "better" place to put the error code
translation in mlock.c now.  
2) patch mlock.c in __mlock_vma_pages_range() [both versions] to
translate the error return from get_user_pages/make_pages_present to the
proper Posix value.  This patch will only affect mlock() error returns.

I have these patches cooking now, but will not have a change to post
them today.  I'll send them out tomorrow.

Regards,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
