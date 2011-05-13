Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD5F86B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 04:48:54 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [RFC][PATCH v7 00/14] memcg: per cgroup dirty page accounting
Date: Fri, 13 May 2011 01:47:39 -0700
Message-Id: <1305276473-14780-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

This patch series provides the ability for each cgroup to have independent dirty
page usage limits.  Limiting dirty memory fixes the max amount of dirty (hard to
reclaim) page cache used by a cgroup.  This allows for better per cgroup memory
isolation and fewer ooms within a single cgroup.

Having per cgroup dirty memory limits is not very interesting unless writeback
is cgroup aware.  There is not much isolation if cgroups have to writeback data
from other cgroups to get below their dirty memory threshold.

Per-memcg dirty limits are provided to support isolation and thus cross cgroup
inode sharing is not a priority.  This allows the code be simpler.

To add cgroup awareness to writeback, this series adds a memcg field to the
inode to allow writeback to isolate inodes for a particular cgroup.  When an
inode is marked dirty, i_memcg is set to the current cgroup.  When inode pages
are marked dirty the i_memcg field compared against the page's cgroup.  If they
differ, then the inode is marked as shared by setting i_memcg to a special
shared value (zero).

Previous discussions suggested that a per-bdi per-memcg b_dirty list was a good
way to assoicate inodes with a cgroup without having to add a field to struct
inode.  I prototyped this approach but found that it involved more complex
writeback changes and had at least one major shortcoming: detection of when an
inode becomes shared by multiple cgroups.  While such sharing is not expected to
be common, the system should gracefully handle it.

balance_dirty_pages() calls mem_cgroup_balance_dirty_pages(), which checks the
dirty usage vs dirty thresholds for the current cgroup and its parents.  If any
over-limit cgroups are found, they are marked in a global over-limit bitmap
(indexed by cgroup id) and the bdi flusher is awoke.

The bdi flusher uses wb_check_background_flush() to check for any memcg over
their dirty limit.  When performing per-memcg background writeback,
move_expired_inodes() walks per bdi b_dirty list using each inode's i_memcg and
the global over-limit memcg bitmap to determine if the inode should be written.

If mem_cgroup_balance_dirty_pages() is unable to get below the dirty page
threshold writing per-memcg inodes, then downshifts to also writing shared
inodes (i_memcg=0).

I know that there is some significant writeback changes associated with the
IO-less balance_dirty_pages() effort.  I am not trying to derail that, so this
patch series is merely an RFC to get feedback on the design.  There are probably
some subtle races in these patches.  I have done moderate functional testing of
the newly proposed features.

Here is an example of the memcg-oom that is avoided with this patch series:
	# mkdir /dev/cgroup/memory/x
	# echo 100M > /dev/cgroup/memory/x/memory.limit_in_bytes
	# echo $$ > /dev/cgroup/memory/x/tasks
	# dd if=/dev/zero of=/data/f1 bs=1k count=1M &
        # dd if=/dev/zero of=/data/f2 bs=1k count=1M &
        # wait
	[1]-  Killed                  dd if=/dev/zero of=/data/f1 bs=1M count=1k
	[2]+  Killed                  dd if=/dev/zero of=/data/f1 bs=1M count=1k

Known limitations:
	If a dirty limit is lowered a cgroup may be over its limit.

Changes since -v6:
- memcg aware writeback.

Single patch that can be applied to mmotm-2011-05-06-16-39:
  http://www.kernel.org/pub/linux/kernel/people/gthelen/memcg/memcg-dirty-limits-v7-on-mmotm-2011-05-06-16-39.patch

Patches are based on mmotm-2011-05-06-16-39.

Greg Thelen (14):
  memcg: document cgroup dirty memory interfaces
  memcg: add page_cgroup flags for dirty page tracking
  memcg: add mem_cgroup_mark_inode_dirty()
  memcg: add dirty page accounting infrastructure
  memcg: add kernel calls for memcg dirty page stats
  memcg: add dirty limits to mem_cgroup
  memcg: add cgroupfs interface to memcg dirty limits
  writeback: add memcg fields to writeback_control
  cgroup: move CSS_ID_MAX to cgroup.h
  memcg: dirty page accounting support routines
  memcg: create support routines for writeback
  memcg: create support routines for page-writeback
  writeback: make background writeback cgroup aware
  memcg: check memcg dirty limits in page writeback

 Documentation/cgroups/memory.txt  |   70 ++++
 fs/fs-writeback.c                 |   33 ++-
 fs/inode.c                        |    3 +
 fs/nfs/write.c                    |    4 +
 include/linux/cgroup.h            |    1 +
 include/linux/fs.h                |    9 +
 include/linux/memcontrol.h        |   64 ++++-
 include/linux/page_cgroup.h       |   23 ++
 include/linux/writeback.h         |    5 +-
 include/trace/events/memcontrol.h |  198 +++++++++++
 kernel/cgroup.c                   |    1 -
 mm/filemap.c                      |    1 +
 mm/memcontrol.c                   |  705 ++++++++++++++++++++++++++++++++++++-
 mm/page-writeback.c               |   42 ++-
 mm/truncate.c                     |    1 +
 mm/vmscan.c                       |    2 +-
 16 files changed, 1134 insertions(+), 28 deletions(-)
 create mode 100644 include/trace/events/memcontrol.h

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
