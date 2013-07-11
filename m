Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 270E66B0033
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:47:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/16] mm: numa: Document automatic NUMA balancing sysctls
Date: Thu, 11 Jul 2013 10:46:45 +0100
Message-Id: <1373536020-2799-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1373536020-2799-1-git-send-email-mgorman@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt | 66 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index ccd4258..0fe678c 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -354,6 +354,72 @@ utilize.
 
 ==============================================================
 
+numa_balancing
+
+Enables/disables automatic page fault based NUMA memory
+balancing. Memory is moved automatically to nodes
+that access it often.
+
+Enables/disables automatic NUMA memory balancing. On NUMA machines, there
+is a performance penalty if remote memory is accessed by a CPU. When this
+feature is enabled the kernel samples what task thread is accessing memory
+by periodically unmapping pages and later trapping a page fault. At the
+time of the page fault, it is determined if the data being accessed should
+be migrated to a local memory node.
+
+The unmapping of pages and trapping faults incur additional overhead that
+ideally is offset by improved memory locality but there is no universal
+guarantee. If the target workload is already bound to NUMA nodes then this
+feature should be disabled. Otherwise, if the system overhead from the
+feature is too high then the rate the kernel samples for NUMA hinting
+faults may be controlled by the numa_balancing_scan_period_min_ms,
+numa_balancing_scan_delay_ms, numa_balancing_scan_period_reset,
+numa_balancing_scan_period_max_ms and numa_balancing_scan_size_mb sysctls.
+
+==============================================================
+
+numa_balancing_scan_period_min_ms, numa_balancing_scan_delay_ms,
+numa_balancing_scan_period_max_ms, numa_balancing_scan_period_reset,
+numa_balancing_scan_size_mb
+
+Automatic NUMA balancing scans tasks address space and unmaps pages to
+detect if pages are properly placed or if the data should be migrated to a
+memory node local to where the task is running.  Every "scan delay" the task
+scans the next "scan size" number of pages in its address space. When the
+end of the address space is reached the scanner restarts from the beginning.
+
+In combination, the "scan delay" and "scan size" determine the scan rate.
+When "scan delay" decreases, the scan rate increases.  The scan delay and
+hence the scan rate of every task is adaptive and depends on historical
+behaviour. If pages are properly placed then the scan delay increases,
+otherwise the scan delay decreases.  The "scan size" is not adaptive but
+the higher the "scan size", the higher the scan rate.
+
+Higher scan rates incur higher system overhead as page faults must be
+trapped and potentially data must be migrated. However, the higher the scan
+rate, the more quickly a tasks memory is migrated to a local node if the
+workload pattern changes and minimises performance impact due to remote
+memory accesses. These sysctls control the thresholds for scan delays and
+the number of pages scanned.
+
+numa_balancing_scan_period_min_ms is the minimum delay in milliseconds
+between scans. It effectively controls the maximum scanning rate for
+each task.
+
+numa_balancing_scan_delay_ms is the starting "scan delay" used for a task
+when it initially forks.
+
+numa_balancing_scan_period_max_ms is the maximum delay between scans. It
+effectively controls the minimum scanning rate for each task.
+
+numa_balancing_scan_size_mb is how many megabytes worth of pages are
+scanned for a given scan.
+
+numa_balancing_scan_period_reset is a blunt instrument that controls how
+often a tasks scan delay is reset to detect sudden changes in task behaviour.
+
+==============================================================
+
 osrelease, ostype & version:
 
 # cat osrelease
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
