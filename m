Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id D22556B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 19:04:44 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so543155eek.31
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 16:04:44 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id m44si486183eef.44.2014.01.28.16.04.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 16:04:43 -0800 (PST)
Date: Tue, 28 Jan 2014 19:03:59 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140129000359.GZ6963@cmpxchg.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>

Hello Minchan,

On Thu, Jan 02, 2014 at 04:12:08PM +0900, Minchan Kim wrote:
> Hey all,
> 
> Happy New Year!
> 
> I know it's bad timing to send this unfamiliar large patchset for
> review but hope there are some guys with freshed-brain in new year
> all over the world. :)
> And most important thing is that before I dive into lots of testing,
> I'd like to make an agreement on design issues and others
> 
> o Syscall interface

Why do we need another syscall for this?  Can't we extend madvise to
take MADV_VOLATILE, MADV_NONVOLATILE, and return -ENOMEM if something
in the range was purged?

> o Not bind with vma split/merge logic to prevent mmap_sem cost and
> o Not bind with vma split/merge logic to avoid vm_area_struct memory
>   footprint.

VMAs are there to track attributes of memory ranges.  Duplicating
large parts of their functionality and co-maintaining both structures
on create, destroy, split, and merge means duplicate code and complex
interactions.

1. You need to define semantics and coordinate what happens when the
   vma underlying a volatile range changes.

   Either you have to strictly co-maintain both range objects, or you
   have weird behavior like volatily outliving a vma and then applying
   to a separate vma created in its place.

   Userspace won't get this right, and even in the kernel this is
   error prone and adds a lot to the complexity of vma management.

2. If page reclaim discards a page from the upper end of a a range,
   you mark the whole range as purged.  If the user later marks the
   lower half of the range as non-volatile, the syscall will report
   purged=1 even though all requested pages are still there.

   The only way to make these semantics clean is either

     a) have vrange() return a range ID so that only full ranges can
     later be marked non-volatile, or

     b) remember individual page purges so that sub-range changes can
     properly report them

   I don't like a) much because it's somewhat arbitrarily more
   restrictive than madvise, mprotect, mmap/munmap etc.  And for b),
   the straight-forward solution would be to put purge-cookies into
   the page tables to properly report purges in subrange changes, but
   that would be even more coordination between vmas, page tables, and
   the ad-hoc vranges.

3. Page reclaim usually happens on individual pages until an
   allocation can be satisfied, but the shrinker purges entire ranges.

   Should it really take out an entire 1G volatile range even though 4
   pages would have been enough to satisfy an allocation?  Sure, we
   assume a range represents an single "object" and userspace would
   have to regenerate the whole thing with only one page missing, but
   there is still a massive difference in page frees, faults, and
   allocations.

There needs to be a *really* good argument why VMAs are not enough for
this purpose.  I would really like to see anon volatility implemented
as a VMA attribute, and have regular reclaim decide based on rmap of
individual pages whether it needs to swap or purge.  Something like
this:

MADV_VOLATILE:
  split vma if necessary
  set VM_VOLATILE

MADV_NONVOLATILE:
  clear VM_VOLATILE
  merge vma if possible
  pte walk to check for pmd_purged()/pte_purged()
  return any_purged

shrink_page_list():
  if PageAnon:
    if try_to_purge_anon():
      page_lock_anon_vma_read()
      anon_vma_interval_tree_foreach:
        if vma->vm_flags & VM_VOLATILE:
          lock page table
          unmap page
          set_pmd_purged() / set_pte_purged()
          unlock page table
      page_lock_anon_vma_read()
   ...
   try to reclaim

