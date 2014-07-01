Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id A98CE6B0036
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 09:02:09 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id v10so7631606qac.32
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 06:02:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t47si6031823qge.73.2014.07.01.06.02.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 06:02:09 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 1/5] mm, shmem: Add shmem resident memory accounting
Date: Tue,  1 Jul 2014 15:01:57 +0200
Message-Id: <1404219721-32241-2-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
References: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

Currently looking at /proc/<pid>/status or statm, there is no way to
distinguish shmem pages from pages mapped to a regular file (shmem
pages are mapped to /dev/zero), even though their implication in
actual memory use is quite different.
This patch adds MM_SHMEMPAGES counter to mm_rss_stat. It keeps track of
resident shmem memory size. Its value is exposed in the new VmShm line
of /proc/<pid>/status.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 Documentation/filesystems/proc.txt |  2 ++
 arch/s390/mm/pgtable.c             |  2 +-
 fs/proc/task_mmu.c                 |  9 ++++++---
 include/linux/mm.h                 |  7 +++++++
 include/linux/mm_types.h           |  7 ++++---
 kernel/events/uprobes.c            |  2 +-
 mm/filemap_xip.c                   |  2 +-
 mm/memory.c                        | 37 +++++++++++++++++++++++++++++++------
 mm/rmap.c                          |  8 ++++----
 9 files changed, 57 insertions(+), 19 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index ddc531a..1c49957 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -171,6 +171,7 @@ read the file /proc/PID/status:
   VmLib:      1412 kB
   VmPTE:        20 kb
   VmSwap:        0 kB
+  VmShm:         0 kB
   Threads:        1
   SigQ:   0/28578
   SigPnd: 0000000000000000
@@ -228,6 +229,7 @@ Table 1-2: Contents of the status files (as of 2.6.30-rc7)
  VmLib                       size of shared library code
  VmPTE                       size of page table entries
  VmSwap                      size of swap usage (the number of referred swapents)
+ VmShm	                      size of resident shmem memory
  Threads                     number of threads
  SigQ                        number of signals queued/max. number for queue
  SigPnd                      bitmap of pending signals for the thread
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 37b8241..9fe31b0 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -612,7 +612,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry, struct mm_struct *mm)
 		if (PageAnon(page))
 			dec_mm_counter(mm, MM_ANONPAGES);
 		else
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_file_counters(mm, page);
 	}
 	free_swap_and_cache(entry);
 }
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cfa63ee..4e60751 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -21,7 +21,7 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap;
+	unsigned long data, text, lib, swap, shmem;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -42,6 +42,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
 	swap = get_mm_counter(mm, MM_SWAPENTS);
+	shmem = get_mm_counter(mm, MM_SHMEMPAGES);
 	seq_printf(m,
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
@@ -54,7 +55,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmExe:\t%8lu kB\n"
 		"VmLib:\t%8lu kB\n"
 		"VmPTE:\t%8lu kB\n"
-		"VmSwap:\t%8lu kB\n",
+		"VmSwap:\t%8lu kB\n"
+		"VmShm:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
 		total_vm << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
@@ -65,7 +67,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		(PTRS_PER_PTE * sizeof(pte_t) *
 		 atomic_long_read(&mm->nr_ptes)) >> 10,
-		swap << (PAGE_SHIFT-10));
+		swap << (PAGE_SHIFT-10),
+		shmem << (PAGE_SHIFT-10));
 }
 
 unsigned long task_vsize(struct mm_struct *mm)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e03dd29..e69ee9d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1299,6 +1299,13 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
 	atomic_long_dec(&mm->rss_stat.count[member]);
 }
 
