From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 3/3] mmu_notifier: invalidate_page callbacks
Date: Wed, 30 Jan 2008 20:57:53 -0800
Message-ID: <20080131045813.016961450@sgi.com>
References: <20080131045750.855008281@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=mmu_invalidate_page_rmap_callbacks
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

Callbacks to remove individual pages as done in rmap code

3 types of callbacks are used:

1. invalidate_page mmu_notifier
	Called from the inner loop of rmap walks to invalidate
	pages.

2. invalidate_page mmu_rmap_notifier
	Called after the Linux rmap loop under PageLock to allow
	a device to scan its own rmaps and remove mappings.

3. mmu_notifier_age_page
	Called for the determination of the page referenced
	status.

The callbacks occur after the Linux rmaps have been walked. A device
driver does not have to support type 1 and 2 callbacks. One is sufficient.
If we do not care about page referenced status then callback #3 can also
be omitted.

Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>

---
 mm/rmap.c |   22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-01-30 20:03:03.000000000 -0800
+++ linux-2.6/mm/rmap.c	2008-01-30 20:17:22.000000000 -0800
@@ -49,6 +49,7 @@
 #include <linux/rcupdate.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -284,7 +285,8 @@ static int page_referenced_one(struct pa
 	if (!pte)
 		goto out;
 
-	if (ptep_clear_flush_young(vma, address, pte))
+	if (ptep_clear_flush_young(vma, address, pte) |
+	    mmu_notifier_age_page(mm, address))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -434,6 +436,7 @@ static int page_mkclean_one(struct page 
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		entry = ptep_clear_flush(vma, address, pte);
+		mmu_notifier(invalidate_page, mm, address);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -473,6 +476,10 @@ int page_mkclean(struct page *page)
 		struct address_space *mapping = page_mapping(page);
 		if (mapping) {
 			ret = page_mkclean_file(mapping, page);
+			if (unlikely(PageExternalRmap(page))) {
+				mmu_rmap_notifier(invalidate_page, page);
+				ClearPageExternalRmap(page);
+			}
 			if (page_test_dirty(page)) {
 				page_clear_dirty(page);
 				ret = 1;
@@ -677,7 +684,8 @@ static int try_to_unmap_one(struct page 
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
+			(ptep_clear_flush_young(vma, address, pte) |
+				mmu_notifier_age_page(mm, address)))) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
@@ -685,6 +693,7 @@ static int try_to_unmap_one(struct page 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
 	pteval = ptep_clear_flush(vma, address, pte);
+	mmu_notifier(invalidate_page, mm, address);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -809,12 +818,14 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young(vma, address, pte))
+		if (ptep_clear_flush_young(vma, address, pte) |
+		    mmu_notifier_age_page(mm, address))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
 		pteval = ptep_clear_flush(vma, address, pte);
+		mmu_notifier(invalidate_page, mm, address);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -971,6 +982,11 @@ int try_to_unmap(struct page *page, int 
 	else
 		ret = try_to_unmap_file(page, migration);
 
+	if (unlikely(PageExternalRmap(page))) {
+		mmu_rmap_notifier(invalidate_page, page);
+		ClearPageExternalRmap(page);
+	}
+
 	if (!page_mapped(page))
 		ret = SWAP_SUCCESS;
 	return ret;

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
