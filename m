Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4A06B025E
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:35:58 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id x26so62780569qtb.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:35:58 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n5si3843607qkl.85.2016.12.16.10.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:35:57 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 00/14] sparc64 shared context/TLB support
Date: Fri, 16 Dec 2016 10:35:23 -0800
Message-Id: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

In Sparc mm code today, each address space is assigned a unique context
identifier.  This context ID is stored in context register 0 of the MMU.
This same context ID is stored in TLB entries.  When the MMU is searching
for a virtual address translation, the context ID as well as the virtual
address must match for a TLB hit.

Beginning with Sparc Niagara 2 processors, the MMU contains an additional
context register (register 1).  When searching the TLB, the MMU will find
a match if the virtual address matches and the ID contained in either
context register 0 -OR- context register 1 matches.

In the Linux kernel today, only context register 0 is set and used by
the MMU.  Solaris has made use of the additional context register for shared
mappings.  If two tasks share an appropriate mapping, then both tasks set
context register 1 to the same value and associate that value with the
shared mapping.  In this way, both tasks can use the same TLB entries for
pages of the shared mapping.

This RFC adds support for the additional context register, and extends the
mmap and System V shared memory system calls so that an application can
request shared context mappings.  At a very high level, this works as follows:
- An application passes a new SHARED_CTX flag to mmap or shmat
- The vma associated with the mapping is marked with a SHARED_CTX flag
  - When a SHARED_CTX marked vma is first created, all other vma's mapping
    the same underlying object are searched looking for a match that:
	1) Is also marked SHARED_CTX 
	2) Is mapped at the same virtual address
  - If a match is found, the new vma shares a context ID with the existing vma.
  - If no match is found, a context ID is allocated for the new vma
- sparc specific code associates the context ID with pages in the shared
  mappings.

This RFC patch series limits a task to having only a single shared context
vma.  Shared context vmas in different processes must match exactly (start
and length) to be shared.  In addition, shared context support is only
provided for huge page (hugetlb) mappings.  These and other restrictions can
be relaxed as the code is further developed.

Most of the code in this patch series is sparc specific for management of
the new context ID and associated TSB entries.  However, there is arch
independent code which needs to enable the flagging of mappings which request
shared context.

This is early proof of concept code.  It is not polished, and there is need
for much more work.  There are even FIXME comments in the code.  My hope is
that it is sufficiently readable to start a discussion about the general
direction to enable such functionality.

It does function, and with perf you can see a reduction in TLB misses for
shared context mappings.  A simple test program which has two tasks touch
pages in a shared mapping has the following dTLB miss rates.

Testing		Normal Mapping			Shared Context Mapping
Rounds		dTLB-load-misses		dTLB-load-misses
1			771				834
10		      1,651				881
100		     10,422				874
1000		     97,992				958
10000		    975,910				963
100000	  	  9,719,193			      1,017
1000000		 97,941,327			      4,148

Mike Kravetz (14):
  sparc64: placeholder for needed mmu shared context patching
  sparc64: add new fields to mmu context for shared context support
  sparc64: routines for basic mmu shared context structure management
  sparc64: load shared id into context register 1
  sparc64: Add PAGE_SHR_CTX flag
  sparc64: general shared context tsb creation and support
  sparc64: move COMPUTE_TAG_TARGET and COMPUTE_TSB_PTR to header file
  sparc64: shared context tsb handling at context switch time
  sparc64: TLB/TSB miss handling for shared context
  mm: add shared context to vm_area_struct
  sparc64: add routines to look for vmsa which can share context
  mm: add mmap and shmat arch hooks for shared context
  sparc64 mm: add shared context support to mmap() and shmat() APIs
  sparc64: add SHARED_MMU_CTX Kconfig option

 arch/powerpc/include/asm/mmu_context.h   |  12 ++
 arch/s390/include/asm/mmu_context.h      |  12 ++
 arch/sparc/Kconfig                       |   3 +
 arch/sparc/include/asm/hugetlb.h         |   4 +
 arch/sparc/include/asm/mman.h            |   6 +
 arch/sparc/include/asm/mmu_64.h          |  36 +++++-
 arch/sparc/include/asm/mmu_context_64.h  | 139 ++++++++++++++++++++++--
 arch/sparc/include/asm/page_64.h         |   1 +
 arch/sparc/include/asm/pgtable_64.h      |  13 +++
 arch/sparc/include/asm/spitfire.h        |   2 +
 arch/sparc/include/asm/tlb_64.h          |   3 +
 arch/sparc/include/asm/trap_block.h      |   3 +-
 arch/sparc/include/asm/tsb.h             |  40 +++++++
 arch/sparc/include/uapi/asm/mman.h       |   1 +
 arch/sparc/kernel/fpu_traps.S            |  63 +++++++++++
 arch/sparc/kernel/head_64.S              |   2 +-
 arch/sparc/kernel/rtrap_64.S             |  20 ++++
 arch/sparc/kernel/setup_64.c             |  11 ++
 arch/sparc/kernel/smp_64.c               |  22 ++++
 arch/sparc/kernel/sun4v_tlb_miss.S       |  37 ++-----
 arch/sparc/kernel/sys_sparc_64.c         |  17 +++
 arch/sparc/kernel/trampoline_64.S        |  20 ++++
 arch/sparc/kernel/tsb.S                  | 172 +++++++++++++++++++++++------
 arch/sparc/mm/fault_64.c                 |  10 ++
 arch/sparc/mm/hugetlbpage.c              |  94 +++++++++++++++-
 arch/sparc/mm/init_64.c                  | 181 ++++++++++++++++++++++++++++++-
 arch/sparc/mm/tsb.c                      |  95 +++++++++++++++-
 arch/unicore32/include/asm/mmu_context.h |  12 ++
 arch/x86/include/asm/mmu_context.h       |  12 ++
 include/asm-generic/mm_hooks.h           |  18 ++-
 include/linux/mm.h                       |   1 +
 include/linux/mm_types.h                 |  13 +++
 include/uapi/linux/shm.h                 |   1 +
 ipc/shm.c                                |  13 +++
 mm/hugetlb.c                             |   9 ++
 mm/mmap.c                                |  10 ++
 36 files changed, 1018 insertions(+), 90 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
