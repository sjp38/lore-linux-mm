Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 60A1B6B019A
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 09:08:34 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so2248166pab.26
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 06:08:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.186])
        by mx.google.com with SMTP id mj9si7039610pab.103.2013.11.08.06.08.30
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 06:08:31 -0800 (PST)
Date: Fri, 8 Nov 2013 14:08:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131108140826.GA3957@suse.de>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
 <20131104200346.GA3066@sgi.com>
 <20131106131048.GC4877@suse.de>
 <20131107214838.GY3066@sgi.com>
 <20131108112054.GB5040@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131108112054.GB5040@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 08, 2013 at 11:20:54AM +0000, Mel Gorman wrote:
> > <SNIP>
> > 0255d491848032f6c601b6410c3b8ebded3a37b1 is the first bad commit
> > commit 0255d491848032f6c601b6410c3b8ebded3a37b1
> > Author: Mel Gorman <mgorman@suse.de>
> > Date:   Mon Oct 7 11:28:47 2013 +0100
> > 
> >     mm: Account for a THP NUMA hinting update as one PTE update
> > 
> >     A THP PMD update is accounted for as 512 pages updated in vmstat.  This is
> >     large difference when estimating the cost of automatic NUMA balancing and
> >     can be misleading when comparing results that had collapsed versus split
> >     THP. This patch addresses the accounting issue.
> > 
> >     Signed-off-by: Mel Gorman <mgorman@suse.de>
> >     Reviewed-by: Rik van Riel <riel@redhat.com>
> >     Cc: Andrea Arcangeli <aarcange@redhat.com>
> >     Cc: Johannes Weiner <hannes@cmpxchg.org>
> >     Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> >     Cc: <stable@kernel.org>
> >     Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> >     Link: http://lkml.kernel.org/r/1381141781-10992-10-git-send-email-mgorman@suse.de
> >     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> > 
> > :040000 040000 e5a44a1f0eea2f41d2cccbdf07eafee4e171b1e2 ef030a7c78ef346095ac991c3e3aa139498ed8e7 M      mm
> > 
> > I haven't had a chance yet to dig into the code for this commit to see
> > what might be causing the crashes, but I have confirmed that this is
> > where the new problem started (checked the commit before this, and we
> > don't get the crash, just segfaults like we were getting before). 
> 
> One consequence of this patch that it adjusts the speed that task_numa_work
> scans the virtual address space. This was an oversight that needs to be
> corrected. Can you test if the following patch on top of 3.12 brings you
> back to "just" segfaulting? It is compile-tested only because my own tests
> will not even be able to start with this patch for another 3-4 hours.
> 

This is a version that is less likely to stab reviewers in the eye. It
moves responsibility for interpreting stats to userspace but is a lot more
readable and maintainable.

---8<---
mm: numa: Return the number of base pages altered by protection changes

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

The impact of this patch is that the NUMA PTE scanner will scan more slowly
when THP is enabled. Workloads may converge slower as a result. On the
flip size system CPU usage should be lower than recent tests. This is an
illustrative example of a short single JVM specjbb test

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

Performance is roughly comparable but note the reduction in system CPU
time. While this showed a performance gain, it will not be universal but at
least it'll be behaving as documented. The vmstats are obviously different
but here is an obvious interpretation of them

                                3.12.0      3.12.0
                               vanillaacctupdates
NUMA page range updates        1408326    11043064
NUMA huge PMD updates                0       21040
NUMA PTE updates               1408326      291624

"NUMA page range updates" == nr_pte_updates and is the value returned to
the NUMA pte scanner. NUMA huge PMD updates were the number of THP updates
which in combination can be used to calculate how many ptes were updated
from userspace.

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
