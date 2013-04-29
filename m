Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2F7186B0032
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 04:41:26 -0400 (EDT)
Date: Mon, 29 Apr 2013 09:41:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Add a sysctl for numa_balancing.
Message-ID: <20130429084113.GI2144@suse.de>
References: <1366847784-29386-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1366847784-29386-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Wed, Apr 24, 2013 at 04:56:24PM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> As discussed earlier, this adds a working sysctl to enable/disable
> automatic numa memory balancing at runtime.
> 
> This was possible earlier through debugfs, but only with special
> debugging options set. Also fix the boot message.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: Mel Gorman <mgorman@suse.de>

Would you like to merge the following patch with it to remove the TBD?

---8<---
mm: numa: Document remaining automatic NUMA balancing sysctls

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/kernel.txt | 62 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 57 insertions(+), 5 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 17a7004..4d56060 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -356,11 +356,63 @@ utilize.
 
 numa_balancing
 
-Enables/disables automatic page fault based NUMA memory
-balancing. Memory is moved automatically to nodes
-that access it often.
-
-TBD someone document the other numa_balancing tunables
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
 
 ==============================================================
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
