Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 032196B0260
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:54:34 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id zm5so123876103pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:54:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id c7si4292091pat.49.2016.04.11.08.54.23
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 08:54:24 -0700 (PDT)
Subject: [PATCH 0/8] System Calls for Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Mon, 11 Apr 2016 08:54:22 -0700
Message-Id: <20160411155422.A2B8FD0C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org

Memory Protection Keys for User pages (pkeys) is a CPU feature
which will first appear on Skylake Servers, but will also be
supported on future non-server parts.  It provides a mechanism
for enforcing page-based protections, but without requiring
modification of the page tables when an application changes
wishes to change permissions.

Patches to implement execute-only mapping support using pkeys was
merged in to 4.6.  But, to do anything else useful with pkeys, an
application needs to be able to set the pkey field in the PTE
(obviously has to be done in-kernel) and make changes to the
"rights" register (using unprivileged instructions).

An application also needs to have an an allocator for the keys
themselves.  If two different parts of an application both want
to protect their data with pkeys, they first need to know which
key to use for their individual purposes.

This set introduces 5 system calls, in 3 logical groups:

1. PTE pkey setting (sys_pkey_mprotect(), patches #1-3)
2. Key allocation (sys_pkey_alloc() / sys_pkey_free(), patch #4)
3. Rights register manipulation (sys_pkey_set/get(), patch #5)

These patches build on top of "core" pkeys support already in
4.6.  This set is specifically built on f87e0434a, which is
tip/x86/urgent since it contained a documentation fix.

I have manpages written for some of these syscalls, and have
submitted them for review to the manpages list.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v031

I've written a set of unit tests for these interfaces, which is
available as the last patch in the series and integrated in to
kselftests.

=== diffstat ===

Dave Hansen (8):
      x86, pkeys: add fault handling for PF_PK page fault bit
      mm: implement new pkey_mprotect() system call
      x86, pkeys: make mprotect_key() mask off additional vm_flags
      x86: wire up mprotect_key() system call
      x86, pkeys: allocation/free syscalls
      x86, pkeys: add pkey set/get syscalls
      pkeys: add details of system call use to Documentation/
      x86, pkeys: add self-tests

 Documentation/x86/protection-keys.txt         |   63 +
 arch/alpha/include/uapi/asm/mman.h            |    5 +
 arch/mips/include/uapi/asm/mman.h             |    5 +
 arch/parisc/include/uapi/asm/mman.h           |    5 +
 arch/x86/entry/syscalls/syscall_32.tbl        |    5 +
 arch/x86/entry/syscalls/syscall_64.tbl        |    5 +
 arch/x86/include/asm/mmu.h                    |    8 +
 arch/x86/include/asm/mmu_context.h            |   25 +-
 arch/x86/include/asm/pkeys.h                  |   83 +-
 arch/x86/kernel/fpu/xstate.c                  |   73 +-
 arch/x86/mm/fault.c                           |    9 +
 arch/x86/mm/pkeys.c                           |   38 +-
 arch/xtensa/include/uapi/asm/mman.h           |    5 +
 include/linux/pkeys.h                         |   39 +-
 include/uapi/asm-generic/mman-common.h        |    5 +
 mm/mprotect.c                                 |  134 +-
 tools/testing/selftests/x86/Makefile          |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  186 +++
 tools/testing/selftests/x86/protection_keys.c | 1199 +++++++++++++++++
 19 files changed, 1863 insertions(+), 31 deletions(-)

Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
