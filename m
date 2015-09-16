Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4B67D6B0258
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:18 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so215288910pad.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:18 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gk11si31520258pbd.34.2015.09.16.10.49.04
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:04 -0700 (PDT)
Subject: [PATCH 00/26] [RFCv2] x86: Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:03 -0700
Message-Id: <20150916174903.E112E464@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

MM reviewers, if you are going to look at one thing, please look
at patch 14 which adds a bunch of additional vma/pte permission
checks.  Everybody else, please take a look at the two syscall
alternatives, especially the non-x86 folk.

This is a second big, fat RFC.  This code is not runnable to
anyone outside of Intel unless they have some special hardware or
a fancy simulator.  If you are interested in running this for
real, please get in touch with me.  Hardware is available to
a very small but nonzero number of people.

Since the last posting, I have implemented almost all of the
"software enforcement" for protection keys.  Basically, in places
where we look at VMA or PTE permissions, we try to enforce
protection keys to make it act similarly to mprotect().  This is
the part of the approach that really needs the most review and is
almost entirely contained in the "check VMAs and PTEs for
protection keys".

I also implemented a new system call.  There are basically two
possibilities for plumbing protection keys out to userspace.
I've included *both* approaches here:
1. Create a new system call: mprotect_key().  It's mprotect(),
   plus a protection key.  The patches implementing this have
   [NEWSYSCALL] in the subject.
2. Hijack some space in the PROT_* bits and pass a protection key
   in there.  That way, existing system calls like mmap(),
   mprotect(), etc... just work.  The patches implementing this
   have [HIJACKPROT] in the subject and must be applied without
   the [NEWSYSCALL] ones.

There is still work left to do here.  Current TODO:
 * Build on something other than x86
 * Do some more exhaustive x86 randconfig tests
 * Make sure DAX mappings work
 * Pound on some of the modified paths to ensure limited
   performance impact from modifications to hot paths.

This set is also available here (with the new syscall):

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v005

A version with the modification of the PROT_ syscalls is tagged
as 'pkeys-v005-protsyscalls'.

=== diffstat (new syscall version) ===

 Documentation/kernel-parameters.txt         |    3 
 Documentation/x86/protection-keys.txt       |   65 ++++++++++++++++++++
 arch/powerpc/include/asm/mman.h             |    5 -
 arch/x86/Kconfig                            |   15 ++++
 arch/x86/entry/syscalls/syscall_32.tbl      |    1 
 arch/x86/entry/syscalls/syscall_64.tbl      |    1 
 arch/x86/include/asm/cpufeature.h           |   54 ++++++++++------
 arch/x86/include/asm/disabled-features.h    |   12 +++
 arch/x86/include/asm/fpu/types.h            |   17 +++++
 arch/x86/include/asm/fpu/xstate.h           |    4 -
 arch/x86/include/asm/mmu_context.h          |   66 ++++++++++++++++++++
 arch/x86/include/asm/pgtable.h              |   37 +++++++++++
 arch/x86/include/asm/pgtable_types.h        |   34 +++++++++-
 arch/x86/include/asm/required-features.h    |    4 +
 arch/x86/include/asm/special_insns.h        |   33 ++++++++++
 arch/x86/include/uapi/asm/mman.h            |   23 +++++++
 arch/x86/include/uapi/asm/processor-flags.h |    2 
 arch/x86/kernel/cpu/common.c                |   27 ++++++++
 arch/x86/kernel/fpu/xstate.c                |   10 ++-
 arch/x86/kernel/process_64.c                |    2 
 arch/x86/kernel/setup.c                     |    9 ++
 arch/x86/mm/fault.c                         |   89 ++++++++++++++++++++++++++--
 arch/x86/mm/gup.c                           |   37 ++++++-----
 drivers/char/agp/frontend.c                 |    2 
 drivers/staging/android/ashmem.c            |    3 
 fs/proc/task_mmu.c                          |    5 +
 include/asm-generic/mm_hooks.h              |   12 +++
 include/linux/mm.h                          |   15 ++++
 include/linux/mman.h                        |    6 -
 include/uapi/asm-generic/siginfo.h          |   11 +++
 mm/Kconfig                                  |   11 +++
 mm/gup.c                                    |   28 +++++++-
 mm/memory.c                                 |    8 +-
 mm/mmap.c                                   |    2 
 mm/mprotect.c                               |   20 +++++-
 35 files changed, 607 insertions(+), 66 deletions(-)

== FEATURE OVERVIEW ==

Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU
feature which will be found in future Intel CPUs.  The work here
was done with the aid of simulators.

Memory Protection Keys provides a mechanism for enforcing
page-based protections, but without requiring modification of the
page tables when an application changes protection domains.  It
works by dedicating 4 previously ignored bits in each page table
entry to assigning a "protection key", giving 16 possible keys to
each page mapping.

There is also a new user-accessible register (PKRU) with two
separate bits (Access Disable and Write Disable) for each key.
Being a CPU register, PKRU is inherently thread-local,
potentially giving each thread a different set of protections
from every other thread.

There are two new instructions (RDPKRU/WRPKRU) for reading and
writing to the new register.  The feature is only available in
64-bit mode, even though there is theoretically space in the PAE
PTEs.  These permissions are enforced on data access only and
have no effect on instruction fetches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
