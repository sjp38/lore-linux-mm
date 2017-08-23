Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43BE36B04C8
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:03:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e2so13550276pgf.7
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:03:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u91si986989plb.1010.2017.08.23.05.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:03:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 00/19] Boot-time switching between 4- and 5-level paging
Date: Wed, 23 Aug 2017 15:03:13 +0300
Message-Id: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The basic idea is to implement the same logic as pgtable-nop4d.h provides,
but at runtime.

Runtime folding is only implemented for CONFIG_X86_5LEVEL=y case. With the
option disabled, we do compile-time folding as before.

Initially, I tried to fold pgd instread. I've got to shell, but it
required a lot of hacks as kernel threats pgd in a special way.

Ingo, if no objections, could you apply the series?

v6:
 - Fix few checkpatch warnings;

v5:
 - Split changes into more patches;
 - Rename p4d_folded to pgtable_l5_enabled and reverse logic around it;
 - Update commit messages to reflect effect on kernel image size;

v4:
 - Use ALTERNATIVE to patch return_from_SYSCALL_64 (Andi);
 - Use __read_mostly where appropriate (Andi);
 - Make X86_5LEVEL dependant on SPARSEMEM_VMEMMAP;
 - Fix build errors and warnings;

v3:
 - Make sparsemem data structures allocation dynamic to lower memory overhead on
   4-level paging machines;
 - Allow XEN_PV and XEN_PVH to be enabled with X86_5LEVEL;
 - XEN cleanups;

Kirill A. Shutemov (19):
  mm/sparsemem: Allocate mem_section at runtime for SPARSEMEM_EXTREME
  mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
  x86/kasan: Use the same shadow offset for 4- and 5-level paging
  x86/xen: Provide pre-built page tables only for XEN_PV and XEN_PVH
  x86/xen: Drop 5-level paging support code from XEN_PV code
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
  x86/mm: Make virtual memory layout movable for CONFIG_X86_5LEVEL
  x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D variable
  x86/mm: Make MAX_PHYSADDR_BITS and MAX_PHYSMEM_BITS dynamic
  x86/mm: Make __PHYSICAL_MASK_SHIFT and __VIRTUAL_MASK_SHIFT dynamic
  x86/mm: Make STACK_TOP_MAX dynamic
  x86/mm: Adjust virtual address space layout in early boot.
  x86/mm: Make early boot code support boot-time switching of paging
    modes
  x86/mm: Fold p4d page table layer at runtime
  x86/mm: Replace compile-time checks for 5-level with runtime-time
  x86/mm: Allow to boot without la57 if CONFIG_X86_5LEVEL=y
  x86/xen: Allow XEN_PV and XEN_PVH to be enabled with X86_5LEVEL
  x86/mm: Redefine some of page table helpers as macros
  x86/mm: Offset boot-time paging mode switching cost

 Documentation/x86/x86_64/5level-paging.txt |   9 +-
 arch/x86/Kconfig                           |   6 +-
 arch/x86/boot/compressed/head_64.S         |  24 ++++
 arch/x86/boot/compressed/kaslr.c           |  14 +++
 arch/x86/boot/compressed/misc.h            |   5 +
 arch/x86/entry/entry_64.S                  |   5 +
 arch/x86/include/asm/kaslr.h               |   4 -
 arch/x86/include/asm/page_64.h             |   4 +
 arch/x86/include/asm/page_64_types.h       |  15 +--
 arch/x86/include/asm/paravirt.h            |  21 ++--
 arch/x86/include/asm/pgalloc.h             |   5 +-
 arch/x86/include/asm/pgtable.h             |  10 +-
 arch/x86/include/asm/pgtable_32.h          |   2 +
 arch/x86/include/asm/pgtable_32_types.h    |   2 +
 arch/x86/include/asm/pgtable_64_types.h    |  53 ++++++---
 arch/x86/include/asm/pgtable_types.h       |  67 +++--------
 arch/x86/include/asm/processor.h           |   2 +-
 arch/x86/include/asm/required-features.h   |   8 +-
 arch/x86/include/asm/sparsemem.h           |   9 +-
 arch/x86/kernel/Makefile                   |   3 +-
 arch/x86/kernel/head64.c                   |  81 +++++++++++--
 arch/x86/kernel/head_64.S                  |  29 +++--
 arch/x86/kernel/setup.c                    |   5 +-
 arch/x86/mm/dump_pagetables.c              |  20 ++--
 arch/x86/mm/fault.c                        |   2 +-
 arch/x86/mm/ident_map.c                    |   2 +-
 arch/x86/mm/init_64.c                      |  32 ++---
 arch/x86/mm/kasan_init_64.c                |  98 ++++++++++++----
 arch/x86/mm/kaslr.c                        |  27 ++---
 arch/x86/platform/efi/efi_64.c             |   6 +-
 arch/x86/power/hibernate_64.c              |   6 +-
 arch/x86/xen/Kconfig                       |   5 -
 arch/x86/xen/mmu_pv.c                      | 180 +++++++++++++----------------
 include/asm-generic/5level-fixup.h         |   1 +
 include/asm-generic/pgtable-nop4d.h        |   1 +
 include/linux/kasan.h                      |   2 +-
 include/linux/mmzone.h                     |   6 +-
 mm/kasan/kasan_init.c                      |   2 +-
 mm/page_alloc.c                            |  10 ++
 mm/sparse.c                                |  17 ++-
 mm/zsmalloc.c                              |   6 +
 41 files changed, 483 insertions(+), 323 deletions(-)

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
