Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D08C46B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:39:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7-v6so4625874pfi.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:39:59 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 88-v6si53306702pla.315.2018.06.07.07.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:39:58 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 0/5] Control Flow Enforcement - Part (1)
Date: Thu,  7 Jun 2018 07:35:39 -0700
Message-Id: <20180607143544.3477-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Control flow enforcement technology (CET) is an upcoming Intel
processor family feature that prevents return/jmp-oriented
programming attacks.  It has two components: shadow stack (SHSTK)
and indirect branch tracking (IBT).

The specification is at:

  https://software.intel.com/sites/default/files/managed/4d/2a/
  control-flow-enforcement-technology-preview.pdf

The SHSTK is a secondary stack allocated from system memory.
The CALL instruction stores a secure copy of the return address
on the SHSTK; the RET instruction compares the return address
from the program stack to the SHSTK copy.  Any mismatch
triggers a control protection fault.

When the IBT is enabled, the processor verifies an indirect
CALL/JMP destination is an ENDBR instruction; otherwise, it
raises a control protection fault.  The compiler inserts ENDBRs
at all valid branch targets.

CET can be enabled for both kernel and user mode protection.
The Linux kernel patches being posted are for user-mode
protection.  They are grouped into four series:

  (1) CPUID enumeration, CET XSAVES system states, and
      documentation;
  (2) Kernel config, exception handling, and memory management
      changes;
  (3) SHSTK support;
  (4) IBT support, command-line tool, PTRACE.

Yu-cheng Yu (5):
  x86/cpufeatures: Add CPUIDs for Control-flow Enforcement Technology
    (CET)
  x86/fpu/xstate: Change some names to separate XSAVES system and user
    states
  x86/fpu/xstate: Enable XSAVES system states
  x86/fpu/xstate: Add XSAVES system states for shadow stack
  Documentation/x86: Add CET description

 Documentation/admin-guide/kernel-parameters.txt |   6 +
 Documentation/x86/intel_cet.txt                 | 161 ++++++++++++++++++++++++
 arch/x86/include/asm/cpufeatures.h              |   2 +
 arch/x86/include/asm/fpu/internal.h             |   6 +-
 arch/x86/include/asm/fpu/types.h                |  22 ++++
 arch/x86/include/asm/fpu/xstate.h               |  31 ++---
 arch/x86/include/uapi/asm/processor-flags.h     |   2 +
 arch/x86/kernel/cpu/scattered.c                 |   1 +
 arch/x86/kernel/fpu/core.c                      |  11 +-
 arch/x86/kernel/fpu/init.c                      |  10 --
 arch/x86/kernel/fpu/signal.c                    |   6 +-
 arch/x86/kernel/fpu/xstate.c                    | 152 +++++++++++++---------
 12 files changed, 319 insertions(+), 91 deletions(-)
 create mode 100644 Documentation/x86/intel_cet.txt

-- 
2.15.1
