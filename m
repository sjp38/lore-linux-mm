Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 338666B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 14:56:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q97so9717063wrb.14
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 11:56:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b3si425130wmc.47.2017.06.09.11.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 11:56:06 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59Ircri103173
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 14:56:05 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2aywh0j3cj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 14:56:05 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 14:56:04 -0400
Date: Fri, 9 Jun 2017 11:55:58 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC v4 00/20] Speculative page faults
Reply-To: paulmck@linux.vnet.ibm.com
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <20170609185558.GK3721@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On Fri, Jun 09, 2017 at 04:20:49PM +0200, Laurent Dufour wrote:
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

For whatever it is worth, this series passes moderate rcutorture testing,
30 minutes on each of sixteen scenarios.  Not that rcutorture is set up
to find mmap_sem issues, but it does place some stress on the kernel as
a whole.

Tested-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

							Thanx, Paul

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
