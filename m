Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 279D45F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:15:10 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 00/11] memcg: per cgroup dirty page accounting
Date: Fri, 15 Oct 2010 14:14:28 -0700
Message-Id: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Changes since V1:
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

- Patch 04/11 disables softirq in lock_page_cgroup().  There has been some
  discussion about the performance of this change.  To compare the cost of
  disabling softirq in patch 04/11, compare the patch 03 and patch 04 rows.

- To compare the performance of a kernel without non-memcg compare the first and
  last rows, neither has memcg configured.  The first row does not include any
  of these memcg patches.

- To compare the performance of using memcg dirty limits, compare the baseline
  (2nd row titled "w/ memcg") with the the code and memcg enabled (2nd to last
  row titled "all patches").

                           root_cgroup                     child_cgroup
                 s_read s_write p_read p_write    s_read s_write p_read p_write
mmotm w/o memcg   0.424  0.399   0.421  0.395
w/ memcg          0.418  0.389   0.398  0.369      0.414  0.389  0.395  0.369
patch 03/11       0.429  0.394   0.405  0.378      0.427  0.393  0.405  0.379
 create extensible routines
patch 04/11       0.424  0.394   0.400  0.373      0.421  0.389  0.398  0.366
  disable softirq
all patches       0.419  0.379   0.392  0.365      0.416  0.379  0.391  0.362
all patches       0.428  0.395   0.421  0.391
  w/o memcg


Balbir Singh (1):
  memcg: CPU hotplug lockdep warning fix

Greg Thelen (10):
  memcg: add page_cgroup flags for dirty page tracking
  memcg: document cgroup dirty memory interfaces
  memcg: create extensible page stat update routines
  memcg: disable softirq in lock_page_cgroup()
  memcg: add dirty page accounting infrastructure
  memcg: add kernel calls for memcg dirty page stats
  memcg: add dirty limits to mem_cgroup
  memcg: add cgroupfs interface to memcg dirty limits
  writeback: make determine_dirtyable_memory() static.
  memcg: check memcg dirty limits in page writeback

 Documentation/cgroups/memory.txt |   60 ++++++
 fs/nfs/write.c                   |    4 +
 include/linux/memcontrol.h       |   78 +++++++-
 include/linux/page_cgroup.h      |   29 +++
 include/linux/writeback.h        |    2 -
 mm/filemap.c                     |    1 +
 mm/memcontrol.c                  |  408 ++++++++++++++++++++++++++++++++++++--
 mm/page-writeback.c              |  213 +++++++++++++-------
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    1 +
 10 files changed, 697 insertions(+), 103 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
