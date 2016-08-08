Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF1376B0005
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 19:18:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so700672334pfx.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 16:18:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id x4si39240583pfa.54.2016.08.08.16.18.22
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 16:18:23 -0700 (PDT)
Subject: [PATCH 00/10] [v6] System Calls for Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Mon, 08 Aug 2016 16:18:20 -0700
Message-Id: <20160808231820.F7A9C4D8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, Dave Hansen <dave@sr71.net>, arnd@arndb.de, dave.hansen@intel.com

Since the last post, I've slightly updated the wording in one of
the patch descriptions but have made no code changes.

I think this is ready to be pulled into the x86 tree.

Note, this set depends on a previously submitted patch to be
applied before it will function:

	http://git.kernel.org/daveh/x86-pkeys/c/0ddc8d2c

Changes since v5:
 * Removed pkey_set/get() system calls to simplify ABI
 * Added 'init_pkru' support to ensure we have a restrictive
   PKRU by default.
 * Requisite changes to selftests, plus some bugfixes around
   stdio in signal handlers
 * Added clarifiction in patch description about when we use
   the new restrictive PKRU value.

--

Memory Protection Keys for User pages (pkeys) is a CPU feature
which will first appear on Skylake Servers, but will also be
supported on future non-server parts.  It provides a mechanism
for enforcing page-based protections, but without requiring
modification of the page tables when an application changes
wishes to change permissions.

Among other things, this feature was designed to help fix a class
of bugs in long-running applications where data corruption is
detected long after it occurs.  Applications today either live
with the corruption or eat a huge performance penalty from
calling mprotect() frequently.  The developers of these
applications are already running this code and are very eager to
see this feature merged and picked up in future distributions
where their customers can use it.

Patches to implement execute-only mapping support using pkeys
were merged in to 4.6.  But, to do anything more useful with
pkeys, an application needs to be able to set the pkey field in
the PTE (obviously has to be done in-kernel) and make changes to
the "rights" register (using unprivileged instructions).

An application also needs to have an an allocator for the keys
themselves.  If two different parts of an application both want
to protect their data with pkeys, they first need to know which
key to use for their individual purposes.

This set introduces 3 system calls:

	sys_pkey_mprotect(): apply PTE to memory (patches #1-3)
	sys_pkey_alloc(): ask the kernel for a free pkey (patch #4)
	sys_pkey_free(): the reverse of alloc (patch #4)

I have manpages written for these syscalls, and have had multiple
rounds of reviews on the manpages list.  I have not revised them
to remove pkey_get/set(), but will once this is merged in -tip.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v041

I've written a set of unit tests for these interfaces, which is
available as the last patch in the series and integrated in to
kselftests.

Folks wishing to run this code can do so with the new PKU support
in qemu >=2.6.  Just boot with -cpu qemu64,+pku,+xsave, and make
sure to apply this patch[1] to qemu.

=== diffstat ===

Dave Hansen (10):
      x86, pkeys: add fault handling for PF_PK page fault bit
      mm: implement new pkey_mprotect() system call
      x86, pkeys: make mprotect_key() mask off additional vm_flags
      x86, pkeys: allocation/free syscalls
      x86: wire up protection keys system calls
      generic syscalls: wire up memory protection keys syscalls
      pkeys: add details of system call use to Documentation/
      x86, pkeys: default to a restrictive init PKRU
      x86, pkeys: allow configuration of init_pkru
      x86, pkeys: add self-tests

 Documentation/kernel-parameters.txt           |    5 +
 Documentation/x86/protection-keys.txt         |   62 +
 arch/alpha/include/uapi/asm/mman.h            |    5 +
 arch/mips/include/uapi/asm/mman.h             |    5 +
 arch/parisc/include/uapi/asm/mman.h           |    5 +
 arch/x86/entry/syscalls/syscall_32.tbl        |    5 +
 arch/x86/entry/syscalls/syscall_64.tbl        |    5 +
 arch/x86/include/asm/mmu.h                    |    8 +
 arch/x86/include/asm/mmu_context.h            |   25 +-
 arch/x86/include/asm/pkeys.h                  |   73 +-
 arch/x86/kernel/fpu/core.c                    |    4 +
 arch/x86/kernel/fpu/xstate.c                  |    5 +-
 arch/x86/mm/fault.c                           |    9 +
 arch/x86/mm/pkeys.c                           |  143 +-
 arch/xtensa/include/uapi/asm/mman.h           |    5 +
 include/linux/pkeys.h                         |   41 +-
 include/linux/syscalls.h                      |    8 +
 include/uapi/asm-generic/mman-common.h        |    5 +
 include/uapi/asm-generic/unistd.h             |   12 +-
 mm/mprotect.c                                 |   90 +-
 tools/testing/selftests/x86/Makefile          |    3 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  219 +++
 tools/testing/selftests/x86/protection_keys.c | 1411 +++++++++++++++++
 23 files changed, 2115 insertions(+), 38 deletions(-)

=== changelog ===

Changes from v5:
 * remove sys_pkey_get/set() to simplify the ABI.  There was
   concern they could not be easily vsyscall-accelerated.
 * Added 'init_pkru' support to ensure we have a restrictive
   PKRU by default.
 * Requisite changes to selftests, plus some bugfixes around
   stdio in signal handlers

Changes from v4:
 * removed validate_pkey().  It was redundant with the work we do
   in mm_pkey_alloc() and all of the mm_pkey_is_allocated() checks.
 * reorder patches to wait to wire up any syscalls until the end.
 * make allocation map functions explicity use unsigned masks
 * some tweaks to changelog (and associated manpages)

Changes from v3:
 * added generic syscalls declarations to include/linux/syscalls.h
   to fix arm64 compile issue.

Changes from v2:
 * selftest updates:
  * formatting changes like what Ingo asked for with MPX
  * actually call WRPKRU in __wrpkru()
  * once __wrpkru() was fixed, revealed a bug in the ptrace
    test where we were testing against the wrong pointer during
    the "baseline" test
 * Man-pages that match this set are here:
 	 http://marc.info/?l=linux-man&m=146540723525616&w=2

Changes from v1:
 * updates to alloc/free patch description calling out that
   "in-use" pkeys may still be pkey_free()'d successfully.
 * Fixed a bug in the selftest where the 'flags' argument was
   not passed to pkey_get().
 * Added all syscalls to generic syscalls header
 * Added extra checking to selftests so it doesn't fall over
   when 1G pages are made the hugetlbfs default.

1. http://lists.nongnu.org/archive/html/qemu-devel/2016-07/msg04774.html

Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: mgorman@techsingularity.net
Cc: Dave Hansen (Intel) <dave.hansen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
