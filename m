Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B35C76B028C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:23:23 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so652416918pfb.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:23:23 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m3si29438841pgm.124.2016.12.08.08.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:23:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 00/28] 5-level paging
Date: Thu,  8 Dec 2016 19:21:21 +0300
Message-Id: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

x86-64 is currently limited to 256 TiB of virtual address space and 64 TiB
of physical address space. We are already bumping into this limit: some
vendors offers servers with 64 TiB of memory today.

To overcome the limitation upcoming hardware will introduce support for
5-level paging[1]. It is a straight-forward extension of the current page
table structure adding one more layer of translation.

It bumps the limits to 128 PiB of virtual address space and 4 PiB of
physical address space. This "ought to be enough for anybody" A(C).

This patchset is still very early. There are a number of things missing
that we have to do before asking anyone to merge it (listed below).
It would be great if folks can start testing applications now (in QEMU) to
look for breakage.
Any early comments on the design or the patches would be appreciated as
well.

More details on the design and whata??s left to implement are below.

  - Linux MM now uses 5-level paging abstraction.

    New page table level is p4d, just below pgd.

  - All architectures converted to folded 5-level paging.

    I added <asm-generic/5level-fixup.h>. It uses the same basic
    approach as <asm-generic/4level-fixup.h> hack.

  - x86 is converted to new <asm-generic/pgtable-nop4d.h>

    All existing paging modes (2-, 3-, 4-level) on x86 are converted to
    pgtable-nop4d.h.

    The new header provides basics for properly folded additional page
    table level. The idea is the same as with other pgtable-nop?d.h.

  - Implement 5-level paging in x86.

    CONFIG_X86_5LEVEL=y will enable new 5-level paging mode.

The patchset is build on top of v4.8.

I've also included a QEMU patch which enables 5-level paging in the
emulator, so anybody can play with the feature.

There is still work to do:

  - Boot-time switch between 4- and 5-level paging.

    We assume that distributions will be keen to avoid returning to the
    i386 days where we shipped one kernel binary for each page table
    layout.

    As page table format is the same for 4- and 5-level paging it should
    be possible to have single kernel binary and switch between them at
    boot-time without too much hassle.

    For now I only implemented compile-time switch.

    I hoped to bring this feature with separate patchset once basic
    enabling is in upstream.

    Is it okay?

  - Handle opt-in wider address space for userspace.

    Not all userspace is ready to handle addresses wider than current
    47-bits. At least some JIT compiler make use of upper bits to encode
    their info.

    We need to have an interface to opt-in wider addresses from userspace
    to avoid regressions.

    For now, I've included testing-only patch which bumps TASK_SIZE to
    56-bits. This can be handy for testing to see what breaks if we max-out
    size of virtual address space.

  - CONFIG_XEN is broken.

    Paravirt Xen MMU support hasn't yet adjusted to work with 5-level
    paging. It's legacy feature, not sure if we really need to support it
    with new paging, but it blocks Xen drivers too.

    I haven't got around to setup testing environment for XEN, so left it
    broken for now.

    I would appreciate help with the code.

  - Split patches further.

    In some cases it's not trivial to split patches into reasonable pieces
    without breaking bisectability

  - Validation.

    I haven't done much testing beyond basic boot.

Git:
	git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git la57/v1

Any comments are welcome.

