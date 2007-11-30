Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts36-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071130161157.UHAO7990.tomts36-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <linux-mm@kvack.org>; Fri, 30 Nov 2007 11:11:57 -0500
Date: Fri, 30 Nov 2007 11:11:55 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [RFC PATCH] LTTng instrumentation mm (updated)
Message-ID: <20071130161155.GA29634@Krystal>
References: <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost> <20071116143019.GA16082@Krystal> <1195495485.27759.115.camel@localhost> <20071128140953.GA8018@Krystal> <1196268856.18851.20.camel@localhost> <20071129023421.GA711@Krystal> <1196317552.18851.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1196317552.18851.47.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

LTTng instrumentation mm

Memory management core events.

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

(note : I did not change the other sites where page_swp_entry could be
used)
(note 2 : my FS instrumentation does not dump the kernel vfs mounts,
which would be useful to interpret the "dump swap files"
instrumentation. I should add this eventually.)

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: linux-mm@kvack.org
CC: Dave Hansen <haveblue@us.ibm.com>
---
 include/linux/swapops.h |    8 ++++++++
 mm/filemap.c            |    6 ++++++
 mm/hugetlb.c            |    2 ++
 mm/memory.c             |   38 +++++++++++++++++++++++++++++---------
 mm/page_alloc.c         |    6 ++++++
 mm/page_io.c            |    5 +++++
 mm/swapfile.c           |   22 ++++++++++++++++++++++
 7 files changed, 78 insertions(+), 9 deletions(-)

Index: linux-2.6-lttng/mm/filemap.c
===================================================================
--- linux-2.6-lttng.orig/mm/filemap.c	2007-11-29 20:22:52.000000000 -0500
+++ linux-2.6-lttng/mm/filemap.c	2007-11-29 20:23:01.000000000 -0500
@@ -514,9 +514,15 @@ void fastcall wait_on_page_bit(struct pa
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
--- linux-2.6-lttng.orig/mm/memory.c	2007-11-29 20:22:52.000000000 -0500
+++ linux-2.6-lttng/mm/memory.c	2007-11-29 20:42:36.000000000 -0500
@@ -2090,6 +2090,10 @@ static int do_swap_page(struct mm_struct
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
+		trace_mark(mm_swap_in, "pfn %lu filp %p offset %lu",
+			page_to_pfn(page),
+			get_swap_info_struct(swp_type(entry))->swap_file,
+			swp_offset(entry));
 	}
 
 	mark_page_accessed(page);
@@ -2526,30 +2530,46 @@ unlock:
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
--- linux-2.6-lttng.orig/mm/page_alloc.c	2007-11-29 20:22:52.000000000 -0500
+++ linux-2.6-lttng/mm/page_alloc.c	2007-11-29 20:23:01.000000000 -0500
@@ -519,6 +519,9 @@ static void __free_pages_ok(struct page 
 	int i;
 	int reserved = 0;
 
+	trace_mark(mm_page_free, "order %u pfn %lu",
+		order, page_to_pfn(page));
+
 	for (i = 0 ; i < (1 << order) ; ++i)
 		reserved += free_pages_check(page + i);
 	if (reserved)
@@ -981,6 +984,8 @@ static void fastcall free_hot_cold_page(
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+	trace_mark(mm_page_free, "order %u pfn %lu", 0, page_to_pfn(page));
+
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))
@@ -1625,6 +1630,7 @@ nopage:
 		show_mem();
 	}
 got_pg:
+	trace_mark(mm_page_alloc, "order %u pfn %lu", order, page_to_pfn(page));
 	return page;
 }
 
Index: linux-2.6-lttng/mm/page_io.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_io.c	2007-11-29 20:22:52.000000000 -0500
+++ linux-2.6-lttng/mm/page_io.c	2007-11-29 20:43:02.000000000 -0500
@@ -114,6 +114,11 @@ int swap_writepage(struct page *page, st
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
--- linux-2.6-lttng.orig/mm/hugetlb.c	2007-11-29 20:22:52.000000000 -0500
+++ linux-2.6-lttng/mm/hugetlb.c	2007-11-29 20:23:01.000000000 -0500
@@ -118,6 +118,7 @@ static void free_huge_page(struct page *
 	int nid = page_to_nid(page);
 	struct address_space *mapping;
 
+	trace_mark(mm_huge_page_free, "pfn %lu", page_to_pfn(page));
 	mapping = (struct address_space *) page_private(page);
 	BUG_ON(page_count(page));
 	INIT_LIST_HEAD(&page->lru);
@@ -401,6 +402,7 @@ static struct page *alloc_huge_page(stru
 	if (!IS_ERR(page)) {
 		set_page_refcounted(page);
 		set_page_private(page, (unsigned long) mapping);
+		trace_mark(mm_huge_page_alloc, "pfn %lu", page_to_pfn(page));
 	}
 	return page;
 }
Index: linux-2.6-lttng/include/linux/swapops.h
===================================================================
--- linux-2.6-lttng.orig/include/linux/swapops.h	2007-11-29 20:22:52.000000000 -0500
+++ linux-2.6-lttng/include/linux/swapops.h	2007-11-29 20:23:01.000000000 -0500
@@ -68,6 +68,14 @@ static inline pte_t swp_entry_to_pte(swp
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
--- linux-2.6-lttng.orig/mm/swapfile.c	2007-11-30 09:18:38.000000000 -0500
+++ linux-2.6-lttng/mm/swapfile.c	2007-11-30 10:21:50.000000000 -0500
@@ -1279,6 +1279,7 @@ asmlinkage long sys_swapoff(const char _
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	trace_mark(mm_swap_file_close, "filp %p", swap_file);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
@@ -1660,6 +1661,8 @@ asmlinkage long sys_swapon(const char __
 	} else {
 		swap_info[prev].next = p - swap_info;
 	}
+	trace_mark(mm_swap_file_open, "filp %p filename %s",
+		swap_file, name);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	error = 0;
@@ -1796,3 +1799,22 @@ int valid_swaphandles(swp_entry_t entry,
 	spin_unlock(&swap_lock);
 	return ret;
 }
+
+void ltt_dump_swap_files(void *call_data)
+{
+	int type;
+	struct swap_info_struct * p = NULL;
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
