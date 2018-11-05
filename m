Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id E385F6B026E
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:37 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id c64-v6so7914927ywd.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:37 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 10-v6si24302607ywe.234.2018.11.05.08.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:36 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Date: Mon,  5 Nov 2018 11:55:45 -0500
Message-Id: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Hi,

This version addresses some of the feedback from Andrew and Michal last year
and describes the plan for tackling the rest.  I'm posting now since I'll be
presenting ktask at Plumbers next week.

Andrew, you asked about parallelizing in more places[0].  This version adds
multithreading for VFIO page pinning, and there are more planned users listed
below.

Michal, you mentioned that ktask should be sensitive to CPU utilization[1].
ktask threads now run at the lowest priority on the system to avoid disturbing
busy CPUs (more details in patches 4 and 5).  Does this address your concern?
The plan to address your other comments is explained below.

Alex, any thoughts about the VFIO changes in patches 6-9?

Tejun and Lai, what do you think of patch 5?

And for everyone, questions and comments welcome.  Any suggestions for more
users?

         Thanks,
            Daniel

P.S.  This series is big to address the above feedback, but I can send patches
7 and 8 separately.


TODO
----

 - Implement cgroup-aware unbound workqueues in a separate series, picking up
   Bandan Das's effort from two years ago[2].  This should hopefully address
   Michal's comment about running ktask threads within the limits of the calling
   context[1].

 - Make ktask aware of power management.  A starting point is to disable the
   framework when energy-conscious cpufreq settings are enabled (e.g.
   powersave, conservative scaling governors).  This should address another
   comment from Michal about keeping CPUs under power constraints idle[1].

 - Add more users.  On my list:
    - __ib_umem_release in IB core, which Jason Gunthorpe mentioned[3]
    - XFS quotacheck and online repair, as suggested by Darrick Wong
    - vfs object teardown at umount time, as Andrew mentioned[0]
    - page freeing in munmap/exit, as Aaron Lu posted[4]
    - page freeing in shmem
   The last three will benefit from scaling zone->lock and lru_lock.

 - CPU hotplug support for ktask to adjust its per-CPU data and resource
   limits.

 - Check with IOMMU folks that iommu_map is safe for all IOMMU backend
   implementations (it is for x86).


Summary
-------

A single CPU can spend an excessive amount of time in the kernel operating
on large amounts of data.  Often these situations arise during initialization-
and destruction-related tasks, where the data involved scales with system size.
These long-running jobs can slow startup and shutdown of applications and the
system itself while extra CPUs sit idle.
    
To ensure that applications and the kernel continue to perform well as core
counts and memory sizes increase, harness these idle CPUs to complete such jobs
more quickly.
    
ktask is a generic framework for parallelizing CPU-intensive work in the
kernel.  The API is generic enough to add concurrency to many different kinds
of tasks--for example, zeroing a range of pages or evicting a list of
inodes--and aims to save its clients the trouble of splitting up the work,
choosing the number of threads to use, maintaining an efficient concurrency
level, starting these threads, and load balancing the work between them.

The first patch has more documentation, and the second patch has the interface.

Current users:
 1) VFIO page pinning before kvm guest startup (others hitting slowness too[5])
 2) deferred struct page initialization at boot time
 3) clearing gigantic pages
 4) fallocate for HugeTLB pages

This patchset is based on the 2018-10-30 head of mmotm/master.

Changelog:

