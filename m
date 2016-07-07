Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF606B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 08:47:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so31325823pac.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 05:47:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p7si4110438pfp.244.2016.07.07.05.47.20
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 05:47:20 -0700 (PDT)
Subject: [PATCH 0/9] [REVIEW-REQUEST] [v4] System Calls for Memory Protection Keys
From: Dave Hansen <dave@sr71.net>
Date: Thu, 07 Jul 2016 05:47:19 -0700
Message-Id: <20160707124719.3F04C882@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, arnd@arndb.de, mgorman@techsingularity.net, hughd@google.com, viro@zeniv.linux.org.uk

I'm resending these because Ingo has said that he'd "love to have
some high level MM review & ack for these syscall ABI extensions."
The only changes to the code in months have been in the selftests.
So, if anyone has been putting off taking a look at these, I'd
appreciate a look now.

I also feel compelled to mention this, since I haven't before and
it gives me confidence that these interfaces are good enough:

Among other things, this feature was designed to help fix a class
of bugs in long-running applications where data corruption is
detected long after it occurs.  Today, applications either live
with the corruption, or eat a huge performance penalty from
calling mprotect() frequently.  The developers of these
applications are already running *this* *code* and are very eager
to see this feature merged and picked up in future distributions
where their customers can use it.

Other than this message, a good place to start with a review
is in the pkey(7) manpage, which I've published in HTML form here:

	https://www.sr71.net/~dave/intel/manpages/

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
with the corruption, or eat a huge performance penalty from
calling mprotect() frequently.  The developers of these
applications are already running this code and are very eager to
see this feature merged and picked up in future distributions
where their customers can use it.

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

I have manpages written for some of these syscalls, and have
had multiple rounds of reviews on the manpages list.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v040

I've written a set of unit tests for these interfaces, which is
available as the last patch in the series and integrated in to
kselftests.

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
 arch/x86/include/asm/pgtable.h                |   13 +-
 arch/x86/include/asm/pgtable_64.h             |   26 +-
 arch/x86/include/asm/pgtable_types.h          |    6 -
 arch/x86/include/asm/pkeys.h                  |   80 +-
 arch/x86/kernel/fpu/xstate.c                  |   73 +-
 arch/x86/mm/fault.c                           |    9 +
 arch/x86/mm/pkeys.c                           |   38 +-
 arch/xtensa/include/uapi/asm/mman.h           |    5 +
 include/linux/pkeys.h                         |   39 +-
 include/linux/syscalls.h                      |    8 +
 include/uapi/asm-generic/mman-common.h        |    5 +
 include/uapi/asm-generic/unistd.h             |   12 +-
 mm/mprotect.c                                 |  134 +-
 tools/testing/selftests/x86/Makefile          |    3 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  191 +++
 tools/testing/selftests/x86/protection_keys.c | 1316 +++++++++++++++++
 24 files changed, 2012 insertions(+), 67 deletions(-)

=== changelog ===

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

Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: mgorman@techsingularity.net
Cc: hughd@google.com
Cc: viro@zeniv.linux.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
