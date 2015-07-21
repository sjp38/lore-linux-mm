Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id BE2499003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:59:54 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so140438888qkd.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 12:59:54 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id 132si10314712qhb.110.2015.07.21.12.59.42
        for <linux-mm@kvack.org>;
        Tue, 21 Jul 2015 12:59:43 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V4 0/6] Allow user to request memory to be locked on page fault
Date: Tue, 21 Jul 2015 15:59:35 -0400
Message-Id: <1437508781-28655-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

mlock() allows a user to control page out of program memory, but this
comes at the cost of faulting in the entire mapping when it is
allocated.  For large mappings where the entire area is not necessary
this is not ideal.  Instead of forcing all locked pages to be present
when they are allocated, this set creates a middle ground.  Pages are
marked to be placed on the unevictable LRU (locked) when they are first
used, but they are not faulted in by the mlock call.

This series introduces a new mlock() system call that takes a flags
argument along with the start address and size.  This flags argument
gives the caller the ability to request memory be locked in the
traditional way, or to be locked after the page is faulted in.  New
calls are added for munlock() and munlockall() which give the called a
way to specify which flags are supposed to be cleared.  A new MCL flag
is added to mirror the lock on fault behavior from mlock() in
mlockall().  Finally, a flag for mmap() is added that allows a user to
specify that the covered are should not be paged out, but only after the
memory has been used the first time.

There are two main use cases that this set covers.  The first is the
security focussed mlock case.  A buffer is needed that cannot be written
to swap.  The maximum size is known, but on average the memory used is
significantly less than this maximum.  With lock on fault, the buffer
is guaranteed to never be paged out without consuming the maximum size
every time such a buffer is created.

The second use case is focussed on performance.  Portions of a large
file are needed and we want to keep the used portions in memory once
accessed.  This is the case for large graphical models where the path
through the graph is not known until run time.  The entire graph is
unlikely to be used in a given invocation, but once a node has been
used it needs to stay resident for further processing.  Given these
constraints we have a number of options.  We can potentially waste a
large amount of memory by mlocking the entire region (this can also
cause a significant stall at startup as the entire file is read in).
We can mlock every page as we access them without tracking if the page
is already resident but this introduces large overhead for each access.
The third option is mapping the entire region with PROT_NONE and using
a signal handler for SIGSEGV to mprotect(PROT_READ) and mlock() the
needed page.  Doing this page at a time adds a significant performance
penalty.  Batching can be used to mitigate this overhead, but in order
to safely avoid trying to mprotect pages outside of the mapping, the
boundaries of each mapping to be used in this way must be tracked and
available to the signal handler.  This is precisely what the mm system
in the kernel should already be doing.

For mlock(MLOCK_ONFAULT) and mmap(MAP_LOCKONFAULT) the user is charged
against RLIMIT_MEMLOCK as if mlock(MLOCK_LOCKED) or mmap(MAP_LOCKED) was
used, so when the VMA is created not when the pages are faulted in.  For
mlockall(MCL_ONFAULT) the user is charged as if MCL_FUTURE was used.
This decision was made to keep the accounting checks out of the page
fault path.

To illustrate the benefit of this set I wrote a test program that mmaps
a 5 GB file filled with random data and then makes 15,000,000 accesses
to random addresses in that mapping.  The test program was run 20 times
for each setup.  Results are reported for two program portions, setup
and execution.  The setup phase is calling mmap and optionally mlock on
the entire region.  For most experiments this is trivial, but it
highlights the cost of faulting in the entire region.  Results are
averages across the 20 runs in milliseconds.

mmap with mlock(MLOCK_LOCKED) on entire range:
Setup avg:      8228.666
Processing avg: 8274.257

mmap with mlock(MLOCK_LOCKED) before each access:
Setup avg:      0.113
Processing avg: 90993.552

mmap with PROT_NONE and signal handler and batch size of 1 page:
With the default value in max_map_count, this gets ENOMEM as I attempt
to change the permissions, after upping the sysctl significantly I get:
Setup avg:      0.058
Processing avg: 69488.073

