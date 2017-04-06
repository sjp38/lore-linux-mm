Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ADBDB6B041E
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:01:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 81so37149312pgh.3
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:01:15 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e92si1965505plk.69.2017.04.06.07.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 07:01:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/8] x86: 5-level paging enabling for v4.12, Part 4
Date: Thu,  6 Apr 2017 17:00:58 +0300
Message-Id: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's the fourth and the last bunch of of patches that brings initial
5-level paging enabling.

Please review and consider applying.

As Ingo requested I've tried to rewrite assembly parts of boot process
into C before bringing 5-level paging support. The only part where I
succeed is startup_64 in arch/x86/kernel/head_64.S. Most of the logic is
now in C.

I failed to rewrite startup_32 in arch/x86/boot/compressed/head_64.S in C.
The code I need to modify in still in 32-bit mode, but if I would move it
to C it will be compiled as 64-bit. I've tried to move it into separate
translation unit and compile it with -m32, but then linking phase fails
due to type mismatch of object files.

I also have trouble with rewriting secondary_startup_64. Stack breaks as
soon as we switch to new page tables when onlining secondary CPUs. I don't
know how to get around this.

I hope it's not show-stopper.

If you know how to get around these issues, let me know.

Kirill A. Shutemov (8):
  x86/boot/64: Rewrite startup_64 in C
  x86/boot/64: Rename init_level4_pgt and early_level4_pgt
  x86/boot/64: Add support of additional page table level during early
    boot
  x86/mm: Add sync_global_pgds() for configuration with 5-level paging
  x86/mm: Make kernel_physical_mapping_init() support 5-level paging
  x86/mm: Add support for 5-level paging for KASLR
  x86: Enable 5-level paging support
  x86/mm: Allow to have userspace mappings above 47-bits

 arch/x86/Kconfig                            |   5 +
 arch/x86/boot/compressed/head_64.S          |  23 ++++-
 arch/x86/include/asm/elf.h                  |   2 +-
 arch/x86/include/asm/mpx.h                  |   9 ++
 arch/x86/include/asm/pgtable.h              |   2 +-
 arch/x86/include/asm/pgtable_64.h           |   6 +-
 arch/x86/include/asm/processor.h            |   9 +-
 arch/x86/include/uapi/asm/processor-flags.h |   2 +
 arch/x86/kernel/espfix_64.c                 |   2 +-
 arch/x86/kernel/head64.c                    | 137 +++++++++++++++++++++++++---
 arch/x86/kernel/head_64.S                   | 132 ++++++---------------------
 arch/x86/kernel/machine_kexec_64.c          |   2 +-
 arch/x86/kernel/sys_x86_64.c                |  28 +++++-
 arch/x86/mm/dump_pagetables.c               |   2 +-
 arch/x86/mm/hugetlbpage.c                   |  27 +++++-
 arch/x86/mm/init_64.c                       | 104 +++++++++++++++++++--
 arch/x86/mm/kasan_init_64.c                 |  12 +--
 arch/x86/mm/kaslr.c                         |  81 ++++++++++++----
 arch/x86/mm/mmap.c                          |   2 +-
 arch/x86/mm/mpx.c                           |  33 ++++++-
 arch/x86/realmode/init.c                    |   2 +-
 arch/x86/xen/Kconfig                        |   1 +
 arch/x86/xen/mmu.c                          |  18 ++--
 arch/x86/xen/xen-pvh.S                      |   2 +-
 24 files changed, 463 insertions(+), 180 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
