Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD826B03A2
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 07:30:54 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 21so32058114pgg.4
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 04:30:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 3si23732098plm.215.2017.04.13.04.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 04:30:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 0/9] x86: 5-level paging enabling for v4.12, Part 4
Date: Thu, 13 Apr 2017 14:30:29 +0300
Message-Id: <20170413113038.3167-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <4c8cd9a9-2013-2a74-6bea-d7dc7207abb1@virtuozzo.com>
References: <4c8cd9a9-2013-2a74-6bea-d7dc7207abb1@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's updated version the fourth and the last bunch of of patches that brings
initial 5-level paging enabling.

Please review and consider applying.

The situation with assembly hasn't changed much. I still not see a way to get
it work.

In this version I've included patch to fix comment in return_from_SYSCALL_64,
fixed bug in coverting startup_64 to C and updated the patch which allows to
opt-in full address space.

Kirill A. Shutemov (9):
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

 arch/x86/Kconfig                            |   5 +
 arch/x86/boot/compressed/head_64.S          |  23 ++++-
 arch/x86/entry/entry_64.S                   |   3 +-
 arch/x86/include/asm/elf.h                  |   4 +-
 arch/x86/include/asm/mpx.h                  |   9 ++
 arch/x86/include/asm/pgtable.h              |   2 +-
 arch/x86/include/asm/pgtable_64.h           |   6 +-
 arch/x86/include/asm/processor.h            |  11 ++-
 arch/x86/include/uapi/asm/processor-flags.h |   2 +
 arch/x86/kernel/espfix_64.c                 |   2 +-
 arch/x86/kernel/head64.c                    | 137 +++++++++++++++++++++++++---
 arch/x86/kernel/head_64.S                   | 134 +++++++--------------------
 arch/x86/kernel/machine_kexec_64.c          |   2 +-
 arch/x86/kernel/sys_x86_64.c                |  30 +++++-
 arch/x86/mm/dump_pagetables.c               |   2 +-
 arch/x86/mm/hugetlbpage.c                   |  27 +++++-
 arch/x86/mm/init_64.c                       | 104 +++++++++++++++++++--
 arch/x86/mm/kasan_init_64.c                 |  12 +--
 arch/x86/mm/kaslr.c                         |  81 ++++++++++++----
 arch/x86/mm/mmap.c                          |   6 +-
 arch/x86/mm/mpx.c                           |  33 ++++++-
 arch/x86/realmode/init.c                    |   2 +-
 arch/x86/xen/Kconfig                        |   1 +
 arch/x86/xen/mmu.c                          |  18 ++--
 arch/x86/xen/xen-pvh.S                      |   2 +-
 25 files changed, 470 insertions(+), 188 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
