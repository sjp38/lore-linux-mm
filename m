Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 096FB900015
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 10:21:06 -0500 (EST)
Received: by widex7 with SMTP id ex7so9285425wid.3
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 07:21:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s16si9583924wiv.17.2015.03.07.07.20.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Mar 2015 07:21:00 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
Date: Sat,  7 Mar 2015 15:20:51 +0000
Message-Id: <1425741651-29152-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1425741651-29152-1-git-send-email-mgorman@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

Dave Chinner reported the following on https://lkml.org/lkml/2015/3/1/226

Across the board the 4.0-rc1 numbers are much slower, and the degradation
is far worse when using the large memory footprint configs. Perf points
straight at the cause - this is from 4.0-rc1 on the "-o bhash=101073" config:

   -   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
      - default_send_IPI_mask_sequence_phys
         - 99.99% physflat_send_IPI_mask
            - 99.37% native_send_call_func_ipi
                 smp_call_function_many
               - native_flush_tlb_others
                  - 99.85% flush_tlb_page
                       ptep_clear_flush
                       try_to_unmap_one
                       rmap_walk
                       try_to_unmap
                       migrate_pages
                       migrate_misplaced_page
                     - handle_mm_fault
                        - 99.73% __do_page_fault
                             trace_do_page_fault
                             do_async_page_fault
                           + async_page_fault
              0.63% native_send_call_func_single_ipi
                 generic_exec_single
                 smp_call_function_single

This is showing excessive migration activity even though excessive migrations
are meant to get throttled. Normally, the scan rate is tuned on a per-task
basis depending on the locality of faults.  However, if migrations fail
for any reason then the PTE scanner may scan faster if the faults continue
to be remote. This means there is higher system CPU overhead and fault
trapping at exactly the time we know that migrations cannot happen. This
patch tracks when migration failures occur and slows the PTE scanner.

This was tested on a 4 socket bare-metal machine with 48 cores. The results
compare 4.0-rc1, the patches applied and 3.19-vanilla which was the last
known good kernel. This is the standard autonuma benchmark

                                           4.0.0-rc1             4.0.0-rc1                3.19.0
                                             vanilla           slowscan-v2               vanilla
Time System-NUMA01                  602.44 (  0.00%)      209.42 ( 65.24%)      194.70 ( 67.68%)
Time System-NUMA01_THEADLOCAL        78.10 (  0.00%)       92.70 (-18.69%)       98.52 (-26.15%)
Time System-NUMA02                    6.47 (  0.00%)        6.06 (  6.34%)        9.28 (-43.43%)
Time System-NUMA02_SMT                5.06 (  0.00%)        3.39 ( 33.00%)        3.79 ( 25.10%)
Time Elapsed-NUMA01                 755.96 (  0.00%)      833.63 (-10.27%)      558.84 ( 26.08%)
Time Elapsed-NUMA01_THEADLOCAL      382.22 (  0.00%)      395.45 ( -3.46%)      382.54 ( -0.08%)
Time Elapsed-NUMA02                  49.38 (  0.00%)       50.21 ( -1.68%)       49.83 ( -0.91%)
Time Elapsed-NUMA02_SMT              47.70 (  0.00%)       48.55 ( -1.78%)       46.59 (  2.33%)

There is a performance drop as a result of this patch although in the
case of NUMA01 it is not a major concern as it's an adverse workload. The
important point is that in most cases system CPU usage is much lower. Here
are the totals

           4.0.0-rc1   4.0.0-rc1      3.19.0
             vanilla  slowscan-v2     vanilla
User        53384.29    56093.11    46119.12
System        692.14      311.64      306.41
Elapsed      1236.87     1328.61     1039.88

Note that the system CPU usage is now similar to 3.19-vanilla.

I also tested with a workload very similar to Dave's. The machine
configuration and storage is completely different so it's not an equivalent
test unfortunately. It's reporting the elapsed time and CPU time while
fsmark is running to create the inodes and when runnig xfsrepair afterwards

xfsrepair
                                    4.0.0-rc1             4.0.0-rc1                3.19.0
                                      vanilla           slowscan-v2               vanilla