mmap with PROT_NONE and signal handler and batch size of 8 pages:
Setup avg:      0.068
Processing avg: 38204.116

mmap with PROT_NONE and signal handler and batch size of 16 pages:
Setup avg:      0.044
Processing avg: 29671.180

mmap with mlock(MLOCK_ONFAULT) on entire range:
Setup avg:      0.189
Processing avg: 17904.899

The signal handler in the batch cases faulted in memory in two steps to
avoid having to know the start and end of the faulting mapping.  The
first step covers the page that caused the fault as we know that it will
be possible to lock.  The second step speculatively tries to mlock and
mprotect the batch size - 1 pages that follow.  There may be a clever
way to avoid this without having the program track each mapping to be
covered by this handeler in a globally accessible structure, but I could
not find it.  It should be noted that with a large enough batch size
this two step fault handler can still cause the program to crash if it
reaches far beyond the end of the mapping.

These results show that if the developer knows that a majority of the
mapping will be used, it is better to try and fault it in at once,
otherwise MAP_LOCKONFAULT is significantly faster.

The performance cost of these patches are minimal on the two benchmarks
I have tested (stream and kernbench).  The following are the average
values across 20 runs of stream and 10 runs of kernbench after a warmup
run whose results were discarded.

Avg throughput in MB/s from stream using 1000000 element arrays
Test     4.2-rc1      4.2-rc1+lock-on-fault
Copy:    10,566.5     10,421
Scale:   10,685       10,503.5
Add:     12,044.1     11,814.2
Triad:   12,064.8     11,846.3

Kernbench optimal load
                 4.2-rc1  4.2-rc1+lock-on-fault
Elapsed Time     78.453   78.991
User Time        64.2395  65.2355
System Time      9.7335   9.7085
Context Switches 22211.5  22412.1
Sleeps           14965.3  14956.1

---
Changes from V3:
Ensure that pages present when mlock2(MLOCK_ONFAULT) is called are locked
Ensure that VM_LOCKONFAULT is handled in cases that used to only check VM_LOCKED
Add tests for new system calls
Add missing syscall entries, fix NR_syscalls on multiple arch's
Add missing MAP_LOCKONFAULT for tile

Changes from V2:
Added new system calls for mlock, munlock, and munlockall with added
flags arguments for controlling how memory is locked or unlocked.