+static inline void dec_mm_file_counters(struct mm_struct *mm, struct page *page)
+{
+	dec_mm_counter(mm, MM_FILEPAGES);
+	if (PageSwapBacked(page))
+		dec_mm_counter(mm, MM_SHMEMPAGES);
+}
+
 static inline unsigned long get_mm_rss(struct mm_struct *mm)
 {
 	return get_mm_counter(mm, MM_FILEPAGES) +
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 21bff4b..e0307c8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -322,9 +322,10 @@ struct core_state {
 };
 
 enum {
-	MM_FILEPAGES,
-	MM_ANONPAGES,
-	MM_SWAPENTS,
+	MM_FILEPAGES,	/* Resident file mapping pages (includes /dev/zero) */
+	MM_ANONPAGES,	/* Resident anonymous pages */
+	MM_SWAPENTS,	/* Anonymous swap entries */
+	MM_SHMEMPAGES,	/* Resident shared memory pages */
 	NR_MM_COUNTERS
 };
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1d0af8a..6c28c72 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -188,7 +188,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
 	if (!PageAnon(page)) {
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_file_counters(mm, page);
 		inc_mm_counter(mm, MM_ANONPAGES);
 	}
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3..4bd4836 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_file_counters(mm, page);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			/* must invalidate_page _before_ freeing the page */
diff --git a/mm/memory.c b/mm/memory.c
index 09e2cd0..c394fc7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -176,6 +176,20 @@ static void check_sync_rss_stat(struct task_struct *task)
 
 #endif /* SPLIT_RSS_COUNTING */
 
+static void inc_mm_file_counters_fast(struct mm_struct *mm, struct page *page)
+{
+	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	if (PageSwapBacked(page))
+		inc_mm_counter_fast(mm, MM_SHMEMPAGES);
+}
+
+static void dec_mm_file_counters_fast(struct mm_struct *mm, struct page *page)
+{
+	dec_mm_counter_fast(mm, MM_FILEPAGES);
+	if (PageSwapBacked(page))
+		dec_mm_counter_fast(mm, MM_SHMEMPAGES);
+}
+
 #ifdef HAVE_GENERIC_MMU_GATHER
 
 static int tlb_next_batch(struct mmu_gather *tlb)
@@ -832,8 +846,11 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 				if (PageAnon(page))
 					rss[MM_ANONPAGES]++;
-				else
+				else {
 					rss[MM_FILEPAGES]++;
+					if (PageSwapBacked(page))
+						rss[MM_SHMEMPAGES]++;
+				}
 
 				if (is_write_migration_entry(entry) &&
 				    is_cow_mapping(vm_flags)) {
@@ -875,8 +892,11 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		page_dup_rmap(page);
 		if (PageAnon(page))
 			rss[MM_ANONPAGES]++;
-		else
+		else {
 			rss[MM_FILEPAGES]++;
+			if (PageSwapBacked(page))
+				rss[MM_SHMEMPAGES]++;
+		}
 	}
 
 out_set_pte:
@@ -1140,6 +1160,8 @@ again:
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
 					mark_page_accessed(page);
 				rss[MM_FILEPAGES]--;
+				if (PageSwapBacked(page))
+					rss[MM_SHMEMPAGES]--;
 			}
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
@@ -1171,8 +1193,11 @@ again:
 
 				if (PageAnon(page))
 					rss[MM_ANONPAGES]--;
-				else
+				else {
 					rss[MM_FILEPAGES]--;
+					if (PageSwapBacked(page))
+						rss[MM_SHMEMPAGES]--;
+				}
 			}
 			if (unlikely(!free_swap_and_cache(entry)))
 				print_bad_pte(vma, addr, ptent, NULL);
@@ -1495,7 +1520,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	inc_mm_file_counters_fast(mm, page);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2217,7 +2242,7 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				dec_mm_file_counters_fast(mm, old_page);
 				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else
@@ -2751,7 +2776,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
-		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
+		inc_mm_file_counters_fast(vma->vm_mm, page);
 		page_add_file_rmap(page);
 	}
 	set_pte_at(vma->vm_mm, address, pte, entry);
diff --git a/mm/rmap.c b/mm/rmap.c
index 7928ddd..d40a65b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1168,7 +1168,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			if (PageAnon(page))
 				dec_mm_counter(mm, MM_ANONPAGES);
 			else
-				dec_mm_counter(mm, MM_FILEPAGES);
+				dec_mm_file_counters(mm, page);
 		}
 		set_pte_at(mm, address, pte,
 			   swp_entry_to_pte(make_hwpoison_entry(page)));
@@ -1181,7 +1181,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (PageAnon(page))
 			dec_mm_counter(mm, MM_ANONPAGES);
 		else
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_file_counters(mm, page);
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
@@ -1225,7 +1225,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_file_counters(mm, page);
 
 	page_remove_rmap(page);
 	page_cache_release(page);
@@ -1376,7 +1376,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 		page_remove_rmap(page);
 		page_cache_release(page);
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_file_counters(mm, page);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
