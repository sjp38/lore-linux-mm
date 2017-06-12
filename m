Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8CBC6B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 06:20:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id s4so21927929wrc.15
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 03:20:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si9193963wrs.220.2017.06.12.03.20.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 03:20:10 -0700 (PDT)
Date: Mon, 12 Jun 2017 12:20:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC v4 00/20] Speculative page faults
Message-ID: <20170612102008.GC22728@quack2.suse.cz>
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

Hello,

On Fri 09-06-17 16:20:49, Laurent Dufour wrote:
> This is a port on kernel 4.12 of the work done by Peter Zijlstra to
> handle page fault without holding the mm semaphore.
> 
> http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
> 
> Compared to the Peter initial work, this series introduce a try spin
> lock when dealing with speculative page fault. This is required to
> avoid dead lock when handling a page fault while a TLB invalidate is
> requested by an other CPU holding the PTE. Another change due to a
> lock dependency issue with mapping->i_mmap_rwsem.
> 
> This series also protect changes to VMA's data which are read or
> change by the page fault handler. The protections is done through the
> VMA's sequence number.
> 
> This series is functional on x86 and PowerPC.
> 
> It's building on top of v4.12-rc4 and relies on the change done by
> Paul McKenney to the SRCU code allowing better performance by
> maintaining per-CPU callback lists:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=da915ad5cf25b5f5d358dd3670c3378d8ae8c03e
> 
> Tests have been made using a large commercial in-memory database on a
> PowerPC system with 752 CPUs. The results are very encouraging since
> the loading of the 2TB database was faster by 20% with the speculative
> page fault.
> 
> Since tests are encouraging and running test suite didn't raise any
> issue, I'd like this request for comment series to move to a patch
> series soon. So please feel free to comment.

I had a look at the series and I have one comment regarding the whole
structure of the series: Instead of taking original Peter's patches and
then fixing up various problems with them, either fold the fixes into
original patches which introduced problems (this would make sense for
example for the lock inversion issue you fix) or just put these changes
to a place in the series where they logically belong - e.g. VMA is
protected by the sequence counter in patch 4 and then you add various
places that were missed later in the series. Instead of this just handle
sequence count protection in consecutive logical steps like vma_adjust()
changes, mremap() changes, munmap() changes, vma->flags protection, ...

Also amount of 'XXX' comments seems to be a bit to high and these should be
addressed.

								Honza
> 
> Changes since V3:
>  - support for the 5-level paging.
>  - abort speculative path before entering userfault code
>  - support for PowerPC architecture
>  - reorder the patch to fix build test errors.
> 
> Laurent Dufour (14):
>   mm: Introduce pte_spinlock
>   mm/spf: Try spin lock in speculative path
>   mm/spf: Fix fe.sequence init in __handle_mm_fault()
>   mm/spf: don't set fault entry's fields if locking failed
>   mm/spf; fix lock dependency against mapping->i_mmap_rwsem
>   mm/spf: Protect changes to vm_flags
>   mm/spf Protect vm_policy's changes against speculative pf
>   mm/spf: Add check on the VMA's flags
>   mm/spf: protect madvise vs speculative pf
>   mm/spf: protect mremap() against speculative pf
>   mm/spf: Don't call user fault callback in the speculative path
>   x86/mm: Update the handle_speculative_fault's path
>   powerpc/mm: Add speculative page fault
>   mm/spf: Clear FAULT_FLAG_KILLABLE in the speculative path
> 
> Peter Zijlstra (6):
>   mm: Dont assume page-table invariance during faults
>   mm: Prepare for FAULT_FLAG_SPECULATIVE
>   mm: VMA sequence count
>   mm: RCU free VMAs
>   mm: Provide speculative fault infrastructure
>   x86/mm: Add speculative pagefault handling
> 
>  arch/powerpc/mm/fault.c  |  25 +++-
>  arch/x86/mm/fault.c      |  14 +++
>  fs/proc/task_mmu.c       |   2 +
>  include/linux/mm.h       |   4 +
>  include/linux/mm_types.h |   3 +
>  kernel/fork.c            |   1 +
>  mm/init-mm.c             |   1 +
>  mm/internal.h            |  20 ++++
>  mm/madvise.c             |   4 +
>  mm/memory.c              | 291 +++++++++++++++++++++++++++++++++++++++--------
>  mm/mempolicy.c           |  10 +-
>  mm/mlock.c               |   9 +-
>  mm/mmap.c                | 123 +++++++++++++++-----
>  mm/mprotect.c            |   2 +
>  mm/mremap.c              |   7 ++
>  15 files changed, 435 insertions(+), 81 deletions(-)
> 
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
