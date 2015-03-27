Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5944E6B0071
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:40:54 -0400 (EDT)
Received: by wibg7 with SMTP id g7so32873957wib.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:40:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id co6si4099689wjb.54.2015.03.27.09.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 09:40:47 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/4] mm, shmem: Add shmem resident memory accounting
Date: Fri, 27 Mar 2015 17:40:40 +0100
Message-Id: <1427474441-17708-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
References: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Vlastimil Babka <vbabka@suse.cz>

From: Jerome Marchand <jmarchan@redhat.com>

Currently looking at /proc/<pid>/status or statm, there is no way to
distinguish shmem pages from pages mapped to a regular file (shmem
pages are mapped to /dev/zero), even though their implication in
actual memory use is quite different.
This patch adds MM_SHMEMPAGES counter to mm_rss_stat to account for
shmem pages instead of MM_FILEPAGES.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/s390/mm/pgtable.c   |  5 +----
 fs/proc/task_mmu.c       |  3 ++-
 include/linux/mm.h       | 28 ++++++++++++++++++++++++++++
 include/linux/mm_types.h |  9 ++++++---
 kernel/events/uprobes.c  |  2 +-
 mm/memory.c              | 30 ++++++++++--------------------
 mm/oom_kill.c            |  5 +++--
 mm/rmap.c                | 15 ++++-----------
 8 files changed, 55 insertions(+), 42 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index b2c1542..5bffd5d 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -617,10 +617,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry, struct mm_struct *mm)
 	else if (is_migration_entry(entry)) {
 		struct page *page = migration_entry_to_page(entry);
 
-		if (PageAnon(page))
-			dec_mm_counter(mm, MM_ANONPAGES);
-		else
-			dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter(page));
 	}
 	free_swap_and_cache(entry);
 }
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 1b271ec..e86e137 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -81,7 +81,8 @@ unsigned long task_statm(struct mm_struct *mm,
 			 unsigned long *shared, unsigned long *text,
 			 unsigned long *data, unsigned long *resident)
 {
-	*shared = get_mm_counter(mm, MM_FILEPAGES);
+	*shared = get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_SHMEMPAGES);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..adfbb5b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1364,6 +1364,16 @@ static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
 	return (unsigned long)val;
 }
 
+/* A wrapper for the CONFIG_SHMEM dependent counter */
+static inline unsigned long get_mm_counter_shmem(struct mm_struct *mm)
+{
+#ifdef CONFIG_SHMEM
+	return get_mm_counter(mm, MM_SHMEMPAGES);
+#else
+	return 0;
+#endif
+}
+
 static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
 {
 	atomic_long_add(value, &mm->rss_stat.count[member]);
@@ -1379,9 +1389,27 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
 	atomic_long_dec(&mm->rss_stat.count[member]);
 }
 
+/* Optimized variant when page is already known not to be PageAnon */
+static inline int mm_counter_file(struct page *page)
+{
+#ifdef CONFIG_SHMEM
+	if (PageSwapBacked(page))
+		return MM_SHMEMPAGES;
+#endif
+	return MM_FILEPAGES;
+}
+
+static inline int mm_counter(struct page *page)
+{
+	if (PageAnon(page))
+		return MM_ANONPAGES;
+	return mm_counter_file(page);
+}
+
 static inline unsigned long get_mm_rss(struct mm_struct *mm)
 {
 	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter_shmem(mm) +
 		get_mm_counter(mm, MM_ANONPAGES);
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03a..d3c2372 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -327,9 +327,12 @@ struct core_state {
 };
 
 enum {
-	MM_FILEPAGES,
-	MM_ANONPAGES,
-	MM_SWAPENTS,
+	MM_FILEPAGES,	/* Resident file mapping pages */
+	MM_ANONPAGES,	/* Resident anonymous pages */
+	MM_SWAPENTS,	/* Anonymous swap entries */
+#ifdef CONFIG_SHMEM
+	MM_SHMEMPAGES,	/* Resident shared memory pages */
+#endif
 	NR_MM_COUNTERS
 };
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index cb346f2..0a08fdd 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -188,7 +188,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
 	if (!PageAnon(page)) {
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter_file(page));
 		inc_mm_counter(mm, MM_ANONPAGES);
 	}
 
diff --git a/mm/memory.c b/mm/memory.c
index 411144f..db66400 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -832,10 +832,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		} else if (is_migration_entry(entry)) {
 			page = migration_entry_to_page(entry);
 
-			if (PageAnon(page))
-				rss[MM_ANONPAGES]++;
-			else
-				rss[MM_FILEPAGES]++;
+			rss[mm_counter(page)]++;
 
 			if (is_write_migration_entry(entry) &&
 					is_cow_mapping(vm_flags)) {
@@ -874,10 +871,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
-		if (PageAnon(page))
-			rss[MM_ANONPAGES]++;
-		else
-			rss[MM_FILEPAGES]++;
+		rss[mm_counter(page)]++;
 	}
 
 out_set_pte:
@@ -1113,9 +1107,8 @@ again:
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
-			if (PageAnon(page))
-				rss[MM_ANONPAGES]--;
-			else {
+
+			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
 					force_flush = 1;
 					set_page_dirty(page);
@@ -1123,8 +1116,8 @@ again:
 				if (pte_young(ptent) &&
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
 					mark_page_accessed(page);
-				rss[MM_FILEPAGES]--;
 			}
+			rss[mm_counter(page)]--;
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
@@ -1146,11 +1139,7 @@ again:
 			struct page *page;
 
 			page = migration_entry_to_page(entry);
-
-			if (PageAnon(page))
-				rss[MM_ANONPAGES]--;
-			else
-				rss[MM_FILEPAGES]--;
+			rss[mm_counter(page)]--;
 		}
 		if (unlikely(!free_swap_and_cache(entry)))
 			print_bad_pte(vma, addr, ptent, NULL);
@@ -1460,7 +1449,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	inc_mm_counter_fast(mm, mm_counter_file(page));
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2174,7 +2163,8 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				dec_mm_counter_fast(mm,
+						mm_counter_file(old_page));
 				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else
@@ -2703,7 +2693,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
-		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
+		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page);
 	}
 	set_pte_at(vma->vm_mm, address, pte, entry);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 642f38c..a5ee3a2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -573,10 +573,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
 	mark_tsk_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
+		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
+		K(get_mm_counter_shmem(victim->mm)));
 	task_unlock(victim);
 
 	/*
diff --git a/mm/rmap.c b/mm/rmap.c
index 5e3e090..e3c4392 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1216,12 +1216,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	update_hiwater_rss(mm);
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (!PageHuge(page)) {
-			if (PageAnon(page))
-				dec_mm_counter(mm, MM_ANONPAGES);
-			else
-				dec_mm_counter(mm, MM_FILEPAGES);
-		}
+		if (!PageHuge(page))
+			dec_mm_counter(mm, mm_counter(page));
 		set_pte_at(mm, address, pte,
 			   swp_entry_to_pte(make_hwpoison_entry(page)));
 	} else if (pte_unused(pteval)) {
@@ -1230,10 +1226,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * interest anymore. Simply discard the pte, vmscan
 		 * will take care of the rest.
 		 */
-		if (PageAnon(page))
-			dec_mm_counter(mm, MM_ANONPAGES);
-		else
-			dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter(page));
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
@@ -1276,7 +1269,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter_file(page));
 
 	page_remove_rmap(page);
 	page_cache_release(page);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
