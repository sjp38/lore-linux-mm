Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AB12A9000C5
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:34 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p8S0nUm0004291
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:31 -0700
Received: from iabn5 (iabn5.prod.google.com [10.12.90.5])
	by wpaz13.hot.corp.google.com with ESMTP id p8S0nQTj024230
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:29 -0700
Received: by iabn5 with SMTP id n5so8949268iab.24
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:29 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/9] kstaled: documentation and config option.
Date: Tue, 27 Sep 2011 17:49:00 -0700
Message-Id: <1317170947-17074-3-git-send-email-walken@google.com>
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

Extend memory cgroup documentation do describe the optional idle page
tracking features, and add the corresponding configuration option.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 Documentation/cgroups/memory.txt |  103 +++++++++++++++++++++++++++++++++++++-
 mm/Kconfig                       |   10 ++++
 2 files changed, 112 insertions(+), 1 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 06eb6d9..7ee2eb3 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -672,7 +672,108 @@ At reading, current status of OOM is shown.
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
-11. TODO
+
+11. Idle page tracking
+
+Idle page tracking works by scanning physical memory at a known rate,
+finding idle pages, and accounting for them in the cgroup owning them.
+
+Idle pages are defined as user pages (either anon or file backed) that have
+not been accessed for a number of consecutive scans, and are also not
+currently pinned down (for example by being mlocked).
+
+11.1 Usage
+
+The first step is to select the global scanning rate:
+
+# echo 120 > /sys/kernel/mm/kstaled/scan_seconds	# 2 minutes per scan
+
+(At boot time, the default value for /sys/kernel/mm/kstaled/scan_seconds
+is 0 which means the idle page tracking feature is disabled).
+
+Then, the per-cgroup memory.idle_page_stats files get updated at the
+end of every scan. The relevant fields are:
+* idle_clean: idle pages that have been untouched for at least one scan cycle,
+  and are also clean. Being clean and unpinned, such pages are immediately
+  reclaimable by the MM's LRU algorithms.
+* idle_dirty_file: idle pages that have been untouched for at least one
+  scan cycle, are dirty, and are file backed. Such pages are not immediately
+  reclaimable as writeback needs to occur first.
+* idle_dirty_swap: idle pages that have been untouched for at least one
+  scan cycle, are dirty, and would have to be written to swap before being
+  reclaimed. This includes dirty anon memory, tmpfs files and shm segments.
+  Note that such pages are counted as idle_dirty_swap regardless of whether
+  swap is enabled or not on the system.
+* idle_2_clean, idle_2_dirty_file, idle_2_dirty_swap: same definitions as
+  above, but for pages that have been untouched for at least two scan cycles.
+* these fields repeat up to idle_240_clean, idle_240_dirty_file and
+  idle_240_dirty_swap, allowing one to observe idle pages over a variety
+  of idle interval lengths. Note that the accounting is cumulative:
+  pages counted as idle for a given interval length are also counted
+  as idle for smaller interval lengths.
+* scans: number of physical memory scans since the cgroup was created.
+
+All the above fields are updated exactly once per scan.
+
+11.2 Responsiveness guarantees
+
+After a user page stops being touched and/or pinned, it takes at least one
+scan cycle for that page to be considered as idle and accounted as such
+in one of the idle_clean / idle_dirty_file / idle_dirty_swap counts
+(or, n scan cycles for the page to be accounted as idle in one of the
+idle_N_clean / idle_N_dirty_file / idle_N_dirty_swap counts).
+
+However, there is no guarantee that pages will be detected that fast.
+In the worst case, it could take up to two extra scan cycle intervals
+for a page to be accounted as idle. This is because after userspace stops
+touching the page, it may take up to one scan interval before we next
+scan it (at which point the page will be seen as not idle yet since it
+was touched during the previous scan) and after the page is finally scanned
+again and detected as idle, it may take up to one extra scan interval before
+completing the physical memory scan and exporting the updated statistics.
+
+Conversely, when userspace touches or pins a page that was previously
+accounted for as idle, it may take up to two scan intervals before the
+corresponding statistics are updated. Once again, this is because it may
+take up to one scan interval before scanning the page and finding it not
+idle anymore, and up to one extra scan interval before completing the
+physical memory scan and exporting the updated statistics.
+
+11.3 Incremental idle page tracking
+
+In some situations, it is desired to obtain faster feedback when
+previously idle, clean user pages start being touched. Remember that
+unpinned clean pages are immediately reclaimable by the MM's LRU
+algorithms. A high number of such pages being idle in a given cgroup
+indicates that this cgroup is not experiencing high memory pressure.
+A decrease of that number can be seen as a leading indicator that
+memory pressure is about to increase, and it may be desired to act
+upon that indication before the two scan interval measurement delay.
+
+The incremental idle page tracking feature can be used for that case.
+It allows for tracking of idle clean pages only, and only for a
+predetermined number of scan intervals (no histogram functionality as
+in the main interface).
+
+The desired idle period must first be selected on a per-cgroup basis
+by writing an integer to the memory.stale_page_age file. The integer
+is the interval we want pages to be idle for, expressed in scan cycles.
+For example to check for pages that have been idle for 5 consecutive
+scan cycles (equivalent to the idle_5_clean statistic), one would
+write 5 to the memory.stale_page_age file. The default value for the
+memory.stale_page_age file is 0, which disables the incremental idle
+page tracking feature.
+
+During scanning, clean unpinned pages that have not been touched for the
+chosen number of scan cycles are incrementally accounted for and reflected
+in the "stale" statistic in memory.idle_page_stats. Likewise, pages that
+were previously accounted as stale and are found not to be idle anymore
+are also incrementally accounted for. Additionally, any pages that are
+being considered by the LRU replacement algorithm and found to have been
+touched are also incrementally accounted for.
+
+
+12. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
diff --git a/mm/Kconfig b/mm/Kconfig
index 8ca47a5..f6443a0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -370,3 +370,13 @@ config CLEANCACHE
 	  in a negligible performance hit.
 
 	  If unsure, say Y to enable cleancache
+
+config KSTALED
+       depends on CGROUP_MEM_RES_CTLR && 64BIT
+       bool "Per-cgroup idle page tracking"
+       help
+         This feature allows the kernel to report the amount of user pages
+	 in a cgroup that have not been touched in a given time.
+	 This information may be used to size the cgroups and/or for
+	 job placement within a compute cluster.
+	 See Documentation/cgroups/memory.txt for a more complete description.
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