v3 -> v4:
 - Added VFIO page pinning use case (Andrew's "more users" comment)
 - Made ktask helpers run at the lowest priority on the system (Michal's
   concern about sensitivity to CPU utilization)
 - ktask learned to undo part of a task on error (required for VFIO)
 - Changed mm->locked_vm to an atomic to improve performance for VFIO.  This can
   be split out into a smaller series (there wasn't time before posting this)
 - Removed /proc/sys/debug/ktask_max_threads (it was a debug-only thing)
 - Some minor improvements in the ktask code itself (shorter, cleaner, etc)
 - Updated Documentation to cover these changes

v2 -> v3:
 - Changed cpu to CPU in the ktask Documentation, as suggested by Randy Dunlap
 - Saved more boot time now that Pavel Tatashin's deferred struct page init
   patches are in mainline (https://lkml.org/lkml/2017/10/13/692).  New
   performance results in patch 7.
 - Added resource limits, per-node and system-wide, to maintain efficient
   concurrency levels (addresses a concern from my Plumbers talk)
 - ktask no longer allocates memory internally during a task so it can be used
   in sensitive contexts
 - Added the option to run work anywhere on the system rather than always
   confining it to a specific node
 - Updated Documentation patch with these changes and reworked motivation
   section

v1 -> v2:
 - Added deferred struct page initialization use case.
 - Explained the source of the performance improvement from parallelizing
   clear_gigantic_page (comment from Dave Hansen).
 - Fixed Documentation and build warnings from CONFIG_KTASK=n kernels.

ktask v3 RFC: lkml.kernel.org/r/20171205195220.28208-1-daniel.m.jordan@oracle.com

[0] https://lkml.kernel.org/r/20171205142300.67489b1a90605e1089c5aaa9@linux-foundation.org
[1] https://lkml.kernel.org/r/20171206143509.GG7515@dhcp22.suse.cz
[2] https://lkml.kernel.org/r/1458339291-4093-1-git-send-email-bsd@redhat.com
[3] https://lkml.kernel.org/r/20180928153922.GA17076@ziepe.ca
[4] https://lkml.kernel.org/r/1489568404-7817-1-git-send-email-aaron.lu@intel.com
[5] https://www.redhat.com/archives/vfio-users/2018-April/msg00020.html

Daniel Jordan (13):
  ktask: add documentation
  ktask: multithread CPU-intensive kernel work
  ktask: add undo support
  ktask: run helper threads at MAX_NICE
  workqueue, ktask: renice helper threads to prevent starvation
  vfio: parallelize vfio_pin_map_dma
  mm: change locked_vm's type from unsigned long to atomic_long_t
  vfio: remove unnecessary mmap_sem writer acquisition around locked_vm
  vfio: relieve mmap_sem reader cacheline bouncing by holding it longer
  mm: enlarge type of offset argument in mem_map_offset and mem_map_next
  mm: parallelize deferred struct page initialization within each node
  mm: parallelize clear_gigantic_page
  hugetlbfs: parallelize hugetlbfs_fallocate with ktask

 Documentation/core-api/index.rst    |   1 +
 Documentation/core-api/ktask.rst    | 213 +++++++++
 arch/powerpc/kvm/book3s_64_vio.c    |  15 +-
 arch/powerpc/mm/mmu_context_iommu.c |  16 +-
 drivers/fpga/dfl-afu-dma-region.c   |  16 +-
 drivers/vfio/vfio_iommu_spapr_tce.c |  14 +-
 drivers/vfio/vfio_iommu_type1.c     | 159 ++++---
 fs/hugetlbfs/inode.c                | 114 ++++-
 fs/proc/task_mmu.c                  |   2 +-
 include/linux/ktask.h               | 267 ++++++++++++
 include/linux/mm_types.h            |   2 +-
 include/linux/workqueue.h           |   5 +
 init/Kconfig                        |  11 +
 init/main.c                         |   2 +
 kernel/Makefile                     |   2 +-
 kernel/fork.c                       |   2 +-
 kernel/ktask.c                      | 646 ++++++++++++++++++++++++++++
 kernel/workqueue.c                  | 106 ++++-
 mm/debug.c                          |   3 +-
 mm/internal.h                       |   7 +-
 mm/memory.c                         |  32 +-
 mm/mlock.c                          |   4 +-
 mm/mmap.c                           |  18 +-
 mm/mremap.c                         |   6 +-
 mm/page_alloc.c                     |  91 +++-
 25 files changed, 1599 insertions(+), 155 deletions(-)
 create mode 100644 Documentation/core-api/ktask.rst
 create mode 100644 include/linux/ktask.h
 create mode 100644 kernel/ktask.c

-- 
2.19.1
