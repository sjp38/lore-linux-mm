Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6C1C8D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 16:36:35 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v5 0/9] memcg: per cgroup dirty page accounting
Date: Fri, 25 Feb 2011 13:35:51 -0800
Message-Id: <1298669760-26344-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

Changes since v4:
- Moved documentation changes to start of series to provide a better
  introduction to the series.
- Added support for hierarchical dirty limits.
- Incorporated bug fixes previously found in v4.
- Include a new patch "writeback: convert variables to unsigned" to provide a
  clearer transition to the the new dirty_info structure (patch "writeback:
  create dirty_info structure").
- Within the new dirty_info structure, replaced nr_reclaimable with
  nr_file_dirty and nr_unstable_nfs to give callers finer grain dirty usage
  information also added dirty_info_reclaimable().
- Rebased the series to mmotm-2011-02-10-16-26 with two pending mmotm patches:
  memcg: break out event counters from other stats
    https://lkml.org/lkml/2011/2/17/415
  memcg: use native word page statistics counters
    https://lkml.org/lkml/2011/2/17/413

Changes since v3:
- Refactored balance_dirty_pages() dirtying checking to use new struct
  dirty_info, which is used to compare both system and memcg dirty limits
  against usage.
- Disabled memcg dirty limits when memory.use_hierarchy=1.  An enhancement is
  needed to check the chain of parents to ensure that no dirty limit is
  exceeded.
- Ported to mmotm-2010-10-22-16-36.

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
be throttled if they cross that limit.

Example use case:
  #!/bin/bash
  #
  # Here is a test script that shows a situation where memcg dirty limits are
  # beneficial.
  #
  # The script runs two programs:
  # 1) a dirty page background antagonist (dd)
  # 2) an interactive foreground process (tar).
  #
  # If the script's argument is false, then both processes are limited by the
  # classic global dirty limits.  If the script is given a true argument, then a
  # per-cgroup dirty limit is used to contain dd dirty page consumption.  The
  # cgroup isolates the dd dirty memory consumption from the rest of the system
  # processes (tar in this case).
  #
  # The time used by the tar process is printed (lower is better).
  #
  # When dd is run within a dirty limiting cgroup, the tar process had faster
  # and more predictable performance.  memcg dirty ratios might be useful to
  # serve different task classes (interactive vs batch).  A past discussion
  # touched on this: http://lkml.org/lkml/2010/5/20/136
  #
  # When called with 'false' (using memcg without dirty isolation):
  #   tar finished in 7.0s
  #   dd reports 92 MB/s  
  #
  # When called with 'true' (using memcg for dirty isolation):
  #   tar finished in 2.5s
  #   dd reports 82 MB/s

  echo memcg_dirty_limits: $1
  
  # set system dirty limits.
  echo $((1<<30)) > /proc/sys/vm/dirty_bytes
  echo $((1<<29)) > /proc/sys/vm/dirty_background_bytes
  
  mkdir /dev/cgroup/memory/A
  
  if $1; then    # if using cgroup to contain 'dd'...
    echo 100M > /dev/cgroup/memory/A/memory.dirty_limit_in_bytes
  fi
  
  # run antagonist (dd) in cgroup A
  (echo $BASHPID > /dev/cgroup/memory/A/tasks; \
   dd if=/dev/zero of=/disk1/big.file count=10k bs=1M) &
  
  # let antagonist (dd) get warmed up
  sleep 10
  
  # time interactive job
  time tar -C /disk2 -xzf linux.tar.gz
  
  wait
  sleep 10
  rmdir /dev/cgroup/memory/A

The patches are based on a series proposed by Andrea Righi in Mar 2010.

Overview:
- Add page_cgroup flags to record when pages are dirty, in writeback, or nfs
  unstable.

- Extend mem_cgroup to record the total number of pages in each of the 
  interesting dirty states (dirty, writeback, unstable_nfs).  

- Add dirty parameters similar to the system-wide /proc/sys/vm/dirty_* limits to
  mem_cgroup.  The mem_cgroup dirty parameters are accessible via cgroupfs
  control files.

- Consider both system and per-memcg dirty limits in page writeback when
  deciding to queue background writeback or throttle dirty memory production.

Known shortcomings (see the patch 1 update to Documentation/cgroups/memory.txt
for more details):
- When a cgroup dirty limit is exceeded, then bdi writeback is employed to
  writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
  just inodes contributing dirty pages to the cgroup exceeding its limit.  

- A cgroup may exceed its dirty limit if the memory is dirtied by a process in a
  different memcg.

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
  --repeat 3".

- All numbers are page fault rate (M/sec).  Higher is better.

- To compare the performance of a kernel without memcg compare the first and
  last rows - neither has memcg configured.  The first row does not include any
  of these memcg dirty limit patches.

- To compare the performance of using memcg dirty limits, compare the memcg
  baseline (2nd row titled "mmotm w/ memcg") with the 3rd row (memcg enabled
  with all patches).

                          root_cgroup                     child_cgroup
                 s_read s_write p_read p_write   s_read s_write p_read p_write
mmotm w/o memcg   0.359  0.312   0.357  0.312
mmotm w/ memcg    0.366  0.316   0.342  0.301     0.368  0.309   0.347  0.301
all patches       0.347  0.322   0.327  0.303     0.342  0.323   0.327  0.305
all patches       0.358  0.322   0.357  0.316
  w/o memcg

Greg Thelen (9):
  memcg: document cgroup dirty memory interfaces
  memcg: add page_cgroup flags for dirty page tracking
  writeback: convert variables to unsigned
  writeback: create dirty_info structure
  memcg: add dirty page accounting infrastructure
  memcg: add kernel calls for memcg dirty page stats
  memcg: add dirty limits to mem_cgroup
  memcg: add cgroupfs interface to memcg dirty limits
  memcg: check memcg dirty limits in page writeback

 Documentation/cgroups/memory.txt |   80 +++++++
 fs/fs-writeback.c                |    7 +-
 fs/nfs/write.c                   |    4 +
 include/linux/memcontrol.h       |   33 +++-
 include/linux/page_cgroup.h      |   23 ++
 include/linux/writeback.h        |   18 ++-
 mm/backing-dev.c                 |   18 +-
 mm/filemap.c                     |    1 +
 mm/memcontrol.c                  |  470 +++++++++++++++++++++++++++++++++++++-
 mm/page-writeback.c              |  150 +++++++++----
 mm/truncate.c                    |    1 +
 mm/vmscan.c                      |    2 +-
 mm/vmstat.c                      |    6 +-
 13 files changed, 742 insertions(+), 71 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
