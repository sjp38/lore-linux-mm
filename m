Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4D5E6B0428
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:50:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e129so281000852pfh.1
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:50:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m62si10537417pfi.30.2017.03.12.22.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/26] x86: 5-level paging enabling for v4.12
Date: Mon, 13 Mar 2017 08:49:54 +0300
Message-Id: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here is v5 of 5-level paging patchset. Please review and consider applying.

== Overview ==

x86-64 is currently limited to 256 TiB of virtual address space and 64 TiB
of physical address space. We are already bumping into this limit: some
vendors offers servers with 64 TiB of memory today.

To overcome the limitation upcoming hardware will introduce support for
5-level paging[1]. It is a straight-forward extension of the current page
table structure adding one more layer of translation.

It bumps the limits to 128 PiB of virtual address space and 4 PiB of
physical address space. This "ought to be enough for anybody" A(C).

==  Patches ==

The patchset is build on top of v4.11-rc2.

Current QEMU upstream git supports 5-level paging. Use "-cpu qemu64,+la57"
to enable it.

Patches 1-12:
	Convert x86 to properly folded p4d layer using
	<asm-generic/pgtable-nop4d.h>.

Patches 13-25:
	Enabling of real 5-level paging.

	CONFIG_X86_5LEVEL=y will enable new paging mode.

Patch 26:
	Introduce new prctl(2) handles -- PR_SET_MAX_VADDR and PR_GET_MAX_VADDR.

	This aims to address compatibility issue. Only supports x86 for
	now, but should be useful for other archtectures.

Git:
	git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git la57/v5

== TODO ==

There is still work to do:

  - CONFIG_XEN is broken for 5-level paging.

    Xen for 5-level paging requires more work to get functional.
    
    Xen on 4-level paging works, so it's not a regression.

  - Boot-time switch between 4- and 5-level paging.

    We assume that distributions will be keen to avoid returning to the
    i386 days where we shipped one kernel binary for each page table
    layout.

    As page table format is the same for 4- and 5-level paging it should
    be possible to have single kernel binary and switch between them at
    boot-time without too much hassle.

    For now I only implemented compile-time switch.

    This will implemented with separate patchset.

== Changelong ==

  v5:
    - Rebased to v4.11-rc2;
    - Fix false-positive BUG_ON() in vmalloc_fault() with 4-level paging
      enabled;
    - __xen_pgd_walk(): do not not miss required flushes;
    - Fix build with CONFIG_XEN_PVH=y;
  v4:
    - Rebased to v4.11-rc1;
    - Use mmap() hint address to allocate virtual addresss space above
      47-bits insteads of prctl() handles.
  v3:
    - Rebased to v4.10-rc5;
    - prctl() handles for large address space opt-in;
    - Xen works for 4-level paging;
    - EFI boot fixed for both 4- and 5-level paging;
    - Hibernation fixed for 4-level paging;
    - kexec() fixed;
    - Couple of build fixes;
  v2:
    - Rebased to v4.10-rc1;
    - RLIMIT_VADDR proposal;
    - Fix virtual map and update documentation;
    - Fix few build errors;
    - Rework cpuid helpers in boot code;
    - Fix espfix code to work with 5-level pages;

[1] https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf

