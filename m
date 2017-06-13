Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABD076B0390
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:24:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m5so73652131pgn.1
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:24:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f123si8986690pfg.37.2017.06.13.03.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 03:24:50 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DAOm7E122851
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:24:50 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b2btvhnj1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:24:50 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 13 Jun 2017 11:24:45 +0100
Subject: Re: [RFC v4 00/20] Speculative page faults
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170612102008.GC22728@quack2.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 13 Jun 2017 12:24:39 +0200
MIME-Version: 1.0
In-Reply-To: <20170612102008.GC22728@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <8637a49b-a25b-27e7-82cf-8d4d12e7b4b6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 12/06/2017 12:20, Jan Kara wrote:
> Hello,
> 
> On Fri 09-06-17 16:20:49, Laurent Dufour wrote:
>> This is a port on kernel 4.12 of the work done by Peter Zijlstra to
>> handle page fault without holding the mm semaphore.
>>
>> http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
>>
>> Compared to the Peter initial work, this series introduce a try spin
>> lock when dealing with speculative page fault. This is required to
>> avoid dead lock when handling a page fault while a TLB invalidate is
>> requested by an other CPU holding the PTE. Another change due to a
>> lock dependency issue with mapping->i_mmap_rwsem.
>>
>> This series also protect changes to VMA's data which are read or
>> change by the page fault handler. The protections is done through the
>> VMA's sequence number.
>>
>> This series is functional on x86 and PowerPC.
>>
>> It's building on top of v4.12-rc4 and relies on the change done by
>> Paul McKenney to the SRCU code allowing better performance by
>> maintaining per-CPU callback lists:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=da915ad5cf25b5f5d358dd3670c3378d8ae8c03e
>>
>> Tests have been made using a large commercial in-memory database on a
>> PowerPC system with 752 CPUs. The results are very encouraging since
>> the loading of the 2TB database was faster by 20% with the speculative
>> page fault.
>>
>> Since tests are encouraging and running test suite didn't raise any
>> issue, I'd like this request for comment series to move to a patch
>> series soon. So please feel free to comment.
> 
> I had a look at the series and I have one comment regarding the whole
> structure of the series: Instead of taking original Peter's patches and
> then fixing up various problems with them, either fold the fixes into
> original patches which introduced problems (this would make sense for
> example for the lock inversion issue you fix) or just put these changes
> to a place in the series where they logically belong - e.g. VMA is
> protected by the sequence counter in patch 4 and then you add various
> places that were missed later in the series. Instead of this just handle
> sequence count protection in consecutive logical steps like vma_adjust()
> changes, mremap() changes, munmap() changes, vma->flags protection, ...

Thanks Jan for the review,

I tried to keep the Peter's patches intact, but I agree, that may not be
a good idea, and I tend to split this series in too much small patches.

I think I'll fold the changes I made into the original patches, this may
also fix some build test issue raised earlier.

> Also amount of 'XXX' comments seems to be a bit to high and these should be
> addressed.

Right, I'll get rid of them !

Thanks,
Laurent.

> 
> 								Honza
>>
>> Changes since V3:
>>  - support for the 5-level paging.
>>  - abort speculative path before entering userfault code
>>  - support for PowerPC architecture
>>  - reorder the patch to fix build test errors.
>>
>> Laurent Dufour (14):
>>   mm: Introduce pte_spinlock
>>   mm/spf: Try spin lock in speculative path
>>   mm/spf: Fix fe.sequence init in __handle_mm_fault()
>>   mm/spf: don't set fault entry's fields if locking failed
>>   mm/spf; fix lock dependency against mapping->i_mmap_rwsem
>>   mm/spf: Protect changes to vm_flags
>>   mm/spf Protect vm_policy's changes against speculative pf
>>   mm/spf: Add check on the VMA's flags
>>   mm/spf: protect madvise vs speculative pf
>>   mm/spf: protect mremap() against speculative pf
>>   mm/spf: Don't call user fault callback in the speculative path
>>   x86/mm: Update the handle_speculative_fault's path
>>   powerpc/mm: Add speculative page fault
>>   mm/spf: Clear FAULT_FLAG_KILLABLE in the speculative path
>>
>> Peter Zijlstra (6):
>>   mm: Dont assume page-table invariance during faults
>>   mm: Prepare for FAULT_FLAG_SPECULATIVE
>>   mm: VMA sequence count
>>   mm: RCU free VMAs
>>   mm: Provide speculative fault infrastructure
>>   x86/mm: Add speculative pagefault handling
>>
>>  arch/powerpc/mm/fault.c  |  25 +++-
>>  arch/x86/mm/fault.c      |  14 +++
>>  fs/proc/task_mmu.c       |   2 +
>>  include/linux/mm.h       |   4 +
>>  include/linux/mm_types.h |   3 +
>>  kernel/fork.c            |   1 +
>>  mm/init-mm.c             |   1 +
>>  mm/internal.h            |  20 ++++
>>  mm/madvise.c             |   4 +
>>  mm/memory.c              | 291 +++++++++++++++++++++++++++++++++++++++--------
>>  mm/mempolicy.c           |  10 +-
>>  mm/mlock.c               |   9 +-
>>  mm/mmap.c                | 123 +++++++++++++++-----
>>  mm/mprotect.c            |   2 +
>>  mm/mremap.c              |   7 ++
>>  15 files changed, 435 insertions(+), 81 deletions(-)
>>
>> -- 
>> 2.7.4
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
