Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD3C6B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o68so29160469pfj.20
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c32si2998544plj.162.2017.04.27.08.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:08 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFpZ7J005265
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:07 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3j0k57gt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:07 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:02 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 00/17] Speculative page faults
Date: Thu, 27 Apr 2017 17:52:39 +0200
Message-Id: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

This is a port on kernel 4.10 of the work done by Peter Zijlstra to
handle page fault without holding the mm semaphore.

http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none

This series is functional on x86, but there may be some pending
issues. It's building on top of v4.10.

Compared to the Peter initial work, this series introduces a try spin
lock when dealing with speculative page fault. This is required to
avoid dead lock when handling a page fault while a TLB invalidate is
requested by an other CPU holding the PTE. Another change due to a
lock dependency issue with mapping->i_mmap_rwsem.

This series also protect changes to VMA's data which are read or
change by the page fault handler. The protections is done through the
VMA's sequence number.

Laurent Dufour (11):
  mm: Introduce pte_spinlock
  mm/spf: Try spin lock in speculative path
  mm/spf: Fix fe.sequence init in __handle_mm_fault()
  mm/spf: don't set fault entry's fields if locking failed
  mm/spf; fix lock dependency against mapping->i_mmap_rwsem
  mm/spf: Protect changes to vm_flags
  mm/spf Protect vm_policy's changes against speculative pf
  x86/mm: Update the handle_speculative_fault's path
  mm/spf: Add check on the VMA's flags
  mm: protect madvise vs speculative pf
  mm/spf: protect mremap() against speculative pf

Peter Zijlstra (6):
  mm: Dont assume page-table invariance during faults
  mm: Prepare for FAULT_FLAG_SPECULATIVE
  mm: VMA sequence count
  RCU free VMAs
  mm: Provide speculative fault infrastructure
  mm,x86: Add speculative pagefault handling

 arch/x86/mm/fault.c      |  15 +++
 fs/proc/task_mmu.c       |   2 +
 include/linux/mm.h       |   4 +
 include/linux/mm_types.h |   3 +
 kernel/fork.c            |   1 +
 mm/init-mm.c             |   1 +
 mm/internal.h            |  18 +++
 mm/madvise.c             |   5 +-
 mm/memory.c              | 284 +++++++++++++++++++++++++++++++++++++++--------
 mm/mempolicy.c           |  10 +-
 mm/mlock.c               |   9 +-
 mm/mmap.c                | 121 +++++++++++++++-----
 mm/mprotect.c            |   2 +
 mm/mremap.c              |   7 ++
 14 files changed, 402 insertions(+), 80 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