Kirill A. Shutemov (26):
  x86: basic changes into headers for 5-level paging
  x86: trivial portion of 5-level paging conversion
  x86/gup: add 5-level paging support
  x86/ident_map: add 5-level paging support
  x86/mm: add support of p4d_t in vmalloc_fault()
  x86/power: support p4d_t in hibernate code
  x86/kexec: support p4d_t
  x86/efi: handle p4d in EFI pagetables
  x86/mm/pat: handle additional page table
  x86/kasan: prepare clear_pgds() to switch to
    <asm-generic/pgtable-nop4d.h>
  x86/xen: convert __xen_pgd_walk() and xen_cleanmfnmap() to support p4d
  x86: convert the rest of the code to support p4d_t
  x86: detect 5-level paging support
  x86/asm: remove __VIRTUAL_MASK_SHIFT==47 assert
  x86/mm: define virtual memory map for 5-level paging
  x86/paravirt: make paravirt code support 5-level paging
  x86/mm: basic defines/helpers for CONFIG_X86_5LEVEL
  x86/dump_pagetables: support 5-level paging
  x86/kasan: extend to support 5-level paging
  x86/espfix: support 5-level paging
  x86/mm: add support of additional page table level during early boot
  x86/mm: add sync_global_pgds() for configuration with 5-level paging
  x86/mm: make kernel_physical_mapping_init() support 5-level paging
  x86/mm: add support for 5-level paging for KASLR
  x86: enable 5-level paging support
  x86/mm: allow to have userspace mappings above 47-bits

 Documentation/x86/x86_64/mm.txt             |  33 ++-
 arch/x86/Kconfig                            |   6 +
 arch/x86/boot/compressed/head_64.S          |  23 +-
 arch/x86/boot/cpucheck.c                    |   9 +
 arch/x86/boot/cpuflags.c                    |  12 +-
 arch/x86/entry/entry_64.S                   |   7 +-
 arch/x86/include/asm/disabled-features.h    |   8 +-
 arch/x86/include/asm/elf.h                  |   2 +-
 arch/x86/include/asm/kasan.h                |   9 +-
 arch/x86/include/asm/kexec.h                |   1 +
 arch/x86/include/asm/mpx.h                  |   9 +
 arch/x86/include/asm/page_64_types.h        |  10 +
 arch/x86/include/asm/paravirt.h             |  65 ++++-
 arch/x86/include/asm/paravirt_types.h       |  17 +-
 arch/x86/include/asm/pgalloc.h              |  37 ++-
 arch/x86/include/asm/pgtable-2level_types.h |   1 +
 arch/x86/include/asm/pgtable-3level_types.h |   1 +
 arch/x86/include/asm/pgtable.h              |  85 +++++-
 arch/x86/include/asm/pgtable_64.h           |  29 +-
 arch/x86/include/asm/pgtable_64_types.h     |  27 ++
 arch/x86/include/asm/pgtable_types.h        |  46 ++-
 arch/x86/include/asm/processor.h            |   9 +-
 arch/x86/include/asm/required-features.h    |   8 +-
 arch/x86/include/asm/sparsemem.h            |   9 +-
 arch/x86/include/asm/xen/page.h             |   8 +-
 arch/x86/include/uapi/asm/processor-flags.h |   2 +
 arch/x86/kernel/espfix_64.c                 |  12 +-
 arch/x86/kernel/head64.c                    |  40 ++-
 arch/x86/kernel/head_64.S                   |  63 +++-
 arch/x86/kernel/machine_kexec_32.c          |   4 +-
 arch/x86/kernel/machine_kexec_64.c          |  16 +-
 arch/x86/kernel/paravirt.c                  |  13 +-
 arch/x86/kernel/sys_x86_64.c                |  28 +-
 arch/x86/kernel/tboot.c                     |   6 +-
 arch/x86/kernel/vm86_32.c                   |   6 +-
 arch/x86/mm/dump_pagetables.c               |  51 +++-
 arch/x86/mm/fault.c                         |  66 ++++-
 arch/x86/mm/gup.c                           |  33 ++-
 arch/x86/mm/hugetlbpage.c                   |  31 +-
 arch/x86/mm/ident_map.c                     |  47 ++-
 arch/x86/mm/init_32.c                       |  22 +-
 arch/x86/mm/init_64.c                       | 269 ++++++++++++++---
 arch/x86/mm/ioremap.c                       |   3 +-
 arch/x86/mm/kasan_init_64.c                 |  41 ++-
 arch/x86/mm/kaslr.c                         |  82 ++++--
 arch/x86/mm/mmap.c                          |   4 +-
 arch/x86/mm/mpx.c                           |  33 ++-
 arch/x86/mm/pageattr.c                      |  56 +++-
 arch/x86/mm/pgtable.c                       |  38 ++-
 arch/x86/mm/pgtable_32.c                    |   8 +-
 arch/x86/platform/efi/efi_64.c              |  38 ++-
 arch/x86/power/hibernate_32.c               |   7 +-
 arch/x86/power/hibernate_64.c               |  49 +++-
 arch/x86/realmode/init.c                    |   2 +-
 arch/x86/xen/Kconfig                        |   1 +
 arch/x86/xen/mmu.c                          | 435 +++++++++++++++++-----------
 arch/x86/xen/mmu.h                          |   1 +
 arch/x86/xen/xen-pvh.S                      |   2 +-
 include/trace/events/xen.h                  |  28 +-
 59 files changed, 1571 insertions(+), 437 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
