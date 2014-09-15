Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 01D3D6B003A
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:41 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i17so4187425qcy.31
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si14894669qan.67.2014.09.15.07.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:25:40 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH v2 1/5] mm, shmem: Add shmem resident memory accounting
Date: Mon, 15 Sep 2014 16:24:33 +0200
Message-Id: <1410791077-5300-2-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

Currently looking at /proc/<pid>/status or statm, there is no way to
distinguish shmem pages from pages mapped to a regular file (shmem
pages are mapped to /dev/zero), even though their implication in
actual memory use is quite different.
This patch adds MM_SHMEMPAGES counter to mm_rss_stat to account for
shmem pages instead of MM_FILEPAGES.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 arch/s390/mm/pgtable.c   |  5 +----
 fs/proc/task_mmu.c       |  3 ++-
 include/linux/mm.h       | 10 ++++++++++
 include/linux/mm_types.h |  7 ++++---
 kernel/events/uprobes.c  |  2 +-
 mm/filemap_xip.c         |  2 +-
 mm/memory.c              | 28 ++++++++--------------------
 mm/oom_kill.c            |  5 +++--
 mm/rmap.c                | 17 +++++------------
 9 files changed, 35 insertions(+), 44 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 296b61a..740ffdf 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -614,10 +614,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry, struct mm_struct *mm)
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
index 7810aba..32657e3 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -77,7 +77,8 @@ unsigned long task_statm(struct mm_struct *mm,
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
index ebc5f90..a5770b3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1311,9 +1311,19 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
 	atomic_long_dec(&mm->rss_stat.count[member]);
 }
 
+static inline int mm_counter(struct page *page)
+{
+	if (PageAnon(page))
+		return MM_ANONPAGES;
+	if (PageSwapBacked(page))
+		return MM_SHMEMPAGES;
+	return MM_FILEPAGES;
+}
+
 static inline unsigned long get_mm_rss(struct mm_struct *mm)
 {
 	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_SHMEMPAGES) +
 		get_mm_counter(mm, MM_ANONPAGES);
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6e0b286..a89eb2a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -322,9 +322,10 @@ struct core_state {
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
index 1d0af8a..0f660a0 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -188,7 +188,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	lru_cache_add_active_or_unevictable(kpage, vma);
 
 	if (!PageAnon(page)) {
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter(page));
 		inc_mm_counter(mm, MM_ANONPAGES);
 	}
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3..85f0e4b 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter(mm, mm_counter(page));
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			/* must invalidate_page _before_ freeing the page */
diff --git a/mm/memory.c b/mm/memory.c
index 838f929..7c44163 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -829,10 +829,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			else if (is_migration_entry(entry)) {
 				page = migration_entry_to_page(entry);
 
-				if (PageAnon(page))
-					rss[MM_ANONPAGES]++;
-				else
-					rss[MM_FILEPAGES]++;
+				rss[mm_counter(page)]++;
 
 				if (is_write_migration_entry(entry) &&
 				    is_cow_mapping(vm_flags)) {
@@ -872,10 +869,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
@@ -1128,9 +1122,7 @@ again:
 					pte_file_mksoft_dirty(ptfile);
 				set_pte_at(mm, addr, pte, ptfile);
 			}
-			if (PageAnon(page))
-				rss[MM_ANONPAGES]--;
-			else {
+			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
 					force_flush = 1;
 					set_page_dirty(page);
@@ -1138,8 +1130,8 @@ again:
 				if (pte_young(ptent) &&
 				    likely(!(vma->vm_flags & VM_SEQ_READ)))
 					mark_page_accessed(page);
-				rss[MM_FILEPAGES]--;
 			}
+			rss[mm_counter(page)]--;
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
@@ -1167,11 +1159,7 @@ again:
 				struct page *page;
 
 				page = migration_entry_to_page(entry);
-
-				if (PageAnon(page))
-					rss[MM_ANONPAGES]--;
-				else
-					rss[MM_FILEPAGES]--;
+				rss[mm_counter(page)]--;
 			}
 			if (unlikely(!free_swap_and_cache(entry)))
 				print_bad_pte(vma, addr, ptent, NULL);
@@ -1494,7 +1482,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	inc_mm_counter_fast(mm, mm_counter(page));
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2216,7 +2204,7 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				dec_mm_counter_fast(mm, mm_counter(old_page));
 				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else
@@ -2758,7 +2746,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
-		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
+		inc_mm_counter_fast(vma->vm_mm, mm_counter(page));
 		page_add_file_rmap(page);
 	}
 	set_pte_at(vma->vm_mm, address, pte, entry);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bbf405a..aab82e5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -480,10 +480,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
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
index 5fbd0fe..08797b2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1164,12 +1164,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
@@ -1178,10 +1174,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
@@ -1225,7 +1218,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter(page));
 
 	page_remove_rmap(page);
 	page_cache_release(page);
@@ -1376,7 +1369,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 
 		page_remove_rmap(page);
 		page_cache_release(page);
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter(mm, mm_counter(page));
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
