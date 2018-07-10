Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A85F56B0266
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q21-v6so14858410pff.4
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q185-v6si17504162pga.322.2018.07.10.15.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:11 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 00/27] Control Flow Enforcement (CET)
Date: Tue, 10 Jul 2018 15:26:12 -0700
Message-Id: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The first version of CET patches were divided into four series.
They can be found in the following links.

  https://lkml.org/lkml/2018/6/7/795
  https://lkml.org/lkml/2018/6/7/782
  https://lkml.org/lkml/2018/6/7/771
  https://lkml.org/lkml/2018/6/7/739

Summary of changes in v2:

  Small fixes in the XSAVES patches.
  Improve: Documentation/x86/intel_cet.txt.
  Remove TLB flushing from ptep/pmdp_set_wrprotect for SHSTK.
  Use shadow stack restore token for signals; save SHSTK pointer after FPU.
  Rewrite ELF header parsing.
  Backward compatibility is now handled from GLIBC tunables.
  Add a new patch to can_follow_write_pte/pmd, for SHSTK.
  Remove blocking of mremap/madvice/munmap.
  Add Makefile checking CET support of assembler/compiler.

H.J. Lu (1):
  x86: Insert endbr32/endbr64 to vDSO

Yu-cheng Yu (26):
  x86/cpufeatures: Add CPUIDs for Control-flow Enforcement Technology
    (CET)
  x86/fpu/xstate: Change some names to separate XSAVES system and user
    states
  x86/fpu/xstate: Enable XSAVES system states
  x86/fpu/xstate: Add XSAVES system states for shadow stack
  Documentation/x86: Add CET description
  x86/cet: Control protection exception handler
  x86/cet/shstk: Add Kconfig option for user-mode shadow stack
  mm: Introduce VM_SHSTK for shadow stack memory
  x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
  x86/mm: Introduce _PAGE_DIRTY_SW
  x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for
    _PAGE_DIRTY_SW
  x86/mm: Shadow stack page fault error checking
  mm: Handle shadow stack page fault
  mm: Handle THP/HugeTLB shadow stack page fault
  mm/mprotect: Prevent mprotect from changing shadow stack
  mm: Modify can_follow_write_pte/pmd for shadow stack
  x86/cet/shstk: User-mode shadow stack support
  x86/cet/shstk: Introduce WRUSS instruction
  x86/cet/shstk: Signal handling for shadow stack
  x86/cet/shstk: ELF header parsing of CET
  x86/cet/ibt: Add Kconfig option for user-mode Indirect Branch Tracking
  x86/cet/ibt: User-mode indirect branch tracking support
  mm/mmap: Add IBT bitmap size to address space limit check
  x86/cet: Add PTRACE interface for CET
  x86/cet/shstk: Handle thread shadow stack
  x86/cet: Add arch_prctl functions for CET

 .../admin-guide/kernel-parameters.txt         |   6 +
 Documentation/x86/intel_cet.txt               | 250 ++++++++++++
 arch/x86/Kconfig                              |  40 ++
 arch/x86/Makefile                             |  14 +
 arch/x86/entry/entry_64.S                     |   2 +-
 arch/x86/entry/vdso/.gitignore                |   4 +
 arch/x86/entry/vdso/Makefile                  |  12 +-
 arch/x86/entry/vdso/vdso-layout.lds.S         |   1 +
 arch/x86/ia32/ia32_signal.c                   |  13 +
 arch/x86/include/asm/cet.h                    |  50 +++
 arch/x86/include/asm/cpufeatures.h            |   2 +
 arch/x86/include/asm/disabled-features.h      |  16 +-
 arch/x86/include/asm/elf.h                    |   5 +
 arch/x86/include/asm/fpu/internal.h           |   6 +-
 arch/x86/include/asm/fpu/regset.h             |   7 +-
 arch/x86/include/asm/fpu/types.h              |  22 +
 arch/x86/include/asm/fpu/xstate.h             |  31 +-
 arch/x86/include/asm/mmu_context.h            |   3 +
 arch/x86/include/asm/msr-index.h              |  14 +
 arch/x86/include/asm/pgtable.h                | 135 ++++++-
 arch/x86/include/asm/pgtable_types.h          |  31 +-
 arch/x86/include/asm/processor.h              |   5 +
 arch/x86/include/asm/sighandling.h            |   5 +
 arch/x86/include/asm/special_insns.h          |  45 +++
 arch/x86/include/asm/traps.h                  |   5 +
 arch/x86/include/uapi/asm/elf_property.h      |  16 +
 arch/x86/include/uapi/asm/prctl.h             |   6 +
 arch/x86/include/uapi/asm/processor-flags.h   |   2 +
 arch/x86/include/uapi/asm/resource.h          |   5 +
 arch/x86/include/uapi/asm/sigcontext.h        |  17 +
 arch/x86/kernel/Makefile                      |   4 +
 arch/x86/kernel/cet.c                         | 375 ++++++++++++++++++
 arch/x86/kernel/cet_prctl.c                   | 141 +++++++
 arch/x86/kernel/cpu/common.c                  |  42 ++
 arch/x86/kernel/cpu/scattered.c               |   1 +
 arch/x86/kernel/elf.c                         | 280 +++++++++++++
 arch/x86/kernel/fpu/core.c                    |  11 +-
 arch/x86/kernel/fpu/init.c                    |  10 -
 arch/x86/kernel/fpu/regset.c                  |  41 ++
 arch/x86/kernel/fpu/signal.c                  |   6 +-
 arch/x86/kernel/fpu/xstate.c                  | 152 ++++---
 arch/x86/kernel/idt.c                         |   4 +
 arch/x86/kernel/process.c                     |  10 +
 arch/x86/kernel/process_64.c                  |   7 +
 arch/x86/kernel/ptrace.c                      |  16 +
 arch/x86/kernel/relocate_kernel_64.S          |   2 +-
 arch/x86/kernel/signal.c                      |  96 +++++
 arch/x86/kernel/traps.c                       |  58 +++
 arch/x86/kvm/vmx.c                            |   2 +-
 arch/x86/lib/x86-opcode-map.txt               |   2 +-
 arch/x86/mm/fault.c                           |  24 +-
 fs/binfmt_elf.c                               |  16 +
 fs/proc/task_mmu.c                            |   3 +
 include/asm-generic/pgtable.h                 |  21 +
 include/linux/mm.h                            |   8 +
 include/uapi/asm-generic/resource.h           |   3 +
 include/uapi/linux/elf.h                      |   2 +
 mm/gup.c                                      |  11 +-
 mm/huge_memory.c                              |  18 +-
 mm/internal.h                                 |   8 +
 mm/memory.c                                   |  38 +-
 mm/mmap.c                                     |  12 +-
 mm/mprotect.c                                 |   9 +
 tools/objtool/arch/x86/lib/x86-opcode-map.txt |   2 +-
 64 files changed, 2070 insertions(+), 135 deletions(-)
 create mode 100644 Documentation/x86/intel_cet.txt
 create mode 100644 arch/x86/include/asm/cet.h
 create mode 100644 arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 arch/x86/kernel/cet.c
 create mode 100644 arch/x86/kernel/cet_prctl.c
 create mode 100644 arch/x86/kernel/elf.c

-- 
2.17.1
