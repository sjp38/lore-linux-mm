Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E67326B0070
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:24:13 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so60737086wib.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:24:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xl8si11473866wib.36.2015.03.23.05.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 05:24:08 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm: numa: Slow PTE scan rate if migration failures occur
Date: Mon, 23 Mar 2015 12:24:03 +0000
Message-Id: <1427113443-20973-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1427113443-20973-1-git-send-email-mgorman@suse.de>
References: <1427113443-20973-1-git-send-email-mgorman@suse.de>
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
index 0a42d1521aa4..51b3e7c64622 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1350,7 +1350,8 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (migrated) {
 		flags |= TNF_MIGRATED;
 		page_nid = target_nid;
-	}
+	} else
+		flags |= TNF_MIGRATE_FAIL;
 
 	goto out;
 clear_pmdnuma:
diff --git a/mm/memory.c b/mm/memory.c
index d20e12da3a3c..97839f5c8c30 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3103,7 +3103,8 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
