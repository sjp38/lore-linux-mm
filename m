Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D80E06B0314
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:31:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d13so979320pgf.12
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:31:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y9si9748415pli.57.2017.06.06.04.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:31:40 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 00/14] x86: 5-level paging enabling for v4.13, Part 4
Date: Tue,  6 Jun 2017 14:31:19 +0300
Message-Id: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's updated version of the last bunch of of patches that brings initial
5-level paging enabling.

Please review and consider applying.

Changes since v6:
 - Major rework 5-level paging enabling in decompression code to fix #GP when
   bootloader enables long mode.
 - Fix in sync_global_pgds() (Andrey Ryabinin);
 - Couple Reviewed-by form Juergen Gross.

Kirill A. Shutemov (14):
  x86/mm/gup: Switch GUP to the generic get_user_page_fast()
    implementation
  x86/asm: Fix comment in return_from_SYSCALL_64
  x86/boot/efi: Cleanup initialization of GDT entries
  x86/boot/efi: Fix __KERNEL_CS definition of GDT entry on 64-bit
    configuration
  x86/boot/efi: Define __KERNEL32_CS GDT on 64-bit configurations
  x86/boot/compressed: Enable 5-level paging during decompression stage
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
 arch/x86/boot/compressed/eboot.c            |  73 ++--
 arch/x86/boot/compressed/head_64.S          |  86 ++++-
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
 35 files changed, 722 insertions(+), 725 deletions(-)
 delete mode 100644 arch/x86/mm/gup.c

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
