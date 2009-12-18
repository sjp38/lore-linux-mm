Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BD9136B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:48:23 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI0mL0S011894
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Dec 2009 09:48:21 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E239B45DE4F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:48:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C32FB45DE4E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:48:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A538F1DB803B
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:48:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 585D71DB803E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:48:17 +0900 (JST)
Date: Fri, 18 Dec 2009 09:45:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC 3/4] lockless vma caching
Message-Id: <20091218094513.490f27b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

For accessing vma in lockless style, some modification for vma lookup is
required. Now, rb-tree is used and it doesn't allow read while modification.

This is a trial to caching vma rather than diving into rb-tree. The last
fault vma is cached to pgd's page->cached_vma field. And, add reference count
and waitqueue to vma.

The accessor will have to do

	vma = lookup_vma_cache(mm, address);
	if (vma) {
		if (mm_check_version(mm) && /* no write lock at this point ? */
		    (vma->vm_start <= address) && (vma->vm_end > address))
			goto found_vma; /* start speculative job */
		else
			vma_release_cache(vma);
		vma = NULL;
	}
	vma = find_vma();
found_vma:
	....do some jobs....
	vma_release_cache(vma);

Maybe some more consideration for invalidation point is necessary.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h       |   20 +++++++++
 include/linux/mm_types.h |    5 ++
 mm/memory.c              |   14 ++++++
 mm/mmap.c                |  102 +++++++++++++++++++++++++++++++++++++++++++++--
 mm/page_alloc.c          |    1 
 5 files changed, 138 insertions(+), 4 deletions(-)

Index: mmotm-mm-accessor/include/linux/mm.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/mm.h
+++ mmotm-mm-accessor/include/linux/mm.h
@@ -763,6 +763,26 @@ unsigned long unmap_vmas(struct mmu_gath
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 
+struct vm_area_struct *lookup_vma_cache(struct mm_struct *mm,
+		unsigned long address);
+void invalidate_vma_cache(struct mm_struct *mm,
+		struct vm_area_struct *vma);
+void wait_vmas_cache_range(struct vm_area_struct *vma, unsigned long end);
+
+static inline void vma_hold(struct vm_area_struct *vma)
+{
+	atomic_inc(&vma->cache_access);
+}
+
+void __vma_release(struct vm_area_struct *vma);
+static inline void vma_release(struct vm_area_struct *vma)
+{
+	if (atomic_dec_and_test(&vma->cache_access)) {
+		if (waitqueue_active(&vma->cache_wait))
+			__vma_release(vma);
+	}
+}
+
 /**
  * mm_walk - callbacks for walk_page_range
  * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
Index: mmotm-mm-accessor/include/linux/mm_types.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/mm_types.h
+++ mmotm-mm-accessor/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/wait.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -77,6 +78,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		void *cache;
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
@@ -180,6 +182,9 @@ struct vm_area_struct {
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
+	atomic_t cache_access;
+	wait_queue_head_t cache_wait;
+
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
 #endif
Index: mmotm-mm-accessor/mm/memory.c
===================================================================
--- mmotm-mm-accessor.orig/mm/memory.c
+++ mmotm-mm-accessor/mm/memory.c
@@ -145,6 +145,14 @@ void pmd_clear_bad(pmd_t *pmd)
 	pmd_clear(pmd);
 }
 
+static void update_vma_cache(pmd_t *pmd, struct vm_area_struct *vma)
+{
+	struct page *page;
+	/* ptelock is held */
+	page = pmd_page(*pmd);
+	page->cache = vma;
+}
+
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
@@ -2118,6 +2126,7 @@ reuse:
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
+		update_vma_cache(pmd, vma);
 		goto unlock;
 	}
 
