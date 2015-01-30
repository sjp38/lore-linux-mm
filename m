Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E7FF0828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:44:00 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so53124874pad.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:44:00 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ub10si13831752pbc.203.2015.01.30.06.43.51
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/19] expose page table levels on Kconfig leve
Date: Fri, 30 Jan 2015 16:43:09 +0200
Message-Id: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've failed my attempt on split up mm_struct into separate header file to
be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
too much breakage and requires massive de-inlining of some architectures
(notably ARM and S390 with PGSTE).

This is other approach: expose number of page table levels on Kconfig
level and use it to get rid of nr_pmds in mm_struct.

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
 51 files changed, 182 insertions(+), 117 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
