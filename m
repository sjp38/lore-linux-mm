Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 249116B038A
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:54:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so199686959pfb.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:54:07 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 88si19119992pla.240.2017.03.06.05.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:54:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 00/33] 5-level paging
Date: Mon,  6 Mar 2017 16:53:24 +0300
Message-Id: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here is v4 of 5-level paging patchset. Please review and consider applying.

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

The patchset is build on top of v4.11-rc1.

Current QEMU upstream git supports 5-level paging. Use "-cpu qemu64,+la57"
to enable it.

Patch 1:
	Detect la57 feature for /proc/cpuinfo.

Patches 2-7:
	Brings 5-level paging to generic code and convert all
	architectures to it using <asm-generic/5level-fixup.h>

Patches 8-19:
	Convert x86 to properly folded p4d layer using
	<asm-generic/pgtable-nop4d.h>.

Patches 20-32:
	Enabling of real 5-level paging.

	CONFIG_X86_5LEVEL=y will enable new paging mode.

Patch 33:
	Introduce new prctl(2) handles -- PR_SET_MAX_VADDR and PR_GET_MAX_VADDR.

	This aims to address compatibility issue. Only supports x86 for
	now, but should be useful for other archtectures.

Git:
	git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git la57/v4

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
Kirill A. Shutemov (33):
  x86/cpufeature: Add 5-level paging detection
  asm-generic: introduce 5level-fixup.h
  asm-generic: introduce __ARCH_USE_5LEVEL_HACK
  arch, mm: convert all architectures to use 5level-fixup.h
  asm-generic: introduce <asm-generic/pgtable-nop4d.h>
  mm: convert generic code to 5-level paging
  mm: introduce __p4d_alloc()
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
  x86/mm: allow to have userspace mappigs above 47-bits

 Documentation/x86/x86_64/mm.txt                  |  33 +-
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
 arch/x86/Kconfig                                 |   6 +
 arch/x86/boot/compressed/head_64.S               |  23 +-
 arch/x86/boot/cpucheck.c                         |   9 +
 arch/x86/boot/cpuflags.c                         |  12 +-
 arch/x86/entry/entry_64.S                        |   7 +-
 arch/x86/include/asm/cpufeatures.h               |   3 +-
 arch/x86/include/asm/disabled-features.h         |   8 +-
 arch/x86/include/asm/elf.h                       |   2 +-
 arch/x86/include/asm/kasan.h                     |   9 +-
 arch/x86/include/asm/kexec.h                     |   1 +
 arch/x86/include/asm/mpx.h                       |   9 +
 arch/x86/include/asm/page_64_types.h             |  10 +
 arch/x86/include/asm/paravirt.h                  |  65 +++-
 arch/x86/include/asm/paravirt_types.h            |  17 +-
 arch/x86/include/asm/pgalloc.h                   |  37 +-
 arch/x86/include/asm/pgtable-2level_types.h      |   1 +
 arch/x86/include/asm/pgtable-3level_types.h      |   1 +
 arch/x86/include/asm/pgtable.h                   |  85 ++++-
 arch/x86/include/asm/pgtable_64.h                |  29 +-
 arch/x86/include/asm/pgtable_64_types.h          |  27 ++
 arch/x86/include/asm/pgtable_types.h             |  42 ++-
 arch/x86/include/asm/processor.h                 |   9 +-
 arch/x86/include/asm/required-features.h         |   8 +-
 arch/x86/include/asm/sparsemem.h                 |   9 +-
 arch/x86/include/asm/xen/page.h                  |   8 +-
 arch/x86/include/uapi/asm/processor-flags.h      |   2 +
 arch/x86/kernel/espfix_64.c                      |  12 +-
 arch/x86/kernel/head64.c                         |  40 ++-
 arch/x86/kernel/head_64.S                        |  63 +++-
 arch/x86/kernel/machine_kexec_32.c               |   4 +-
 arch/x86/kernel/machine_kexec_64.c               |  16 +-
 arch/x86/kernel/paravirt.c                       |  13 +-
 arch/x86/kernel/sys_x86_64.c                     |  28 +-
 arch/x86/kernel/tboot.c                          |   6 +-
 arch/x86/kernel/vm86_32.c                        |   6 +-
 arch/x86/mm/dump_pagetables.c                    |  51 ++-
 arch/x86/mm/fault.c                              |  57 ++-
 arch/x86/mm/gup.c                                |  33 +-
 arch/x86/mm/hugetlbpage.c                        |  31 +-
 arch/x86/mm/ident_map.c                          |  47 ++-
 arch/x86/mm/init_32.c                            |  22 +-
 arch/x86/mm/init_64.c                            | 269 ++++++++++++--
 arch/x86/mm/ioremap.c                            |   3 +-
 arch/x86/mm/kasan_init_64.c                      |  41 ++-
 arch/x86/mm/kaslr.c                              |  82 ++++-
 arch/x86/mm/mmap.c                               |   4 +-
 arch/x86/mm/mpx.c                                |  33 +-
 arch/x86/mm/pageattr.c                           |  56 ++-
 arch/x86/mm/pgtable.c                            |  38 +-
 arch/x86/mm/pgtable_32.c                         |   8 +-
 arch/x86/platform/efi/efi_64.c                   |  38 +-
 arch/x86/power/hibernate_32.c                    |   7 +-
 arch/x86/power/hibernate_64.c                    |  49 ++-
 arch/x86/realmode/init.c                         |   2 +-
 arch/x86/xen/Kconfig                             |   1 +
 arch/x86/xen/mmu.c                               | 433 ++++++++++++++---------
 arch/x86/xen/mmu.h                               |   1 +
 arch/xtensa/include/asm/pgtable.h                |   1 +
 drivers/misc/sgi-gru/grufault.c                  |   9 +-
 fs/userfaultfd.c                                 |   6 +-
 include/asm-generic/4level-fixup.h               |   3 +-
 include/asm-generic/5level-fixup.h               |  41 +++
 include/asm-generic/pgtable-nop4d-hack.h         |  62 ++++
 include/asm-generic/pgtable-nop4d.h              |  56 +++
 include/asm-generic/pgtable-nopud.h              |  48 +--
 include/asm-generic/pgtable.h                    |  48 ++-
 include/asm-generic/tlb.h                        |  14 +-
 include/linux/hugetlb.h                          |   5 +-
 include/linux/kasan.h                            |   1 +
 include/linux/mm.h                               |  34 +-
 include/trace/events/xen.h                       |  28 +-
 lib/ioremap.c                                    |  39 +-
 mm/gup.c                                         |  46 ++-
 mm/huge_memory.c                                 |   7 +-
 mm/hugetlb.c                                     |  29 +-
 mm/kasan/kasan_init.c                            |  35 +-
 mm/memory.c                                      | 230 ++++++++++--
 mm/mlock.c                                       |   1 +
 mm/mprotect.c                                    |  26 +-
 mm/mremap.c                                      |  13 +-
 mm/page_vma_mapped.c                             |   6 +-
 mm/pagewalk.c                                    |  32 +-
 mm/pgtable-generic.c                             |   6 +
 mm/rmap.c                                        |   7 +-
 mm/sparse-vmemmap.c                              |  22 +-
 mm/swapfile.c                                    |  26 +-
 mm/userfaultfd.c                                 |  23 +-
 mm/vmalloc.c                                     |  81 +++--
 120 files changed, 2413 insertions(+), 577 deletions(-)
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
