Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 829CB6B027B
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:30:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so188647716wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:30:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si2730411wjz.179.2015.11.18.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 01:29:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v5 5/6] mm, shmem: add internal shmem resident memory accounting
Date: Wed, 18 Nov 2015 10:29:35 +0100
Message-Id: <1447838976-17607-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
References: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@suse.com>

From: Jerome Marchand <jmarchan@redhat.com>

Currently looking at /proc/<pid>/status or statm, there is no way to
distinguish shmem pages from pages mapped to a regular file (shmem pages are
mapped to /dev/zero), even though their implication in actual memory use is
quite different.

The internal accounting currently counts shmem pages together with regular
files. As a preparation to extend the userspace interfaces, this patch adds
MM_SHMEMPAGES counter to mm_rss_stat to account for shmem pages separately from
MM_FILEPAGES. The next patch will expose it to userspace - this patch doesn't
change the exported values yet, by adding up MM_SHMEMPAGES to MM_FILEPAGES at
places where MM_FILEPAGES was used before. The only user-visible change after
this patch is the OOM killer message that separates the reported "shmem-rss"
from "file-rss".

[vbabka@suse.cz: forward-porting, tweak changelog]
Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Hugh Dickins <hughd@google.com>
---
 arch/s390/mm/pgtable.c   |  5 +----
 fs/proc/task_mmu.c       |  3 ++-
 include/linux/mm.h       | 18 +++++++++++++++++-
 include/linux/mm_types.h |  7 ++++---
 kernel/events/uprobes.c  |  2 +-
 mm/memory.c              | 30 ++++++++++--------------------
 mm/oom_kill.c            |  5 +++--
 mm/rmap.c                | 12 +++---------
 8 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 34f3790..43b9a48 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -603,10 +603,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry, struct mm_struct *mm)
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
index a0338ec..19d190b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -83,7 +83,8 @@ unsigned long task_statm(struct mm_struct *mm,
 			 unsigned long *shared, unsigned long *text,
 			 unsigned long *data, unsigned long *resident)
 {
-	*shared = get_mm_counter(mm, MM_FILEPAGES);
+	*shared = get_mm_counter(mm, MM_FILEPAGES) +
+			get_mm_counter(mm, MM_SHMEMPAGES);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fc9a3b8..25cdec3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1342,10 +1342,26 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
 	atomic_long_dec(&mm->rss_stat.count[member]);
 }
 
+/* Optimized variant when page is already known not to be PageAnon */
+static inline int mm_counter_file(struct page *page)
+{
+	if (PageSwapBacked(page))
+		return MM_SHMEMPAGES;
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
-		get_mm_counter(mm, MM_ANONPAGES);
+		get_mm_counter(mm, MM_ANONPAGES) +
+		get_mm_counter(mm, MM_SHMEMPAGES);
 }
 
 static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5e37e91..22beb22 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -361,9 +361,10 @@ struct core_state {
 };
 
 enum {
-	MM_FILEPAGES,
-	MM_ANONPAGES,
-	MM_SWAPENTS,
+	MM_FILEPAGES,	/* Resident file mapping pages */
+	MM_ANONPAGES,	/* Resident anonymous pages */
+	MM_SWAPENTS,	/* Anonymous swap entries */
+	MM_SHMEMPAGES,	/* Resident shared memory pages */
 	NR_MM_COUNTERS
 };
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 5137399..373a3ab 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -181,7 +181,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
 	if (!PageAnon(page)) {
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter_file(page));
 		inc_mm_counter(mm, MM_ANONPAGES);
 	}
 
diff --git a/mm/memory.c b/mm/memory.c
index 7f3b9f2..f5b8e8c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -826,10 +826,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		} else if (is_migration_entry(entry)) {
 			page = migration_entry_to_page(entry);
 
-			if (PageAnon(page))
-				rss[MM_ANONPAGES]++;
-			else
-				rss[MM_FILEPAGES]++;
+			rss[mm_counter(page)]++;
 
 			if (is_write_migration_entry(entry) &&
 					is_cow_mapping(vm_flags)) {
@@ -868,10 +865,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page, false);
-		if (PageAnon(page))
-			rss[MM_ANONPAGES]++;
-		else
-			rss[MM_FILEPAGES]++;
+		rss[mm_counter(page)]++;
 	}
 
 out_set_pte:
@@ -1107,9 +1101,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
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
@@ -1117,8 +1110,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				if (pte_young(ptent) &&
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
 					mark_page_accessed(page);
-				rss[MM_FILEPAGES]--;
 			}
+			rss[mm_counter(page)]--;
 			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
@@ -1140,11 +1133,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
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
@@ -1454,7 +1443,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	inc_mm_counter_fast(mm, mm_counter_file(page));
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2091,7 +2080,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				dec_mm_counter_fast(mm,
+						mm_counter_file(old_page));
 				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else {
@@ -2815,7 +2805,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address, false);
 	} else {
-		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
+		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page);
 	}
 	set_pte_at(vma->vm_mm, address, pte, entry);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d13a339..5314b20 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -585,10 +585,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
+		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
+		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
 	task_unlock(victim);
 
 	/*
diff --git a/mm/rmap.c b/mm/rmap.c
index e045fea..2d87940 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1450,10 +1450,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (PageHuge(page)) {
 			hugetlb_count_sub(1 << compound_order(page), mm);
 		} else {
-			if (PageAnon(page))
-				dec_mm_counter(mm, MM_ANONPAGES);
-			else
-				dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter(mm, mm_counter(page));
 		}
 		set_pte_at(mm, address, pte,
 			   swp_entry_to_pte(make_hwpoison_entry(page)));
@@ -1463,10 +1460,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * interest anymore. Simply discard the pte, vmscan
 		 * will take care of the rest.
 		 */
-		if (PageAnon(page))
-			dec_mm_counter(mm, MM_ANONPAGES);
-		else
-			dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter(page));
 	} else if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION)) {
 		swp_entry_t entry;
 		pte_t swp_pte;
@@ -1506,7 +1500,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
 		set_pte_at(mm, address, pte, swp_pte);
 	} else
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter_file(page));
 
 	page_remove_rmap(page, PageHuge(page));
 	page_cache_release(page);
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
