Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4361E6B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:02:27 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id v77so36923ybi.1
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 08:02:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z17sor3728181ybj.171.2017.11.20.08.02.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 08:02:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
From: Juerg Haefliger <juergh@gmail.com>
Date: Mon, 20 Nov 2017 17:02:23 +0100
Message-ID: <CADLDEKuKjtOcfyjiPe+3MS0DxhTYsuUvy-7xrkFCeuYQjx8LSg@mail.gmail.com>
Subject: Re: [PATCH 00/30] [v3] KAISER: unmap most of the kernel from
 userspace page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com

On Fri, Nov 10, 2017 at 8:30 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> Thanks, everyone for all the reviews thus far.  I hope I managed to
> address all the feedback given so far, except for the TODOs of
> course.  This is a pretty minor update compared to v1->v2.
>
> These patches are all on top of Andy's entry changes here:
>
>         https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/entry_consolidation
>
> Changes from v2:
>  * Reword documentation removing "we"
>  * Fix some whitespace damage
>  * Fix up MAX ASID values off-by-one noted by Peter Z
>  * Change CodingStyle stuff from Borislav comments
>  * Always use _KERNPG_TABLE for pmd_populate_kernel().
>
> Changes from v1:
>  * Updated to be on top of Andy L's new entry code
>  * Allow global pages again, and use them for pages mapped into
>    userspace page tables.
>  * Use trampoline stack instead of process stack at entry so no
>    longer need to map process stack (big win in fork() speed)
>  * Made the page table walking less generic by restricting it
>    to kernel addresses and !_PAGE_USER pages.
>  * Added a debugfs file to enable/disable CR3 switching at
>    runtime.  This does not remove all the KAISER overhead, but
>    it removes the largest source.
>  * Use runtime disable with Xen to permit Xen-PV guests with
>    KAISER=y.
>  * Moved assembly code from "core" to "prepare assembly" patch
>  * Pass full register name to asm macros
>  * Remove double stack switch in entry_SYSENTER_compat
>  * Disable vsyscall native case when KAISER=y
>  * Separate PER_CPU_USER_MAPPED generic definitions from use
>    by arch/x86/.
>
> TODO:
>  * Allow dumping the shadow page tables with the ptdump code
>  * Put LDT at top of userspace
>  * Create separate tlb flushing functions for user and kernel
>  * Chase down the source of the new !CR4.PGE warning that 0day
>    found with i386
>
> ---
>
> tl;dr:
>
> KAISER makes it harder to defeat KASLR, but makes syscalls and
> interrupts slower.  These patches are based on work from a team at
> Graz University of Technology posted here[1].  The major addition is
> support for Intel PCIDs which builds on top of Andy Lutomorski's PCID
> work merged for 4.14.  PCIDs make KAISER's overhead very reasonable
> for a wide variety of use cases.
>
> Full Description:
>
> KAISER is a countermeasure against attacks on kernel address
> information.  There are at least three existing, published,
> approaches using the shared user/kernel mapping and hardware features
> to defeat KASLR.  One approach referenced in the paper locates the
> kernel by observing differences in page fault timing between
> present-but-inaccessable kernel pages and non-present pages.
>
> KAISER addresses this by unmapping (most of) the kernel when
> userspace runs.  It leaves the existing page tables largely alone and
> refers to them as "kernel page tables".  For running userspace, a new
> "shadow" copy of the page tables is allocated for each process.  The
> shadow page tables map all the same user memory as the "kernel" copy,
> but only maps a minimal set of kernel memory.
>
> When we enter the kernel via syscalls, interrupts or exceptions,
> page tables are switched to the full "kernel" copy.  When the system
> switches back to user mode, the "shadow" copy is used.  Process
> Context IDentifiers (PCIDs) are used to to ensure that the TLB is not
> flushed when switching between page tables, which makes syscalls
> roughly 2x faster than without it.  PCIDs are usable on Haswell and
> newer CPUs (the ones with "v4", or called fourth-generation Core).
>
> The minimal kernel page tables try to map only what is needed to
> enter/exit the kernel such as the entry/exit functions, interrupt
> descriptors (IDT) and the kernel trampoline stacks.  This minimal set
> of data can still reveal the kernel's ASLR base address.  But, this
> minimal kernel data is all trusted, which makes it harder to exploit
> than data in the kernel direct map which contains loads of
> user-controlled data.
>
> KAISER will affect performance for anything that does system calls or
> interrupts: everything.  Just the new instructions (CR3 manipulation)
> add a few hundred cycles to a syscall or interrupt.  Most workloads
> that we have run show single-digit regressions.  5% is a good round
> number for what is typical.  The worst we have seen is a roughly 30%
> regression on a loopback networking test that did a ton of syscalls
> and context switches.  More details about possible performance
> impacts are in the new Documentation/ file.
>
> This code is based on a version I downloaded from
> (https://github.com/IAIK/KAISER).  It has been heavily modified.
>
> The approach is described in detail in a paper[2].  However, there is
> some incorrect and information in the paper, both on how Linux and
> the hardware works.  For instance, I do not share the opinion that
> KAISER has "runtime overhead of only 0.28%".  Please rely on this
> patch series as the canonical source of information about this
> submission.
>
> Here is one example of how the kernel image grow with CONFIG_KAISER
> on and off.  Most of the size increase is presumably from additional
> alignment requirements for mapping entry/exit code and structures.
>
>     text    data     bss      dec filename
> 11786064 7356724 2928640 22071428 vmlinux-nokaiser
> 11798203 7371704 2928640 22098547 vmlinux-kaiser
>   +12139  +14980       0   +27119
>
> To give folks an idea what the performance impact is like, I took
> the following test and ran it single-threaded:
>
>         https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c
>
> It's a pretty quick syscall so this shows how much KAISER slows
> down syscalls (and how much PCIDs help).  The units here are
> lseeks/second:
>
>         no kaiser: 5.2M
>     kaiser+  pcid: 3.0M
>     kaiser+nopcid: 2.2M
>
> "nopcid" is literally with the "nopcid" command-line option which
> turns PCIDs off entirely.
>
> Thanks to:
> The original KAISER team at Graz University of Technology.
> Andy Lutomirski for all the help with the entry code.
> Kirill Shutemov for a helpful review of the code.
>
> 1. https://github.com/IAIK/KAISER
> 2. https://gruss.cc/files/kaiser.pdf
>
> --
>
> The code is available here:
>
>         https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/
>
>  Documentation/x86/kaiser.txt                | 160 +++++
>  arch/x86/Kconfig                            |   8 +
>  arch/x86/entry/calling.h                    |  89 +++
>  arch/x86/entry/entry_64.S                   |  44 +-
>  arch/x86/entry/entry_64_compat.S            |   8 +
>  arch/x86/events/intel/ds.c                  |  49 +-
>  arch/x86/include/asm/cpufeatures.h          |   1 +
>  arch/x86/include/asm/desc.h                 |   2 +-
>  arch/x86/include/asm/kaiser.h               |  62 ++
>  arch/x86/include/asm/mmu_context.h          |  29 +-
>  arch/x86/include/asm/pgalloc.h              |  37 +-
>  arch/x86/include/asm/pgtable.h              |  20 +-
>  arch/x86/include/asm/pgtable_64.h           | 135 +++++
>  arch/x86/include/asm/pgtable_types.h        |  25 +-
>  arch/x86/include/asm/processor.h            |   2 +-
>  arch/x86/include/asm/tlbflush.h             | 232 +++++++-
>  arch/x86/include/uapi/asm/processor-flags.h |   3 +-
>  arch/x86/kernel/cpu/common.c                |  21 +-
>  arch/x86/kernel/espfix_64.c                 |  27 +-
>  arch/x86/kernel/head_64.S                   |  30 +-
>  arch/x86/kernel/ldt.c                       |  25 +-
>  arch/x86/kernel/process.c                   |   2 +-
>  arch/x86/kernel/process_64.c                |   2 +-
>  arch/x86/kernel/traps.c                     |  46 +-
>  arch/x86/kvm/x86.c                          |   3 +-
>  arch/x86/mm/Makefile                        |   1 +
>  arch/x86/mm/init.c                          |  75 ++-
>  arch/x86/mm/kaiser.c                        | 627 ++++++++++++++++++++
>  arch/x86/mm/pageattr.c                      |  18 +-
>  arch/x86/mm/pgtable.c                       |  16 +-
>  arch/x86/mm/tlb.c                           | 105 +++-
>  include/asm-generic/vmlinux.lds.h           |  17 +
>  include/linux/kaiser.h                      |  34 ++
>  include/linux/percpu-defs.h                 |  30 +
>  init/main.c                                 |   3 +
>  kernel/fork.c                               |   1 +
>  security/Kconfig                            |  10 +
>  37 files changed, 1851 insertions(+), 148 deletions(-)
>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> Cc: Juergen Gross <jgross@suse.com>

I get a compilation error with:
CONFIG_RANDOMIZE_BASE=y

  OBJCOPY arch/x86/boot/compressed/vmlinux.bin
  RELOCS  arch/x86/boot/compressed/vmlinux.relocs
  CC      arch/x86/boot/compressed/early_serial_console.o
  CC      arch/x86/boot/compressed/kaslr.o
  CC      arch/x86/boot/compressed/pagetable.o
  CC      arch/x86/boot/compressed/misc.o
  GZIP    arch/x86/boot/compressed/vmlinux.bin.gz
  MKPIGGY arch/x86/boot/compressed/piggy.S
  AS      arch/x86/boot/compressed/piggy.o
  DATAREL arch/x86/boot/compressed/vmlinux
  LD      arch/x86/boot/compressed/vmlinux
arch/x86/boot/compressed/pagetable.o: In function `kernel_ident_mapping_init':
pagetable.c:(.text+0x31b): undefined reference to `kaiser_enabled'
arch/x86/boot/compressed/Makefile:106: recipe for target
'arch/x86/boot/compressed/vmlinux' failed
make[2]: *** [arch/x86/boot/compressed/vmlinux] Error 1
arch/x86/boot/Makefile:112: recipe for target
'arch/x86/boot/compressed/vmlinux' failed
make[1]: *** [arch/x86/boot/compressed/vmlinux] Error 2
arch/x86/Makefile:295: recipe for target 'bzImage' failed
make: *** [bzImage] Error 2

Compiles fine with:
# CONFIG_RANDOMIZE_BASE is not set

...Juerg


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
