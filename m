Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 13C7E6B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 13:17:57 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so89447202pdb.1
        for <linux-mm@kvack.org>; Fri, 08 May 2015 10:17:56 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id k9si7837403pbq.210.2015.05.08.10.17.44
        for <linux-mm@kvack.org>;
        Fri, 08 May 2015 10:17:44 -0700 (PDT)
Message-Id: <cover.1431103461.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Fri, 8 May 2015 09:44:21 -0700
Subject: [PATCHv2 0/3] Find mirrored memory, use for boot time allocations
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Some high end Intel Xeon systems report uncorrectable memory errors
as a recoverable machine check. Linux has included code for some time
to process these and just signal the affected processes (or even
recover completely if the error was in a read only page that can be
replaced by reading from disk).

But we have no recovery path for errors encountered during kernel
code execution. Except for some very specific cases were are unlikely
to ever be able to recover.

Enter memory mirroring. Actually 3rd generation of memory mirroing.

Gen1: All memory is mirrored
	Pro: No s/w enabling - h/w just gets good data from other side of the mirror
	Con: Halves effective memory capacity available to OS/applications
Gen2: Partial memory mirror - just mirror memory begind some memory controllers
	Pro: Keep more of the capacity
	Con: Nightmare to enable. Have to choose between allocating from
	     mirrored memory for safety vs. NUMA local memory for performance
Gen3: Address range partial memory mirror - some mirror on each memory controller
	Pro: Can tune the amount of mirror and keep NUMA performance
	Con: I have to write memory management code to implement

The current plan is just to use mirrored memory for kernel allocations. This
has been broken into two phases:
1) This patch series - find the mirrored memory, use it for boot time allocations
2) Wade into mm/page_alloc.c and define a ZONE_MIRROR to pick up the unused
   mirrored memory from mm/memblock.c and only give it out to select kernel
   allocations (this is still being scoped because page_alloc.c is scary).

Tony Luck (3):
  mm/memblock: Add extra "flags" to memblock to allow selection of
    memory based on attribute
  mm/memblock: Allocate boot time data structures from mirrored memory
  x86, mirror: x86 enabling - find mirrored memory ranges

 arch/s390/kernel/crash_dump.c |   5 +-
 arch/sparc/mm/init_64.c       |   6 ++-
 arch/x86/kernel/check.c       |   3 +-
 arch/x86/kernel/e820.c        |   3 +-
 arch/x86/kernel/setup.c       |   3 ++
 arch/x86/mm/init_32.c         |   2 +-
 arch/x86/platform/efi/efi.c   |  21 ++++++++
 include/linux/efi.h           |   3 ++
 include/linux/memblock.h      |  49 +++++++++++------
 mm/cma.c                      |   6 ++-
 mm/memblock.c                 | 123 +++++++++++++++++++++++++++++++++---------
 mm/memtest.c                  |   3 +-
 mm/nobootmem.c                |  14 ++++-
 13 files changed, 188 insertions(+), 53 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
