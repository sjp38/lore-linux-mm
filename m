Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E86C56B0266
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z1-v6so4680781pfh.3
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:41 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b60-v6si54342625plc.270.2018.06.07.07.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:40:40 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 0/9] Control Flow Enforcement - Part (2)
Date: Thu,  7 Jun 2018 07:36:56 -0700
Message-Id: <20180607143705.3531-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Summary of changes:

  Shadow stack kernel config option;
  Control protection exception; and
  Shadow stack memory management.

The shadow stack PTE needs to be read-only and dirty.  Changes
are made to:

  Use the read-only and hardware dirty combination exclusively
  for shadow stack;

  Use a PTE spare bit to indicate other PTE dirty conditions;

  Shadow stack page fault handling.

Yu-cheng Yu (9):
  x86/cet: Control protection exception handler
  x86/cet: Add Kconfig option for user-mode shadow stack
  mm: Introduce VM_SHSTK for shadow stack memory
  x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
  x86/mm: Introduce _PAGE_DIRTY_SW
  x86/mm: Introduce ptep_set_wrprotect_flush and related functions
  x86/mm: Shadow stack page fault error checking
  x86/cet: Handle shadow stack page fault
  x86/cet: Handle THP/HugeTLB shadow stack page copying

 arch/x86/Kconfig                     |  24 ++++++
 arch/x86/entry/entry_32.S            |   5 ++
 arch/x86/entry/entry_64.S            |   2 +-
 arch/x86/include/asm/pgtable.h       | 149 ++++++++++++++++++++++++++++++-----
 arch/x86/include/asm/pgtable_types.h |  31 +++++---
 arch/x86/include/asm/traps.h         |   5 ++
 arch/x86/kernel/idt.c                |   1 +
 arch/x86/kernel/relocate_kernel_64.S |   2 +-
 arch/x86/kernel/traps.c              |  61 ++++++++++++++
 arch/x86/kvm/vmx.c                   |   2 +-
 arch/x86/mm/fault.c                  |  11 +++
 include/asm-generic/pgtable.h        |  38 +++++++++
 include/linux/mm.h                   |   8 ++
 mm/huge_memory.c                     |  10 ++-
 mm/hugetlb.c                         |   2 +-
 mm/internal.h                        |   8 ++
 mm/memory.c                          |  32 +++++++-
 17 files changed, 353 insertions(+), 38 deletions(-)

-- 
2.15.1
