Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 736BC6B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 05:43:37 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p2so9868232wre.19
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 02:43:37 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id y7si1250438edm.292.2018.03.26.02.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 02:43:35 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 7CDA61C1468
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:43:35 +0100 (IST)
Date: Mon, 26 Mar 2018 10:43:34 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] sched/numa: Avoid trapping faults and attempting migration
 of file-backed dirty pages
Message-ID: <20180326094334.zserdec62gwmmfqf@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

change_pte_range is called from task work context to mark PTEs for receiving
NUMA faulting hints. If the marked pages are dirty then migration may fail.
Some filesystems cannot migrate dirty pages without blocking so are skipped
in MIGRATE_ASYNC mode which just wastes CPU. Even when they can, it can
be a waste of cycles when the pages are shared forcing higher scan rates.
This patch avoids marking shared dirty pages for hinting faults but also
will skip a migration if the page was dirtied after the scanner updated
a clean page.

This is most noticable running the NASA Parallel Benchmark when backed by
btrfs, the default root filesystem for some distributions, but also noticable
when using XFS.

The following are results from a 4-socket machine running a 4.16-rc4 kernel
with some scheduler patches that are pending for the next merge window.

                      4.16.0-rc4             4.16.0-rc4
               schedtip-20180309          nodirty-v1
Time cg.D      459.07 (   0.00%)      444.21 (   3.24%)
Time ep.D       76.96 (   0.00%)       77.69 (  -0.95%)
Time is.D       25.55 (   0.00%)       27.85 (  -9.00%)
Time lu.D      601.58 (   0.00%)      596.87 (   0.78%)
Time mg.D      107.73 (   0.00%)      108.22 (  -0.45%)

is.D regresses slightly in terms of absolute time but note that that
particular load varies quite a bit from run to run. The more relevant
observation is the total system CPU usage.

          4.16.0-rc4  4.16.0-rc4
        schedtip-20180309 nodirty-v1
User        71471.91    70627.04
System      11078.96     8256.13
Elapsed       661.66      632.74

That is a substantial drop in system CPU usage and overall the workload
completes faster. The NUMA balancing statistics are also interesting

NUMA base PTE updates        111407972   139848884
NUMA huge PMD updates           206506      264869
NUMA page range updates      217139044   275461812
NUMA hint faults               4300924     3719784
NUMA hint local faults         3012539     3416618
NUMA hint local percent             70          91
NUMA pages migrated            1517487     1358420

While more PTEs are scanned due to changes in what faults are gathered,
it's clear that a far higher percentage of faults are local as the bulk
of the remote hits were dirty pages that, in this case with btrfs, had
no chance of migrating.

The following is a comparison when using XFS as that is a more realistic
filesystem choice for a data partition

                      4.16.0-rc4             4.16.0-rc4
               schedtip-20180309          nodirty-v1r47
Time cg.D      485.28 (   0.00%)      442.62 (   8.79%)
Time ep.D       77.68 (   0.00%)       77.54 (   0.18%)
Time is.D       26.44 (   0.00%)       24.79 (   6.24%)
Time lu.D      597.46 (   0.00%)      597.11 (   0.06%)
Time mg.D      142.65 (   0.00%)      105.83 (  25.81%)

That is a reasonable gain on two relatively long-lived workloads. While
not presented, there is also a substantial drop in system CPu usage and
the NUMA balancing stats show similar improvements in locality as btrfs did.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

diff --git a/mm/migrate.c b/mm/migrate.c
index 1e5525a25691..d26832f0723b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1955,6 +1955,13 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	    (vma->vm_flags & VM_EXEC))
 		goto out;
 
+	/*
+	 * Also do not migrate dirty pages as not all filesystems can move
+	 * dirty pages in MIGRATE_ASYNC mode which is a waste of cycles.
+	 */
+	if (page_is_file_cache(page) && PageDirty(page))
+		goto out;
+
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e3309fcf586b..3cfd095e2bb0 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -27,6 +27,7 @@
 #include <linux/pkeys.h>
 #include <linux/ksm.h>
 #include <linux/uaccess.h>
+#include <linux/mm_inline.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
@@ -89,6 +90,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				    page_mapcount(page) != 1)
 					continue;
 
+				/*
+				 * While migration can move some dirty pages,
+				 * it cannot move them all from MIGRATE_ASYNC
+				 * context.
+				 */
+				if (page_is_file_cache(page) && PageDirty(page))
+					continue;
+
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
