Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20AF66B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id m22so5400131pfg.15
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:17:14 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j75si2238413pgc.156.2018.02.14.03.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 03:17:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/9] x86/mm: Dynamic memory layout
Date: Wed, 14 Feb 2018 14:16:47 +0300
Message-Id: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is the next batch of patches required to bring boot-time switching
between 4- and 5-level paging. Please review and consider applying.

Patches in this patchset makes memory layout dynamic enough to be able to
switch between paging modes at boot-time.

Ingo, it worth noticing that we discussed some parts of the patchset
before (back in October) and had disagrement on how to handle situation.
You can read my position on the matter by the link[1].

Some changes made in this patchset can be replaced by patching constants
in code once we have infrastructure for this.

[1] http://lkml.kernel.org/r/20171031120429.ehaqy2iciewcij35@node.shutemov.name

Kirill A. Shutemov (9):
  x86/mm/64: Make __PHYSICAL_MASK_SHIFT always 52
  mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
  x86/mm: Make virtual memory layout movable for CONFIG_X86_5LEVEL
  x86: Introduce pgtable_l5_enabled
  x86/mm: Make LDT_BASE_ADDR dynamic
  x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D variable
  x86/mm: Make MAX_PHYSADDR_BITS and MAX_PHYSMEM_BITS dynamic
  x86/mm: Make __VIRTUAL_MASK_SHIFT dynamic
  x86/mm: Adjust virtual address space layout in early boot

 arch/x86/Kconfig                            |  9 ++++
 arch/x86/boot/compressed/kaslr.c            | 14 ++++++
 arch/x86/entry/entry_64.S                   | 12 ++++++
 arch/x86/include/asm/kaslr.h                |  4 --
 arch/x86/include/asm/page_64.h              |  4 ++
 arch/x86/include/asm/page_64_types.h        | 20 ++++-----
 arch/x86/include/asm/pgtable-3level_types.h |  1 +
 arch/x86/include/asm/pgtable_32.h           |  2 +
 arch/x86/include/asm/pgtable_32_types.h     |  2 +
 arch/x86/include/asm/pgtable_64_types.h     | 67 ++++++++++++++++++-----------
 arch/x86/include/asm/sparsemem.h            |  9 +---
 arch/x86/kernel/cpu/mcheck/mce.c            | 18 +++-----
 arch/x86/kernel/head64.c                    | 57 ++++++++++++++++++++++--
 arch/x86/kernel/head_64.S                   |  2 +-
 arch/x86/kernel/setup.c                     |  5 +--
 arch/x86/mm/dump_pagetables.c               | 32 +++++++++-----
 arch/x86/mm/init_64.c                       |  2 +-
 arch/x86/mm/kasan_init_64.c                 |  2 +-
 arch/x86/mm/kaslr.c                         | 23 ++++------
 arch/x86/platform/efi/efi_64.c              |  4 +-
 include/asm-generic/5level-fixup.h          |  1 +
 include/asm-generic/pgtable-nop4d.h         |  9 ++--
 include/linux/kasan.h                       |  2 +-
 mm/kasan/kasan_init.c                       |  2 +-
 mm/zsmalloc.c                               | 13 +++---
 25 files changed, 208 insertions(+), 108 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
