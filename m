Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7564E6B02FD
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:54:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n75so191020091pfh.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:54:31 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d19si23700799pgk.108.2017.05.24.02.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 02:54:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 00/10] x86: 5-level paging enabling for v4.12, Part 4
Date: Wed, 24 May 2017 12:54:09 +0300
Message-Id: <20170524095419.14281-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's silghtly revised version of the last bunch of of patches that brings
initial 5-level paging enabling.

Please review and consider applying.

Changes since v5:
 - Added patch to re-apply switching x86 to generic GUP_fast(). It was reverted
   earlier from tip/mm due to regression.
 - X86_5LEVEL now conflicts with XEN_PV, not whole XEN.
 - Ack from Michal for the last patch.
 - Remove unused L4_START_KERNEL from head_64.S.

Kirill A. Shutemov (10):
  x86/mm/gup: Switch GUP to the generic get_user_page_fast()
    implementation
  x86/asm: Fix comment in return_from_SYSCALL_64
  x86/boot/64: Rewrite startup_64 in C
  x86/boot/64: Rename init_level4_pgt and early_level4_pgt
  x86/boot/64: Add support of additional page table level during early
    boot
  x86/mm: Add sync_global_pgds() for configuration with 5-level paging
  x86/mm: Make kernel_physical_mapping_init() support 5-level paging
  x86/mm: Add support for 5-level paging for KASLR
  x86: Enable 5-level paging support
  x86/mm: Allow to have userspace mappings above 47-bits

 arch/arm/Kconfig                            |   2 +-
 arch/arm64/Kconfig                          |   2 +-
 arch/powerpc/Kconfig                        |   2 +-
 arch/x86/Kconfig                            |   8 +
 arch/x86/boot/compressed/head_64.S          |  23 +-
 arch/x86/entry/entry_64.S                   |   3 +-
 arch/x86/include/asm/elf.h                  |   4 +-
 arch/x86/include/asm/mmu_context.h          |  12 -
 arch/x86/include/asm/mpx.h                  |   9 +
 arch/x86/include/asm/pgtable-3level.h       |  47 +++
 arch/x86/include/asm/pgtable.h              |  55 ++-
 arch/x86/include/asm/pgtable_64.h           |  22 +-
 arch/x86/include/asm/processor.h            |  12 +-
 arch/x86/include/uapi/asm/processor-flags.h |   2 +
 arch/x86/kernel/espfix_64.c                 |   2 +-
 arch/x86/kernel/head64.c                    | 143 +++++++-
 arch/x86/kernel/head_64.S                   | 131 ++------
 arch/x86/kernel/machine_kexec_64.c          |   2 +-
 arch/x86/kernel/sys_x86_64.c                |  30 +-
 arch/x86/mm/Makefile                        |   2 +-
 arch/x86/mm/dump_pagetables.c               |   2 +-
 arch/x86/mm/gup.c                           | 496 ----------------------------
 arch/x86/mm/hugetlbpage.c                   |  27 +-
 arch/x86/mm/init_64.c                       | 108 +++++-
 arch/x86/mm/kasan_init_64.c                 |  12 +-
 arch/x86/mm/kaslr.c                         |  81 +++--
 arch/x86/mm/mmap.c                          |   6 +-
 arch/x86/mm/mpx.c                           |  33 +-
 arch/x86/realmode/init.c                    |   2 +-
 arch/x86/xen/Kconfig                        |   1 +
 arch/x86/xen/mmu_pv.c                       |  16 +-
 arch/x86/xen/xen-pvh.S                      |   2 +-
 mm/Kconfig                                  |   2 +-
 mm/gup.c                                    |  10 +-
 34 files changed, 605 insertions(+), 706 deletions(-)
 delete mode 100644 arch/x86/mm/gup.c

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
