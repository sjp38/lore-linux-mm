Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 658446B026A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o60-v6so825401edd.13
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:22 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id u29-v6si2049483edl.395.2018.07.18.02.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:20 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 00/39 v8] PTI support for x86-32
Date: Wed, 18 Jul 2018 11:40:37 +0200
Message-Id: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

Hi,

here is version 8 of my patches to enable PTI on x86-32. The
last version got some good review which I mostly worked into
this version.

I didn't rebase it to v4.18-rc5, as that base didn't boot on
x86-32 because of a regression introduced by

	e181ae0c5db9 ('mm: zero unavailable pages before memmap init')

But that is already being worked on. The rebase I tried
showed no conflicts, so these patches should apply cleanly
there as well.

The changes to v7 are:

	* Fixed kbuild error (one patch failed to build)

	* Removed segment loading changes from SAVE_ALL

	* More restrictive entry-stack check in
	  SWITCH_TO_KERNEL_STACK

	* Renamed TSS_entry_stack to TSS_entry2task_stack

	* Documented properly what will go into TSS.sp1

	* Fixed comment for clearing high-bits of the dword
	  containing CS-slot in pt_regs

	* Fixed X86_FEATURE_PCID check for x86-32 in pti_init()

	* Made entry-debugging depend on CONFIG_DEBUG_ENTRY
	  instead of a new config option

	* Dropped cpu_current_top_of_stack->tss.sp1 patch.
	  It was actually subtly broken on x86-32 because
	  there is a difference between the task-stack
	  pointer and cpu_current_top_of_stack. The formula
	  is:

		task_stack = cpu_current_top_of_stack - padding
	
	  On x86-64 the padding is zero, so there is no
	  difference, but on x86-32 it is 8 or 16 bytes so
	  that cpu_current_top_of_stack can't point to
	  tss.sp1 without breaking current_pt_regs().

	* Renamed update_sp0 to update_task_stack() and made
	  that function update TSS.sp1 on x86-32. This is
	  also needed for VM86 mode. I think it can also be
	  implemented this way on x86-64, but that will be a
	  separate patch outside of this patch-set.

The patches still need fixes already in tip-tree to work
correctly. I merged these fixes into the branch I pushed to

	git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v8

for easier testing. The code survived >12h overnight testing
with my usual

	* 'perf top' for NMI load

	* x86-selftests in a loop (except mpx and pkeys
	  which are not supported on the machine)

	* kernel-compile in a loop

all in parallel. I also boot-tested x86-64 and !PAE config
again and ran my GLB-test to make sure that the global
mappings between user and kernel page-table are identical.
All that succeeded and showed no regressions.

Previous versions of this patch-set are:

	* For v7:
	  Post : https://lore.kernel.org/lkml/1531308586-29340-1-git-send-email-joro@8bytes.org/
	  Git  : git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v7

	* For v6:
	  Post : https://lore.kernel.org/lkml/1524498460-25530-1-git-send-email-joro@8bytes.org/
	  Git  : git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v6

	* For v5:
	  Post : https://marc.info/?l=linux-kernel&m=152389297705480&w=2
	  Git  : git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v5

	* For v4:
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


Joerg Roedel (39):
  x86/asm-offsets: Move TSS_sp0 and TSS_sp1 to asm-offsets.c
  x86/entry/32: Rename TSS_sysenter_sp0 to TSS_entry2task_stack
  x86/entry/32: Load task stack from x86_tss.sp1 in SYSENTER handler
  x86/entry/32: Put ESPFIX code into a macro
  x86/entry/32: Unshare NMI return path
  x86/entry/32: Split off return-to-kernel path
  x86/entry/32: Enter the kernel via trampoline stack
  x86/entry/32: Leave the kernel via trampoline stack
  x86/entry/32: Introduce SAVE_ALL_NMI and RESTORE_ALL_NMI
  x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
  x86/entry/32: Simplify debug entry point
  x86/entry/32: Add PTI cr3 switch to non-NMI entry/exit points
  x86/entry/32: Add PTI cr3 switches to NMI handler code
  x86/entry: Rename update_sp0 to update_task_stack
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
  x86/mm/pti: Make pti_clone_kernel_text() compile on 32 bit
  x86/mm/pti: Keep permissions when cloning kernel text in
    pti_clone_kernel_text()
  x86/mm/pti: Introduce pti_finalize()
  x86/mm/pti: Clone entry-text again in pti_finalize()
  x86/mm/dump_pagetables: Define INIT_PGD
  x86/pgtable/pae: Use separate kernel PMDs for user page-table
  x86/ldt: Reserve address-space range on 32 bit for the LDT
  x86/ldt: Define LDT_END_ADDR
  x86/ldt: Split out sanity check in map_ldt_struct()
  x86/ldt: Enable LDT user-mapping for PAE
  x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32
  x86/mm/pti: Add Warning when booting on a PCID capable CPU
  x86/entry/32: Add debug code to check entry/exit cr3

 arch/x86/entry/entry_32.S                   | 624 +++++++++++++++++++++++-----
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
 arch/x86/include/asm/pti.h                  |   3 +-
 arch/x86/include/asm/sections.h             |   1 +
 arch/x86/include/asm/switch_to.h            |  16 +-
 arch/x86/kernel/asm-offsets.c               |   5 +
 arch/x86/kernel/asm-offsets_32.c            |  10 +-
 arch/x86/kernel/asm-offsets_64.c            |   2 -
 arch/x86/kernel/cpu/common.c                |   5 +-
 arch/x86/kernel/head_32.S                   |  20 +-
 arch/x86/kernel/ldt.c                       | 137 ++++--
 arch/x86/kernel/process.c                   |   2 -
 arch/x86/kernel/process_32.c                |   2 +-
 arch/x86/kernel/process_64.c                |   2 +-
 arch/x86/kernel/vm86_32.c                   |   4 +-
 arch/x86/kernel/vmlinux.lds.S               |  17 +-
 arch/x86/mm/dump_pagetables.c               |  21 +-
 arch/x86/mm/init_64.c                       |   6 -
 arch/x86/mm/pgtable.c                       | 105 ++++-
 arch/x86/mm/pti.c                           |  73 +++-
 include/linux/pti.h                         |   1 +
 init/main.c                                 |   7 +
 security/Kconfig                            |   2 +-
 34 files changed, 1014 insertions(+), 307 deletions(-)

-- 
2.7.4
