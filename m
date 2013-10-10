Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0046B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:07 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so2998364pde.37
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/34] dynamically allocate split ptl if it cannot be embedded to struct page
Date: Thu, 10 Oct 2013 21:05:25 +0300
Message-Id: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In split page table lock case, we embed spinlock_t into struct page. For
obvious reason, we don't want to increase size of struct page if
spinlock_t is too big, like with DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC or on
-rt kernel. So we disble split page table lock, if spinlock_t is too big.

This patchset allows to allocate the lock dynamically if spinlock_t is
big. In this page->ptl is used to store pointer to spinlock instead of
spinlock itself. It costs additional cache line for indirect access, but
fix page fault scalability for multi-threaded applications.

LOCK_STAT depends on DEBUG_SPINLOCK, so on current kernel enabling
LOCK_STAT to analyse scalability issues breaks scalability. ;)

The patchset mostly fixes this. Results for ./thp_memscale -c 80 -b 512M
on 4-socket machine:

baseline, no CONFIG_LOCK_STAT:	9.115460703 seconds time elapsed
baseline, CONFIG_LOCK_STAT=y:	53.890567123 seconds time elapsed
patched, no CONFIG_LOCK_STAT:	8.852250368 seconds time elapsed
patched, CONFIG_LOCK_STAT=y:	11.069770759 seconds time elapsed

Patch count is scary, but most of them trivial. Overview:

 Patches 1-4	Few bug fixes. No dependencies to other patches.
		Probably should applied as soon as possible.

 Patch 5	Changes signature of pgtable_page_ctor(). We will use it
		for dynamic lock allocation, so it can fail.

 Patches 6-8	Add missing constructor/destructor calls on few archs.
		It's fixes NR_PAGETABLE accounting and prepare to use
		split ptl.

 Patches 9-33	Add pgtable_page_ctor() fail handling to all archs.

 Patches 34	Finally adds support of dynamically-allocated page->pte.
		Also contains documentation for split page table lock.

Any comments?

Kirill A. Shutemov (34):
  x86: add missed pgtable_pmd_page_ctor/dtor calls for preallocated pmds
  cris: fix potential NULL-pointer dereference
  m32r: fix potential NULL-pointer dereference
  xtensa: fix potential NULL-pointer dereference
  mm: allow pgtable_page_ctor() to fail
  microblaze: add missing pgtable_page_ctor/dtor calls
  mn10300: add missing pgtable_page_ctor/dtor calls
  openrisc: add missing pgtable_page_ctor/dtor calls
  alpha: handle pgtable_page_ctor() fail
  arc: handle pgtable_page_ctor() fail
  arm: handle pgtable_page_ctor() fail
  arm64: handle pgtable_page_ctor() fail
  avr32: handle pgtable_page_ctor() fail
  cris: handle pgtable_page_ctor() fail
  frv: handle pgtable_page_ctor() fail
  hexagon: handle pgtable_page_ctor() fail
  ia64: handle pgtable_page_ctor() fail
  m32r: handle pgtable_page_ctor() fail
  m68k: handle pgtable_page_ctor() fail
  metag: handle pgtable_page_ctor() fail
  mips: handle pgtable_page_ctor() fail
  parisc: handle pgtable_page_ctor() fail
  powerpc: handle pgtable_page_ctor() fail
  s390: handle pgtable_page_ctor() fail
  score: handle pgtable_page_ctor() fail
  sh: handle pgtable_page_ctor() fail
  sparc: handle pgtable_page_ctor() fail
  tile: handle pgtable_page_ctor() fail
  um: handle pgtable_page_ctor() fail
  unicore32: handle pgtable_page_ctor() fail
  x86: handle pgtable_page_ctor() fail
  xtensa: handle pgtable_page_ctor() fail
  iommu/arm-smmu: handle pgtable_page_ctor() fail
  mm: dynamically allocate page->ptl if it cannot be embedded to struct
    page

 Documentation/vm/split_page_table_lock   | 90 ++++++++++++++++++++++++++++++++
 arch/alpha/include/asm/pgalloc.h         |  5 +-
 arch/arc/include/asm/pgalloc.h           | 11 ++--
 arch/arm/include/asm/pgalloc.h           | 12 +++--
 arch/arm64/include/asm/pgalloc.h         |  9 ++--
 arch/avr32/include/asm/pgalloc.h         |  5 +-
 arch/cris/include/asm/pgalloc.h          |  7 ++-
 arch/frv/mm/pgalloc.c                    | 12 +++--
 arch/hexagon/include/asm/pgalloc.h       | 10 ++--
 arch/ia64/include/asm/pgalloc.h          |  5 +-
 arch/m32r/include/asm/pgalloc.h          |  7 ++-
 arch/m68k/include/asm/motorola_pgalloc.h |  5 +-
 arch/m68k/include/asm/sun3_pgalloc.h     |  5 +-
 arch/metag/include/asm/pgalloc.h         |  8 ++-
 arch/microblaze/include/asm/pgalloc.h    | 12 +++--
 arch/mips/include/asm/pgalloc.h          |  9 ++--
 arch/mn10300/include/asm/pgalloc.h       |  1 +
 arch/mn10300/mm/pgtable.c                |  9 +++-
 arch/openrisc/include/asm/pgalloc.h      | 10 +++-
 arch/parisc/include/asm/pgalloc.h        |  8 ++-
 arch/powerpc/include/asm/pgalloc-64.h    |  5 +-
 arch/powerpc/mm/pgtable_32.c             |  5 +-
 arch/powerpc/mm/pgtable_64.c             |  7 +--
 arch/s390/mm/pgtable.c                   | 11 +++-
 arch/score/include/asm/pgalloc.h         |  9 ++--
 arch/sh/include/asm/pgalloc.h            |  5 +-
 arch/sparc/mm/init_64.c                  | 11 ++--
 arch/sparc/mm/srmmu.c                    |  5 +-
 arch/tile/mm/pgtable.c                   |  6 ++-
 arch/um/kernel/mem.c                     |  8 ++-
 arch/unicore32/include/asm/pgalloc.h     | 14 ++---
 arch/x86/mm/pgtable.c                    | 19 +++++--
 arch/x86/xen/mmu.c                       |  2 +-
 arch/xtensa/include/asm/pgalloc.h        | 11 +++-
 drivers/iommu/arm-smmu.c                 |  5 +-
 include/linux/mm.h                       | 73 +++++++++++++++++++-------
 include/linux/mm_types.h                 |  5 +-
 mm/Kconfig                               |  2 -
 mm/memory.c                              | 19 +++++++
 39 files changed, 365 insertions(+), 97 deletions(-)
 create mode 100644 Documentation/vm/split_page_table_lock

-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
