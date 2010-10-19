Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC3856B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 20:40:16 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v3 00/11] memcg: per cgroup dirty page accounting
Date: Mon, 18 Oct 2010 17:39:33 -0700
Message-Id: <1287448784-25684-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Changes since v2:
- Rather than disabling softirq in lock_page_cgroup(), introduce a separate lock
  to synchronize between memcg page accounting and migration.  This only affects
  patch 4 of the series.  Patch 4 used to disable softirq, now it introduces the
  new lock.

Changes since v1:
- Renamed "nfs"/"total_nfs" to "nfs_unstable"/"total_nfs_unstable" in per cgroup
  memory.stat to match /proc/meminfo.
- Avoid lockdep warnings by using rcu_read_[un]lock() in
  mem_cgroup_has_dirty_limit().
- Fixed lockdep issue in mem_cgroup_read_stat() which is exposed by these
  patches.
- Remove redundant comments.
- Rename (for clarity):
  - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
  - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
- Renamed newly created proc files:
  - memory.dirty_bytes -> memory.dirty_limit_in_bytes
  - memory.dirty_background_bytes -> memory.dirty_background_limit_in_bytes
- Removed unnecessary get_ prefix from get_xxx() functions.
- Allow [kKmMgG] suffixes for newly created dirty limit value cgroupfs files.
- Disable softirq rather than hardirq in lock_page_cgroup()
- Made mem_cgroup_move_account_page_stat() inline.
- Ported patches to mmotm-2010-10-13-17-13.

This patch set provides the ability for each cgroup to have independent dirty
page limits.

Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
not be able to consume more than their designated share of dirty pages and will
be forced to perform write-out if they cross that limit.

The patches are based on a series proposed by Andrea Righi in Mar 2010.


Overview:
- Add page_cgroup flags to record when pages are dirty, in writeback, or nfs
  unstable.

- Extend mem_cgroup to record the total number of pages in each of the 
  interesting dirty states (dirty, writeback, unstable_nfs).  

- Add dirty parameters similar to the system-wide  /proc/sys/vm/dirty_*
  limits to mem_cgroup.  The mem_cgroup dirty parameters are accessible
  via cgroupfs control files.

- Consider both system and per-memcg dirty limits in page writeback when
  deciding to queue background writeback or block for foreground writeback.


Known shortcomings:
- When a cgroup dirty limit is exceeded, then bdi writeback is employed to
  writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
  just inodes contributing dirty pages to the cgroup exceeding its limit.  


Performance data:
- A page fault microbenchmark workload was used to measure performance, which
  can be called in read or write mode:
        f = open(foo. $cpu)
        truncate(f, 4096)
        alarm(60)
        while (1) {
                p = mmap(f, 4096)
                if (write)
			*p = 1
		else
			x = *p
                munmap(p)
        }

- The workload was called for several points in the patch series in different
  modes:
  - s_read is a single threaded reader
  - s_write is a single threaded writer
  - p_read is a 16 thread reader, each operating on a different file
  - p_write is a 16 thread writer, each operating on a different file

- Measurements were collected on a 16 core non-numa system using "perf stat
  --repeat 3".  The -a option was used for parallel (p_*) runs.

- All numbers are page fault rate (M/sec).  Higher is better.

- To compare the performance of a kernel without non-memcg compare the first and
  last rows, neither has memcg configured.  The first row does not include any
  of these memcg patches.

- To compare the performance of using memcg dirty limits, compare the baseline
  (2nd row titled "w/ memcg") with the the code and memcg enabled (2nd to last
  row titled "all patches").

                           root_cgroup                     child_cgroup
                 s_read s_write p_read p_write    s_read s_write p_read p_write
mmotm w/o memcg   0.424  0.400   0.420  0.395
w/ memcg          0.419  0.390   0.395  0.371      0.413  0.385   0.385  0.361
all patches       0.421  0.384   0.395  0.362      0.418  0.380   0.396  0.360
all patches       0.425  0.396   0.423  0.388
  w/o memcg


Balbir Singh (1):
  memcg: CPU hotplug lockdep warning fix

Greg Thelen (9):
  memcg: add page_cgroup flags for dirty page tracking
  memcg: document cgroup dirty memory interfaces
  memcg: create extensible page stat update routines
  memcg: add dirty page accounting infrastructure
  memcg: add kernel calls for memcg dirty page stats
  memcg: add dirty limits to mem_cgroup
  memcg: add cgroupfs interface to memcg dirty limits
  writeback: make determine_dirtyable_memory() static.
  memcg: check memcg dirty limits in page writeback

KAMEZAWA Hiroyuki (1):
  memcg: add lock to synchronize page accounting and migration

 Documentation/cgroups/memory.txt |   60 ++++++
 fs/nfs/write.c                   |    4 +
 include/linux/memcontrol.h       |   78 +++++++-
 include/linux/page_cgroup.h      |   54 +++++-
 include/linux/writeback.h        |    2 -
 mm/filemap.c                     |    1 +
 mm/memcontrol.c                  |  417 ++++++++++++++++++++++++++++++++++++--
 mm/page-writeback.c              |  213 +++++++++++++-------
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    1 +
 10 files changed, 726 insertions(+), 108 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
