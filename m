Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1908782F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 20:11:12 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id ho8so102883858pac.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:11:12 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id c9si43213304pas.70.2016.02.22.17.11.08
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 17:11:08 -0800 (PST)
Subject: [RFC][PATCH 0/7] System Calls for Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Mon, 22 Feb 2016 17:11:08 -0800
Message-Id: <20160223011107.FB9B8215@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org

As promised, here are the proposed new Memory Protection Keys
interfaces.  These interfaces make it possible to do something
with pkeys other than execute-only support.

There are 5 syscalls here.  I'm hoping for reviews of this set
which can help nail down what the final interfaces will be.

You can find a high-level overview of the feature and the new
syscalls here:

	https://www.sr71.net/~dave/intel/pkeys.txt

===============================================================

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

These patches build on top of "core" support already in the tip tree,
specifically 62b5f7d013, which can currently be found at:

	http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/log/?h=mm/pkeys

I have manpages written for some of these syscalls, and I will
submit a full set of manpages once we've reached some consensus
on what the interfaces should be.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v024

I've written a set of unit tests for these interfaces, which is
available here:

	https://www.sr71.net/~dave/intel/pkeys-test-2016-02-22/

I will submit that code for inclusion with the final version of
these patches.

=== diffstat ===

Dave Hansen (7):
      x86, pkeys: Documentation
      mm: implement new pkey_mprotect() system call
      x86, pkeys: make mprotect_key() mask off additional vm_flags
      x86: wire up mprotect_key() system call
      x86, pkeys: allocation/free syscalls
      x86, pkeys: add pkey set/get syscalls
      pkeys: add details of system call use to Documentation/

 Documentation/x86/protection-keys.txt  |  91 +++++++++++++++++
 arch/x86/entry/syscalls/syscall_32.tbl |   5 +
 arch/x86/entry/syscalls/syscall_64.tbl |   5 +
 arch/x86/include/asm/mmu.h             |   8 ++
 arch/x86/include/asm/mmu_context.h     |  25 +++--
 arch/x86/include/asm/pkeys.h           |  83 ++++++++++++++-
 arch/x86/kernel/fpu/xstate.c           |  73 +++++++++++++-
 arch/x86/mm/pkeys.c                    |  40 ++++++--
 include/linux/pkeys.h                  |  39 ++++++--
 include/uapi/asm-generic/mman-common.h |   5 +
 mm/mprotect.c                          | 133 ++++++++++++++++++++++++-
 11 files changed, 476 insertions(+), 31 deletions(-)

Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
