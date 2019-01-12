Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42B568E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:36:52 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q207so14271437iod.18
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:36:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k75sor4935586itb.18.2019.01.11.16.36.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 16:36:50 -0800 (PST)
From: Blake Caldwell <blake.caldwell@colorado.edu>
Subject: [PATCH 0/4] RFC: userfaultfd remap
Date: Sat, 12 Jan 2019 00:36:25 +0000
Message-Id: <cover.1547251023.git.blake.caldwell@colorado.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: blake.caldwell@colorado.edu
Cc: rppt@linux.vnet.ibm.com, xemul@virtuozzo.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, aarcange@redhat.com

Hello,

Since userfaultfd remap functionality was first proposed by Andrea
Arcangeli [1], a new use case has been demonstrated for removing pages
from the userfaultfd registered region. FluidMem [2] is a system for
expanding or limiting the resident size of a VM using a remote key-value
store as backing storage instead of swap space. It runs on the hypervisor
and uses userfaultfd to manage the memory regions malloc'd by qemu.
Since FluidMem maintains a constant resident size using an LRU list, it
must evict pages to the remote key-value store to make room for pages that
were just faulted in. This requires UFFDIO_REMAP to remove pages from the
uncooperative userspace page fault handler.

The VM shadow page tables must be kept in sync after a remapping, so
mmu_notifier_invalidate_range_(start/end) calls are made as necessary.

FluiMem enables page fault latencies to a remote key-value store that are
as fast as swap backed by DRAM (/dev/pmem0) and 77% faster than swap with a
SSD drive. pmbench [3] was used to measure page fault latencies with a 4 GB
working set size, within a VM using 1 GB DRAM (20% local):

  FluidMem (RAMCloud): 24.87 microseconds
  Swap (pmem DRAM): 26.34 microseconds
  Swap (NVMe over Fabrics): 41.73 microseconds
  Swap (SSD): 106.56 microseconds

For real applications FluidMem has an additional benefit of allowing
unused kernel pages to be removed from DRAM and stored in backend storage,
making room for additional application pages to be kept in local DRAM.
The useful memory capacity for the VM is increased.

The main complexity of this code is found in rmap, where it overwrites the
page->index when it moves the page to a different vma with different
vma->vm_pgoff. Overwriting page->index requires the rmap change and it's
only possible when the page_mapcount is 1.

Changes since [1]:
 - Changed the direction supported by UFFDIO_REMAP to the OUT direction 
   needed by FluidMem. The IN direction is not necessary, as UFFDIO_COPY
   should be used instead because it doesn't require a TLB flush.
 - Code has been kept up-to-date by Andrea in branch userfault from [4].

[1] https://lkml.org/lkml/2015/3/5/576
[2] Caldwell, Blake, Youngbin Im, Sangtae Ha, Richard Han, and
    Eric Keller. "FluidMem: Memory as a Service for the Datacenter."
    arXiv preprint arXiv:1707.07780 (2017).
    https://github.com/blakecaldwell/fluidmem
[3] Yang, Jisoo, and Julian Seymour. "Pmbench: A Micro-Benchmark for
    Profiling Paging Performance on a System with Low-Latency SSDs."
    Information Technology-New Generations. Springer, Cham, 2018. 627-633.
    https://bitbucket.org/jisooy/pmbench/src
[4] https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

Andrea Arcangeli (3):
  userfaultfd: UFFDIO_REMAP: rmap preparation
  userfaultfd: UFFDIO_REMAP uABI
  userfaultfd: UFFDIO_REMAP

Blake Caldwell (1):
  userfaultfd: change the direction for UFFDIO_REMAP to out

 Documentation/admin-guide/mm/userfaultfd.rst |  10 +
 fs/userfaultfd.c                             |  49 +++
 include/linux/userfaultfd_k.h                |  17 +
 include/uapi/linux/userfaultfd.h             |  25 +-
 mm/huge_memory.c                             | 117 ++++++
 mm/khugepaged.c                              |   3 +
 mm/rmap.c                                    |  13 +
 mm/userfaultfd.c                             | 536 +++++++++++++++++++++++++++
 8 files changed, 769 insertions(+), 1 deletion(-)

-- 
1.8.3.1
