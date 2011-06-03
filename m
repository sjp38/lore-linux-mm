Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6666B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 12:13:07 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v8 01/12] memcg: document cgroup dirty memory interfaces
Date: Fri,  3 Jun 2011 09:12:07 -0700
Message-Id: <1307117538-14317-2-git-send-email-gthelen@google.com>
In-Reply-To: <1307117538-14317-1-git-send-email-gthelen@google.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Document cgroup dirty memory interfaces and statistics.

The implementation for these new interfaces routines comes in a series
of following patches.

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 Documentation/cgroups/memory.txt |   70 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 43b9e46..15019a3 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -395,6 +395,10 @@ soft_direct_steal- # of pages reclaimed in global hierarchical reclaim from
 		direct reclaim
 soft_direct_scan- # of pages scanned in global hierarchical reclaim from
 		direct reclaim
+dirty		- # of bytes that are waiting to get written back to the disk.
+writeback	- # of bytes that are actively being written back to the disk.
+nfs_unstable	- # of bytes sent to the NFS server, but not yet committed to
+		the actual storage.
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
@@ -420,6 +424,9 @@ total_soft_kswapd_steal	- sum of all children's "soft_kswapd_steal"
 total_soft_kswapd_scan	- sum of all children's "soft_kswapd_scan"
 total_soft_direct_steal	- sum of all children's "soft_direct_steal"
 total_soft_direct_scan	- sum of all children's "soft_direct_scan"
+total_dirty		- sum of all children's "dirty"
+total_writeback		- sum of all children's "writeback"
+total_nfs_unstable	- sum of all children's "nfs_unstable"
 total_inactive_anon	- sum of all children's "inactive_anon"
 total_active_anon	- sum of all children's "active_anon"
 total_inactive_file	- sum of all children's "inactive_file"
@@ -476,6 +483,69 @@ value for efficient access. (Of course, when necessary, it's synchronized.)
 If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
 value in memory.stat(see 5.2).
 
+5.6 dirty memory
+
+Control the maximum amount of dirty pages a cgroup can have at any given time.
+
+Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
+page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
+not be able to consume more than their designated share of dirty pages and will
+be throttled if they cross that limit.  System-wide dirty limits are also
+consulted.  Dirty memory consumption is checked against both system-wide and
+per-cgroup dirty limits.
+
+The interface is similar to the procfs interface: /proc/sys/vm/dirty_*.  It is
+possible to configure a limit to trigger throttling of a dirtier or queue
+background writeback.  The root cgroup memory.dirty_* control files are
+read-only and match the contents of the /proc/sys/vm/dirty_* files.
+
+Per-cgroup dirty limits can be set using the following files in the cgroupfs:
+
+- memory.dirty_ratio: the amount of dirty memory (expressed as a percentage of
+  cgroup memory) at which a process generating dirty pages will be throttled.
+  The default value is the system-wide dirty ratio, /proc/sys/vm/dirty_ratio.
+
+- memory.dirty_limit_in_bytes: the amount of dirty memory (expressed in bytes)
+  in the cgroup at which a process generating dirty pages will be throttled.
+  Suffix (k, K, m, M, g, or G) can be used to indicate that value is kilo, mega
+  or gigabytes.  The default value is the system-wide dirty limit,
+  /proc/sys/vm/dirty_bytes.
+
+  Note: memory.dirty_limit_in_bytes is the counterpart of memory.dirty_ratio.
+  Only one may be specified at a time.  When one is written it is immediately
+  taken into account to evaluate the dirty memory limits and the other appears
+  as 0 when read.
+
+- memory.dirty_background_ratio: the amount of dirty memory of the cgroup
+  (expressed as a percentage of cgroup memory) at which background writeback
+  kernel threads will start writing out dirty data.  The default value is the
+  system-wide background dirty ratio, /proc/sys/vm/dirty_background_ratio.
+
+- memory.dirty_background_limit_in_bytes: the amount of dirty memory (expressed
+  in bytes) in the cgroup at which background writeback kernel threads will
+  start writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to
+  indicate that value is kilo, mega or gigabytes.  The default value is the
+  system-wide dirty background limit, /proc/sys/vm/dirty_background_bytes.
+
+  Note: memory.dirty_background_limit_in_bytes is the counterpart of
+  memory.dirty_background_ratio.  Only one may be specified at a time.  When one
+  is written it is immediately taken into account to evaluate the dirty memory
+  limits and the other appears as 0 when read.
+
+A cgroup may contain more dirty memory than its dirty limit.  This is possible
+because of the principle that the first cgroup to touch a page is charged for
+it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
+counted to the originally charged cgroup.  Example: If page is allocated by a
+cgroup A task, then the page is charged to cgroup A.  If the page is later
+dirtied by a task in cgroup B, then the cgroup A dirty count will be
+incremented.  If cgroup A is over its dirty limit but cgroup B is not, then
+dirtying a cgroup A page from a cgroup B task may push cgroup A over its dirty
+limit without throttling the dirtying cgroup B task.
+
+When use_hierarchy=0, each cgroup has independent dirty memory usage and limits.
+When use_hierarchy=1 the dirty limits of parent cgroups are also checked to
+ensure that no dirty limit is exceeded.
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
