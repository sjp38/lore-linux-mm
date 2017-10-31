Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1BB16B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:31:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l23so446718pgc.10
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:31:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f126si2860108pfg.410.2017.10.31.15.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:31:48 -0700 (PDT)
Subject: [PATCH 00/23] KAISER: unmap most of the kernel from userspace page tables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:31:46 -0700
Message-Id: <20171031223146.6B47C861@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com

tl;dr:

KAISER makes it harder to defeat KASLR, but makes syscalls and
interrupts slower.  These patches are based on work from a team at
Graz University of Technology posted here[1].  The major addition is
support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
for a wide variety of use cases.

Full Description:

KAISER is a countermeasure against attacks on kernel address
information.  There are at least three existing, published,
approaches using the shared user/kernel mapping and hardware features
to defeat KASLR.  One approach referenced in the paper locates the
kernel by observing differences in page fault timing between
present-but-inaccessable kernel pages and non-present pages.

KAISER addresses this by unmapping (most of) the kernel when
userspace runs.  It leaves the existing page tables largely alone and
refers to them as "kernel page tables".  For running userspace, a new
"shadow" copy of the page tables is allocated for each process.  The
shadow page tables map all the same user memory as the "kernel" copy,
but only maps a minimal set of kernel memory.

When we enter the kernel via syscalls, interrupts or exceptions,
page tables are switched to the full "kernel" copy.  When the system
switches back to user mode, the "shadow" copy is used.  Process
Context IDentifiers (PCIDs) are used to to ensure that the TLB is not
flushed when switching between page tables, which makes syscalls
roughly 2x faster than without it.  PCIDs are usable on Haswell and
newer CPUs (the ones with "v4", or called fourth-generation Core).

The minimal kernel page tables try to map only what is needed to
enter/exit the kernel such as the entry/exit functions, interrupt
descriptors (IDT) and the kernel stacks.  This minimal set of data
can still reveal the kernel's ASLR base address.  But, this minimal
kernel data is all trusted, which makes it harder to exploit than
data in the kernel direct map which contains loads of user-controlled
data.

KAISER will affect performance for anything that does system calls or
interrupts: everything.  Just the new instructions (CR3 manipulation)
add a few hundred cycles to a syscall or interrupt.  Most workloads
that we have run show single-digit regressions.  5% is a good round
number for what is typical.  The worst we have seen is a roughly 30%
regression on a loopback networking test that did a ton of syscalls
and context switches.  More details about possible performance
impacts are in the new Documentation/ file.

This code is based on a version I downloaded from
(https://github.com/IAIK/KAISER).  It has been heavily modified.

The approach is described in detail in a paper[2].  However, there is
some incorrect and information in the paper, both on how Linux and
the hardware works.  For instance, I do not share the opinion that
KAISER has "runtime overhead of only 0.28%".  Please rely on this
patch series as the canonical source of information about this
submission.

Here is one example of how the kernel image grow with CONFIG_KAISER
on and off.  Most of the size increase is presumably from additional
alignment requirements for mapping entry/exit code and structures.

    text    data     bss      dec filename
11786064 7356724 2928640 22071428 vmlinux-nokaiser
11798203 7371704 2928640 22098547 vmlinux-kaiser
  +12139  +14980       0   +27119

To give folks an idea what the performance impact is like, I took
the following test and ran it single-threaded:

	https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c

It's a pretty quick syscall so this shows how much KAISER slows
down syscalls (and how much PCIDs help).  The units here are
lseeks/second:

        no kaiser: 5.2M
    kaiser+  pcid: 3.0M
    kaiser+nopcid: 2.2M

"nopcid" is literally with the "nopcid" command-line option which
turns PCIDs off entirely.

Thanks to:
The original KAISER team at Graz University of Technology.
Andy Lutomirski for all the help with the entry code.
Kirill Shutemov for a helpful review of the code.

1. https://github.com/IAIK/KAISER
2. https://gruss.cc/files/kaiser.pdf

--

The code is available here:

	https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/

 Documentation/x86/kaiser.txt                | 128 ++++++
 arch/x86/Kconfig                            |   4 +
 arch/x86/entry/calling.h                    |  77 ++++
 arch/x86/entry/entry_64.S                   |  34 +-
 arch/x86/entry/entry_64_compat.S            |  13 +
 arch/x86/events/intel/ds.c                  |  57 ++-
 arch/x86/include/asm/cpufeatures.h          |   1 +
 arch/x86/include/asm/desc.h                 |   2 +-
 arch/x86/include/asm/hw_irq.h               |   2 +-
 arch/x86/include/asm/kaiser.h               |  59 +++
 arch/x86/include/asm/mmu_context.h          |  29 +-
 arch/x86/include/asm/pgalloc.h              |  32 +-
 arch/x86/include/asm/pgtable.h              |  20 +-
 arch/x86/include/asm/pgtable_64.h           | 121 ++++++
 arch/x86/include/asm/pgtable_types.h        |  16 +
 arch/x86/include/asm/processor.h            |   2 +-
 arch/x86/include/asm/tlbflush.h             | 230 +++++++++--
 arch/x86/include/uapi/asm/processor-flags.h |   3 +-
 arch/x86/kernel/cpu/common.c                |  21 +-
 arch/x86/kernel/espfix_64.c                 |  22 +-
 arch/x86/kernel/head_64.S                   |  30 +-
 arch/x86/kernel/irqinit.c                   |   2 +-
 arch/x86/kernel/ldt.c                       |  25 +-
 arch/x86/kernel/process.c                   |   2 +-
 arch/x86/kernel/process_64.c                |   2 +-
 arch/x86/kvm/x86.c                          |   3 +-
 arch/x86/mm/Makefile                        |   1 +
 arch/x86/mm/init.c                          |  75 ++--
 arch/x86/mm/kaiser.c                        | 416 ++++++++++++++++++++
 arch/x86/mm/pageattr.c                      |  63 ++-
 arch/x86/mm/pgtable.c                       |  16 +-
 arch/x86/mm/tlb.c                           | 105 ++++-
 include/asm-generic/vmlinux.lds.h           |  17 +
 include/linux/kaiser.h                      |  34 ++
 include/linux/percpu-defs.h                 |  32 +-
 init/main.c                                 |   2 +
 kernel/fork.c                               |   6 +
 security/Kconfig                            |  10 +
 38 files changed, 1565 insertions(+), 149 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
