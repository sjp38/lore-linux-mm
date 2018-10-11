Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 852326B0296
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:21:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 43-v6so6555152ple.19
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:21:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w90-v6si28024425pfk.208.2018.10.11.08.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:21:43 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 00/11] Control Flow Enforcement: Branch Tracking, PTRACE
Date: Thu, 11 Oct 2018 08:16:43 -0700
Message-Id: <20181011151654.27221-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The previous version of CET Branch Tracking/PTRACE patches is at the following
link:

  https://lkml.org/lkml/2018/9/21/773

Summary of changes from v4:

  Add ENDBR32/ENDBR64 to vsyscall assembly code.
  Small cleanups.
  Small fixes in IBT bitmap allocation.

  From the discussion of IBT bitmap size, I got:

    1. There are potential issues from using TASK_SIZE/TASK_SIZE_MAX;
    2. We cannot always depend on in_compat_syscall();
    3. Doing allocation in the kernel is tricky;

    The bitmap is needed only when an app does dlopen() non-IBT .so
    files; most applications do not need it.

    I am proposing that dlopen() does mmap() and passes the bitmap to
    the kernel.  If that is accepted, we can change these patches
    accordingly.

H.J. Lu (3):
  x86: Insert endbr32/endbr64 to vDSO
  x86/vsyscall/32: Add ENDBR32 to vsyscall entry point
  x86/vsyscall/64: Add ENDBR64 to vsyscall entry points

Yu-cheng Yu (8):
  x86/cet/ibt: Add Kconfig option for user-mode Indirect Branch Tracking
  x86/cet/ibt: User-mode indirect branch tracking support
  x86/cet/ibt: Add IBT legacy code bitmap allocation function
  mm/mmap: Add IBT bitmap size to address space limit check
  x86/cet/ibt: ELF header parsing for IBT
  x86/cet/ibt: Add arch_prctl functions for IBT
  x86/cet/ibt: Add ENDBR to op-code-map
  x86/cet: Add PTRACE interface for CET

 arch/x86/Kconfig                              | 16 ++++
 arch/x86/Makefile                             |  7 ++
 arch/x86/entry/vdso/.gitignore                |  4 +
 arch/x86/entry/vdso/Makefile                  | 12 ++-
 arch/x86/entry/vdso/vdso-layout.lds.S         |  1 +
 arch/x86/entry/vdso/vdso32/system_call.S      |  3 +
 arch/x86/entry/vsyscall/vsyscall_emu_64.S     |  9 +++
 arch/x86/include/asm/cet.h                    |  8 ++
 arch/x86/include/asm/disabled-features.h      |  8 +-
 arch/x86/include/asm/fpu/regset.h             |  7 +-
 arch/x86/include/asm/mmu_context.h            |  7 ++
 arch/x86/include/uapi/asm/elf_property.h      |  1 +
 arch/x86/include/uapi/asm/prctl.h             |  1 +
 arch/x86/kernel/cet.c                         | 78 +++++++++++++++++++
 arch/x86/kernel/cet_prctl.c                   | 35 +++++++++
 arch/x86/kernel/cpu/common.c                  | 17 ++++
 arch/x86/kernel/elf.c                         |  5 ++
 arch/x86/kernel/fpu/regset.c                  | 41 ++++++++++
 arch/x86/kernel/process.c                     |  1 +
 arch/x86/kernel/ptrace.c                      | 16 ++++
 arch/x86/lib/x86-opcode-map.txt               | 13 +++-
 include/uapi/linux/elf.h                      |  1 +
 mm/mmap.c                                     | 19 ++++-
 tools/objtool/arch/x86/lib/x86-opcode-map.txt | 13 +++-
 24 files changed, 313 insertions(+), 10 deletions(-)

-- 
2.17.1
