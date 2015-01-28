Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BE6D76B0070
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:24:25 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so25515796pab.12
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:24:25 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fp6si393259pdb.222.2015.01.28.05.24.24
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 05:24:25 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] Introduce <linux/mm_struct.h>
Date: Wed, 28 Jan 2015 15:17:40 +0200
Message-Id: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset moves definition of mm_struct into separate header file.
It allows to get rid of nr_pmds if PMD page table level is folded.
We cannot do it with current mm_types.h because we need
__PAGETABLE_PMD_FOLDED from <asm/pgtable.h> which creates circular
dependencies.

I've done few build tests and looks like it works, but I expect breakage
on some configuration. Please test.

I hope one day we would rely on LTO for inlining instead of this header
mess :-/

Kirill A. Shutemov (4):
  mm: move enum tlb_flush_reason into <trace/events/tlb.h>
  mm: split up mm_struct to separate header file
  mm: define __PAGETABLE_{PMD,PUD}_FOLDED to zero or one
  mm: do not add nr_pmds into mm_struct if PMD is folded

 arch/arm/include/asm/pgtable-2level.h |   2 +-
 arch/arm64/include/asm/kvm_mmu.h      |   4 +-
 arch/arm64/kernel/efi.c               |   1 +
 arch/arm64/mm/hugetlbpage.c           |   6 +-
 arch/c6x/kernel/dma.c                 |   1 -
 arch/microblaze/include/asm/pgtable.h |   2 +-
 arch/mips/include/asm/pgalloc.h       |   4 +-
 arch/mips/kernel/asm-offsets.c        |   4 +-
 arch/mips/mm/init.c                   |   2 +-
 arch/mips/mm/pgtable-64.c             |   6 +-
 arch/mips/mm/tlbex.c                  |   8 +-
 arch/powerpc/mm/pgtable_64.c          |   2 +-
 arch/s390/include/asm/pgtable.h       |   1 +
 arch/sh/mm/init.c                     |   2 +-
 arch/tile/mm/hugetlbpage.c            |   4 +-
 arch/tile/mm/pgtable.c                |   4 +-
 arch/x86/include/asm/mmu_context.h    |   1 +
 arch/x86/include/asm/pgtable.h        |  15 +--
 arch/x86/include/asm/xen/page.h       |   2 +-
 drivers/iommu/amd_iommu_v2.c          |   1 +
 drivers/staging/android/ion/ion.c     |   1 -
 include/asm-generic/4level-fixup.h    |   2 +-
 include/asm-generic/pgtable-nopmd.h   |   2 +-
 include/asm-generic/pgtable-nopud.h   |   2 +-
 include/asm-generic/pgtable.h         |   8 ++
 include/linux/mm.h                    |   5 +-
 include/linux/mm_struct.h             | 217 ++++++++++++++++++++++++++++++++
 include/linux/mm_types.h              | 226 ++--------------------------------
 include/linux/mmu_notifier.h          |   1 +
 include/linux/sched.h                 |   1 +
 include/trace/events/tlb.h            |  15 ++-
 kernel/fork.c                         |   2 +-
 mm/init-mm.c                          |   1 +
 mm/kmemcheck.c                        |   1 -
 mm/memory.c                           |   4 +-
 35 files changed, 289 insertions(+), 271 deletions(-)
 create mode 100644 include/linux/mm_struct.h

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
