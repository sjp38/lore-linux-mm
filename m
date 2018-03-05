Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 774DC6B000C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:26:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e74so4416694wmg.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:26:21 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id i35si716065edd.278.2018.03.05.02.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:07 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 00/34 v3] PTI support for x32
Date: Mon,  5 Mar 2018 11:25:29 +0100
Message-Id: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

Hi,

here is an updated version of my PTI patches for x86-32. I
worked in the review comments and fixed a few bugs that were
found during review of v2.

In particular, the changes to v2 are:

	* Switched from movsb to movsl for stack copy
	* Simplified sysexit path to not do a full pt_regs
	  copy, copies now only 2 dwords to entry stack
	* Renamed pti_set_user_pgd() to pti_set_user_pgtbl()
	* Added a warning in case someone boots a 32 bit
	  kernel on a PCIE capable machine
	* Added switch to user-cr3 to the paranoid exit path
	  in case we entered the kernel from kernel-mode
	  with user-cr3
	* Simplified the debug handler now that all its
	  special cases are handled in the stack/cr3-switch
	  code
	* Fixed PGD_PAE_PHYS_MASK for XEN-PV
	
Here is a link to my post of the v2 patches:

	https://marc.info/?l=linux-kernel&m=151816914932088&w=2

And I also pushed these out to:

	git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v3

For easier testing. Please review.

Thanks,

	Joerg

Joerg Roedel (34):
  x86/asm-offsets: Move TSS_sp0 and TSS_sp1 to asm-offsets.c
  x86/entry/32: Rename TSS_sysenter_sp0 to TSS_entry_stack
  x86/entry/32: Load task stack from x86_tss.sp1 in SYSENTER handler
  x86/entry/32: Put ESPFIX code into a macro
  x86/entry/32: Unshare NMI return path
  x86/entry/32: Split off return-to-kernel path
  x86/entry/32: Restore segments before int registers
  x86/entry/32: Enter the kernel via trampoline stack
  x86/entry/32: Leave the kernel via trampoline stack
  x86/entry/32: Introduce SAVE_ALL_NMI and RESTORE_ALL_NMI
  x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
  x86/entry/32: Simplify debug entry point
  x86/entry/32: Add PTI cr3 switches to NMI handler code
  x86/entry/32: Add PTI cr3 switch to non-NMI entry/exit points
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
  x86/mm/pti: Add Warning when booting on a PCIE capable CPU

 arch/x86/entry/entry_32.S                   | 668 ++++++++++++++++++++++------
 arch/x86/include/asm/mmu_context.h          |   4 -
 arch/x86/include/asm/pgtable-2level.h       |   9 +
 arch/x86/include/asm/pgtable-2level_types.h |   3 +
 arch/x86/include/asm/pgtable-3level.h       |   7 +
 arch/x86/include/asm/pgtable-3level_types.h |   6 +-
 arch/x86/include/asm/pgtable.h              |  88 ++++
 arch/x86/include/asm/pgtable_32_types.h     |   9 +-
 arch/x86/include/asm/pgtable_64.h           |  89 +---
 arch/x86/include/asm/pgtable_64_types.h     |   4 +
 arch/x86/include/asm/pgtable_types.h        |  28 +-
 arch/x86/include/asm/processor-flags.h      |   8 +-
 arch/x86/include/asm/switch_to.h            |   6 +-
 arch/x86/kernel/asm-offsets.c               |   5 +
 arch/x86/kernel/asm-offsets_32.c            |   2 +-
 arch/x86/kernel/asm-offsets_64.c            |   2 -
 arch/x86/kernel/cpu/common.c                |   5 +-
 arch/x86/kernel/head_32.S                   |  20 +-
 arch/x86/kernel/ldt.c                       | 137 ++++--
 arch/x86/kernel/process.c                   |   2 -
 arch/x86/kernel/process_32.c                |  10 +-
 arch/x86/mm/dump_pagetables.c               |  21 +-
 arch/x86/mm/pgtable.c                       | 105 ++++-
 arch/x86/mm/pti.c                           |  42 +-
 security/Kconfig                            |   2 +-
 25 files changed, 963 insertions(+), 319 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