> o Purging logic - when we trigger purging volatile pages to prevent
>   working set and stop to prevent too excessive purging of volatile
>   pages
> o How to test
>   Currently, we have a patched jemalloc allocator by Jason's help
>   although it's not perfect and more rooms to be enhanced but IMO,
>   it's enough to prove vrange-anonymous. The problem is that
>   lack of benchmark for testing vrange-file side. I hope that
>   Mozilla folks can help.
> 
> So its been a while since the last release of the volatile ranges
> patches, again. I and John have been busy with other things.
> Still, we have been slowly chipping away at issues and differences
> trying to get a patchset that we both agree on.
> 
> There's still a few issues, but we figured any further polishing of
> the patch series in private would be unproductive and it would be much
> better to send the patches out for review and comment and get some wider
> opinions.
> 
> You could get full patchset by git
> 
> git clone -b vrange-v10-rc5 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git
> 
> In v10, there are some notable changes following as
> 
> Whats new in v10:
> * Fix several bugs and build break
> * Add shmem_purge_page to correct purging shmem/tmpfs
> * Replace slab shrinker with direct hooked reclaim path
> * Optimize pte scanning by caching previous place
> * Reorder patch and tidy up Cc-list
> * Rebased on v3.12
> * Add vrange-anon test with jemalloc in Dhaval's test suite
>   - https://github.com/volatile-ranges-test/vranges-test
>   so, you could test any application with vrange-patched jemalloc by
>   LD_PRELOAD but please keep in mind that it's just a prototype to
>   prove vrange syscall concept so it has more rooms to optimize.
>   So, please do not compare it with another allocator.
>    
> Whats new in v9:
> * Updated to v3.11
> * Added vrange purging logic to purge anonymous pages on
>   swapless systems

We stopped scanning anon on swapless systems because anon needed swap
to be reclaimable.  If we can reclaim anon without swap, we have to
start scanning anon again unconditionally.  It makes no sense to me to
work around this optimization and implement a separate reclaim logic.

> The syscall interface is defined in patch [4/16] in this series, but
> briefly there are two ways to utilze the functionality:
> 
> Explicit marking method:
> 1) Userland marks a range of memory that can be regenerated if necessary
> as volatile
> 2) Before accessing the memory again, userland marks the memroy as
> nonvolatile, and the kernel will provide notifcation if any pages in the
> range has been purged.
>
> Optimistic method:
> 1) Userland marks a large range of data as volatile
> 2) Userland continues to access the data as it needs.
> 3) If userland accesses a page that has been purged, the kernel will
> send a SIGBUS
> 4) Userspace can trap the SIGBUS, mark the afected pages as
> non-volatile, and refill the data as needed before continuing on

What happens if a pointer to volatile memory is passed to a syscall
and the fault happens inside copy_*_user()?

> Other details:
> The interface takes a range of memory, which can cover anonymous pages
> as well as mmapped file pages. In the case that the pages are from a
> shared mmapped file, the volatility set on those file pages is global.
> Thus much as writes to those pages are shared to other processes, pages
> marked volatile will be volatile to any other processes that have the
> file mapped as well. It is advised that processes coordinate when using
> volatile ranges on shared mappings (much as they must coordinate when
> writing to shared data). Any uncleared volatility on mmapped files will
> last until the the file is closed by all users (ie: volatility isn't
> persistent on disk).

Support for file pages are a very big deal and they seem to have had
an impact on many design decisions, but they are only mentioned on a
side note in this email.

The rationale behind volatile anon pages was that they are often used
as caches and that dropping them under pressure and regenerating the
cache contents later on was much faster than swapping.

But pages that are backed by an actual filesystem are "regenerated" by
reading the contents back from disk!  What's the point of declaring
them volatile?

Shmem pages are a different story.  They might be implemented by a
virtual filesystem, but they behave like anon pages when it comes to
reclaim and repopulation so the same rationale for volatility appies.

But a big aspect of anon volatility is communicating to userspace
whether *content* has been destroyed while in volatile state.  Shmem
pages might not necessarily need this.  The oft-cited example is the
message passing in a large circular buffer that is unused most of the
time.  The sender would mark it non-volatile before writing, and the
receiver would mark it volatile again after reading.  The writer can
later reuse any unreclaimed *memory*, but nobody is coming back for
the actual *contents* stored in there.  This usecase would be
perfectly fine with an interface that simply clears the dirty bits of
a range of shmem pages (through mmap or fd).  The writer would set the
pages non-volatile by dirtying them, whereas the reader would mark
them volatile again by clearing the dirty bits.  Reclaim would simply
discard clean pages.

So I'm not convinced that the anon side needs to be that awkward, that
all filesystems need to be supported because of shmem, and that shmem
needs more than an interface to clear dirty bits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
