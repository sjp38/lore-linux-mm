Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 649686B017B
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:16:09 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 00/13] memcg: per cgroup dirty page limiting
Date: Wed, 17 Aug 2011 09:14:52 -0700
Message-Id: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

This patch series provides the ability for each cgroup to have independent dirty
page usage limits.  Limiting dirty memory fixes the max amount of dirty (hard to
reclaim) page cache used by a cgroup.  This allows for better per cgroup memory
isolation and fewer memcg OOMs.

Three features are included in this patch series:
  1. memcg dirty page accounting
  2. memcg writeback
  3. memcg dirty page limiting


1. memcg dirty page accounting

Each memcg maintains a dirty page count and dirty page limit.  Previous
iterations of this patch series have refined this logic.  The interface is
similar to the procfs interface: /proc/sys/vm/dirty_*.  It is possible to
configure a limit to trigger throttling of a dirtier or queue background
writeback.  The root cgroup memory.dirty_* control files are read-only and match
the contents of the /proc/sys/vm/dirty_* files.


2. memcg writeback

Having per cgroup dirty memory limits is not very interesting unless writeback
is also cgroup aware.  There is not much isolation if cgroups have to writeback data
from outside the affected cgroup to get below the cgroup dirty memory threshold.

Per-memcg dirty limits are provided to support isolation and thus cross cgroup
inode sharing is not a priority.  This allows the code be simpler.

To add cgroup awareness to writeback, this series adds an i_memcg field to
struct address_space to allow writeback to isolate inodes for a particular
cgroup.  When an inode is marked dirty, i_memcg is set to the current cgroup.
When inode pages are marked dirty the i_memcg field is compared against the
page's cgroup.  If they differ, then the inode is marked as shared by setting
i_memcg to a special shared value (zero).

When performing per-memcg writeback, move_expired_inodes() scans the per bdi
b_dirty list using each inode's i_memcg and the global over-limit memcg bitmap
to determine if the inode should be written.  This inode scan may involve
skipping many unrelated inodes from other cgroup.  To test the scanning
overhead, I created two cgroups (cgroup_A with 100,000 dirty inodes under A's
dirty limit, cgroup_B with 1 inode over B's dirty limit).  The writeback code
then had to skip 100,000 inodes when balancing cgroup_B to find the one inode
that needed writing.  This scanning took 58 msec to skip 100,000 foreign inodes.


3. memcg dirty page limiting

balance_dirty_pages() calls mem_cgroup_balance_dirty_pages(), which checks the
dirty usage vs dirty thresholds for the current cgroup and its parents.  As
cgroups exceed their background limit, they are marked in a global over-limit
bitmap (indexed by cgroup id) and the bdi flusher is awoke.  As a cgroup hits is
foreground limit, the task is throttled while performing foreground writeback on
inodes owned by the over-limit cgroup.  If mem_cgroup_balance_dirty_pages() is
unable to get below the dirty page threshold writing per-memcg inodes, then
downshifts to also writing shared inodes (i_memcg=0).

I know that there is some significant IO-less balance_dirty_pages() changes.  I
am not trying to derail that effort.  I have done moderate functional testing of
the newly proposed features.

The memcg aspects of this patch are pretty mature.  The writeback aspects are
still fairly new and need feedback from the writeback community.  These features
are linked, so it's not clear which branch to send the changes to (the writeback
development branch or mmotm).

Here is an example of the memcg OOM that is avoided with this patch series:
	# mkdir /dev/cgroup/memory/x
	# echo 100M > /dev/cgroup/memory/x/memory.limit_in_bytes
	# echo $$ > /dev/cgroup/memory/x/tasks
	# dd if=/dev/zero of=/data/f1 bs=1k count=1M &
        # dd if=/dev/zero of=/data/f2 bs=1k count=1M &
        # wait
	[1]-  Killed                  dd if=/dev/zero of=/data/f1 bs=1M count=1k
	[2]+  Killed                  dd if=/dev/zero of=/data/f1 bs=1M count=1k

Changes since -v8:
- Reordered patches for better more readability.

- No longer passing struct writeback_control into memcontrol functions.  Instead
  the needed attributes (memcg_id, etc.) are explicitly passed in.  Therefore no
  more field additions to struct writeback_control.

- Replaced 'Andrea Righi <arighi@develer.com>' with 
  'Andrea Righi <andrea@betterlinux.com>' in commit descriptions.

- Rebased to mmotm-2011-08-02-16-19

Greg Thelen (13):
  memcg: document cgroup dirty memory interfaces
  memcg: add page_cgroup flags for dirty page tracking
  memcg: add dirty page accounting infrastructure
  memcg: add kernel calls for memcg dirty page stats
  memcg: add mem_cgroup_mark_inode_dirty()
  memcg: add dirty limits to mem_cgroup
  memcg: add cgroupfs interface to memcg dirty limits
  memcg: dirty page accounting support routines
  memcg: create support routines for writeback
  writeback: pass wb_writeback_work into move_expired_inodes()
  writeback: make background writeback cgroup aware
  memcg: create support routines for page writeback
  memcg: check memcg dirty limits in page writeback

 Documentation/cgroups/memory.txt  |   70 ++++
 fs/buffer.c                       |    2 +-
 fs/fs-writeback.c                 |  113 ++++--
 fs/inode.c                        |    3 +
 fs/nfs/write.c                    |    4 +
 fs/sync.c                         |    2 +-
 include/linux/cgroup.h            |    1 +
 include/linux/fs.h                |    9 +
 include/linux/memcontrol.h        |   64 +++-
 include/linux/page_cgroup.h       |   23 ++
 include/linux/writeback.h         |    9 +-
 include/trace/events/memcontrol.h |  207 ++++++++++
 kernel/cgroup.c                   |    1 -
 mm/backing-dev.c                  |    3 +-
 mm/filemap.c                      |    1 +
 mm/memcontrol.c                   |  760 ++++++++++++++++++++++++++++++++++++-
 mm/page-writeback.c               |   44 ++-
 mm/truncate.c                     |    1 +
 mm/vmscan.c                       |    5 +-
 19 files changed, 1265 insertions(+), 57 deletions(-)
 create mode 100644 include/trace/events/memcontrol.h

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
