Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57C1A6B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:47:15 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z189so54691141itg.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 13:47:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id u3si36703372pfu.244.2016.06.07.13.47.14
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 13:47:14 -0700 (PDT)
Subject: [PATCH 0/9] [v2] System Calls for Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 Jun 2016 13:47:12 -0700
Message-Id: <20160607204712.594DE00A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, arnd@arndb.de

Are there any concerns with merging these into the x86 tree so
that they go upstream for 4.8?  The updates here are pretty
minor.

Changes from v1:
 * updates to alloc/free patch description calling out that
   "in-use" pkeys may still be pkey_free()'d successfully.
 * Fixed a bug in the selftest where the 'flags' argument was
   not passed to pkey_get().
 * Added all syscalls to generic syscalls header
 * Added extra checking to selftests so it doesn't fall over
   when 1G pages are made the hugetlbfs default.

--

Memory Protection Keys for User pages (pkeys) is a CPU feature
which will first appear on Skylake Servers, but will also be
supported on future non-server parts.  It provides a mechanism
for enforcing page-based protections, but without requiring
modification of the page tables when an application changes
wishes to change permissions.

Patches to implement execute-only mapping support using pkeys
were merged in to 4.6.  But, to do anything else useful with
pkeys, an application needs to be able to set the pkey field in
the PTE (obviously has to be done in-kernel) and make changes to
the "rights" register (using unprivileged instructions).

An application also needs to have an an allocator for the keys
themselves.  If two different parts of an application both want
to protect their data with pkeys, they first need to know which
key to use for their individual purposes.

This set introduces 5 system calls, in 3 logical groups:

1. PTE pkey setting (sys_pkey_mprotect(), patches #1-3)
2. Key allocation (sys_pkey_alloc() / sys_pkey_free(), patch #4)
3. Rights register manipulation (sys_pkey_set/get(), patch #5)

These patches build on top of "core" pkeys support already in
4.6.

I have manpages written for some of these syscalls, and have
had multiple rounds of reviews on the manpages list.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v037

I've written a set of unit tests for these interfaces, which is
available as the last patch in the series and integrated in to
kselftests.

Note: this is based on a plain 4.6 kernel and will have a minor
merge conflict in the x86 selftests makefile with the new
MPX selftest if those get merged first.

=== diffstat ===

Dave Hansen (9):
      x86, pkeys: add fault handling for PF_PK page fault bit
      mm: implement new pkey_mprotect() system call
      x86, pkeys: make mprotect_key() mask off additional vm_flags
      x86: wire up mprotect_key() system call
      x86, pkeys: allocation/free syscalls
      x86, pkeys: add pkey set/get syscalls
      generic syscalls: wire up memory protection keys syscalls
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
 arch/x86/include/asm/pkeys.h                  |   80 +-
 arch/x86/kernel/fpu/xstate.c                  |   73 +-
 arch/x86/mm/fault.c                           |    9 +
 arch/x86/mm/pkeys.c                           |   38 +-
 arch/xtensa/include/uapi/asm/mman.h           |    5 +
 include/linux/pkeys.h                         |   39 +-
 include/uapi/asm-generic/mman-common.h        |    5 +
 include/uapi/asm-generic/unistd.h             |   12 +-
 mm/mprotect.c                                 |  134 +-
 tools/testing/selftests/x86/Makefile          |    3 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  187 +++
 tools/testing/selftests/x86/protection_keys.c | 1283 +++++++++++++++++
 20 files changed, 1958 insertions(+), 31 deletions(-)

Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
