Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B3D7E6B0259
	for <linux-mm@kvack.org>; Sat,  9 Nov 2013 09:37:26 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so3335023pdj.5
        for <linux-mm@kvack.org>; Sat, 09 Nov 2013 06:37:26 -0800 (PST)
Received: from psmtp.com ([74.125.245.205])
        by mx.google.com with SMTP id sg3si10122102pbb.253.2013.11.09.06.37.23
        for <linux-mm@kvack.org>;
        Sat, 09 Nov 2013 06:37:24 -0800 (PST)
Date: Sat, 9 Nov 2013 14:37:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Return the number of base pages altered by
 protection changes
Message-ID: <20131109143718.GC5040@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 0255d491 (mm: Account for a THP NUMA hinting update as one PTE
update) was added to account for the number of PTE updates when marking
pages prot_numa. task_numa_work was using the old return value to track
how much address space had been updated. Altering the return value causes
the scanner to do more work than it is configured or documented to in a
single unit of work.

This patch reverts 0255d491 and accounts for the number of THP updates
separately in vmstat. It is up to the administrator to interpret the pair
of values correctly. This is a straight-forward operation and likely to
only be of interest when actively debugging NUMA balancing problems.

The impact of this patch is that the NUMA PTE scanner will scan slower when
THP is enabled and workloads may converge slower as a result. On the flip
size system CPU usage should be lower than recent tests reported. This is
an illustrative example of a short single JVM specjbb test

specjbb
                       3.12.0                3.12.0
                      vanilla      acctupdates
TPut 1      26143.00 (  0.00%)     25747.00 ( -1.51%)
TPut 7     185257.00 (  0.00%)    183202.00 ( -1.11%)
TPut 13    329760.00 (  0.00%)    346577.00 (  5.10%)
TPut 19    442502.00 (  0.00%)    460146.00 (  3.99%)
TPut 25    540634.00 (  0.00%)    549053.00 (  1.56%)
TPut 31    512098.00 (  0.00%)    519611.00 (  1.47%)
TPut 37    461276.00 (  0.00%)    474973.00 (  2.97%)
TPut 43    403089.00 (  0.00%)    414172.00 (  2.75%)

              3.12.0      3.12.0
             vanillaacctupdates
User         5169.64     5184.14
System        100.45       80.02
Elapsed       252.75      251.85

Performance is similar but note the reduction in system CPU time. While
this showed a performance gain, it will not be universal but at least
it'll be behaving as documented. The vmstats are obviously different but
here is an obvious interpretation of them from mmtests.

                                3.12.0      3.12.0
                               vanillaacctupdates
NUMA page range updates        1408326    11043064
NUMA huge PMD updates                0       21040
NUMA PTE updates               1408326      291624

"NUMA page range updates" == nr_pte_updates and is the value returned to
the NUMA pte scanner. NUMA huge PMD updates were the number of THP updates
which in combination can be used to calculate how many ptes were updated
from userspace.

Reported-by: Alex Thorlton <athorlton@sgi.com>
Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h | 1 +
 mm/mprotect.c                 | 6 +++++-
 mm/vmstat.c                   | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 1855f0a..c557c6d 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -39,6 +39,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
+		NUMA_HUGE_PTE_UPDATES,
 		NUMA_HINT_FAULTS,
 		NUMA_HINT_FAULTS_LOCAL,
 		NUMA_PAGE_MIGRATE,
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 412ba2b..f94d2bd 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -138,6 +138,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	pmd_t *pmd;
 	unsigned long next;
 	unsigned long pages = 0;
+	unsigned long nr_huge_updates = 0;
 	bool all_same_node;
 
 	pmd = pmd_offset(pud, addr);
@@ -148,7 +149,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				split_huge_page_pmd(vma, addr, pmd);
 			else if (change_huge_pmd(vma, pmd, addr, newprot,
 						 prot_numa)) {
-				pages++;
+				pages += HPAGE_PMD_NR;
+				nr_huge_updates++;
 				continue;
 			}
 			/* fall through */
@@ -168,6 +170,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
+	if (nr_huge_updates)
+		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
 	return pages;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9bb3145..5a442a7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -812,6 +812,7 @@ const char * const vmstat_text[] = {
 
 #ifdef CONFIG_NUMA_BALANCING
 	"numa_pte_updates",
+	"numa_huge_pte_updates",
 	"numa_hint_faults",
 	"numa_hint_faults_local",
 	"numa_pages_migrated",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
