Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E00636B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 00:51:29 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so4074827pac.0
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 21:51:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ak3si7386016pbc.91.2014.10.11.21.51.28
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 21:51:28 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v9 00/12] Intel MPX support
Date: Sun, 12 Oct 2014 12:41:43 +0800
Message-Id: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

This patch set adds support for the Memory Protection eXtensions
(MPX) feature found in future Intel processors. MPX is used in
conjunction with compiler changes to check memory references, and
can be used to catch buffer overflow or underflow.

For MPX to work, changes are required in the kernel, binutils and
compiler. No source changes are required for applications, just a
recompile.

There are a lot of moving parts of this to all work right:

===== Example Compiler / Application / Kernel Interaction =====

1. Application developer compiles with -fmpx.  The compiler will add the
   instrumentation as well as some setup code called early after the app
   starts. New instruction prefixes are noops for old CPUs.
2. That setup code allocates (virtual) space for the "bounds directory",
   points the "bndcfgu" register to the directory and notifies the
   kernel (via the new prctl(PR_MPX_ENABLE_MANAGEMENT)) that the app will
   be using MPX.
3. The kernel detects that the CPU has MPX, allows the new prctl() to
   succeed, and notes the location of the bounds directory. Userspace is
   expected to keep the bounds directory at that location. We note it
   instead of reading it each time because the 'xsave' operation needed
   to access the bounds directory register is an expensive operation.
4. If the application needs to spill bounds out of the 4 registers, it
   issues a bndstx instruction.  Since the bounds directory is empty at
   this point, a bounds fault (#BR) is raised, the kernel allocates a
   bounds table (in the user address space) and makes the relevant
   entry in the bounds directory point to the new table. [1]
5. If the application violates the bounds specified in the bounds
   registers, a separate kind of #BR is raised which will deliver a
   signal with information about the violation in the 'struct siginfo'.
6. Whenever memory is freed, we know that it can no longer contain
   valid pointers, and we attempt to free the associated space in the
   bounds tables. If an entire table becomes unused, we will attempt
   to free the table and remove the entry in the directory.

To summarize, there are essentially three things interacting here:

GCC with -fmpx:
 * enables annotation of code with MPX instructions and prefixes
 * inserts code early in the application to call in to the "gcc runtime"
GCC MPX Runtime:
 * Checks for hardware MPX support in cpuid leaf
 * allocates virtual space for the bounds directory (malloc()
   essentially)
 * points the hardware BNDCFGU register at the directory
 * calls a new prctl() to notify the kernel to start managing the
   bounds directories
Kernel MPX Code:
 * Checks for hardware MPX support in cpuid leaf
 * Handles #BR exceptions and sends SIGSEGV to the app when it violates
   bounds, like during a buffer overflow.
 * When bounds are spilled in to an unallocated bounds table, the kernel
   notices in the #BR exception, allocates the virtual space, then
   updates the bounds directory to point to the new table. It keeps
   special track of the memory with a specific ->vm_ops for MPX.
 * Frees unused bounds tables at the time that the memory they described
   is unmapped. (See "cleanup unused bound tables")

===== Testing =====

This patchset has been tested on real internal hardware platform at Intel.
We have some simple unit tests in user space, which directly call MPX
instructions to produce #BR to let kernel allocate bounds tables and cause
bounds violations. We also compiled several benchmarks with an MPX-enabled
compiler and ran them with this patch set. We found a number of bugs in this
code in these tests.

1. For more info on why the kernel does these allocations, see the patch
"on-demand kernel allocation of bounds tables"

Future TODO items:
1) support 32-bit binaries on 64-bit kernels.

Changes since v1:
  * check to see if #BR occurred in userspace or kernel space.
  * use generic structure and macro as much as possible when
    decode mpx instructions.

Changes since v2:
  * fix some compile warnings.
  * update documentation.

Changes since v3:
  * correct some syntax errors at documentation, and document
    extended struct siginfo.
  * for kill the process when the error code of BNDSTATUS is 3.
  * add some comments.
  * remove new prctl() commands.
  * fix some compile warnings for 32-bit.

Changes since v4:
  * raise SIGBUS if the allocations of the bound tables fail.

