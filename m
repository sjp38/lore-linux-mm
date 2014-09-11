Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D1DDC6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:54:04 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so12869955pde.5
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:54:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id v3si274639pds.170.2014.09.11.01.54.03
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 01:54:03 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v8 00/10] Intel MPX support
Date: Thu, 11 Sep 2014 16:46:40 +0800
Message-Id: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qiaowei Ren <qiaowei.ren@intel.com>

This patchset adds support for the Memory Protection Extensions
(MPX) feature found in future Intel processors.

MPX can be used in conjunction with compiler changes to check memory
references, for those references whose compile-time normal intentions
are usurped at runtime due to buffer overflow or underflow.

MPX provides this capability at very low performance overhead for
newly compiled code, and provides compatibility mechanisms with legacy
software components. MPX architecture is designed allow a machine to
run both MPX enabled software and legacy software that is MPX unaware.
In such a case, the legacy software does not benefit from MPX, but it
also does not experience any change in functionality or reduction in
performance.

More information about Intel MPX can be found in "Intel(R) Architecture
Instruction Set Extensions Programming Reference".

To get the advantage of MPX, changes are required in the OS kernel,
binutils, compiler, system libraries support.

New GCC option -fmpx is introduced to utilize MPX instructions.
Currently GCC compiler sources with MPX support is available in a
separate branch in common GCC SVN repository. See GCC SVN page
(http://gcc.gnu.org/svn.html) for details.

To have the full protection, we had to add MPX instrumentation to all
the necessary Glibc routines (e.g. memcpy) written on assembler, and
compile Glibc with the MPX enabled GCC compiler. Currently MPX enabled
Glibc source can be found in Glibc git repository.

Enabling an application to use MPX will generally not require source
code updates but there is some runtime code, which is responsible for
configuring and enabling MPX, needed in order to make use of MPX.
For most applications this runtime support will be available by linking
to a library supplied by the compiler or possibly it will come directly
from the OS once OS versions that support MPX are available.

MPX kernel code, namely this patchset, has mainly the 2 responsibilities:
provide handlers for bounds faults (#BR), and manage bounds memory.

The high-level areas modified in the patchset are as follow:
1) struct siginfo is extended to include bound violation information.
2) two prctl() commands are added to do performance optimization.

Currently no hardware with MPX ISA is available but it is always
possible to use SDE (Intel(R) software Development Emulator) instead,
which can be downloaded from
http://software.intel.com/en-us/articles/intel-software-development-emulator

This patchset has been tested on real internal hardware platform at Intel.
We have some simple unit tests in user space, which directly call MPX
instructions to produce #BR to let kernel allocate bounds tables and
cause bounds violations. We also compiled several benchmarks with an
MPX-enabled Gcc/Glibc and ICC, an ran them with this patch set.
We found a number of bugs in this code in these tests.

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

Qiaowei Ren (10):
  x86, mpx: introduce VM_MPX to indicate that a VMA is MPX specific
  x86, mpx: add MPX specific mmap interface
  x86, mpx: add macro cpu_has_mpx
  x86, mpx: hook #BR exception handler to allocate bound tables
  x86, mpx: extend siginfo structure to include bound violation
    information
  mips: sync struct siginfo with general version
  x86, mpx: decode MPX instruction to get bound violation information
  x86, mpx: add prctl commands PR_MPX_REGISTER, PR_MPX_UNREGISTER
  x86, mpx: cleanup unused bound tables
  x86, mpx: add documentation on Intel MPX

 Documentation/x86/intel_mpx.txt      |  127 +++++++++++
 arch/mips/include/uapi/asm/siginfo.h |    4 +
 arch/x86/Kconfig                     |    4 +
 arch/x86/include/asm/cpufeature.h    |    6 +
 arch/x86/include/asm/mmu_context.h   |   16 ++
 arch/x86/include/asm/mpx.h           |   91 ++++++++
 arch/x86/include/asm/processor.h     |   18 ++
 arch/x86/kernel/Makefile             |    1 +
 arch/x86/kernel/mpx.c                |  412 ++++++++++++++++++++++++++++++++++
 arch/x86/kernel/traps.c              |   61 +++++-
 arch/x86/mm/Makefile                 |    2 +
 arch/x86/mm/mpx.c                    |  331 +++++++++++++++++++++++++++
 fs/proc/task_mmu.c                   |    1 +
 include/asm-generic/mmu_context.h    |    6 +
 include/linux/mm.h                   |    6 +
 include/linux/mm_types.h             |    3 +
 include/uapi/asm-generic/siginfo.h   |    9 +-
 include/uapi/linux/prctl.h           |    6 +
 kernel/signal.c                      |    4 +
 kernel/sys.c                         |   12 +
 mm/mmap.c                            |    2 +
 21 files changed, 1120 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/x86/intel_mpx.txt
 create mode 100644 arch/x86/include/asm/mpx.h
 create mode 100644 arch/x86/kernel/mpx.c
 create mode 100644 arch/x86/mm/mpx.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
