Message-Id: <20080327133014.319485760@polymtl.ca>
References: <20080327132057.449831367@polymtl.ca>
Date: Thu, 27 Mar 2008 09:21:02 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch for 2.6.26 5/7] LTTng instrumentation mm
Content-Disposition: inline; filename=lttng-instrumentation-mm.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Memory management core events.

Added markers :

mm_filemap_wait_end
mm_filemap_wait_start
mm_handle_fault_entry
mm_handle_fault_exit
mm_huge_page_alloc
mm_huge_page_free
mm_page_alloc
mm_page_free
mm_swap_file_close
mm_swap_file_open
mm_swap_in
mm_swap_out
statedump_swap_files

Changelog:
- Use page_to_pfn for swap out instrumentation, wait_on_page_bit, do_swap_page,
  page alloc/free.
- add missing free_hot_cold_page instrumentation.
- add hugetlb page_alloc page_free instrumentation.
- Add write_access to mm fault.
- Add page bit_nr waited for by wait_on_page_bit.
- Move page alloc instrumentation to __aloc_pages so we cover the alloc zeroed
  page path.
- Add swap file used for swap in and swap out events.
- Dump the swap files, instrument swapon and swapoff.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: linux-mm@kvack.org
CC: Dave Hansen <haveblue@us.ibm.com>
---
 include/linux/swapops.h |    8 ++++++++
 mm/filemap.c            |    7 +++++++
 mm/hugetlb.c            |    3 +++
 mm/memory.c             |   39 ++++++++++++++++++++++++++++++---------
 mm/page_alloc.c         |    9 +++++++++
 mm/page_io.c            |    6 ++++++
 mm/swapfile.c           |   23 +++++++++++++++++++++++
 7 files changed, 86 insertions(+), 9 deletions(-)

