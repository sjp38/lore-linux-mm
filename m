Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 663186B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 10:29:40 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so2922392bkc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 07:29:38 -0800 (PST)
Date: Tue, 20 Nov 2012 16:29:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] mm, numa: Turn 4K pte NUMA faults into effective hugepage
 ones
Message-ID: <20121120152933.GA17996@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121120071704.GA14199@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Mon, Nov 19, 2012 at 12:36 PM, Ingo Molnar <mingo@kernel.org> wrote:
> > >
> > > Hugepages is a must for most forms of NUMA/HPC. This alone
> > > questions the relevance of most of your prior numa/core testing
> > > results. I now have to strongly dispute your other conclusions
> > > as well.
> > 
> > Ingo, stop doing this kind of crap.
> > 
> > Let's make it clear: if the NUMA patches continue to regress 
> > performance for reasonable loads (and that very much includes 
> > "no THP") then they won't be merged.
> [...]
> 
> No doubt numa/core should not regress with THP off or on and 
> I'll fix that.

Once it was clear how Mel's workload was configured I could 
reproduce it immediately myself as well and the fix was easy and 
straightforward: the attached patch should do the trick.

(Lightly tested.)

Updated 32-warehouse SPECjbb test benchmarks on a 4x4 64 GB 
system:

         mainline:                 395 k/sec
         numa/core +patch:         512 k/sec     [ +29.6% ]

         mainline +THP:            524 k/sec
         numa/core +patch +THP:    654 k/sec     [ +24.8% ]

So here on my box the reported 32-warehouse SPECjbb regressions 
are fixed to the best of my knowledge, and numa/core is now a 
nice unconditional speedup over mainline.

CONFIG_NUMA_BALANCING=y brings roughly as much of a speedup to 
mainline as CONFIG_TRANSPARENT_HUGEPAGE=y itself - and the 
combination of the two features brings roughly a combination of 
speedups: +65%, which looks pretty impressive.

This fix had no impact on the good "+THP +NUMA" results that 
were reproducible with -v16 already.

Mel, David, could you give this patch too a whirl? It should 
improve !THP workloads.

( The 4x JVM regression is still an open bug I think - I'll
  re-check and fix that one next, no need to re-report it,
  I'm on it. )

Thanks,

	Ingo


----------------------------->
Subject: mm, numa: Turn 4K pte NUMA faults into effective hugepage ones
From: Ingo Molnar <mingo@kernel.org>
Date: Tue Nov 20 15:48:26 CET 2012

Reduce the 4K page fault count by looking around and processing
nearby pages if possible.

To keep the logic simple and straightforward we do a couple of 
simplifications:

 - we only scan in the HPAGE_SIZE range of the faulting address
 - we only go as far as the vma allows us

Also simplify the do_numa_page() flow while at it and fix the 
previous double faulting we incurred due to not properly fixing 
up freshly migrated ptes.

Suggested-by: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/memory.c |  101 +++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 66 insertions(+), 35 deletions(-)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c
+++ linux/mm/memory.c
@@ -3455,64 +3455,94 @@ static int do_nonlinear_fault(struct mm_
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int __do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, pmd_t *pmd,
-			unsigned int flags, pte_t entry)
+			unsigned int flags, pte_t entry, spinlock_t *ptl)
 {
-	struct page *page = NULL;
-	int node, page_nid = -1;
-	int last_cpu = -1;
-	spinlock_t *ptl;
-
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (unlikely(!pte_same(*ptep, entry)))
-		goto out_unlock;
+	struct page *page;
+	int new_node;
 
 	page = vm_normal_page(vma, address, entry);
 	if (page) {
-		get_page(page);
-		page_nid = page_to_nid(page);
-		last_cpu = page_last_cpu(page);
-		node = mpol_misplaced(page, vma, address);
-		if (node != -1 && node != page_nid)
+		int page_nid = page_to_nid(page);
+		int last_cpu = page_last_cpu(page);
+
+		new_node = mpol_misplaced(page, vma, address);
+		if (new_node != -1 && new_node != page_nid)
 			goto migrate;
+		task_numa_fault(page_nid, last_cpu, 1);
 	}
 
-out_pte_upgrade_unlock:
+out_pte_upgrade:
 	flush_cache_page(vma, address, pte_pfn(entry));
-
 	ptep_modify_prot_start(mm, address, ptep);
 	entry = pte_modify(entry, vma->vm_page_prot);
+	if (pte_dirty(entry))
+		entry = pte_mkwrite(entry);
 	ptep_modify_prot_commit(mm, address, ptep, entry);
-
 	/* No TLB flush needed because we upgraded the PTE */
-
 	update_mmu_cache(vma, address, ptep);
-
-out_unlock:
-	pte_unmap_unlock(ptep, ptl);
-
-	if (page) {
-		task_numa_fault(page_nid, last_cpu, 1);
-		put_page(page);
-	}
 out:
 	return 0;
 
 migrate:
+	get_page(page);
 	pte_unmap_unlock(ptep, ptl);
 
-	if (migrate_misplaced_page(page, node)) {
+	migrate_misplaced_page(page, new_node);
+
+	/* Re-check after migration: */
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+	entry = ACCESS_ONCE(*ptep);
+
+	if (!pte_numa(vma, entry))
 		goto out;
-	}
-	page = NULL;
 
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_same(*ptep, entry))
-		goto out_unlock;
+	page = vm_normal_page(vma, address, entry);
+	goto out_pte_upgrade;
+}
 
-	goto out_pte_upgrade_unlock;
+/*
+ * Add a simple loop to also fetch ptes within the same pmd:
+ */
+static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr0, pte_t *ptep0, pmd_t *pmd,
+			unsigned int flags, pte_t entry0)
+{
+	unsigned long addr0_pmd = addr0 & PMD_MASK;
+	unsigned long addr_start;
+	unsigned long addr;
+	spinlock_t *ptl;
+	int entries = 0;
+	pte_t *ptep;
+
+	addr_start = max(addr0_pmd, vma->vm_start);
+	ptep = pte_offset_map(pmd, addr_start);
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	for (addr = addr_start; addr < vma->vm_end; addr += PAGE_SIZE, ptep++) {
+ 		pte_t entry;
+
+		entry = ACCESS_ONCE(*ptep);
+
+		if ((addr & PMD_MASK) != addr0_pmd)
+			break;
+		if (!pte_present(entry))
+			continue;
+		if (!pte_numa(vma, entry))
+			continue;
+
+		__do_numa_page(mm, vma, addr, ptep, pmd, flags, entry, ptl);
+		entries++;
+	}
+
+	pte_unmap_unlock(ptep, ptl);
+	
+	return 0;
 }
 
 /*
@@ -3536,6 +3566,7 @@ int handle_pte_fault(struct mm_struct *m
 	spinlock_t *ptl;
 
 	entry = ACCESS_ONCE(*pte);
+
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
