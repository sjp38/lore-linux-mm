Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFDB6B0007
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:20:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k66-v6so6222690pga.21
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:20:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m7-v6si30485701pfi.286.2018.10.11.08.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:20:45 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 00/27] Control Flow Enforcement: Shadow Stack
Date: Thu, 11 Oct 2018 08:14:56 -0700
Message-Id: <20181011151523.27101-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The previous version of CET Shadow Stack patches is at the following
link:

  https://lkml.org/lkml/2018/9/21/776

Summary of changes from v4:

  Clean up XSAVES system states patches.
  Update control protection fault handler to provide error code to user.
  Add CONFIG_VM_AREA_GUARD.
  Clean up arch_prctl.
  Fix some typos and macros.

Yu-cheng Yu (27):
  x86/cpufeatures: Add CPUIDs for Control Flow Enforcement Technology
    (CET)
  x86/fpu/xstate: Change names to separate XSAVES system and user states
  x86/fpu/xstate: Introduce XSAVES system states
  x86/fpu/xstate: Add XSAVES system states for shadow stack
  Documentation/x86: Add CET description
  x86/cet: Control protection exception handler
  mm/mmap: Create a guard area between VMAs
  x86/cet/shstk: Add Kconfig option for user-mode shadow stack
  mm: Introduce VM_SHSTK for shadow stack memory
  mm/mmap: Prevent Shadow Stack VMA merges
  x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
  x86/mm: Introduce _PAGE_DIRTY_SW
  drm/i915/gvt: Update _PAGE_DIRTY to _PAGE_DIRTY_BITS
  x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for
    _PAGE_DIRTY_SW
  x86/mm: Shadow stack page fault error checking
  mm: Handle shadow stack page fault
  mm: Handle THP/HugeTLB shadow stack page fault
  mm: Update can_follow_write_pte/pmd for shadow stack
  mm: Introduce do_mmap_locked()
  x86/cet/shstk: User-mode shadow stack support
  x86/cet/shstk: Introduce WRUSS instruction
  x86/cet/shstk: Signal handling for shadow stack
  x86/cet/shstk: ELF header parsing of Shadow Stack
  x86/cet/shstk: Handle thread shadow stack
  mm/mmap: Add Shadow stack pages to memory accounting
  x86/cet/shstk: Add arch_prctl functions for Shadow Stack
  x86/cet/shstk: Add Shadow Stack instructions to opcode map

 .../admin-guide/kernel-parameters.txt         |   6 +
 Documentation/index.rst                       |   1 +
 Documentation/x86/index.rst                   |  11 +
 Documentation/x86/intel_cet.rst               | 266 ++++++++++++++
 arch/x86/Kconfig                              |  30 ++
 arch/x86/Makefile                             |   7 +
 arch/x86/entry/entry_64.S                     |   2 +-
 arch/x86/ia32/ia32_signal.c                   |  13 +
 arch/x86/include/asm/cet.h                    |  46 +++
 arch/x86/include/asm/cpufeatures.h            |   2 +
 arch/x86/include/asm/disabled-features.h      |   8 +-
 arch/x86/include/asm/elf.h                    |   5 +
 arch/x86/include/asm/fpu/internal.h           |   5 +-
 arch/x86/include/asm/fpu/types.h              |  22 ++
 arch/x86/include/asm/fpu/xstate.h             |  26 +-
 arch/x86/include/asm/mmu_context.h            |   3 +
 arch/x86/include/asm/msr-index.h              |  14 +
 arch/x86/include/asm/pgtable.h                | 191 ++++++++--
 arch/x86/include/asm/pgtable_types.h          |  38 +-
 arch/x86/include/asm/processor.h              |   5 +
 arch/x86/include/asm/sighandling.h            |   5 +
 arch/x86/include/asm/special_insns.h          |  32 ++
 arch/x86/include/asm/traps.h                  |   5 +
 arch/x86/include/uapi/asm/elf_property.h      |  15 +
 arch/x86/include/uapi/asm/prctl.h             |   5 +
 arch/x86/include/uapi/asm/processor-flags.h   |   2 +
 arch/x86/include/uapi/asm/sigcontext.h        |  15 +
 arch/x86/kernel/Makefile                      |   4 +
 arch/x86/kernel/cet.c                         | 298 +++++++++++++++
 arch/x86/kernel/cet_prctl.c                   |  86 +++++
 arch/x86/kernel/cpu/common.c                  |  25 ++
 arch/x86/kernel/elf.c                         | 341 ++++++++++++++++++
 arch/x86/kernel/fpu/core.c                    |  10 +-
 arch/x86/kernel/fpu/init.c                    |  10 -
 arch/x86/kernel/fpu/signal.c                  |   6 +-
 arch/x86/kernel/fpu/xstate.c                  | 146 +++++---
 arch/x86/kernel/idt.c                         |   4 +
 arch/x86/kernel/process.c                     |   7 +-
 arch/x86/kernel/process_64.c                  |   7 +
 arch/x86/kernel/relocate_kernel_64.S          |   2 +-
 arch/x86/kernel/signal.c                      |  97 +++++
 arch/x86/kernel/signal_compat.c               |   2 +-
 arch/x86/kernel/traps.c                       |  64 ++++
 arch/x86/kvm/vmx.c                            |   2 +-
 arch/x86/lib/x86-opcode-map.txt               |  26 +-
 arch/x86/mm/fault.c                           |  27 ++
 arch/x86/mm/pgtable.c                         |  41 +++
 drivers/gpu/drm/i915/gvt/gtt.c                |   2 +-
 fs/binfmt_elf.c                               |  15 +
 fs/proc/task_mmu.c                            |   3 +
 include/asm-generic/pgtable.h                 |  14 +
 include/linux/mm.h                            |  56 ++-
 include/uapi/asm-generic/siginfo.h            |   3 +-
 include/uapi/linux/elf.h                      |   1 +
 mm/Kconfig                                    |   7 +
 mm/gup.c                                      |   8 +-
 mm/huge_memory.c                              |  12 +-
 mm/memory.c                                   |   7 +-
 mm/mmap.c                                     |  11 +
 tools/objtool/arch/x86/lib/x86-opcode-map.txt |  26 +-
 60 files changed, 1986 insertions(+), 164 deletions(-)
 create mode 100644 Documentation/x86/index.rst
 create mode 100644 Documentation/x86/intel_cet.rst
 create mode 100644 arch/x86/include/asm/cet.h
 create mode 100644 arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 arch/x86/kernel/cet.c
 create mode 100644 arch/x86/kernel/cet_prctl.c
 create mode 100644 arch/x86/kernel/elf.c

-- 
2.17.1
