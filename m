Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 3AF7F6B0069
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 20:02:09 -0500 (EST)
Date: Tue, 11 Dec 2012 01:02:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121211010201.GP1009@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210113945.GA7550@gmail.com>
 <20121210152405.GJ1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121210152405.GJ1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 10, 2012 at 03:24:05PM +0000, Mel Gorman wrote:
> For example, I think that point 5 above is the potential source of the
> corruption because. You're not flushing the TLBs for the PTEs you are
> updating in batch. Granted, you're relaxing rather than restricting access
> so it should be ok and at worse cause a spurious fault but I also find
> it suspicious that you do not recheck pte_same under the PTL when doing
> the final PTE update.

Looking again, the lack of a pte_same check should be ok. The addr,
addr_start, ptep and ptep_start is a little messy but also look fine.
You're not accidentally crossing a PMD boundary. You should be protected
against huge pages being collapsed underneath you as you hold mmap_sem for
read. If the first page in the pmd (or VMA) is not present then
target_nid == -1 which gets passed into __do_numa_page. This check

        if (target_nid == -1 || target_nid == page_nid)
                goto out;

then means you never actually migrate for that whole PMD and will just
clear the PTEs. Possibly wrong, but not what we're looking for. Holding
PTL across task_numa_fault is bad, but not the bad we're looking for.

/me scratches his head

Machine is still unavailable so in an attempt to rattle this out I prototyped
the equivalent patch for balancenuma and then went back to numacore to see
could I spot a major difference.  Comparing them, there is no guarantee you
clear pte_numa for the address that was originally faulted if there was a
racing fault that cleared it underneath you but in itself that should not
be an issue. Your use of ptep++ instead of pte_offset_map() might break
on 32-bit with NUMA support if PTE pages are stored in highmem. Still the
wrong wrong.

If the bug is indeed here, it's not obvious. I don't know why I'm
triggering it or why it only triggers for specjbb as I cannot imagine
what the JVM would be doing that is that weird or that would not have
triggered before. Maybe we both suffer this type of problem but that
numacores rate of migration is able to trigger it.

> Basically if I felt that handling ptes in batch like this was of
> critical important I would have implemented it very differently on top of
> balancenuma. I would have only taken the PTL lock if updating the PTE to
> keep contention down and redid racy checks under PTL, I'd have only used
> trylock for every non-faulted PTE and I would only have migrated if it
> was a remote->local copy. I certainly would not hold PTL while calling
> task_numa_fault(). I would have kept the handling ona per-pmd basis when
> it was expected that most PTEs underneath should be on the same node.
> 

This is prototype only but what I was using as a reference to see could
I spot a problem in yours. It has not been even boot tested but avoids
remote->remote copies, contending on PTL or holding it longer than necessary
(should anyway)

---8<---
mm: numa: Batch pte handling

diff --git a/mm/memory.c b/mm/memory.c
index 33e20b3..f871d5d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3461,30 +3461,14 @@ int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
+static
+int __do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd,
+		   spinlock_t *ptl, bool only_local, bool *migrated)
 {
 	struct page *page = NULL;
-	spinlock_t *ptl;
 	int current_nid = -1;
 	int target_nid;
-	bool migrated = false;
-
-	/*
-	* The "pte" at this point cannot be used safely without
-	* validation through pte_unmap_same(). It's of NUMA type but
-	* the pfn may be screwed if the read is non atomic.
-	*
-	* ptep_modify_prot_start is not called as this is clearing
-	* the _PAGE_NUMA bit and it is not really expected that there
-	* would be concurrent hardware modifications to the PTE.
-	*/
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (unlikely(!pte_same(*ptep, pte))) {
-		pte_unmap_unlock(ptep, ptl);
-		goto out;
-	}
 
 	pte = pte_mknonnuma(pte);
 	set_pte_at(mm, addr, ptep, pte);
@@ -3493,7 +3477,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = vm_normal_page(vma, addr, pte);
 	if (!page) {
 		pte_unmap_unlock(ptep, ptl);
-		return 0;
+		goto out;
 	}
 
 	current_nid = page_to_nid(page);
@@ -3509,15 +3493,88 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out;
 	}
 
+	/*
+	 * Only do remote-local copies when handling PTEs in batch. This does
+	 * mean we effectively lost the NUMA hinting fault if the workload
+	 * was not converged on a PMD boundary. This is bad but is it worse
+	 * can doing a remote->remote copy?
+	 */
+	if (only_local && target_nid != numa_node_id()) {
+		current_nid = -1;
+		put_page(page);
+		goto out;
+	}
+
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, target_nid);
-	if (migrated)
+	*migrated = migrate_misplaced_page(page, target_nid);
+	if (*migrated)
 		current_nid = target_nid;
 
 out:
+	return current_nid;
+}
+
+int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
+{
+	spinlock_t *ptl;
+	int current_nid = -1;
+	bool migrated = false;
+	unsigned long end_addr;
+
+	/*
+	* The "pte" at this point cannot be used safely without
+	* validation through pte_unmap_same(). It's of NUMA type but
+	* the pfn may be screwed if the read is non atomic.
+	*
+	* ptep_modify_prot_start is not called as this is clearing
+	* the _PAGE_NUMA bit and it is not really expected that there
+	* would be concurrent hardware modifications to the PTE.
+	*/
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*ptep, pte))) {
+		pte_unmap_unlock(ptep, ptl);
+		goto out;
+	}
+
+	current_nid = __do_numa_page(mm, vma, addr, pte, ptep, pmd, ptl, false, &migrated);
+
+	/* Batch handle all PTEs in this area. PTL is not held initially */
+	addr = max(addr & PMD_MASK, vma->vm_start);
+	end_addr = min((addr + PMD_SIZE) & PMD_MASK, vma->vm_end);
+	for (; addr < end_addr; addr += PAGE_SIZE) {
+		bool batch_migrated = false;
+		int batch_nid = -1;
+
+		ptep = pte_offset_map(pmd, addr);
+		pte = *ptep;
+		if (!pte_present(pte))
+			continue;
+		if (!pte_numa(pte))
+			continue;
+
+		if (!spin_trylock(ptl)) {
+			pte_unmap(ptep);
+			break;
+		}
+
+		/* Recheck PTE under lock */
+		if (!pte_same(*ptep, pte)) {
+			pte_unmap_unlock(ptep, ptl);
+			continue;
+		}
+
+		batch_nid = __do_numa_page(mm, vma, addr, pte, ptep, pmd, ptl, true, &batch_migrated);
+		if (batch_nid != -1)
+			task_numa_fault(current_nid, 1, batch_migrated);
+	}
+
+out:
 	if (current_nid != -1)
 		task_numa_fault(current_nid, 1, migrated);
 	return 0;
+
 }
 
 /* NUMA hinting page fault entry point for regular pmds */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
