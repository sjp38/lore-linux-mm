Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECFD66B027B
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:55:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a190so686580076pgc.0
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:55:09 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f17si44788970pgi.11.2016.12.26.17.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:55:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 00/29] 5-level paging
Date: Tue, 27 Dec 2016 04:53:44 +0300
Message-Id: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here is v2 of 5-level paging patchset.

Please consider applying first 7 patches.

Main x86 portion requires more work (mostly Xen), but any feedback is
welcome.

I've also included a patch proposal to address compatibility issue with
wide addresses that some software has.

Ingo wants to to see opt-out, but I believe opt-in is required to not
break userspace. That's not purely theoretical, I see one crash due to
the issue.

See description of patchset split below.

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

The patchset is build on top of v4.10-rc1.

Current QEMU upstream git supports 5-level paging. Use "-cpu qemu64,+la57"
to enable it.

Patch 1:
	Detect la57 feature for /proc/cpuinfo. It's trivial and can be
	applied now.

Patches 2-7:
	Brings 5-level paging to generic code and convert all
	architectures to it using <asm-generic/5level-fixup.h>

	I think this should be ready for -mm tree. Please consider
	applying.

Patches 8-15:
	Convert x86 to properly folded p4d layer using
	<asm-generic/pgtable-nop4d.h>.

Patches 16-28:
	Enabling of real 5-level paging.

	CONFIG_X86_5LEVEL=y will enable new paging mode.

Patch 29:
	Extends rlimit interface to set/get maximum virtual address that
	the application can map.

	This aims to address compatibility issue. Only supports x86 for
	now.

	I also patched dash to add the rlimit support. It was handy for
	testing. Let me know if anybody wants to play with it.

	Comments are welcome.

Git:
	git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git la57/v2

== TODO ==

There is still work to do:

  - CONFIG_XEN is broken.

    Paravirt Xen MMU support hasn't yet adjusted to work with 5-level
    paging. It's legacy feature, not sure if we really need to support it
    with new paging, but it blocks Xen drivers too.

    I haven't got around to setup testing environment for XEN, so left it
    broken for now.

    I would appreciate help with the code.

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
  v2:
    - Rebased to v4.10-rc1;
    - RLIMIT_VADDR proposal;
    - Fix virtual map and update documentation;
    - Fix few build errors;
    - Rework cpuid helpers in boot code;
    - Fix espfix code to work with 5-level pages;

[1] https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf

Kirill A. Shutemov (29):
  x86/cpufeature: Add 5-level paging detecton
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
  x86: convert the rest of the code to support p4d_t
  x86: detect 5-level paging support
  x86/asm: remove __VIRTUAL_MASK_SHIFT==47 assert
  x86/mm: define virtual memory map for 5-level paging
  x86/paravirt: make paravirt code support 5-level paging
  x86/mm: basic defines/helpers for CONFIG_X86_5LEVEL
  x86/dump_pagetables: support 5-level paging
  x86/mm: extend kasan to support 5-level paging
  x86/espfix: support 5-level paging
  x86/mm: add support of additional page table level during early boot
  x86/mm: add sync_global_pgds() for configuration with 5-level paging
  x86/mm: make kernel_physical_mapping_init() support 5-level paging
  x86/mm: add support for 5-level paging for KASLR
  x86: enable 5-level paging support
  mm, x86: introduce RLIMIT_VADDR

 Documentation/x86/x86_64/mm.txt                  |  33 ++-
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
 arch/powerpc/include/asm/book3s/64/pgtable.h     |   2 +
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
 arch/x86/Kconfig                                 |   7 +
 arch/x86/boot/compressed/head_64.S               |  23 ++-
 arch/x86/boot/cpucheck.c                         |   9 +
 arch/x86/boot/cpuflags.c                         |  12 +-
 arch/x86/entry/entry_64.S                        |   7 +-
 arch/x86/include/asm/cpufeatures.h               |   3 +-
 arch/x86/include/asm/disabled-features.h         |   8 +-
 arch/x86/include/asm/elf.h                       |   2 +-
 arch/x86/include/asm/kasan.h                     |   9 +-
 arch/x86/include/asm/kexec.h                     |   1 +
 arch/x86/include/asm/page_64_types.h             |  10 +
 arch/x86/include/asm/paravirt.h                  |  64 +++++-
 arch/x86/include/asm/paravirt_types.h            |  17 +-
 arch/x86/include/asm/pgalloc.h                   |  36 +++-
 arch/x86/include/asm/pgtable-2level_types.h      |   1 +
 arch/x86/include/asm/pgtable-3level_types.h      |   1 +
 arch/x86/include/asm/pgtable.h                   |  91 ++++++++-
 arch/x86/include/asm/pgtable_64.h                |  29 ++-
 arch/x86/include/asm/pgtable_64_types.h          |  27 +++
 arch/x86/include/asm/pgtable_types.h             |  42 +++-
 arch/x86/include/asm/processor.h                 |  17 +-
 arch/x86/include/asm/required-features.h         |   8 +-
 arch/x86/include/asm/sparsemem.h                 |   9 +-
 arch/x86/include/uapi/asm/processor-flags.h      |   2 +
 arch/x86/kernel/espfix_64.c                      |  12 +-
 arch/x86/kernel/head64.c                         |  40 +++-
 arch/x86/kernel/head_64.S                        |  58 ++++--
 arch/x86/kernel/machine_kexec_32.c               |   4 +-
 arch/x86/kernel/machine_kexec_64.c               |  14 +-
 arch/x86/kernel/paravirt.c                       |  13 +-
 arch/x86/kernel/sys_x86_64.c                     |   6 +-
 arch/x86/kernel/tboot.c                          |   6 +-
 arch/x86/kernel/vm86_32.c                        |   6 +-
 arch/x86/mm/dump_pagetables.c                    |  51 ++++-
 arch/x86/mm/fault.c                              |  57 +++++-
 arch/x86/mm/gup.c                                |  33 ++-
 arch/x86/mm/hugetlbpage.c                        |   8 +-
 arch/x86/mm/ident_map.c                          |  42 +++-
 arch/x86/mm/init_32.c                            |  22 +-
 arch/x86/mm/init_64.c                            | 248 ++++++++++++++++++++---
 arch/x86/mm/ioremap.c                            |   3 +-
 arch/x86/mm/kasan_init_64.c                      |  42 +++-
 arch/x86/mm/kaslr.c                              |  82 ++++++--
 arch/x86/mm/mmap.c                               |   4 +-
 arch/x86/mm/pageattr.c                           |  56 +++--
 arch/x86/mm/pgtable.c                            |  38 +++-
 arch/x86/mm/pgtable_32.c                         |   8 +-
 arch/x86/platform/efi/efi_64.c                   |  21 +-
 arch/x86/power/hibernate_32.c                    |   7 +-
 arch/x86/power/hibernate_64.c                    |  35 ++--
 arch/x86/realmode/init.c                         |   2 +-
 arch/x86/xen/Kconfig                             |   1 +
 arch/xtensa/include/asm/pgtable.h                |   1 +
 drivers/misc/sgi-gru/grufault.c                  |   9 +-
 fs/binfmt_aout.c                                 |   2 -
 fs/binfmt_elf.c                                  |  10 +-
 fs/hugetlbfs/inode.c                             |   6 +-
 fs/proc/base.c                                   |   1 +
 fs/userfaultfd.c                                 |   6 +-
 include/asm-generic/4level-fixup.h               |   3 +-
 include/asm-generic/5level-fixup.h               |  41 ++++
 include/asm-generic/pgtable-nop4d-hack.h         |  62 ++++++
 include/asm-generic/pgtable-nop4d.h              |  56 +++++
 include/asm-generic/pgtable-nopud.h              |  48 +++--
 include/asm-generic/pgtable.h                    |  48 ++++-
 include/asm-generic/resource.h                   |   4 +
 include/asm-generic/tlb.h                        |  14 +-
 include/linux/hugetlb.h                          |   5 +-
 include/linux/kasan.h                            |   1 +
 include/linux/mm.h                               |  34 +++-
 include/linux/sched.h                            |   5 +
 include/uapi/asm-generic/resource.h              |   3 +-
 kernel/events/uprobes.c                          |   5 +-
 kernel/sys.c                                     |   6 +-
 lib/ioremap.c                                    |  39 +++-
 mm/gup.c                                         |  46 ++++-
 mm/huge_memory.c                                 |   7 +-
 mm/hugetlb.c                                     |  29 ++-
 mm/kasan/kasan_init.c                            |  35 +++-
 mm/memory.c                                      | 230 +++++++++++++++++----
 mm/mlock.c                                       |   1 +
 mm/mmap.c                                        |  20 +-
 mm/mprotect.c                                    |  26 ++-
 mm/mremap.c                                      |  16 +-
 mm/nommu.c                                       |   2 +-
 mm/pagewalk.c                                    |  32 ++-
 mm/pgtable-generic.c                             |   6 +
 mm/rmap.c                                        |  13 +-
 mm/shmem.c                                       |   8 +-
 mm/sparse-vmemmap.c                              |  22 +-
 mm/swapfile.c                                    |  26 ++-
 mm/userfaultfd.c                                 |  23 ++-
 mm/vmalloc.c                                     |  81 ++++++--
 125 files changed, 2047 insertions(+), 410 deletions(-)
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