Eric B Munson (6):
  mm: mlock: Refactor mlock, munlock, and munlockall code
  mm: mlock: Add new mlock, munlock, and munlockall system calls
  mm: gup: Add mm_lock_present()
  mm: mlock: Introduce VM_LOCKONFAULT and add mlock flags to enable it
  mm: mmap: Add mmap flag to request VM_LOCKONFAULT
  selftests: vm: Add tests for lock on fault

 arch/alpha/include/asm/unistd.h             |   2 +-
 arch/alpha/include/uapi/asm/mman.h          |   5 +
 arch/alpha/include/uapi/asm/unistd.h        |   3 +
 arch/alpha/kernel/systbls.S                 |   3 +
 arch/arm/include/asm/unistd.h               |   2 +-
 arch/arm/include/uapi/asm/unistd.h          |   3 +
 arch/arm/kernel/calls.S                     |   3 +
 arch/arm64/include/asm/unistd32.h           |   6 +
 arch/avr32/include/uapi/asm/unistd.h        |   3 +
 arch/avr32/kernel/syscall_table.S           |   3 +
 arch/blackfin/include/uapi/asm/unistd.h     |   3 +
 arch/blackfin/mach-common/entry.S           |   3 +
 arch/cris/arch-v10/kernel/entry.S           |   3 +
 arch/cris/arch-v32/kernel/entry.S           |   3 +
 arch/frv/kernel/entry.S                     |   3 +
 arch/ia64/include/asm/unistd.h              |   2 +-
 arch/ia64/include/uapi/asm/unistd.h         |   3 +
 arch/ia64/kernel/entry.S                    |   3 +
 arch/m32r/kernel/entry.S                    |   3 +
 arch/m32r/kernel/syscall_table.S            |   3 +
 arch/m68k/include/asm/unistd.h              |   2 +-
 arch/m68k/include/uapi/asm/unistd.h         |   3 +
 arch/m68k/kernel/syscalltable.S             |   3 +
 arch/microblaze/include/uapi/asm/unistd.h   |   3 +
 arch/microblaze/kernel/syscall_table.S      |   3 +
 arch/mips/include/uapi/asm/mman.h           |   8 +
 arch/mips/include/uapi/asm/unistd.h         |  21 +-
 arch/mips/kernel/scall32-o32.S              |   3 +
 arch/mips/kernel/scall64-64.S               |   3 +
 arch/mips/kernel/scall64-n32.S              |   3 +
 arch/mips/kernel/scall64-o32.S              |   3 +
 arch/mn10300/kernel/entry.S                 |   3 +
 arch/parisc/include/uapi/asm/mman.h         |   5 +
 arch/parisc/include/uapi/asm/unistd.h       |   5 +-
 arch/powerpc/include/uapi/asm/mman.h        |   5 +
 arch/powerpc/include/uapi/asm/unistd.h      |   3 +
 arch/s390/include/uapi/asm/unistd.h         |   5 +-
 arch/s390/kernel/compat_wrapper.c           |   3 +
 arch/s390/kernel/syscalls.S                 |   3 +
 arch/sh/kernel/syscalls_32.S                |   3 +
 arch/sparc/include/uapi/asm/mman.h          |   5 +
 arch/sparc/include/uapi/asm/unistd.h        |   5 +-
 arch/sparc/kernel/systbls_32.S              |   2 +-
 arch/sparc/kernel/systbls_64.S              |   4 +-
 arch/tile/include/uapi/asm/mman.h           |   9 +
 arch/x86/entry/syscalls/syscall_32.tbl      |   3 +
 arch/x86/entry/syscalls/syscall_64.tbl      |   3 +
 arch/xtensa/include/uapi/asm/mman.h         |   8 +
 arch/xtensa/include/uapi/asm/unistd.h       |  10 +-
 drivers/gpu/drm/drm_vm.c                    |   8 +-
 fs/proc/task_mmu.c                          |   3 +-
 include/linux/mm.h                          |   2 +
 include/linux/mman.h                        |   3 +-
 include/linux/syscalls.h                    |   4 +
 include/uapi/asm-generic/mman.h             |   5 +
 include/uapi/asm-generic/unistd.h           |   8 +-
 kernel/events/core.c                        |   2 +
 kernel/events/uprobes.c                     |   2 +-
 kernel/fork.c                               |   2 +-
 kernel/sys_ni.c                             |   3 +
 mm/debug.c                                  |   1 +
 mm/gup.c                                    | 175 +++++++-
 mm/huge_memory.c                            |   3 +-
 mm/hugetlb.c                                |   4 +-
 mm/internal.h                               |   5 +-
 mm/ksm.c                                    |   2 +-
 mm/madvise.c                                |   4 +-
 mm/memory.c                                 |   5 +-
 mm/mlock.c                                  | 159 +++++--
 mm/mmap.c                                   |  32 +-
 mm/mremap.c                                 |   6 +-
 mm/msync.c                                  |   2 +-
 mm/rmap.c                                   |  12 +-
 mm/shmem.c                                  |   2 +-
 mm/swap.c                                   |   3 +-
 mm/vmscan.c                                 |   2 +-
 tools/testing/selftests/vm/Makefile         |   3 +
 tools/testing/selftests/vm/lock-on-fault.c  | 344 +++++++++++++++
 tools/testing/selftests/vm/mlock2-tests.c   | 621 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/on-fault-limit.c |  47 +++
 tools/testing/selftests/vm/run_vmtests      |  33 ++
 81 files changed, 1604 insertions(+), 104 deletions(-)
 create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
 create mode 100644 tools/testing/selftests/vm/mlock2-tests.c
 create mode 100644 tools/testing/selftests/vm/on-fault-limit.c

Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: linux-api@vger.kernel.org

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
