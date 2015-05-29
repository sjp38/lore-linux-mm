Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id D43876B0032
	for <linux-mm@kvack.org>; Fri, 29 May 2015 19:18:47 -0400 (EDT)
Received: by obew15 with SMTP id w15so68865384obe.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 16:18:47 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id kp7si4397837oeb.81.2015.05.29.16.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 16:18:46 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v11 0/12] Support Write-Through mapping on x86
Date: Fri, 29 May 2015 16:58:58 -0600
Message-Id: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

This patchset adds support of Write-Through (WT) mapping on x86.
The study below shows that using WT mapping may be useful for
non-volatile memory.

http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf

The patchset consists of the following changes.
 - Patch 1/12 to 2/12 refactor !pat_enable paths
 - Patch 3/12 to 8/12 add ioremap_wt()
 - Patch 9/12 adds pgprot_writethrough()
 - Patch 10/12 to 11/12 add set_memory_wt()
 - Patch 12/12 changes the pmem driver to call ioremap_wt()

All new/modified interfaces have been tested.

---
v11:
- Reordered the refactor changes from patch 10-11 to 1-2.
  (Borislav Petkov)
- Changed BUG() to panic(). (Borislav Petkov)
- Rebased to tip/master and resolved conflicts. 

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
 1/12 x86, mm, pat: Cleanup init flags in pat_init()
 2/12 x86, mm, pat: Refactor !pat_enable handling
 3/12 x86, mm, pat: Set WT to PA7 slot of PAT MSR
 4/12 x86, mm, pat: Change reserve_memtype() for WT
 5/12 x86, asm: Change is_new_memtype_allowed() for WT
 6/12 x86, mm, asm-gen: Add ioremap_wt() for WT
 7/12 arch/*/asm/io.h: Add ioremap_wt() to all architectures
 8/12 video/fbdev, asm/io.h: Remove ioremap_writethrough()
 9/12 x86, mm, pat: Add pgprot_writethrough() for WT
10/12 x86, mm, asm: Add WT support to set_page_memtype()
11/12 x86, mm: Add set_memory_wt() for WT
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
 arch/x86/mm/pat.c                    | 229 +++++++++++++++++++++++------------
 arch/xtensa/include/asm/io.h         |   1 +
 drivers/block/pmem.c                 |   4 +-
 drivers/video/fbdev/amifb.c          |   4 +-
 drivers/video/fbdev/atafb.c          |   3 +-
 drivers/video/fbdev/hpfb.c           |   4 +-
 include/asm-generic/io.h             |   9 ++
 include/asm-generic/iomap.h          |   4 +
 include/asm-generic/pgtable.h        |   4 +
 34 files changed, 310 insertions(+), 125 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
