Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3CFE76B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 20:21:47 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 0/5] mm: i_mmap_mutex to rwsem
Date: Mon, 24 Jun 2013 17:21:33 -0700
Message-Id: <1372119698-13147-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, akpm@linux-foundation.org
Cc: walken@google.com, alex.shi@intel.com, tim.c.chen@linux.intel.com, a.p.zijlstra@chello.nl, riel@redhat.com, peter@hurleysoftware.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

This patchset extends the work started by Ingo Molnar in late 2012,
optimizing the anon-vma mutex lock, converting it from a exclusive mutex
to a rwsem, and sharing the lock for read-only paths when walking the
the vma-interval tree. More specifically commits 5a505085 and 4fc3f1d6.

The i_mmap mutex has similar responsibilities with the anon-vma, protecting
file backed pages. Therefore we can use similar locking techniques: covert
the mutex to a rwsem and share the lock when possible.

With these changes, and the rwsem optimizations discussed in
http://lkml.org/lkml/2013/6/16/38 we can see performance improvements.
For instance, on a 8 socket, 80 core DL980, when compared to a vanilla 3.10-rc5, 
aim7 benefits in throughput, with the following workloads (beyond 500 users):

- alltests (+14.5%)
- custom (+17%)
- disk (+11%)
- high_systime (+5%)
- shared (+15%)
- short (+4%)

For lower amounts of users, there are no significant differences as all numbers
are within the 0-2% noise range.

Davidlohr Bueso (5):
  mm,fs: introduce helpers around i_mmap_mutex
  mm: use new helper functions around the i_mmap_mutex
  mm: convert i_mmap_mutex to rwsem
  mm/rmap: share the i_mmap_rwsem
  mm: rename leftover i_mmap_mutex

 Documentation/lockstat.txt   |  2 +-
 Documentation/vm/locking     |  2 +-
 arch/x86/mm/hugetlbpage.c    |  6 +++---
 fs/hugetlbfs/inode.c         |  4 ++--
 fs/inode.c                   |  2 +-
 include/linux/fs.h           | 22 +++++++++++++++++++++-
 include/linux/mmu_notifier.h |  2 +-
 kernel/events/uprobes.c      |  6 +++---
 kernel/fork.c                |  4 ++--
 mm/filemap.c                 | 10 +++++-----
 mm/filemap_xip.c             |  4 ++--
 mm/fremap.c                  |  4 ++--
 mm/hugetlb.c                 | 16 ++++++++--------
 mm/memory-failure.c          |  7 +++----
 mm/memory.c                  |  8 ++++----
 mm/mmap.c                    | 22 +++++++++++-----------
 mm/mremap.c                  |  6 +++---
 mm/nommu.c                   | 14 +++++++-------
 mm/rmap.c                    | 24 ++++++++++++------------
 19 files changed, 92 insertions(+), 73 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
