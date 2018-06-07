Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 506F86B027C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so5521530plf.19
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:30 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:29 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 00/10] Control Flow Enforcement - Part (3)
Date: Thu,  7 Jun 2018 07:37:57 -0700
Message-Id: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

This series introduces CET - Shadow stack

At the high level, shadow stack is:

	Allocated from a task's address space with vm_flags VM_SHSTK;
	Its PTEs must be read-only and dirty;
	Fixed sized, but the default size can be changed by sys admin.

For a forked child, the shadow stack is duplicated when the next
shadow stack access takes place.

For a pthread child, a new shadow stack is allocated.

The signal handler uses the same shadow stack as the main program.

Yu-cheng Yu (10):
  x86/cet: User-mode shadow stack support
  x86/cet: Introduce WRUSS instruction
  x86/cet: Signal handling for shadow stack
  x86/cet: Handle thread shadow stack
  x86/cet: ELF header parsing of Control Flow Enforcement
  x86/cet: Add arch_prctl functions for shadow stack
  mm: Prevent mprotect from changing shadow stack
  mm: Prevent mremap of shadow stack
  mm: Prevent madvise from changing shadow stack
  mm: Prevent munmap and remap_file_pages of shadow stack

 arch/x86/Kconfig                              |   4 +
 arch/x86/ia32/ia32_signal.c                   |   5 +
 arch/x86/include/asm/cet.h                    |  48 ++++++
 arch/x86/include/asm/disabled-features.h      |   8 +-
 arch/x86/include/asm/elf.h                    |   5 +
 arch/x86/include/asm/mmu_context.h            |   3 +
 arch/x86/include/asm/msr-index.h              |  14 ++
 arch/x86/include/asm/processor.h              |   5 +
 arch/x86/include/asm/special_insns.h          |  44 +++++
 arch/x86/include/uapi/asm/elf_property.h      |  16 ++
 arch/x86/include/uapi/asm/prctl.h             |  15 ++
 arch/x86/include/uapi/asm/sigcontext.h        |   4 +
 arch/x86/kernel/Makefile                      |   4 +
 arch/x86/kernel/cet.c                         | 224 ++++++++++++++++++++++++
 arch/x86/kernel/cet_prctl.c                   | 203 ++++++++++++++++++++++
 arch/x86/kernel/cpu/common.c                  |  24 +++
 arch/x86/kernel/elf.c                         | 236 ++++++++++++++++++++++++++
 arch/x86/kernel/process.c                     |  10 ++
 arch/x86/kernel/process_64.c                  |   7 +
 arch/x86/kernel/signal.c                      |  11 ++
 arch/x86/lib/x86-opcode-map.txt               |   2 +-
 arch/x86/mm/fault.c                           |  13 +-
 fs/binfmt_elf.c                               |  16 ++
 fs/proc/task_mmu.c                            |   3 +
 include/uapi/linux/elf.h                      |   1 +
 mm/madvise.c                                  |   9 +
 mm/mmap.c                                     |  13 ++
 mm/mprotect.c                                 |   9 +
 mm/mremap.c                                   |   5 +-
 tools/objtool/arch/x86/lib/x86-opcode-map.txt |   2 +-
 30 files changed, 958 insertions(+), 5 deletions(-)
 create mode 100644 arch/x86/include/asm/cet.h
 create mode 100644 arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 arch/x86/kernel/cet.c
 create mode 100644 arch/x86/kernel/cet_prctl.c
 create mode 100644 arch/x86/kernel/elf.c

-- 
2.15.1
