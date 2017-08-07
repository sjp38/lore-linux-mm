Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA98D6B02C3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 10:15:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v77so5016926pgb.15
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 07:15:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v14si4688577pgq.229.2017.08.07.07.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 07:15:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 00/13] Boot-time switching between 4- and 5-level paging
Date: Mon,  7 Aug 2017 17:14:38 +0300
Message-Id: <20170807141451.80934-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The basic idea is to implement the same logic as pgtable-nop4d.h provides,
but at runtime.

Runtime folding is only implemented for CONFIG_X86_5LEVEL=y case. With the
option disabled, we do compile-time folding as before..

Initially, I tried to fold pgd instread. I've got to shell, but it
required a lot of hacks as kernel threats pgd in a special way.

Please review and consider applying.

v3:
 - Make sparsemem data stuctures allocation dynamic to lower memory overhead on
   4-level paging machines;
 - Allow XEN_PV and XEN_PVH to be enabled with X86_5LEVEL;
 - XEN cleanups;

Kirill A. Shutemov (13):
  mm, sparsemem: Allocate mem_section at runtime for SPARSEMEM_EXTREME
  x86/kasan: Use the same shadow offset for 4- and 5-level paging
  x86/xen: Provide pre-built page tables only for XEN_PV and XEN_PVH
  x86/xen: Drop 5-level paging support code from XEN_PV code
  x86/boot/compressed/64: Detect and handle 5-level paging at boot-time
  x86/mm: Make virtual memory layout movable for CONFIG_X86_5LEVEL
  x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D variable
  x86/mm: Handle boot-time paging mode switching at early boot
  x86/mm: Fold p4d page table layer at runtime
  x86/mm: Replace compile-time checks for 5-level with runtime-time
  x86/mm: Allow to boot without la57 if CONFIG_X86_5LEVEL=y
  x86/xen: Allow XEN_PV and XEN_PVH to be enabled with X86_5LEVEL
  x86/mm: Offset boot-time paging mode switching cost

 Documentation/x86/x86_64/5level-paging.txt |   9 +-
 arch/x86/Kconfig                           |   5 +-
 arch/x86/boot/compressed/head_64.S         |  24 ++++
 arch/x86/boot/compressed/kaslr.c           |  14 +++
 arch/x86/boot/compressed/misc.h            |   5 +
 arch/x86/entry/entry_64.S                  |  12 ++
 arch/x86/include/asm/kaslr.h               |   4 -
 arch/x86/include/asm/page_64.h             |   4 +
 arch/x86/include/asm/page_64_types.h       |  15 +--
 arch/x86/include/asm/paravirt.h            |  21 ++--
 arch/x86/include/asm/pgalloc.h             |   5 +-
 arch/x86/include/asm/pgtable.h             |  10 +-
 arch/x86/include/asm/pgtable_32.h          |   2 +
 arch/x86/include/asm/pgtable_32_types.h    |   2 +
 arch/x86/include/asm/pgtable_64_types.h    |  51 +++++---
 arch/x86/include/asm/pgtable_types.h       |  67 +++--------
 arch/x86/include/asm/processor.h           |   2 +-
 arch/x86/include/asm/required-features.h   |   8 +-
 arch/x86/include/asm/sparsemem.h           |   9 +-
 arch/x86/kernel/Makefile                   |   3 +-
 arch/x86/kernel/head64.c                   |  71 ++++++++++--
 arch/x86/kernel/head_64.S                  |  35 +++---
 arch/x86/kernel/setup.c                    |   5 +-
 arch/x86/mm/dump_pagetables.c              |  20 ++--
 arch/x86/mm/fault.c                        |   2 +-
 arch/x86/mm/ident_map.c                    |   2 +-
 arch/x86/mm/init_64.c                      |  32 ++---
 arch/x86/mm/kasan_init_64.c                |  94 +++++++++++----
 arch/x86/mm/kaslr.c                        |  27 ++---
 arch/x86/platform/efi/efi_64.c             |   6 +-
 arch/x86/power/hibernate_64.c              |   6 +-
 arch/x86/xen/Kconfig                       |   5 -
 arch/x86/xen/mmu_pv.c                      | 180 +++++++++++++----------------
 include/asm-generic/5level-fixup.h         |   1 +
 include/asm-generic/pgtable-nop4d.h        |   1 +
 include/linux/kasan.h                      |   2 +-
 include/linux/mmzone.h                     |   2 +-
 mm/kasan/kasan_init.c                      |   2 +-
 mm/page_alloc.c                            |  10 ++
 mm/sparse.c                                |   3 +-
 40 files changed, 462 insertions(+), 316 deletions(-)

-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
