Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0F72C6B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 09:26:57 -0400 (EDT)
Received: by qczw4 with SMTP id w4so17157233qcz.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 06:26:56 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id 19si8592168qhg.115.2015.06.10.06.26.54
        for <linux-mm@kvack.org>;
        Wed, 10 Jun 2015 06:26:54 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [RESEND PATCH V2 0/3] Allow user to request memory to be locked on page fault
Date: Wed, 10 Jun 2015 09:26:47 -0400
Message-Id: <1433942810-7852-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

mlock() allows a user to control page out of program memory, but this
comes at the cost of faulting in the entire mapping when it is
allocated.  For large mappings where the entire area is not necessary
this is not ideal.

This series introduces new flags for mmap() and mlockall() that allow a
user to specify that the covered are should not be paged out, but only
after the memory has been used the first time.

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

For mmap(MAP_LOCKONFAULT) the user is charged against RLIMIT_MEMLOCK
as if MAP_LOCKED was used, so when the VMA is created not when the pages
are faulted in.  For mlockall(MCL_ON_FAULT) the user is charged as if
MCL_FUTURE was used.  This decision was made to keep the accounting
checks out of the page fault path.

To illustrate the benefit of this patch I wrote a test program that
mmaps a 5 GB file filled with random data and then makes 15,000,000
accesses to random addresses in that mapping.  The test program was run
20 times for each setup.  Results are reported for two program portions,
setup and execution.  The setup phase is calling mmap and optionally
mlock on the entire region.  For most experiments this is trivial, but
it highlights the cost of faulting in the entire region.  Results are
averages across the 20 runs in milliseconds.

mmap with MAP_LOCKED:
Setup avg:      11821.193
Processing avg: 3404.286

mmap with mlock() before each access:
Setup avg:      0.054
Processing avg: 34263.201

mmap with PROT_NONE and signal handler and batch size of 1 page:
With the default value in max_map_count, this gets ENOMEM as I attempt
to change the permissions, after upping the sysctl significantly I get:
Setup avg:      0.050
Processing avg: 67690.625

mmap with PROT_NONE and signal handler and batch size of 8 pages:
Setup avg:      0.098
Processing avg: 37344.197

mmap with PROT_NONE and signal handler and batch size of 16 pages:
Setup avg:      0.0548
Processing avg: 29295.669

mmap with MAP_LOCKONFAULT:
Setup avg:      0.073
Processing avg: 18392.136

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
values across 20 runs of each benchmark after a warmup run whose
results were discarded.

Avg throughput in MB/s from stream using 1000000 element arrays
Test     4.1-rc2      4.1-rc2+lock-on-fault
Copy:    10,979.08    10,917.34
Scale:   11,094.45    11,023.01
Add:     12,487.29    12,388.65
Triad:   12,505.77    12,418.78

Kernbench optimal load
                 4.1-rc2  4.1-rc2+lock-on-fault
Elapsed Time     71.046   71.324
User Time        62.117   62.352
System Time      8.926    8.969
Context Switches 14531.9  14542.5
Sleeps           14935.9  14939

Eric B Munson (3):
  Add mmap flag to request pages are locked after page fault
  Add mlockall flag for locking pages on fault
  Add tests for lock on fault

 arch/alpha/include/uapi/asm/mman.h          |   2 +
 arch/mips/include/uapi/asm/mman.h           |   2 +
 arch/parisc/include/uapi/asm/mman.h         |   2 +
 arch/powerpc/include/uapi/asm/mman.h        |   2 +
 arch/sparc/include/uapi/asm/mman.h          |   2 +
 arch/tile/include/uapi/asm/mman.h           |   2 +
 arch/xtensa/include/uapi/asm/mman.h         |   2 +
 include/linux/mm.h                          |   1 +
 include/linux/mman.h                        |   3 +-
 include/uapi/asm-generic/mman.h             |   2 +
 mm/mlock.c                                  |  13 ++-
 mm/mmap.c                                   |   4 +-
 mm/swap.c                                   |   3 +-
 tools/testing/selftests/vm/Makefile         |   8 +-
 tools/testing/selftests/vm/lock-on-fault.c  | 145 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/on-fault-limit.c |  47 +++++++++
 tools/testing/selftests/vm/run_vmtests      |  23 +++++
 17 files changed, 254 insertions(+), 9 deletions(-)
 create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
 create mode 100644 tools/testing/selftests/vm/on-fault-limit.c

Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
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
