Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 648A76B0008
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:25:57 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 17so4204619wrm.10
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:25:57 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id y33si1232683edy.458.2018.02.09.01.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:53 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 00/31 v2] PTI support for x86_32
Date: Fri,  9 Feb 2018 10:25:09 +0100
Message-Id: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

Hi,

here is the second version of my PTI implementation for
x86_32, based on tip/x86-pti-for-linus. It took a lot longer
than I had hoped, but there have been a number of obstacles
on the way. It also isn't the small patch-set anymore that v1
was, but compared to it this one actually works :)

The biggest changes were necessary in the entry code, a lot
of it is moving code around, but there are also significant
changes to get all cases covered. This includes NMIs and
exceptions on the kernel exit-path where we are already on
the entry-stack. To make this work I decided to mostly split
up the common kernel-exit path into a return-to-kernel,
return-to-user and return-from-nmi part.

On the page-table side I had to do a lot of special cases
for PAE because PAE paging is so, well, special. The biggest
example here is the LDT mapping code, which needs to work on
the PMD level instead of PGD when PAE is enabled.

During development I also experimented with unshared PMDs
between the kernel and the user page-tables for PAE. It
worked by allocating 8k PMDs and using the lower half for
the kernel and the upper half for the user page-table. While
this worked and allowed me to NX-protect the user-space
address-range in the kernel page-table, it also required 5
order-1 allocations in low-mem for each process. In my
testing I got this to fail pretty quickly and trigger OOM,
so I abandoned the approach for now.

Here is how I tested these patches:

	* Booted on a real machine (4C/8T, 16GB RAM) and run
	  an overnight load-test with 'perf top' running
	  (for the NMIs), the ldt_gdt selftest running in a
	  loop (for more stress on the entry/exit path) and
	  a -j16 kernel compile also running in a loop. The
	  box survived the test, which ran for more than 18
	  hours.

	* Tested most x86 selftests in the kernel on the
	  real machine. This showed no regressions. I did
	  not run the mpx and protection-key tests, as the
	  machine does not support these features, and I
	  also skipped the check_initial_reg_state test, as
	  it made problems while compiling and it didn't
	  seem relevant enough to fix that for this
	  patch-set.

	* Boot tested all valid combinations of [NO]HIGHMEM* vs.
	  VMSPLIT* vs. PAE in KVM. All booted fine.

	* Did compile-tests with various configs (allyes,
	  allmod, defconfig, ..., basically what I usually
	  use to test the iommu-tree as well). All compiled
	  fine.

	* Some basic compile, boot and runtime testing of
	  64 bit to make sure I didn't break anything there.

I did not explicitly test wine and dosemu, but since the
vm86 and the ldt_gdt self-tests all passed fine I am
confident that those will also still work.

XENPV is also untested from my side, but I added checks to
not do the stack switches in the entry-code when XENPV is
enabled, so hopefully it works. But someone should test it,
of course.

I also pushed these patches to

	git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v2

for easier testing.

I do not claim that I've found the best solution for every
problem I encountered, so please review and give me feedback
on what I should change or solve differently. Of course I am
also interested in all bugs that may still be in there.

Thanks a lot,

       Joerg


Joerg Roedel (31):
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
  x86/entry/32: Add PTI cr3 switches to NMI handler code
  x86/entry/32: Add PTI cr3 switch to non-NMI entry/exit points
  x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
  x86/pgtable/pae: Unshare kernel PMDs when PTI is enabled
  x86/pgtable/32: Allocate 8k page-tables when PTI is enabled
  x86/pgtable: Move pgdp kernel/user conversion functions to pgtable.h
  x86/pgtable: Move pti_set_user_pgd() to pgtable.h
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

 arch/x86/entry/entry_32.S                   | 581 ++++++++++++++++++++++------
 arch/x86/include/asm/mmu_context.h          |   4 -
 arch/x86/include/asm/pgtable-2level.h       |   9 +
 arch/x86/include/asm/pgtable-2level_types.h |   3 +
 arch/x86/include/asm/pgtable-3level.h       |   7 +
 arch/x86/include/asm/pgtable-3level_types.h |   6 +-
 arch/x86/include/asm/pgtable.h              |  88 +++++
 arch/x86/include/asm/pgtable_32_types.h     |   9 +-
 arch/x86/include/asm/pgtable_64.h           |  85 ----
 arch/x86/include/asm/pgtable_64_types.h     |   4 +
 arch/x86/include/asm/pgtable_types.h        |  26 +-
 arch/x86/include/asm/processor-flags.h      |   8 +-
 arch/x86/include/asm/switch_to.h            |   6 +-
 arch/x86/kernel/asm-offsets.c               |   5 +
 arch/x86/kernel/asm-offsets_32.c            |   2 +-
 arch/x86/kernel/asm-offsets_64.c            |   2 -
 arch/x86/kernel/cpu/common.c                |   5 +-
 arch/x86/kernel/head_32.S                   |  20 +-
 arch/x86/kernel/ldt.c                       | 137 +++++--
 arch/x86/kernel/process.c                   |   2 -
 arch/x86/kernel/process_32.c                |  10 +-
 arch/x86/mm/dump_pagetables.c               |  21 +-
 arch/x86/mm/pgtable.c                       | 105 ++++-
 arch/x86/mm/pti.c                           |  24 ++
 security/Kconfig                            |   2 +-
 25 files changed, 888 insertions(+), 283 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
