Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3776B0006
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:51 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id f4so11319169plr.14
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:51 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id l1si140806pgc.548.2018.02.14.10.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:49 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/9] x86: enable boot-time switching between paging modes
Date: Wed, 14 Feb 2018 21:25:33 +0300
Message-Id: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset finally brings support of switching between 4- and 5-level
paging modes!

There will be few patches after this to optimize switching and support
mode Xen modes, but this makes the same kernel image to run on both 4- and
5-level machines.

Please review and consider applying.

First 5 patches is split up of the last patch from the previous patchset.
The rest is pretty trivial too.

Kirill A. Shutemov (9):
  x86/mm: Initialize pgtable_l5_enabled at boot-time
  x86/mm: Initialize pgdir_shift and ptrs_per_p4d at boot-time
  x86/mm: Initialize page_offset_base at boot-time
  x86/mm: Adjust vmalloc base and size at boot-time
  x86/mm: Initialize vmemmap_base at boot-time
  x86/mm: Make early boot code support boot-time switching of paging
    modes
  x86/mm: Fold p4d page table layer at runtime
  x86/mm: Replace compile-time checks for 5-level with runtime-time
  x86/mm: Allow to boot without la57 if CONFIG_X86_5LEVEL=y

 Documentation/x86/x86_64/5level-paging.txt |  9 ++--
 arch/x86/Kconfig                           |  4 +-
 arch/x86/boot/compressed/kaslr.c           | 14 ++++--
 arch/x86/boot/compressed/misc.c            | 16 -------
 arch/x86/include/asm/page_64_types.h       |  9 ++--
 arch/x86/include/asm/paravirt.h            | 10 +++--
 arch/x86/include/asm/pgalloc.h             |  5 ++-
 arch/x86/include/asm/pgtable.h             | 11 ++++-
 arch/x86/include/asm/pgtable_64.h          | 23 +++++-----
 arch/x86/include/asm/pgtable_64_types.h    | 25 +++++------
 arch/x86/include/asm/required-features.h   |  8 +---
 arch/x86/kernel/head64.c                   | 68 ++++++++++++++++++++++++------
 arch/x86/kernel/head_64.S                  | 12 +++---
 arch/x86/mm/dump_pagetables.c              |  4 +-
 arch/x86/mm/fault.c                        |  4 +-
 arch/x86/mm/ident_map.c                    |  2 +-
 arch/x86/mm/init_64.c                      | 30 +++++++------
 arch/x86/mm/kasan_init_64.c                | 12 +++---
 arch/x86/mm/kaslr.c                        | 17 ++++----
 arch/x86/mm/tlb.c                          |  2 +-
 arch/x86/platform/efi/efi_64.c             |  2 +-
 arch/x86/power/hibernate_64.c              |  6 +--
 22 files changed, 165 insertions(+), 128 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
