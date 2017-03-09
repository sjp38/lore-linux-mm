Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6342808D6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:25:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id l66so113932228pfl.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:25:04 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 90si6583840pfp.242.2017.03.09.06.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 06:25:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/7] 5-level paging: prepare generic code
Date: Thu,  9 Mar 2017 17:24:01 +0300
Message-Id: <20170309142408.2868-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's relatively low-risk part of 5-level paging patchset.
Merging it now would make x86 5-level paging enabling in v4.12 easier.

Linus, please consider applying.


The first patch is actually x86-specific: detect 5-level paging support.
It boils down to single define.

The rest of patchset converts Linux MMU abstraction from 4- to 5-level
paging.

Enabling of new abstraction in most cases requires adding single line of
code in arch-specific code. The rest is taken care by asm-generic/.

Changes to mm/ code are mostly mechanical: add support for new page table
level -- p4d_t -- where we deal with pud_t now.

v2:
  - fix build on microblaze (Michal);
  - comment for __ARCH_HAS_5LEVEL_HACK in kasan_populate_zero_shadow();
  - acks from Michal;

Kirill A. Shutemov (7):
  x86/cpufeature: Add 5-level paging detection
  asm-generic: introduce 5level-fixup.h
  asm-generic: introduce __ARCH_USE_5LEVEL_HACK
  arch, mm: convert all architectures to use 5level-fixup.h
  asm-generic: introduce <asm-generic/pgtable-nop4d.h>
  mm: convert generic code to 5-level paging
  mm: introduce __p4d_alloc()

 arch/arc/include/asm/hugepage.h                  |   1 +
 arch/arc/include/asm/pgtable.h                   |   1 +
 arch/arm/include/asm/pgtable.h                   |   1 +
 arch/arm64/include/asm/pgtable-types.h           |   4 +
 arch/avr32/include/asm/pgtable-2level.h          |   1 +
 arch/cris/include/asm/pgtable.h                  |   1 +
 arch/frv/include/asm/pgtable.h                   |   1 +
 arch/h8300/include/asm/pgtable.h                 |   1 +
 arch/hexagon/include/asm/pgtable.h               |   1 +
 arch/ia64/include/asm/pgtable.h                  |   2 +
 arch/metag/include/asm/pgtable.h                 |   1 +
 arch/microblaze/include/asm/page.h               |   3 +-
 arch/mips/include/asm/pgtable-32.h               |   1 +
 arch/mips/include/asm/pgtable-64.h               |   1 +
 arch/mn10300/include/asm/page.h                  |   1 +
 arch/nios2/include/asm/pgtable.h                 |   1 +
 arch/openrisc/include/asm/pgtable.h              |   1 +
 arch/powerpc/include/asm/book3s/32/pgtable.h     |   1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h     |   3 +
 arch/powerpc/include/asm/nohash/32/pgtable.h     |   1 +
 arch/powerpc/include/asm/nohash/64/pgtable-4k.h  |   3 +
 arch/powerpc/include/asm/nohash/64/pgtable-64k.h |   1 +
 arch/s390/include/asm/pgtable.h                  |   1 +
 arch/score/include/asm/pgtable.h                 |   1 +
 arch/sh/include/asm/pgtable-2level.h             |   1 +
 arch/sh/include/asm/pgtable-3level.h             |   1 +
 arch/sparc/include/asm/pgtable_64.h              |   1 +
 arch/tile/include/asm/pgtable_32.h               |   1 +
 arch/tile/include/asm/pgtable_64.h               |   1 +
 arch/um/include/asm/pgtable-2level.h             |   1 +
 arch/um/include/asm/pgtable-3level.h             |   1 +
 arch/unicore32/include/asm/pgtable.h             |   1 +
 arch/x86/include/asm/cpufeatures.h               |   3 +-
 arch/x86/include/asm/pgtable_types.h             |   4 +
 arch/xtensa/include/asm/pgtable.h                |   1 +
 drivers/misc/sgi-gru/grufault.c                  |   9 +-
 fs/userfaultfd.c                                 |   6 +-
 include/asm-generic/4level-fixup.h               |   3 +-
 include/asm-generic/5level-fixup.h               |  41 ++++
 include/asm-generic/pgtable-nop4d-hack.h         |  62 ++++++
 include/asm-generic/pgtable-nop4d.h              |  56 ++++++
 include/asm-generic/pgtable-nopud.h              |  48 ++---
 include/asm-generic/pgtable.h                    |  48 ++++-
 include/asm-generic/tlb.h                        |  14 +-
 include/linux/hugetlb.h                          |   5 +-
 include/linux/kasan.h                            |   1 +
 include/linux/mm.h                               |  34 +++-
 lib/ioremap.c                                    |  39 +++-
 mm/gup.c                                         |  46 ++++-
 mm/huge_memory.c                                 |   7 +-
 mm/hugetlb.c                                     |  29 +--
 mm/kasan/kasan_init.c                            |  44 ++++-
 mm/memory.c                                      | 230 +++++++++++++++++++----
 mm/mlock.c                                       |   1 +
 mm/mprotect.c                                    |  26 ++-
 mm/mremap.c                                      |  13 +-
 mm/page_vma_mapped.c                             |   6 +-
 mm/pagewalk.c                                    |  32 +++-
 mm/pgtable-generic.c                             |   6 +
 mm/rmap.c                                        |   7 +-
 mm/sparse-vmemmap.c                              |  22 ++-
 mm/swapfile.c                                    |  26 ++-
 mm/userfaultfd.c                                 |  23 ++-
 mm/vmalloc.c                                     |  81 +++++---
 64 files changed, 868 insertions(+), 147 deletions(-)
 create mode 100644 include/asm-generic/5level-fixup.h
 create mode 100644 include/asm-generic/pgtable-nop4d-hack.h
 create mode 100644 include/asm-generic/pgtable-nop4d.h

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
