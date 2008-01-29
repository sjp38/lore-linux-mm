Date: Tue, 29 Jan 2008 15:24:52 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 4/6] MMU notifier: invalidate_page callbacks using
	Linux rmaps
Message-ID: <20080129142452.GH7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202924.334342410@sgi.com> <20080129140345.GG7233@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080129140345.GG7233@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This should fix the aging bugs you introduced through the faulty cpp
expansion. This is hard to write for me, given any time somebody does
a ptep_clear_flush_young w/o manually cpp-expandin "|
mmu_notifier_age_page" after it, it's always a bug that needs fixing,
similar bugs can emerge with time for ptep_clear_flush too. What will
happen is that somebody will cleanup in 26+ and we'll remain with a
#ifdef KERNEL_VERSION() < 2.6.26 in ksm.c to call
mmu_notifier(invalidate_page) explicitly. Performance and
optimizations or unnecessary invalidate_page are a red-herring, it can
be fully optimized both ways. 99% of the time when somebody calls
ptep_clear_flush and ptep_clear_flush_young, the respective mmu
notifier can't be forgotten (and calling them once more even if a
later invalidate_range is invoked, is always safer and preferable than
not calling them at all) so I fail to see how this will not be cleaned
up eventually, the same way the tlb flushes have been cleaned up
already. Nevertheless I back your implementation and I'm not even
trying at changing it with the risk to slowdown merging.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -285,10 +285,8 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
-	if (ptep_clear_flush_young(vma, address, pte))
-		referenced++;
-
-	if (mmu_notifier_age_page(mm, address))
+	if (ptep_clear_flush_young(vma, address, pte) |
+	    mmu_notifier_age_page(mm, address))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -684,7 +682,7 @@ static int try_to_unmap_one(struct page 
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte) ||
+			(ptep_clear_flush_young(vma, address, pte) |
 				mmu_notifier_age_page(mm, address)))) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
@@ -818,10 +816,8 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young(vma, address, pte))
-			continue;
-
-		if (mmu_notifier_age_page(mm, address))
+		if (ptep_clear_flush_young(vma, address, pte) | 
+		    mmu_notifier_age_page(mm, address))
 			continue;
 
 		/* Nuke the page table entry. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
