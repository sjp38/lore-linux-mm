Subject: Re: [RFC PATCH for -mm 3/5] kill unnecessary locked_vm adjustment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080813174122.E779.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811160542.945F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1218570910.6360.120.camel@lts-notebook>
	 <20080813174122.E779.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 15 Aug 2008 09:54:36 -0400
Message-Id: <1218808477.6373.49.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-13 at 18:37 +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > > Now, __mlock_vma_pages_range never return positive value.
> > > So, locked_vm adjustment code is unnecessary.
> > 
> > True, __mlock_vma_pages_range() does not return a positive value.  [It
> > didn't before this patch series, right?]  
> 
> True.
> 
> 
> > However, you are now counting
> > mlocked hugetlb pages and user mapped kernel pages against locked_vm--at
> > least in the mmap(MAP_LOCKED) path--even tho' we don't actually mlock().
> > Note that mlock[all]() will still avoid counting these pages in
> > mlock_fixup(), as I think it should.
> > 
> > Huge shm pages are already counted against user->locked_shm.  This patch
> > counts them against mm->locked_vm, as well, if one mlock()s them.  But,
> > since locked_vm and locked_shm are compared to the memlock rlimit
> > independently, so we won't be double counting the huge pages against
> > either limit.  However,  mlock()ed [not SHMLOCKed] hugetlb pages will
> > now be counted against locked_vm limit and will reduce the amount of
> > non-shm memory that the task can lock [maybe not such a bad thing?].
> > Also, mlock()ed hugetlb pages will be included in the /proc/<pid>/status
> > "VmLck" element, even tho' they're not really mlocked and they don't
> > show up in the /proc/meminfo "Mlocked" count.
> > 
> > Similarly, mlock()ing a vm range backed by kernel pages--e.g.,
> > VM_RESERVED|VM_DONTEXPAND vmas--will show up in the VmLck status
> > element, but won't actually be mlocked nor counted in Mlocked meminfo
> > field.  They will be counted against the task's locked vm limit.
> > 
> > So, I don't know whether to Ack or Nack this.  I guess it's no further
> > from reality than the current code.  But, I don't think you need this
> > one.  The code already differentiates between negative values as error
> > codes and non-negative values as an adjustment to locked_vm, so you
> > should be able to meet the standards mandated error returns without this
> > patch.  
> > 
> > Still thinking about this...
> 
> I think...
> 
> In general, nobody want regression.
> and locked_vm exist from long time ago.
> 
> So, We shouldn't change locked_vm behavior although this have
> very strange behavior.
> 
> in linus-tree locked_vm indicate count of amount of VM_LOCKED vma range,
> not populated pages nor number of physical pages of locked vma.
> 
> Yes, current linus-tree locked_vm code have some strange behavior.
> but if we want to change it, we should split out from split-lru patch, IMHO.
> 
> Then, I hope to remove locked_vm adjustment code.
> Am I missing point?

OK.  

I'd like to drop this patch and keep the locked_vm adjustment.  It
should still handle the error conditions, as a negative 'adjustment'
from mlock_vma_pages_range() is handled correctly as an error code.

Now, why keep the adjustment?

First, I agree that locked_vm tracks amount of locked Virtual Memory, as
the name indicates.  IMO, this is not a useful metric.  I think what we
want to track IS the amount of physical memory locked down by the tasks.
However, this is difficult.  Consider that today, if one has called,
say, mlockall(MCL_FUTURE) and then you mmap() some large segment into
your address space more than once, you'll get charged for the locked_vm
each time you mmap() the same segment.  One can easily exceed the
rlimit, even when the actual amount of locked pages is less than the
limit.  But, as I say, this is difficult to fix efficiently and I don't
want to try to do that in the context of these patches.

Now, taking the view that locked_vm counts VM_LOCKED vmas, note that we
do not set VM_LOCKED for those vmas where it does not make sense to
mlock the pages with SetPageMlocked().  That is, the "special" vmas,
that have the following flags:  VM_IO, VM_PFNMAP, VM_RESERVED,
VM_DONTEXPAND, and VM_HUGETLB -- all of the vmas that we filter out in
mlock_fixup().  

Now, for vmas with VM_IO or VM_PFNMAP, we don't even attempt to
"make_pages_present()" because get_user_pages() will error out
immediately.  For the other types, we do make_pages_present() to avoid
future minor faults, but we don't set PageMlocked().  Because we don't
want to have to deal with these vmas during munmap() [including exit
processing] nor duplicate the vma filtering in that path, we don't set
the VM_LOCKED flags for these vmas.  Since the vma is not VM_LOCKED, we
don't want to count the memory as locked_vm.  

For mlock[all](), we do the locked_vm accounting in mlock_fixup().  We
just don't count these vmas.  See the comments "don't set VM_LOCKED,
don't count" in the code.  However, mmap() does the locked_vm accounting
before calling mlock_vma_pages_range() [which replaces calls to
make_pages_present()].  To make mmap(MAP_LOCKED) behavior consistent
with mlock[all]() behavior, we return a "locked_vm" adjustment from
mlock_vma_pages_range().  For the filtered, special vmas, this is always
the size of the vma which mmap() has already added to locked_vm().  

So, I'd like to keep the adjustment returned by mlock_vma_pages_range().
However, as you note, the internal function __mlock_vma_pages_range()
always returns non-positive values [in earlier versions of this series
it could return a positive, non-zero value but I decided that was not
appropriate].  It can, however, return an error code with your changes.
If we keep the locked_vm adjustment, as I propose here, then we need to
pass any return value from __mlock_vma_pages_range() via the "nr_pages"
variable which can contain an error code [< 0] as well as a locked_vm
adjustment [>= 0].

IMO, we still have some issues in locked_vm accounting that needs to be
addressed.  E.g., when you attached a hugetlb shm segment, it is
automatically counted as locked_shm [tracked independently of locked_vm
in the user struct instead of mm -- go figure!].  However, when we
mmap() a hugetlbfs file, we don't automatically add this to locked_vm.
Maybe we should, but not as part of this patch series, I think.

Does this make sense?

Maybe I need to explain the rationale better in the unevictable_lru
documentation.  I do discuss the behavior [locked_vm adjustment], but
maybe not enough rationale.

Lee


> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