Index: linux-2.6-lttng/mm/filemap.c
===================================================================
--- linux-2.6-lttng.orig/mm/filemap.c	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/mm/filemap.c	2008-03-27 09:19:23.000000000 -0400
@@ -33,6 +33,7 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/marker.h>
 #include "internal.h"
 
 /*
@@ -540,9 +541,15 @@ void wait_on_page_bit(struct page *page,
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
 
+	trace_mark(mm_filemap_wait_start, "pfn %lu bit_nr %d",
+		page_to_pfn(page), bit_nr);
+
 	if (test_bit(bit_nr, &page->flags))
 		__wait_on_bit(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
+
+	trace_mark(mm_filemap_wait_end, "pfn %lu bit_nr %d",
+		page_to_pfn(page), bit_nr);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
Index: linux-2.6-lttng/mm/memory.c
===================================================================
--- linux-2.6-lttng.orig/mm/memory.c	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/mm/memory.c	2008-03-27 09:19:23.000000000 -0400
@@ -45,6 +45,7 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/marker.h>
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/delayacct.h>
@@ -2050,6 +2051,10 @@ static int do_swap_page(struct mm_struct
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
+		trace_mark(mm_swap_in, "pfn %lu filp %p offset %lu",
+			page_to_pfn(page),
+			get_swap_info_struct(swp_type(entry))->swap_file,
+			swp_offset(entry));
 	}
 
 	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
@@ -2509,30 +2514,46 @@ unlock:
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, int write_access)
 {
+	int res;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
+	trace_mark(mm_handle_fault_entry,
+		"address %lu ip #p%ld write_access %d",
+		address, KSTK_EIP(current), write_access);
+
 	__set_current_state(TASK_RUNNING);
 
 	count_vm_event(PGFAULT);
 
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
+	if (unlikely(is_vm_hugetlb_page(vma))) {
+		res = hugetlb_fault(mm, vma, address, write_access);
+		goto end;
+	}
 
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
-		return VM_FAULT_OOM;
+	if (!pud) {
+		res = VM_FAULT_OOM;
+		goto end;
+	}
 	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
-		return VM_FAULT_OOM;
+	if (!pmd) {
+		res = VM_FAULT_OOM;
+		goto end;
+	}
 	pte = pte_alloc_map(mm, pmd, address);
-	if (!pte)
-		return VM_FAULT_OOM;
+	if (!pte) {
+		res = VM_FAULT_OOM;
+		goto end;
+	}
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	res = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+end:
+	trace_mark(mm_handle_fault_exit, MARK_NOARGS);
+	return res;
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED
Index: linux-2.6-lttng/mm/page_alloc.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_alloc.c	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/mm/page_alloc.c	2008-03-27 09:19:23.000000000 -0400
@@ -45,6 +45,7 @@
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
+#include <linux/marker.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -527,6 +528,9 @@ static void __free_pages_ok(struct page 
 	int i;
 	int reserved = 0;
 
+	trace_mark(mm_page_free, "order %u pfn %lu",
+		order, page_to_pfn(page));
+
 	for (i = 0 ; i < (1 << order) ; ++i)
 		reserved += free_pages_check(page + i);
 	if (reserved)
@@ -990,6 +994,8 @@ static void free_hot_cold_page(struct pa
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+	trace_mark(mm_page_free, "order %u pfn %lu", 0, page_to_pfn(page));
+
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))
@@ -1643,6 +1649,9 @@ nopage:
 		show_mem();
 	}
 got_pg:
+	if (page)
+		trace_mark(mm_page_alloc, "order %u pfn %lu", order,
+			   page_to_pfn(page));
 	return page;
 }
 
Index: linux-2.6-lttng/mm/page_io.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_io.c	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/mm/page_io.c	2008-03-27 09:19:23.000000000 -0400
@@ -17,6 +17,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/marker.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
@@ -114,6 +115,11 @@ int swap_writepage(struct page *page, st
 		rw |= (1 << BIO_RW_SYNC);
 	count_vm_event(PSWPOUT);
 	set_page_writeback(page);
+	trace_mark(mm_swap_out, "pfn %lu filp %p offset %lu",
+			page_to_pfn(page),
+			get_swap_info_struct(swp_type(
+				page_swp_entry(page)))->swap_file,
+			swp_offset(page_swp_entry(page)));
 	unlock_page(page);
 	submit_bio(rw, bio);
 out:
Index: linux-2.6-lttng/mm/hugetlb.c
===================================================================
--- linux-2.6-lttng.orig/mm/hugetlb.c	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/mm/hugetlb.c	2008-03-27 09:19:23.000000000 -0400
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/marker.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -137,6 +138,7 @@ static void free_huge_page(struct page *
 	int nid = page_to_nid(page);
 	struct address_space *mapping;
 
+	trace_mark(mm_huge_page_free, "pfn %lu", page_to_pfn(page));
 	mapping = (struct address_space *) page_private(page);
 	set_page_private(page, 0);
 	BUG_ON(page_count(page));
@@ -485,6 +487,7 @@ static struct page *alloc_huge_page(stru
 	if (!IS_ERR(page)) {
 		set_page_refcounted(page);
 		set_page_private(page, (unsigned long) mapping);
+		trace_mark(mm_huge_page_alloc, "pfn %lu", page_to_pfn(page));
 	}
 	return page;
 }
Index: linux-2.6-lttng/include/linux/swapops.h
===================================================================
--- linux-2.6-lttng.orig/include/linux/swapops.h	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/include/linux/swapops.h	2008-03-27 09:19:23.000000000 -0400
@@ -76,6 +76,14 @@ static inline pte_t swp_entry_to_pte(swp
 	return __swp_entry_to_pte(arch_entry);
 }
 
+static inline swp_entry_t page_swp_entry(struct page *page)
+{
+	swp_entry_t entry;
+	VM_BUG_ON(!PageSwapCache(page));
+	entry.val = page_private(page);
+	return entry;
+}
+
 #ifdef CONFIG_MIGRATION
 static inline swp_entry_t make_migration_entry(struct page *page, int write)
 {
Index: linux-2.6-lttng/mm/swapfile.c
===================================================================
--- linux-2.6-lttng.orig/mm/swapfile.c	2008-03-27 09:18:44.000000000 -0400
+++ linux-2.6-lttng/mm/swapfile.c	2008-03-27 09:19:43.000000000 -0400
@@ -28,6 +28,7 @@
 #include <linux/capability.h>
 #include <linux/syscalls.h>
 #include <linux/memcontrol.h>
+#include <linux/marker.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -1310,6 +1311,7 @@ asmlinkage long sys_swapoff(const char _
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	trace_mark(mm_swap_file_close, "filp %p", swap_file);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
@@ -1691,6 +1693,8 @@ asmlinkage long sys_swapon(const char __
 	} else {
 		swap_info[prev].next = p - swap_info;
 	}
+	trace_mark(mm_swap_file_open, "filp %p filename %s",
+		swap_file, name);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	error = 0;
@@ -1844,3 +1848,22 @@ int valid_swaphandles(swp_entry_t entry,
 	*offset = ++toff;
 	return nr_pages? ++nr_pages: 0;
 }
+
+void ltt_dump_swap_files(void *call_data)
+{
+	int type;
+	struct swap_info_struct *p = NULL;
+
+	mutex_lock(&swapon_mutex);
+	for (type = swap_list.head; type >= 0; type = swap_info[type].next) {
+		p = swap_info + type;
+		if ((p->flags & SWP_ACTIVE) != SWP_ACTIVE)
+			continue;
+		__trace_mark(0, statedump_swap_files, call_data,
+			"filp %p vfsmount %p dname %s",
+			p->swap_file, p->swap_file->f_vfsmnt,
+			p->swap_file->f_dentry->d_name.name);
+	}
+	mutex_unlock(&swapon_mutex);
+}
+EXPORT_SYMBOL_GPL(ltt_dump_swap_files);

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
