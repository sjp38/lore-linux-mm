Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6239E6B0256
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:21 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so186090246pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id wf3si30681170pab.166.2015.09.28.12.18.18
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:18 -0700 (PDT)
Subject: [PATCH 00/25] x86: Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:17 -0700
Message-Id: <20150928191817.035A64E2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org

I have addressed all known issues and review comments.  I believe
they are ready to be pulled in to the x86 tree.  Note that this
is also the first time anyone has seen the new 'selftests' code.
If there are issues limited to it, I'd prefer to fix those up
separately post-merge.

Changes from RFCv2 (Thanks Ingo and Thomas for most of these):

 * few minor compile warnings
 * changed 'nopku' interaction with cpuid bits.  Now, we do not
   clear the PKU cpuid bit, we just skip enabling it.
 * changed __pkru_allows_write() to also check access disable bit
 * removed the unused write_pkru()
 * made si_pkey a u64 and added some patch description details.
   Also made it share space in siginfo with MPX and clarified
   comments.
 * give some real text for the Processor Trace xsave state
 * made vma_pkey() less ugly (and much more optimized actually)
 * added SEGV_PKUERR to copy_siginfo_to_user()
 * remove page table walk when filling in si_pkey, added some
   big fat comments about it being inherently racy.
 * added self test code

MM reviewers, if you are going to look at one thing, please look
at patch 14 which adds a bunch of additional vma/pte permission
checks.

This code contains a new system call: mprotect_key(),  This needs
the usual amount of rigor around new interfaces.  Review there
would be much appreciated.

This code is not runnable to anyone outside of Intel unless they
have some special hardware or a fancy simulator.  If you are
interested in running this for real, please get in touch with me.
Hardware is available to a very small but nonzero number of
people.

This set is also available here (with the new syscall):

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v006

=== diffstat ===

(note that over half of this is kselftests)

 Documentation/kernel-parameters.txt           |    3 
 Documentation/x86/protection-keys.txt         |   54 +
 arch/powerpc/include/asm/mman.h               |    5 
 arch/powerpc/include/asm/mmu_context.h        |   11 
 arch/s390/include/asm/mmu_context.h           |   11 
 arch/unicore32/include/asm/mmu_context.h      |   11 
 arch/x86/Kconfig                              |   15 
 arch/x86/entry/syscalls/syscall_32.tbl        |    1 
 arch/x86/entry/syscalls/syscall_64.tbl        |    1 
 arch/x86/include/asm/cpufeature.h             |   54 +
 arch/x86/include/asm/disabled-features.h      |   12 
 arch/x86/include/asm/fpu/types.h              |   16 
 arch/x86/include/asm/fpu/xstate.h             |    4 
 arch/x86/include/asm/mmu_context.h            |   71 ++
 arch/x86/include/asm/pgtable.h                |   45 +
 arch/x86/include/asm/pgtable_types.h          |   34 -
 arch/x86/include/asm/required-features.h      |    4 
 arch/x86/include/asm/special_insns.h          |   32 +
 arch/x86/include/uapi/asm/mman.h              |   23 
 arch/x86/include/uapi/asm/processor-flags.h   |    2 
 arch/x86/kernel/cpu/common.c                  |   42 +
 arch/x86/kernel/fpu/xstate.c                  |    7 
 arch/x86/kernel/process_64.c                  |    2 
 arch/x86/kernel/setup.c                       |    9 
 arch/x86/mm/fault.c                           |  143 +++-
 arch/x86/mm/gup.c                             |   37 -
 drivers/char/agp/frontend.c                   |    2 
 drivers/staging/android/ashmem.c              |    9 
 fs/proc/task_mmu.c                            |    5 
 include/asm-generic/mm_hooks.h                |   11 
 include/linux/mm.h                            |   13 
 include/linux/mman.h                          |    6 
 include/uapi/asm-generic/siginfo.h            |   17 
 kernel/signal.c                               |    4 
 mm/Kconfig                                    |   11 
 mm/gup.c                                      |   28 
 mm/memory.c                                   |    4 
 mm/mmap.c                                     |    2 
 mm/mprotect.c                                 |   20 
 mm/nommu.c                                    |    2 
 tools/testing/selftests/x86/Makefile          |    3 
 tools/testing/selftests/x86/pkey-helpers.h    |  182 +++++
 tools/testing/selftests/x86/protection_keys.c |  828 ++++++++++++++++++++++++++
 43 files changed, 1705 insertions(+), 91 deletions(-)

Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
