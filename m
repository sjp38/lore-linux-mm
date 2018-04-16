Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 94C1C6B0006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:25:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b10so1944307wrf.3
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:25:39 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 32si3320921edy.432.2018.04.16.08.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:25:37 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 00/35 v5] PTI support for x32
Date: Mon, 16 Apr 2018 17:24:48 +0200
Message-Id: <1523892323-14741-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

Hi,

here is the 5th iteration of my PTI enablement patches for
x86-32. There are no real changes between v4 and v5 besides
that I rebased the whole patch-set to v4.17-rc1 and resolved
the numerous conflicts that this caused.

Two separate fixes came up since the last post and I sent them
out separatly. One is already in v4.17-rc1 (commit e3e288121408)
and the other was sent a few hours ago
(https://lkml.org/lkml/2018/4/16/230).

I pushed the rebased patches together with the mentioned fix
to:

	git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v5

for easier testing.

I tested this version again with my load-test of running
perf-top/various x86-selftests/kernel-compile in a loop for
a couple of hours. This showed no issues. I also briefly
tested a 64bit kernel and this also worked as expected.

Previous versions of these patches can be found at:

	* For v4
	  Post : https://marc.info/?l=linux-kernel&m=152122860630236&w=2
	  Git  : git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v4

	* For v3:
	  Post : https://marc.info/?l=linux-kernel&m=152024559419876&w=2
	  Git  : git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v3

	* For v2:
	  Post : https://marc.info/?l=linux-kernel&m=151816914932088&w=2
	  Git  : git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v2

Please review.

Thanks,

	Joerg


Joerg Roedel (35):
  x86/asm-offsets: Move TSS_sp0 and TSS_sp1 to asm-offsets.c
  x86/entry/32: Rename TSS_sysenter_sp0 to TSS_entry_stack
  x86/entry/32: Load task stack from x86_tss.sp1 in SYSENTER handler
  x86/entry/32: Put ESPFIX code into a macro
  x86/entry/32: Unshare NMI return path
  x86/entry/32: Split off return-to-kernel path
  x86/entry/32: Enter the kernel via trampoline stack
  x86/entry/32: Leave the kernel via trampoline stack
  x86/entry/32: Introduce SAVE_ALL_NMI and RESTORE_ALL_NMI
  x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
  x86/entry/32: Simplify debug entry point
  x86/32: Use tss.sp1 as cpu_current_top_of_stack
  x86/entry/32: Add PTI cr3 switch to non-NMI entry/exit points
  x86/entry/32: Add PTI cr3 switches to NMI handler code
  x86/pgtable: Rename pti_set_user_pgd to pti_set_user_pgtbl
  x86/pgtable/pae: Unshare kernel PMDs when PTI is enabled
  x86/pgtable/32: Allocate 8k page-tables when PTI is enabled
  x86/pgtable: Move pgdp kernel/user conversion functions to pgtable.h
  x86/pgtable: Move pti_set_user_pgtbl() to pgtable.h
  x86/pgtable: Move two more functions from pgtable_64.h to pgtable.h
  x86/mm/pae: Populate valid user PGD entries
  x86/mm/pae: Populate the user page-table with user pgd's
  x86/mm/legacy: Populate the user page-table with user pgd's
  x86/mm/pti: Add an overflow check to pti_clone_pmds()
  x86/mm/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
  x86/mm/pti: Clone CPU_ENTRY_AREA on PMD level on x86_32
  x86/mm/dump_pagetables: Define INIT_PGD
  x86/pgtable/pae: Use separate kernel PMDs for user page-table
  x86/ldt: Reserve address-space range on 32 bit for the LDT
  x86/ldt: Define LDT_END_ADDR
  x86/ldt: Split out sanity check in map_ldt_struct()
  x86/ldt: Enable LDT user-mapping for PAE
  x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32
  x86/mm/pti: Add Warning when booting on a PCID capable CPU
  x86/entry/32: Add debug code to check entry/exit cr3

 arch/x86/Kconfig.debug                      |  12 +
 arch/x86/entry/entry_32.S                   | 640 +++++++++++++++++++++++-----
 arch/x86/include/asm/mmu_context.h          |   5 -
 arch/x86/include/asm/pgtable-2level.h       |   9 +
 arch/x86/include/asm/pgtable-2level_types.h |   3 +
 arch/x86/include/asm/pgtable-3level.h       |   7 +
 arch/x86/include/asm/pgtable-3level_types.h |   6 +-
 arch/x86/include/asm/pgtable.h              |  87 ++++
 arch/x86/include/asm/pgtable_32.h           |   2 -
 arch/x86/include/asm/pgtable_32_types.h     |   9 +-
 arch/x86/include/asm/pgtable_64.h           |  89 +---
 arch/x86/include/asm/pgtable_64_types.h     |   3 +
 arch/x86/include/asm/pgtable_types.h        |  28 +-
 arch/x86/include/asm/processor-flags.h      |   8 +-
 arch/x86/include/asm/processor.h            |   4 -
 arch/x86/include/asm/switch_to.h            |   6 +-
 arch/x86/include/asm/thread_info.h          |   2 -
 arch/x86/kernel/asm-offsets.c               |   5 +
 arch/x86/kernel/asm-offsets_32.c            |   2 +-
 arch/x86/kernel/asm-offsets_64.c            |   2 -
 arch/x86/kernel/cpu/common.c                |   9 +-
 arch/x86/kernel/head_32.S                   |  20 +-
 arch/x86/kernel/ldt.c                       | 137 ++++--
 arch/x86/kernel/process.c                   |   2 -
 arch/x86/kernel/process_32.c                |   4 +-
 arch/x86/mm/dump_pagetables.c               |  21 +-
 arch/x86/mm/pgtable.c                       | 105 ++++-
 arch/x86/mm/pti.c                           |  42 +-
 security/Kconfig                            |   2 +-
 29 files changed, 967 insertions(+), 304 deletions(-)

-- 
2.7.4