Min      real-fsmark        1157.41 (  0.00%)     1150.38 (  0.61%)     1164.44 ( -0.61%)
Min      syst-fsmark        3998.06 (  0.00%)     3988.42 (  0.24%)     4016.12 ( -0.45%)
Min      real-xfsrepair      497.64 (  0.00%)      456.87 (  8.19%)      442.64 ( 11.05%)
Min      syst-xfsrepair      500.61 (  0.00%)      263.41 ( 47.38%)      194.97 ( 61.05%)
Amean    real-fsmark        1166.63 (  0.00%)     1155.97 (  0.91%)     1166.28 (  0.03%)
Amean    syst-fsmark        4020.94 (  0.00%)     4004.19 (  0.42%)     4025.87 ( -0.12%)
Amean    real-xfsrepair      507.85 (  0.00%)      459.58 (  9.50%)      447.66 ( 11.85%)
Amean    syst-xfsrepair      519.88 (  0.00%)      281.63 ( 45.83%)      202.93 ( 60.97%)
Stddev   real-fsmark           6.55 (  0.00%)        3.97 ( 39.30%)        1.44 ( 77.98%)
Stddev   syst-fsmark          16.22 (  0.00%)       15.09 (  6.96%)        9.76 ( 39.86%)
Stddev   real-xfsrepair       11.17 (  0.00%)        3.41 ( 69.43%)        5.57 ( 50.17%)
Stddev   syst-xfsrepair       13.98 (  0.00%)       19.94 (-42.60%)        5.69 ( 59.31%)
CoeffVar real-fsmark           0.56 (  0.00%)        0.34 ( 38.74%)        0.12 ( 77.97%)
CoeffVar syst-fsmark           0.40 (  0.00%)        0.38 (  6.57%)        0.24 ( 39.93%)
CoeffVar real-xfsrepair        2.20 (  0.00%)        0.74 ( 66.22%)        1.24 ( 43.47%)
CoeffVar syst-xfsrepair        2.69 (  0.00%)        7.08 (-163.23%)        2.80 ( -4.23%)
Max      real-fsmark        1171.98 (  0.00%)     1159.25 (  1.09%)     1167.96 (  0.34%)
Max      syst-fsmark        4033.84 (  0.00%)     4024.53 (  0.23%)     4039.20 ( -0.13%)
Max      real-xfsrepair      523.40 (  0.00%)      464.40 ( 11.27%)      455.42 ( 12.99%)
Max      syst-xfsrepair      533.37 (  0.00%)      309.38 ( 42.00%)      207.94 ( 61.01%)

The key point is that system CPU usage for xfsrepair (syst-xfsrepair)
is almost cut in half. It's still not as low as 3.19-vanilla but it's
much closer

                             4.0.0-rc1   4.0.0-rc1      3.19.0
                               vanilla  slowscan-v2     vanilla
NUMA alloc hit               146138883   121929782   104019526
NUMA alloc miss               13146328    11456356     7806370
NUMA interleave hit                  0           0           0
NUMA alloc local             146060848   121865921   103953085
NUMA base PTE updates        242201535   117237258   216624143
NUMA huge PMD updates           113270       52121      127782
NUMA page range updates      300195775   143923210   282048527
NUMA hint faults             180388025    87299060   147235021
NUMA hint local faults        72784532    32939258    61866265
NUMA hint local percent             40          37          42
NUMA pages migrated           71175262    41395302    23237799

Note the big differences in faults trapped and pages migrated. 3.19-vanilla
still migrated fewer pages but if necessary the threshold at which we
start throttling migrations can be lowered.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h | 9 +++++----
 kernel/sched/fair.c   | 8 ++++++--
 mm/huge_memory.c      | 3 ++-
 mm/memory.c           | 3 ++-
 4 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d77432e14ff..a419b65770d6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1625,11 +1625,11 @@ struct task_struct {
 
 	/*
 	 * numa_faults_locality tracks if faults recorded during the last
-	 * scan window were remote/local. The task scan period is adapted
-	 * based on the locality of the faults with different weights
-	 * depending on whether they were shared or private faults
+	 * scan window were remote/local or failed to migrate. The task scan
+	 * period is adapted based on the locality of the faults with different
+	 * weights depending on whether they were shared or private faults
 	 */
-	unsigned long numa_faults_locality[2];
+	unsigned long numa_faults_locality[3];
 
 	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
@@ -1719,6 +1719,7 @@ struct task_struct {
 #define TNF_NO_GROUP	0x02
 #define TNF_SHARED	0x04
 #define TNF_FAULT_LOCAL	0x08
+#define TNF_MIGRATE_FAIL 0x10
 
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, int flags);
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7ce18f3c097a..bcfe32088b37 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1609,9 +1609,11 @@ static void update_task_scan_period(struct task_struct *p,
 	/*
 	 * If there were no record hinting faults then either the task is
 	 * completely idle or all activity is areas that are not of interest
-	 * to automatic numa balancing. Scan slower
+	 * to automatic numa balancing. Related to that, if there were failed
+	 * migration then it implies we are migrating too quickly or the local
+	 * node is overloaded. In either case, scan slower
 	 */
-	if (local + shared == 0) {
+	if (local + shared == 0 || p->numa_faults_locality[2]) {
 		p->numa_scan_period = min(p->numa_scan_period_max,
 			p->numa_scan_period << 1);
 
@@ -2080,6 +2082,8 @@ void task_numa_fault(int last_cpupid, int mem_node, int pages, int flags)
 
 	if (migrated)
 		p->numa_pages_migrated += pages;
+	if (flags & TNF_MIGRATE_FAIL)
+		p->numa_faults_locality[2] += pages;
 
 	p->numa_faults[task_faults_idx(NUMA_MEMBUF, mem_node, priv)] += pages;
 	p->numa_faults[task_faults_idx(NUMA_CPUBUF, cpu_node, priv)] += pages;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ae13ad31e113..f508fda07d34 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1353,7 +1353,8 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (migrated) {
 		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
-	}
+	} else
+		flags |= TNF_MIGRATE_FAIL;
 
 	goto out;
 clear_pmdnuma:
diff --git a/mm/memory.c b/mm/memory.c
index 8068893697bb..187daf695f88 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3097,7 +3097,8 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (migrated) {
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
-	}
+	} else
+		flags |= TNF_MIGRATE_FAIL;
 
 out:
 	if (page_nid != -1)
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