[1] https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf
Kirill A. Shutemov (28):
  asm-generic: introduce 5level-fixup.h
  asm-generic: introduce __ARCH_USE_5LEVEL_HACK
  arch, mm: convert all architectures to use 5level-fixup.h
  asm-generic: introduce <asm-generic/pgtable-nop4d.h>
  mm: convert generic code to 5-level paging
  x86: basic changes into headers for 5-level paging
  x86: trivial portion of 5-level paging conversion
  x86/gup: add 5-level paging support
  x86/ident_map: add 5-level paging support
  x86/mm: add support of p4d_t in vmalloc_fault()
  x86/power: support p4d_t in hibernate code
  x86/kexec: support p4d_t
  x86: convert the rest of the code to support p4d_t
  mm: introduce __p4d_alloc()
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
  x86: enable la57 support
  TESTING-ONLY: bump TASK_SIZE_MAX

 Documentation/x86/x86_64/mm.txt                  |  23 +-
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
 arch/x86/boot/compressed/head_64.S               |  23 +-
 arch/x86/boot/cpucheck.c                         |   9 +
 arch/x86/boot/cpuflags.c                         |  16 ++
 arch/x86/entry/entry_64.S                        |   7 +-
 arch/x86/include/asm/cpufeatures.h               |   1 +
 arch/x86/include/asm/disabled-features.h         |   8 +-
 arch/x86/include/asm/kasan.h                     |   9 +-
 arch/x86/include/asm/kexec.h                     |   1 +
 arch/x86/include/asm/page_64_types.h             |  10 +
 arch/x86/include/asm/paravirt.h                  |  64 +++++-
 arch/x86/include/asm/paravirt_types.h            |  17 +-
 arch/x86/include/asm/pgalloc.h                   |  36 ++-
 arch/x86/include/asm/pgtable-2level_types.h      |   1 +
 arch/x86/include/asm/pgtable-3level_types.h      |   1 +
 arch/x86/include/asm/pgtable.h                   |  91 +++++++-
 arch/x86/include/asm/pgtable_64.h                |  29 ++-
 arch/x86/include/asm/pgtable_64_types.h          |  27 +++
 arch/x86/include/asm/pgtable_types.h             |  42 +++-
 arch/x86/include/asm/processor.h                 |   3 +-
 arch/x86/include/asm/required-features.h         |   8 +-
 arch/x86/include/asm/sparsemem.h                 |   9 +-
 arch/x86/include/uapi/asm/processor-flags.h      |   2 +
 arch/x86/kernel/espfix_64.c                      |  43 +++-
 arch/x86/kernel/head64.c                         |  40 +++-
 arch/x86/kernel/head_64.S                        |  58 +++--
 arch/x86/kernel/machine_kexec_32.c               |   4 +-
 arch/x86/kernel/machine_kexec_64.c               |  14 +-
 arch/x86/kernel/paravirt.c                       |  13 +-
 arch/x86/kernel/tboot.c                          |   6 +-
 arch/x86/kernel/vm86_32.c                        |   6 +-
 arch/x86/mm/dump_pagetables.c                    |  51 ++++-
 arch/x86/mm/fault.c                              |  57 ++++-
 arch/x86/mm/gup.c                                |  33 ++-
 arch/x86/mm/ident_map.c                          |  42 +++-
 arch/x86/mm/init_32.c                            |  22 +-
 arch/x86/mm/init_64.c                            | 274 +++++++++++++++++++----
 arch/x86/mm/ioremap.c                            |   3 +-
 arch/x86/mm/kasan_init_64.c                      |  42 +++-
 arch/x86/mm/kaslr.c                              |  82 +++++--
 arch/x86/mm/pageattr.c                           |  56 +++--
 arch/x86/mm/pgtable.c                            |  38 +++-
 arch/x86/mm/pgtable_32.c                         |   8 +-
 arch/x86/platform/efi/efi_64.c                   |  21 +-
 arch/x86/power/hibernate_32.c                    |   7 +-
 arch/x86/power/hibernate_64.c                    |  35 +--
 arch/x86/realmode/init.c                         |   2 +-
 arch/x86/xen/Kconfig                             |   1 +
 arch/xtensa/include/asm/pgtable.h                |   1 +
 drivers/misc/sgi-gru/grufault.c                  |   9 +-
 fs/userfaultfd.c                                 |   6 +-
 include/asm-generic/4level-fixup.h               |   3 +-
 include/asm-generic/5level-fixup.h               |  41 ++++
 include/asm-generic/pgtable-nop4d-hack.h         |  62 +++++
 include/asm-generic/pgtable-nop4d.h              |  56 +++++
 include/asm-generic/pgtable-nopud.h              |  48 ++--
 include/asm-generic/pgtable.h                    |  48 +++-
 include/asm-generic/tlb.h                        |  12 +-
 include/linux/hugetlb.h                          |   5 +-
 include/linux/kasan.h                            |   1 +
 include/linux/mm.h                               |  32 ++-
 lib/ioremap.c                                    |  39 +++-
 mm/gup.c                                         |  46 +++-
 mm/huge_memory.c                                 |   7 +-
 mm/hugetlb.c                                     |  29 ++-
 mm/kasan/kasan_init.c                            |  35 ++-
 mm/memory.c                                      | 230 ++++++++++++++++---
 mm/mlock.c                                       |   1 +
 mm/mprotect.c                                    |  26 ++-
 mm/mremap.c                                      |  13 +-
 mm/pagewalk.c                                    |  32 ++-
 mm/pgtable-generic.c                             |   6 +
 mm/rmap.c                                        |  13 +-
 mm/sparse-vmemmap.c                              |  22 +-
 mm/swapfile.c                                    |  26 ++-
 mm/userfaultfd.c                                 |  23 +-
 mm/vmalloc.c                                     |  81 +++++--
 109 files changed, 2027 insertions(+), 366 deletions(-)
 create mode 100644 include/asm-generic/5level-fixup.h
 create mode 100644 include/asm-generic/pgtable-nop4d-hack.h
 create mode 100644 include/asm-generic/pgtable-nop4d.h

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
