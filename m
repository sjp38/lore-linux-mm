Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 67F3D6B0047
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 02:59:04 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 00/10] memcg: per cgroup dirty page accounting
Date: Sun,  3 Oct 2010 23:57:55 -0700
Message-Id: <1286175485-30643-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

This patch set provides the ability for each cgroup to have independent dirty
page limits.

Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
not be able to consume more than their designated share of dirty pages and will
be forced to perform write-out if they cross that limit.

These patches were developed and tested on mmotm 2010-09-28-16-13.  The patches
are based on a series proposed by Andrea Righi in Mar 2010.

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

Performance measurements:
- kernel builds are unaffected unless run with a small dirty limit.
- all data collected with CONFIG_CGROUP_MEM_RES_CTLR=y.
- dd has three data points (in secs) for three data sizes (100M, 200M, and 1G).  
  As expected, dd slows when it exceed its cgroup dirty limit.

               kernel_build          dd
mmotm             2:37        0.18, 0.38, 1.65
  root_memcg

mmotm             2:37        0.18, 0.35, 1.66
  non-root_memcg

mmotm+patches     2:37        0.18, 0.35, 1.68
  root_memcg

mmotm+patches     2:37        0.19, 0.35, 1.69
  non-root_memcg

mmotm+patches     2:37        0.19, 2.34, 22.82
  non-root_memcg
  150 MiB memcg dirty limit

mmotm+patches     3:58        1.71, 3.38, 17.33
  non-root_memcg
  1 MiB memcg dirty limit

Greg Thelen (10):
  memcg: add page_cgroup flags for dirty page tracking
  memcg: document cgroup dirty memory interfaces
  memcg: create extensible page stat update routines
  memcg: disable local interrupts in lock_page_cgroup()
  memcg: add dirty page accounting infrastructure
  memcg: add kernel calls for memcg dirty page stats
  memcg: add dirty limits to mem_cgroup
  memcg: add cgroupfs interface to memcg dirty limits
  writeback: make determine_dirtyable_memory() static.
  memcg: check memcg dirty limits in page writeback

 Documentation/cgroups/memory.txt |   37 ++++
 fs/nfs/write.c                   |    4 +
 include/linux/memcontrol.h       |   78 +++++++-
 include/linux/page_cgroup.h      |   31 +++-
 include/linux/writeback.h        |    2 -
 mm/filemap.c                     |    1 +
 mm/memcontrol.c                  |  426 ++++++++++++++++++++++++++++++++++----
 mm/page-writeback.c              |  211 ++++++++++++-------
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    1 +
 10 files changed, 672 insertions(+), 123 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
