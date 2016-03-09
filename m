Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2296B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:00:10 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id tt10so49977042pab.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:00:10 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bp6si867568pac.135.2016.03.09.14.00.09
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 14:00:09 -0800 (PST)
Subject: [PATCH 0/9] System Calls for Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Wed, 09 Mar 2016 14:00:08 -0800
Message-Id: <20160309220008.D61AF421@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org

To use memory protection keys (pkeys), an application absolutely
needs to be able to set the pkey field in the PTE (obviously has
to be done in-kernel) and make changes to the "rights" register
(using unprivileged instructions).

An application also needs to have an an allocator for the keys
themselves.  If two different parts of an application both want
to protect their data with pkeys, they first need to know which
key to use for their individual purposes.

This set introduces 5 system calls, in 3 logical groups:

1. PTE pkey setting (sys_pkey_mprotect(), patches #1-3)
2. Key allocation (sys_pkey_alloc() / sys_pkey_free(), patch #4)
3. Rights register manipulation (sys_pkey_set/get(), patch #5)

These patches build on top of "core" pkeys support already in the
tip tree.  This set is specifically built on 3055e4444.

I have manpages written for some of these syscalls, and have
submitted them for review to the manpages list.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v028

I've written a set of unit tests for these interfaces, which is
available as the last patch in the series and integrated in to
kselftests.

=== diffstat ===

Dave Hansen (9):
      x86, pkeys: Documentation
      x86, pkeys: add fault handling for PF_PK page fault bit
      mm: implement new pkey_mprotect() system call
      x86, pkeys: make mprotect_key() mask off additional vm_flags
      x86: wire up mprotect_key() system call
      x86, pkeys: allocation/free syscalls
      x86, pkeys: add pkey set/get syscalls
      pkeys: add details of system call use to Documentation/
      x86, pkeys: add self-tests

 Documentation/x86/protection-keys.txt         |   91 ++
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
 arch/x86/mm/pkeys.c                           |   40 +-
 arch/xtensa/include/uapi/asm/mman.h           |    5 +
 include/linux/pkeys.h                         |   39 +-
 include/uapi/asm-generic/mman-common.h        |    5 +
 mm/mprotect.c                                 |  133 +-
 tools/testing/selftests/x86/Makefile          |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  186 +++
 tools/testing/selftests/x86/protection_keys.c | 1098 +++++++++++++++++
 19 files changed, 1790 insertions(+), 32 deletions(-)

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
