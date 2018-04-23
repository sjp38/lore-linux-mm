Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDC6B6B000C
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:47:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so16758164wrh.6
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:47:50 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id y67si3670980ede.364.2018.04.23.08.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:47:45 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 00/37 v6] PTI support for x86-32
Date: Mon, 23 Apr 2018 17:47:03 +0200
Message-Id: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

Hi,

here is the new version of my PTI patches for x86-32 which
implement last weeks review comments.

Changes to v5 are:

	* Rebased to v4.17-rc2

	* Removed the protection changes between memory
	  areas mapped in the kernel and user page-tables
	  with global bit set

	* Added kernel text mapping to the user-space
	  page-table as it is done on x86-64 to gain
	  performance

	* Measured the performance again

The result of the changes are two small new patches, namely
patches 27 and 28 which implement most of the above. I also
removed the GLB bit clearing from patch 26.

Here are the new performance numbers, I used the same
benchmark that Ingo suggested to use for v2. It actually
shows quite some improvement over the numbers gathered back
then. The reason is most likely the global kernel
text-mapping added to the user page-table. In particular,
the numbers are:

For 'perf stat --null --sync --repeat 50 perf bench sched messaging -g 20':

v4.17-rc2          : 0.306761370 seconds time elapsed                                          ( +-  0.93% )
pti-x32-v6 pti=on  : 0.406391420 seconds time elapsed                                          ( +-  0.45% )
pti-x32-v6 pti=off : 0.306383858 seconds time elapsed                                          ( +-  0.90% )

and for 'perf stat --null --sync --repeat 50 perf bench sched messaging -g 20 -t':

v4.17-rc2          : 0.299934984 seconds time elapsed                                          ( +-  1.00% )
pti-x32-v6 pti=on  : 0.379535803 seconds time elapsed                                          ( +-  0.81% )
pti-x32-v6 pti=off : 0.297920551 seconds time elapsed                                          ( +-  1.12% )

So the slowdown is around 32.5% for the non-threaded test
vs. 26.5% for the threaded test. That is quite an
improvement over v2, where the slowdown for the non-threaded
test was at 57%.

The difference between v4.17-rc2 and the pti=off kernel is
in the noise, I wasn't able to measure a reliable slowdown.

For the global bit settings, all page-tables have now
identical regions mapped with global bits:

 # grep GLB /sys/kernel/debug/page_tables/kernel > kernel
 # grep GLB /sys/kernel/debug/page_tables/current_user > current_user
 # grep GLB /sys/kernel/debug/page_tables/current_kernel > current_kernel
 # sha1sum *
15820e407be3650cf705a26e2291ef1a6ef1bce0  current_kernel
15820e407be3650cf705a26e2291ef1a6ef1bce0  current_user
15820e407be3650cf705a26e2291ef1a6ef1bce0  kernel

In particular, the regions mapped with global bits are the
kernel text mapping and the cpu entry area of the address
space.

This patch-set also got similar testing like the previous
ones. I did the the load-test with 'perf top', several x86
self-tests and a -j16 kernel compile in parallel and a loop
for a couple of hours without any issues. Further I
boot-tested non-pae and also 64bit configs with these
patches.

As with previous versions there is also a branch for people
to test:

	git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux.git pti-x32-v6

And the previous versions are also still around and can be
found at:

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

Joerg Roedel (37):
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
  x86/mm/pti: Keep permissions when cloning kernel text in
    pti_clone_kernel_text()
  x86/mm/pti: Map kernel-text to user-space on 32 bit kernels
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
 arch/x86/mm/init_32.c                       |   6 +
 arch/x86/mm/pgtable.c                       | 105 ++++-
 arch/x86/mm/pti.c                           |  44 +-
 security/Kconfig                            |   2 +-
 30 files changed, 974 insertions(+), 305 deletions(-)

-- 
2.7.4