@@ -2186,6 +2195,7 @@ gotten:
 		 */
 		set_pte_at_notify(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
+		update_vma_cache(pmd, vma);
 		if (old_page) {
 			/*
 			 * Only after switching the pte to the new page may
@@ -2626,6 +2636,7 @@ static int do_swap_page(struct mm_struct
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
+	update_vma_cache(pmd, vma);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
@@ -2691,6 +2702,7 @@ setpte:
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
+	update_vma_cache(pmd, vma);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
@@ -2852,6 +2864,7 @@ static int __do_fault(struct mm_struct *
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
+		update_vma_cache(pmd, vma);
 	} else {
 		if (charged)
 			mem_cgroup_uncharge_page(page);
@@ -2989,6 +3002,7 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (ptep_set_access_flags(vma, address, pte, entry, flags & FAULT_FLAG_WRITE)) {
 		update_mmu_cache(vma, address, entry);
+		update_vma_cache(pmd, vma);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
Index: mmotm-mm-accessor/mm/mmap.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mmap.c
+++ mmotm-mm-accessor/mm/mmap.c
@@ -187,6 +187,94 @@ error:
 	return -ENOMEM;
 }
 
+struct vm_area_struct *
+lookup_vma_cache(struct mm_struct *mm, unsigned long address)
+{
+	struct page *page;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	struct vm_area_struct *ret = NULL;
+
+	if (!mm)
+		return NULL;
+
+	preempt_disable();
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		goto out;
+	page = pmd_page(*pmd);
+	if (PageReserved(page))
+		goto out;
+	ret = (struct vm_area_struct *)page->cache;
+	if (ret)
+		vma_hold(ret);
+out:
+	preempt_enable();
+	return ret;
+}
+
+void invalidate_vma_cache_range(struct mm_struct *mm,
+	unsigned long start, unsigned long end)
+{
+	struct page *page;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	unsigned long address = start;
+	spinlock_t *lock;
+
+	if (!mm)
+		return;
+
+	while (address < end) {
+		pgd = pgd_offset(mm, address);
+		if (!pgd_present(*pgd)) {
+			address = pgd_addr_end(address, end);
+			continue;
+		}
+		pud = pud_offset(pgd, address);
+		if (!pud_present(*pud)) {
+			address = pud_addr_end(address, end);
+			continue;
+		}
+		pmd = pmd_offset(pud, address);
+		if (pmd_present(*pmd)) {
+			page = pmd_page(*pmd);
+			/*
+ 			 * this spinlock guarantee no race with speculative
+			 * page fault, finally.
+			 */
+			lock = pte_lockptr(mm, pmd);
+			spin_lock(lock);
+			page->cache = NULL;
+			spin_unlock(lock);
+		}
+		address = pmd_addr_end(address, end);
+	}
+}
+
+/* called under mm_write_lock() */
+void wait_vmas_cache_access(struct vm_area_struct *vma, unsigned long end)
+{
+	while (vma && (vma->vm_start < end)) {
+		wait_event_interruptible(vma->cache_wait,
+				atomic_read(&vma->cache_access) == 0);
+		vma = vma->vm_next;
+	}
+}
+
+void __vma_release(struct vm_area_struct *vma)
+{
+	wake_up(&vma->cache_wait);
+}
+
 /*
  * Requires inode->i_mapping->i_mmap_lock
  */
@@ -406,6 +494,8 @@ void __vma_link_rb(struct mm_struct *mm,
 {
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
+	atomic_set(&vma->cache_access, 0);
+	init_waitqueue_head(&vma->cache_wait);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -774,7 +864,8 @@ struct vm_area_struct *vma_merge(struct 
 	area = next;
 	if (next && next->vm_end == end)		/* cases 6, 7, 8 */
 		next = next->vm_next;
-
+	invalidate_vma_cache_range(mm, addr, end);
+	wait_vmas_cache_access(next, end);
 	/*
 	 * Can it merge with the predecessor?
 	 */
@@ -1162,7 +1253,6 @@ munmap_back:
 			return -ENOMEM;
 		vm_flags |= VM_ACCOUNT;
 	}
-
 	/*
 	 * Can we just expand an old mapping?
 	 */
@@ -1930,7 +2020,9 @@ int do_munmap(struct mm_struct *mm, unsi
 	end = start + len;
 	if (vma->vm_start >= end)
 		return 0;
-
+	/* Before going further, clear vma cache */
+	invalidate_vma_cache_range(mm, start, end);
+	wait_vmas_cache_access(vma, end);
 	/*
 	 * If we need to split any vma, do it now to save pain later.
 	 *
@@ -1940,7 +2032,6 @@ int do_munmap(struct mm_struct *mm, unsi
 	 */
 	if (start > vma->vm_start) {
 		int error;
-
 		/*
 		 * Make sure that map_count on return from munmap() will
 		 * not exceed its limit; but let map_count go just above
@@ -2050,6 +2141,7 @@ unsigned long do_brk(unsigned long addr,
 	if (error)
 		return error;
 
+
 	/*
 	 * mlock MCL_FUTURE?
 	 */
@@ -2069,6 +2161,7 @@ unsigned long do_brk(unsigned long addr,
 	 */
 	verify_mm_writelocked(mm);
 
+	invalidate_vma_cache_range(mm, addr,addr+len);
 	/*
 	 * Clear old maps.  this also does some error checking for us
 	 */
@@ -2245,6 +2338,7 @@ struct vm_area_struct *copy_vma(struct v
 				kmem_cache_free(vm_area_cachep, new_vma);
 				return NULL;
 			}
+			atomic_set(&new_vma->cache_access, 0);
 			vma_set_policy(new_vma, pol);
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
Index: mmotm-mm-accessor/mm/page_alloc.c
===================================================================
--- mmotm-mm-accessor.orig/mm/page_alloc.c
+++ mmotm-mm-accessor/mm/page_alloc.c
@@ -698,6 +698,7 @@ static int prep_new_page(struct page *pa
 
 	set_page_private(page, 0);
 	set_page_refcounted(page);
+	page->cache = NULL;
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
