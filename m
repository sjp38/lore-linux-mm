Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 83F536B0092
	for <linux-mm@kvack.org>; Wed, 27 May 2015 11:38:38 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so562162pac.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 08:38:38 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id nw14si4587056pab.158.2015.05.27.08.38.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 08:38:37 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v10 0/12] Support Write-Through mapping on x86
Date: Wed, 27 May 2015 09:18:52 -0600
Message-Id: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

This patchset adds support of Write-Through (WT) mapping on x86.
The study below shows that using WT mapping may be useful for
non-volatile memory.

http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf

The patchset consists of the following changes.
 - Patch 1/12 to 6/12 add ioremap_wt()
 - Patch 7/12 adds pgprot_writethrough()
 - Patch 8/12 to 9/12 add set_memory_wt()
 - Patch 10/12 to 11/12 refactor !pat_enable paths
 - Patch 12/12 changes the pmem driver to call ioremap_wt()

All new/modified interfaces have been tested.

---
v10:
- Removed ioremap_writethrough(). (Thomas Gleixner)
- Clarified and cleaned up multiple comments and functions.
  (Thomas Gleixner) 
- Changed ioremap_change_attr() to accept the WT type.

v9:
- Changed to export the set_xxx_wt() interfaces with GPL.
  (Ingo Molnar)
- Changed is_new_memtype_allowed() to handle WT cases.
- Changed arch-specific io.h to define ioremap_wt().
- Changed the pmem driver to use ioremap_wt().
- Rebased to 4.1-rc3 and resolved minor conflicts.

v8:
- Rebased to 4.0-rc1 and resolved conflicts with 9d34cfdf4 in
  patch 5/7.

v7:
- Rebased to 3.19-rc3 as Juergen's patchset for the PAT management
  has been accepted.

v6:
- Dropped the patch moving [set|get]_page_memtype() to pat.c
  since the tip branch already has this change.
- Fixed an issue when CONFIG_X86_PAT is not defined.

v5:
- Clarified comment of why using slot 7. (Andy Lutomirski,
  Thomas Gleixner)
- Moved [set|get]_page_memtype() to pat.c. (Thomas Gleixner)
- Removed BUG() from set_page_memtype(). (Thomas Gleixner)

v4:
- Added set_memory_wt() by adding WT support of regular memory.

v3:
- Dropped the set_memory_wt() patch. (Andy Lutomirski)
- Refactored the !pat_enabled handling. (H. Peter Anvin,
  Andy Lutomirski)
- Added the picture of PTE encoding. (Konrad Rzeszutek Wilk)

v2:
- Changed WT to use slot 7 of the PAT MSR. (H. Peter Anvin,
  Andy Lutomirski)
- Changed to have conservative checks to exclude all Pentium 2, 3,
  M, and 4 families. (Ingo Molnar, Henrique de Moraes Holschuh,
  Andy Lutomirski)
- Updated documentation to cover WT interfaces and usages.
  (Andy Lutomirski, Yigal Korman)

---
Toshi Kani (12):
 1/12 x86, mm, pat: Set WT to PA7 slot of PAT MSR
 2/12 x86, mm, pat: Change reserve_memtype() for WT
 3/12 x86, asm: Change is_new_memtype_allowed() for WT
 4/12 x86, mm, asm-gen: Add ioremap_wt() for WT
 5/12 arch/*/asm/io.h: Add ioremap_wt() to all architectures
 6/12 video/fbdev, asm/io.h: Remove ioremap_writethrough()
 7/12 x86, mm, pat: Add pgprot_writethrough() for WT
 8/12 x86, mm, asm: Add WT support to set_page_memtype()
 9/12 x86, mm: Add set_memory_wt() for WT
10/12 x86, mm, pat: Cleanup init flags in pat_init()
11/12 x86, mm, pat: Refactor !pat_enable handling
12/12 drivers/block/pmem: Map NVDIMM with ioremap_wt()

---
 Documentation/x86/pat.txt            |  13 +-
 arch/arc/include/asm/io.h            |   1 +
 arch/arm/include/asm/io.h            |   1 +
 arch/arm64/include/asm/io.h          |   1 +
 arch/avr32/include/asm/io.h          |   1 +
 arch/frv/include/asm/io.h            |   4 +-
 arch/m32r/include/asm/io.h           |   1 +
 arch/m68k/include/asm/io_mm.h        |   4 +-
 arch/m68k/include/asm/io_no.h        |   4 +-
 arch/metag/include/asm/io.h          |   3 +
 arch/microblaze/include/asm/io.h     |   2 +-
 arch/mn10300/include/asm/io.h        |   1 +
 arch/nios2/include/asm/io.h          |   1 +
 arch/s390/include/asm/io.h           |   1 +
 arch/sparc/include/asm/io_32.h       |   1 +
 arch/sparc/include/asm/io_64.h       |   1 +
 arch/tile/include/asm/io.h           |   2 +-
 arch/x86/include/asm/cacheflush.h    |   6 +-
 arch/x86/include/asm/io.h            |   2 +
 arch/x86/include/asm/pgtable.h       |   8 +-
 arch/x86/include/asm/pgtable_types.h |   3 +
 arch/x86/mm/init.c                   |   6 +-
 arch/x86/mm/iomap_32.c               |  12 +-
 arch/x86/mm/ioremap.c                |  29 ++++-
 arch/x86/mm/pageattr.c               |  65 +++++++---
 arch/x86/mm/pat.c                    | 232 +++++++++++++++++++++++------------
 arch/xtensa/include/asm/io.h         |   1 +
 drivers/block/pmem.c                 |   4 +-
 drivers/video/fbdev/amifb.c          |   4 +-
 drivers/video/fbdev/atafb.c          |   3 +-
 drivers/video/fbdev/hpfb.c           |   4 +-
 include/asm-generic/io.h             |   9 ++
 include/asm-generic/iomap.h          |   4 +
 include/asm-generic/pgtable.h        |   4 +
 34 files changed, 311 insertions(+), 127 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
