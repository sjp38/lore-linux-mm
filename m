From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 2/4] mmu_notifier: Callbacks to invalidate
	address ranges
Date: Thu, 24 Jan 2008 21:56:08 -0800
Message-ID: <20080125055801.441867600@sgi.com>
References: <20080125055606.102986685@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=mmu_invalidate_range_callbacks
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
Cc: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
List-Id: linux-mm.kvack.org

The invalidation of address ranges in a mm_struct needs to be
performed when pages are removed or permissions etc change.

invalidate_range() is generally called with mmap_sem held but
no spinlocks are active.

Exceptions:

We hold i_mmap_lock in __unmap_hugepage_range and
sometimes in zap_page_range. Should we pass a parameter to indicate
the different lock situation?

Comments state that mmap_sem must be held for
remap_pfn_range() but various drivers do not seem to do this?

Signed-off-by: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>

---
 mm/fremap.c  |    2 ++
 mm/hugetlb.c |    2 ++
 mm/memory.c  |    9 +++++++--
 mm/mmap.c    |    1 +
 4 files changed, 12 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2008-01-24 20:59:17.000000000 -0800
+++ linux-2.6/mm/fremap.c	2008-01-24 21:01:17.000000000 -0800
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -211,6 +212,7 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier(invalidate_range, mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-01-24 20:59:17.000000000 -0800
+++ linux-2.6/mm/hugetlb.c	2008-01-24 21:01:17.000000000 -0800
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -763,6 +764,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier(invalidate_range, mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-01-24 20:59:17.000000000 -0800
+++ linux-2.6/mm/memory.c	2008-01-24 21:01:17.000000000 -0800
@@ -50,6 +50,7 @@
 #include <linux/delayacct.h>
 #include <linux/init.h>
 #include <linux/writeback.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -891,6 +892,7 @@ unsigned long zap_page_range(struct vm_a
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
+	mmu_notifier(invalidate_range, mm, address, end);
 	return end;
 }
 
@@ -1319,7 +1321,7 @@ int remap_pfn_range(struct vm_area_struc
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + PAGE_ALIGN(size);
+	unsigned long start = addr, end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
@@ -1360,6 +1362,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range, mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1443,7 +1446,7 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
@@ -1454,6 +1457,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range, mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1634,6 +1638,7 @@ gotten:
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
+	mmu_notifier(invalidate_range, mm, address, address + PAGE_SIZE - 1);
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-01-24 20:59:19.000000000 -0800
+++ linux-2.6/mm/mmap.c	2008-01-24 21:01:17.000000000 -0800
@@ -1748,6 +1748,7 @@ static void unmap_region(struct mm_struc
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	mmu_notifier(invalidate_range, mm, start, end);
 }
 
 /*

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