Changes since v5:
  * hook unmap() path to cleanup unused bounds tables, and use
    new prctl() command to register bounds directory address to
    struct mm_struct to check whether one process is MPX enabled
    during unmap().
  * in order track precisely MPX memory usage, add MPX specific
    mmap interface and one VM_MPX flag to check whether a VMA
    is MPX bounds table.
  * add macro cpu_has_mpx to do performance optimization.
  * sync struct figinfo for mips with general version to avoid
    build issue.

Changes since v6:
  * because arch_vma_name is removed, this patchset have toset MPX
    specific ->vm_ops to do the same thing.
  * fix warnings for 32 bit arch.
  * add more description into these patches.

Changes since v7:
  * introduce VM_ARCH_2 flag. 
  * remove all of the pr_debug()s.
  * fix prctl numbers in documentation.
  * fix some bugs on bounds tables freeing.

Changes since v8:
  * add new patch to rename cfg_reg_u and status_reg.
  * add new patch to use disabled features from Dave's patches.
  * add new patch to sync struct siginfo for IA64.
  * rename two new prctl() commands to PR_MPX_ENABLE_MANAGEMENT and
    PR_MPX_DISABLE_MANAGEMENT, check whether the management of bounds
    tables in kernel is enabled at #BR fault time, and add locking to
    protect the access to 'bd_addr'.
  * update the documentation file to add more content about on-demand
    allocation of bounds tables, etc..

Qiaowei Ren (12):
  mm: distinguish VMAs with different vm_ops
  x86, mpx: rename cfg_reg_u and status_reg
  x86, mpx: add MPX specific mmap interface
  x86, mpx: add MPX to disaabled features
  x86, mpx: on-demand kernel allocation of bounds tables
  mpx: extend siginfo structure to include bound violation information
  mips: sync struct siginfo with general version
  ia64: sync struct siginfo with general version
  x86, mpx: decode MPX instruction to get bound violation information
  x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT,
    PR_MPX_DISABLE_MANAGEMENT
  x86, mpx: cleanup unused bound tables
  x86, mpx: add documentation on Intel MPX


Qiaowei Ren (12):
  x86, mpx: introduce VM_MPX to indicate that a VMA is MPX specific
  x86, mpx: rename cfg_reg_u and status_reg
  x86, mpx: add MPX specific mmap interface
  x86, mpx: add MPX to disaabled features
  x86, mpx: on-demand kernel allocation of bounds tables
  mpx: extend siginfo structure to include bound violation information
  mips: sync struct siginfo with general version
  ia64: sync struct siginfo with general version
  x86, mpx: decode MPX instruction to get bound violation information
  x86, mpx: add prctl commands PR_MPX_ENABLE_MANAGEMENT,
    PR_MPX_DISABLE_MANAGEMENT
  x86, mpx: cleanup unused bound tables
  x86, mpx: add documentation on Intel MPX

 Documentation/x86/intel_mpx.txt          |  245 +++++++++++++++
 arch/ia64/include/uapi/asm/siginfo.h     |    8 +-
 arch/mips/include/uapi/asm/siginfo.h     |    4 +
 arch/x86/Kconfig                         |    4 +
 arch/x86/include/asm/disabled-features.h |    8 +-
 arch/x86/include/asm/mmu_context.h       |   25 ++
 arch/x86/include/asm/mpx.h               |  101 ++++++
 arch/x86/include/asm/processor.h         |   22 ++-
 arch/x86/kernel/Makefile                 |    1 +
 arch/x86/kernel/mpx.c                    |  488 ++++++++++++++++++++++++++++++
 arch/x86/kernel/setup.c                  |    8 +
 arch/x86/kernel/traps.c                  |   86 ++++++-
 arch/x86/mm/Makefile                     |    2 +
 arch/x86/mm/mpx.c                        |  385 +++++++++++++++++++++++
 fs/exec.c                                |    2 +
 fs/proc/task_mmu.c                       |    1 +
 include/asm-generic/mmu_context.h        |   11 +
 include/linux/mm.h                       |    6 +
 include/linux/mm_types.h                 |    3 +
 include/uapi/asm-generic/siginfo.h       |    9 +-
 include/uapi/linux/prctl.h               |    6 +
 kernel/signal.c                          |    4 +
 kernel/sys.c                             |   12 +
 mm/mmap.c                                |    2 +
 24 files changed, 1436 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/x86/intel_mpx.txt
 create mode 100644 arch/x86/include/asm/mpx.h
 create mode 100644 arch/x86/kernel/mpx.c
 create mode 100644 arch/x86/mm/mpx.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
