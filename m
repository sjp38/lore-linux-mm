From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 2/6] mmu_notifier: Callbacks to invalidate
	address ranges
Date: Fri, 08 Feb 2008 14:06:18 -0800
Message-ID: <20080208220656.073652142@sgi.com>
References: <20080208220616.089936205@sgi.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

The invalidation of address ranges in a mm_struct needs to be
performed when pages are removed or permissions etc change.

If invalidate_range_begin() is called with locks held then we
pass a flag into invalidate_range() to indicate that no sleeping is
possible. Locks are only held for truncate and huge pages.

In two cases we use invalidate_range_begin/end to invalidate
single pages because the pair allows holding off new references
(idea by Robin Holt).

do_wp_page(): We hold off new references while we update the pte.

xip_unmap: We are not taking the PageLock so we cannot
use the invalidate_page mmu_rmap_notifier. invalidate_range_begin/end
stands in.

Signed-off-by: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Signed-off-by: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>

---
 mm/filemap_xip.c |    5 +++++
 mm/fremap.c      |    3 +++
 mm/hugetlb.c     |    3 +++
 mm/memory.c      |   35 +++++++++++++++++++++++++++++------
 mm/mmap.c        |    2 ++
 mm/mprotect.c    |    3 +++
 mm/mremap.c      |    7 ++++++-
 7 files changed, 51 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2008-02-08 13:18:58.000000000 -0800
+++ linux-2.6/mm/fremap.c	2008-02-08 13:25:22.000000000 -0800
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -214,7 +215,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier(invalidate_range_begin, mm, start, start + size, 0);
 	err = populate_range(mm, vma, start, size, pgoff);
+	mmu_notifier(invalidate_range_end, mm, start, start + size, 0);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/mm/memory.c	2008-02-08 13:25:22.000000000 -0800
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -611,6 +612,9 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_range_begin, src_mm, addr, end, 0);
+
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
@@ -621,6 +625,11 @@ int copy_page_range(struct mm_struct *ds
 						vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_range_end, src_mm,
+						vma->vm_start, end, 0);
+
 	return 0;
 }
 
@@ -893,13 +902,16 @@ unsigned long zap_page_range(struct vm_a
 	struct mmu_gather *tlb;
 	unsigned long end = address + size;
 	unsigned long nr_accounted = 0;
+	int atomic = details ? (details->i_mmap_lock != 0) : 0;
 
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier(invalidate_range_begin, mm, address, end, atomic);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
+	mmu_notifier(invalidate_range_end, mm, address, end, atomic);
 	return end;
 }
 
@@ -1337,7 +1349,7 @@ int remap_pfn_range(struct vm_area_struc
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + PAGE_ALIGN(size);
+	unsigned long start = addr, end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
@@ -1371,6 +1383,7 @@ int remap_pfn_range(struct vm_area_struc
 	pfn -= addr >> PAGE_SHIFT;
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
+	mmu_notifier(invalidate_range_begin, mm, start, end, 0);
 	do {
 		next = pgd_addr_end(addr, end);
 		err = remap_pud_range(mm, pgd, addr, next,
@@ -1378,6 +1391,7 @@ int remap_pfn_range(struct vm_area_struc
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range_end, mm, start, end, 0);
 	return err;
 }
 EXPORT_SYMBOL(remap_pfn_range);
@@ -1461,10 +1475,11 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
+	mmu_notifier(invalidate_range_begin, mm, start, end, 0);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1472,6 +1487,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier(invalidate_range_end, mm, start, end, 0);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1612,8 +1628,10 @@ static int do_wp_page(struct mm_struct *
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
 			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
-				goto unlock;
+			if (!pte_same(*page_table, orig_pte)) {
+				pte_unmap_unlock(page_table, ptl);
+				goto check_dirty;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -1629,7 +1647,8 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
-		goto unlock;
+		pte_unmap_unlock(page_table, ptl);
+		goto check_dirty;
 	}
 
 	/*
@@ -1651,6 +1670,8 @@ gotten:
 	if (mem_cgroup_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
+	mmu_notifier(invalidate_range_begin, mm, address,
+				address + PAGE_SIZE, 0);
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -1689,8 +1710,10 @@ gotten:
 		page_cache_release(new_page);
 	if (old_page)
 		page_cache_release(old_page);
-unlock:
 	pte_unmap_unlock(page_table, ptl);
+	mmu_notifier(invalidate_range_end, mm,
+				address, address + PAGE_SIZE, 0);
+check_dirty:
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-02-08 13:25:21.000000000 -0800
+++ linux-2.6/mm/mmap.c	2008-02-08 13:25:22.000000000 -0800
@@ -1748,11 +1748,13 @@ static void unmap_region(struct mm_struc
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
+	mmu_notifier(invalidate_range_begin, mm, start, end, 0);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
+	mmu_notifier(invalidate_range_end, mm, start, end, 0);
 }
 
 /*
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/mm/hugetlb.c	2008-02-08 13:25:22.000000000 -0800
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -753,6 +754,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	mmu_notifier(invalidate_range_begin, mm, start, end, 1);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -773,6 +775,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier(invalidate_range_end, mm, start, end, 1);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/mm/filemap_xip.c	2008-02-08 13:25:22.000000000 -0800
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/uio.h>
 #include <linux/rmap.h>
+#include <linux/mmu_notifier.h>
 #include <linux/sched.h>
 #include <asm/tlbflush.h>
 
@@ -190,6 +191,8 @@ __xip_unmap (struct address_space * mapp
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+		mmu_notifier(invalidate_range_begin, mm, address,
+					address + PAGE_SIZE, 1);
 		pte = page_check_address(page, mm, address, &ptl);
 		if (pte) {
 			/* Nuke the page table entry. */
@@ -201,6 +204,8 @@ __xip_unmap (struct address_space * mapp
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
 		}
+		mmu_notifier(invalidate_range_end, mm,
+				address, address + PAGE_SIZE, 1);
 	}
 	spin_unlock(&mapping->i_mmap_lock);
 }
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c	2008-02-08 13:18:58.000000000 -0800
+++ linux-2.6/mm/mremap.c	2008-02-08 13:25:22.000000000 -0800
@@ -18,6 +18,7 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -124,12 +125,15 @@ unsigned long move_page_tables(struct vm
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len)
 {
-	unsigned long extent, next, old_end;
+	unsigned long extent, next, old_start, old_end;
 	pmd_t *old_pmd, *new_pmd;
 
+	old_start = old_addr;
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
 
+	mmu_notifier(invalidate_range_begin, vma->vm_mm,
+					old_addr, old_end, 0);
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
@@ -150,6 +154,7 @@ unsigned long move_page_tables(struct vm
 		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
 				new_vma, new_pmd, new_addr);
 	}
+	mmu_notifier(invalidate_range_end, vma->vm_mm, old_start, old_end, 0);
 
 	return len + old_addr - old_end;	/* how much done */
 }
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c	2008-02-08 13:18:58.000000000 -0800
+++ linux-2.6/mm/mprotect.c	2008-02-08 13:25:22.000000000 -0800
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -198,10 +199,12 @@ success:
 		dirty_accountable = 1;
 	}
 
+	mmu_notifier(invalidate_range_begin, mm, start, end, 0);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	mmu_notifier(invalidate_range_end, mm, start, end, 0);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
