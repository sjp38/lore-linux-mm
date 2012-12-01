Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A9E3D6B004D
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 07:26:55 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so979387eek.14
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 04:26:54 -0800 (PST)
Date: Sat, 1 Dec 2012 13:26:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [RFC PATCH] mm/migration: Remove anon vma locking from
 try_to_unmap() use
Message-ID: <20121201122649.GA20322@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121201094927.GA12366@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> 1)
> 
> This patch might solve the remapping 
> (remove_migration_ptes()), but does not solve the anon-vma 
> locking done in the first, unmapping step of pte-migration - 
> which is done via try_to_unmap(): which is a generic VM 
> function used by swapout too, so callers do not necessarily 
> hold the mmap_sem.
> 
> A new TTU flag might solve it although I detest flag-driven 
> locking semantics with a passion:
> 
> Splitting out unlocked versions of try_to_unmap_anon(), 
> try_to_unmap_ksm(), try_to_unmap_file() and constructing an 
> unlocked try_to_unmap() out of them, to be used by the 
> migration code, would be the cleaner option.

So as a quick concept hack I wrote the patch attached below. 
(It's not signed off, see the patch description text for the 
reason.)

With this applied I get the same good 4x JVM performance:

     spec1.txt:           throughput =     157471.10 SPECjbb2005 bops 
     spec2.txt:           throughput =     157817.09 SPECjbb2005 bops 
     spec3.txt:           throughput =     157581.79 SPECjbb2005 bops 
     spec4.txt:           throughput =     157890.26 SPECjbb2005 bops 
                                           --------------------------
           SUM:           throughput =     630760.24 SPECjbb2005 bops

... because the JVM workload did not trigger the migration 
scalability threshold to begin with.

Mainline 4xJVM SPECjbb performance:

     spec1.txt:           throughput =     128575.47 SPECjbb2005 bops
     spec2.txt:           throughput =     125767.24 SPECjbb2005 bops
     spec3.txt:           throughput =     130042.30 SPECjbb2005 bops
     spec4.txt:           throughput =     128155.32 SPECjbb2005 bops
                                       --------------------------
           SUM:           throughput =     512540.33 SPECjbb2005 bops

     # (32 CPUs, 4 instances, 8 warehouses each, 240 seconds runtime, !THP)

But !THP/4K numa02 performance went trough the roof!

Mainline !THP numa02 performance:

         40.918 secs runtime/thread
         26.051 secs fastest (min) thread time
         59.229 secs elapsed (max) thread time [ spread: -28.0% ]
         26.844 GB data processed, per thread
        858.993 GB data processed, total
          2.206 nsecs/byte/thread
          0.453 GB/sec/thread
         14.503 GB/sec total

numa/core v18 + migration-locking-enhancements, !THP:

         18.543 secs runtime/thread
         17.721 secs fastest (min) thread time
         19.262 secs elapsed (max) thread time [ spread: -4.0% ]
         26.844 GB data processed, per thread
        858.993 GB data processed, total
          0.718 nsecs/byte/thread
          1.394 GB/sec/thread
         44.595 GB/sec total

as you can see the performance of each of the 32 threads is 
within a tight bound:

         17.721 secs fastest (min) thread time
         19.262 secs elapsed (max) thread time [ spread: -4.0% ]

... with very little spread between them.

So this is roughly as good as it can get without hard binding - 
and according to my limited testing the numa02 workload is 
20-30% faster than the AutoNUMA or balancenuma kernels on the 
same hardware/kernel combo. The above numa02 result now also 
gets reasonably close to the numa/core +THP numa02 numbers (to 
within 10%).

As expected there's a lot of TLB flushing going on, but, and 
this was unexpected to me, even maximally pushing the migration 
code does not trigger anything pathological on this 4-node 
system - so while the TLB optimization will be a welcome 
enhancement, it's not a must-have at this stage.

I'll do a cleaner version of this patch and I'll test on a 
larger system with a large NUMA factor too to make sure we don't 
need the TLB optimization on !THP.

So I think (assuming that I have not overlooked something 
critical in these patches!), with these two fixes all the 
difficult known regressions in numa/core are fixed.

I'll do more testing with broader workloads and on more systems 
to ascertain this.

Thanks,

	Ingo

---------------->
Subject: mm/migration: Remove anon vma locking from try_to_unmap() use
From: Ingo Molnar <mingo@kernel.org>
Date: Sat Dec 1 11:22:09 CET 2012

As outlined in:

    mm/migration: Don't lock anon vmas in rmap_walk_anon()

the process-global anon vma mutex locking of the page migration
code can be very expensive.

This removes the second (and last) use of that mutex from the
migration code: try_to_unmap().

Since try_to_unmap() is used by swapout and filesystem code
as well, which does not hold the mmap_sem, we only want to
do this optimization from the migration path.

This patch is ugly and should be replaced via a
try_to_unmap_locked() variant instead which offers us the
unlocked codepath, but it's good enough for testing purposes.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>
Not-Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/rmap.h |    2 +-
 mm/huge_memory.c     |    2 +-
 mm/memory-failure.c  |    2 +-
 mm/rmap.c            |   13 ++++++++++---
 4 files changed, 13 insertions(+), 6 deletions(-)

Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -220,7 +220,7 @@ int try_to_munlock(struct page *);
 /*
  * Called by memory-failure.c to kill processes.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page);
+struct anon_vma *page_lock_anon_vma(struct page *page, enum ttu_flags flags);
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
 int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c
+++ linux/mm/huge_memory.c
@@ -1645,7 +1645,7 @@ int split_huge_page(struct page *page)
 	int ret = 1;
 
 	BUG_ON(!PageAnon(page));
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 0);
 	if (!anon_vma)
 		goto out;
 	ret = 0;
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -402,7 +402,7 @@ static void collect_procs_anon(struct pa
 	struct anon_vma *av;
 	pgoff_t pgoff;
 
-	av = page_lock_anon_vma(page);
+	av = page_lock_anon_vma(page, 0);
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -442,7 +442,7 @@ out:
  * atomic op -- the trylock. If we fail the trylock, we fall back to getting a
  * reference like with page_get_anon_vma() and then block on the mutex.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page, enum ttu_flags flags)
 {
 	struct anon_vma *anon_vma = NULL;
 	struct anon_vma *root_anon_vma;
@@ -456,6 +456,13 @@ struct anon_vma *page_lock_anon_vma(stru
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
+	/*
+	 * The migration code paths are already holding the mmap_sem,
+	 * so the anon vma cannot go away from under us - return it:
+	 */
+	if (flags & TTU_MIGRATION)
+		goto out;
+
 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
 	if (mutex_trylock(&root_anon_vma->mutex)) {
 		/*
@@ -732,7 +739,7 @@ static int page_referenced_anon(struct p
 	struct anon_vma_chain *avc;
 	int referenced = 0;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, 0);
 	if (!anon_vma)
 		return referenced;
 
@@ -1474,7 +1481,7 @@ static int try_to_unmap_anon(struct page
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = page_lock_anon_vma(page);
+	anon_vma = page_lock_anon_vma(page, flags);
 	if (!anon_vma)
 		return ret;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
