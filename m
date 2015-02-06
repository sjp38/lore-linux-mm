Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E8D746B0038
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:51:13 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so15162443pdb.4
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:51:13 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g8si10528117pdk.182.2015.02.06.06.51.12
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 00/19] expose page table levels as Kconfig option
Date: Fri,  6 Feb 2015 16:50:45 +0200
Message-Id: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've implemented accounting for pmd page tables as we have for pte (see
mm->nr_ptes). It's requires a new counter in mm_struct: mm->nr_pmds.

But the feature doesn't make any sense if an architecture has PMD level
folded and it would be nice get rid of the counter in this case.

The problem is that we cannot use __PAGETABLE_PMD_FOLDED in
<linux/mm_types.h> due to circular dependencies:

<linux/mm_types> -> <asm/pgtable.h> -> <linux/mm_types.h>

In most cases <asm/pgtable.h> wants <linux/mm_types.h> to get definition
of struct page and struct vm_area_struct. I've tried to split mm_struct
into separate header file to be able to user <asm/pgtable.h> there.

But it doesn't fly on some architectures, like ARM: it wants mm_struct
<asm/pgtable.h> to implement tlb flushing. I don't see how to fix it without
massive de-inlining or coverting a lot for inline functions to macros.

This is other approach: expose number of page tables in use via Kconfig
and use it in <linux/mm_types.h> instead of __PAGETABLE_PMD_FOLDED from
<asm/pgtable.h>.

v2:
  - powerpc: s/64K_PAGES/PPC_64K_PAGES/;
  - s390: fix typo s/64BI/64BIT/;
  - ia64: fix default for IA64_PAGE_SIZE_64KB;
  - x86: s/PAGETABLE_LEVELS/CONFIG_PGTABLE_LEVELS/ include/trace/events/xen.h;

Kirill A. Shutemov (19):
  alpha: expose number of page table levels on Kconfig level
  arm64: expose number of page table levels on Kconfig level
  arm: expose number of page table levels on Kconfig level
  frv: mark PUD and PMD folded
  ia64: expose number of page table levels on Kconfig level
  m32r: mark PMD folded
  m68k: mark PMD folded and expose number of page table levels
  mips: expose number of page table levels on Kconfig level
  mn10300: mark PUD and PMD folded
  parisc: expose number of page table levels on Kconfig level
  powerpc: expose number of page table levels on Kconfig level
  s390: expose number of page table levels
  sh: expose number of page table levels
  sparc: expose number of page table levels
  tile: expose number of page table levels
  um: expose number of page table levels
  x86: expose number of page table levels on Kconfig level
  mm: define default PGTABLE_LEVELS to two
  mm: do not add nr_pmds into mm_struct if PMD is folded

 arch/Kconfig                                |  4 ++++
 arch/alpha/Kconfig                          |  4 ++++
 arch/arm/Kconfig                            |  5 +++++
 arch/arm64/Kconfig                          | 14 +++++++-------
 arch/arm64/include/asm/kvm_mmu.h            |  4 ++--
 arch/arm64/include/asm/page.h               |  4 ++--
 arch/arm64/include/asm/pgalloc.h            |  8 ++++----
 arch/arm64/include/asm/pgtable-hwdef.h      |  6 +++---
 arch/arm64/include/asm/pgtable-types.h      | 12 ++++++------
 arch/arm64/include/asm/pgtable.h            |  8 ++++----
 arch/arm64/include/asm/tlb.h                |  4 ++--
 arch/arm64/mm/mmu.c                         |  4 ++--
 arch/frv/include/asm/pgtable.h              |  2 ++
 arch/ia64/Kconfig                           | 18 +++++-------------
 arch/ia64/include/asm/page.h                |  4 ++--
 arch/ia64/include/asm/pgalloc.h             |  4 ++--
 arch/ia64/include/asm/pgtable.h             | 12 ++++++------
 arch/ia64/kernel/ivt.S                      | 12 ++++++------
 arch/ia64/kernel/machine_kexec.c            |  4 ++--
 arch/m32r/include/asm/pgtable-2level.h      |  1 +
 arch/m68k/Kconfig                           |  4 ++++
 arch/m68k/include/asm/pgtable_mm.h          |  2 ++
 arch/mips/Kconfig                           |  5 +++++
 arch/mn10300/include/asm/pgtable.h          |  2 ++
 arch/parisc/Kconfig                         |  5 +++++
 arch/parisc/include/asm/pgalloc.h           |  2 +-
 arch/parisc/include/asm/pgtable.h           | 17 ++++++++---------
 arch/parisc/kernel/entry.S                  |  4 ++--
 arch/parisc/kernel/head.S                   |  4 ++--
 arch/parisc/mm/init.c                       |  2 +-
 arch/powerpc/Kconfig                        |  6 ++++++
 arch/s390/Kconfig                           |  5 +++++
 arch/s390/include/asm/pgtable.h             |  2 ++
 arch/sh/Kconfig                             |  4 ++++
 arch/sparc/Kconfig                          |  4 ++++
 arch/tile/Kconfig                           |  5 +++++
 arch/um/Kconfig.um                          |  5 +++++
 arch/x86/Kconfig                            |  6 ++++++
 arch/x86/include/asm/paravirt.h             |  8 ++++----
 arch/x86/include/asm/paravirt_types.h       |  8 ++++----
 arch/x86/include/asm/pgalloc.h              |  8 ++++----
 arch/x86/include/asm/pgtable-2level_types.h |  1 -
 arch/x86/include/asm/pgtable-3level_types.h |  2 --
 arch/x86/include/asm/pgtable.h              |  8 ++++----
 arch/x86/include/asm/pgtable_64_types.h     |  1 -
 arch/x86/include/asm/pgtable_types.h        |  4 ++--
 arch/x86/kernel/paravirt.c                  |  6 +++---
 arch/x86/mm/pgtable.c                       | 14 +++++++-------
 arch/x86/xen/mmu.c                          | 14 +++++++-------
 include/asm-generic/pgtable.h               |  5 +++++
 include/linux/mm_types.h                    |  2 ++
 include/trace/events/xen.h                  |  2 +-
 52 files changed, 183 insertions(+), 118 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
