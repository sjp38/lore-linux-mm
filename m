Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B012E6B00CA
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 10:18:19 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so2916249pad.17
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 07:18:19 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id kl11si28657792pbd.55.2014.11.14.07.18.16
        for <linux-mm@kvack.org>;
        Fri, 14 Nov 2014 07:18:17 -0800 (PST)
Subject: [PATCH 00/11] [v11] Intel MPX support
From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 07:18:16 -0800
Message-Id: <20141114151816.F56A3072@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>

From: Dave Hansen <dave.hansen@linux.intel.com>

Changes since v10:
 * get rid of some generic #ifdefs and add mpx_mm_init(mm)
 * add comment about reasons for doing xsaves
 * Cleanups in "on-demand allocation" patch, and add a missing
   return
 * Changes in some of the unmapping code error handling.  Make
   it more strict not to ever ignore unmapping errors.
 * Add the get_xsave_addr() to one spot which was missed

----

Why am I cc'ing you on this?

mips/ia64 folks: the only patch that applies to you is the'
	 	 'struct siginfo' one.
mm folks: the most interesting patches are the last 2 (excluding
	  the Documentation/ one).

---

We (Intel) are also trying to get some code merged in to GCC for
MPX.  It will be calling the new prctl()s introduced in this set.
We need to get those numbers locked down an reserved in the
kernel before we push the GCC code, though.

This currently requires booting with 'noxsaves' to work around
what I presume is an issue in the x86 'xsaves' code.  I'll work
with the folks responsible to get it fixed up properlye

---

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
2) Remove dependence on mmap_sem for ->bd_addr serialization
3) Lots of performance work
4) Manpage (not a kernel patch, but worth mentioning)  I have a
   patch to do it and will submit once this is merged.
5) prctl() so we can write wrappers to disable MPX in children
6) Tracepoints to help diagnose what's going on

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

Changes since v9:
 * New instruction decoder.  Uses generic infrastructure instead
   of "private" MPX decoder. (details in that patch)
 * Switched over to using get_user_pages() to handle faults when
   we touch userspace.
 * Lots of clarified comments and grammar fixups.
 * Merged arch/x86/kernel/mpx.c and arch/x86/mm/mpx.c
 * #ifdef'd the smaps display of the MPX flag (compile error on
   non-x86)
 * Added code to use new functions to access the "xsaves" compact

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
