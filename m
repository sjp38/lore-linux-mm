Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D61C6B026A
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 18:33:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so40148027pgb.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:31 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 33si26799953ply.217.2017.02.03.15.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 15:33:29 -0800 (PST)
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v13NWZDW015221
	for <linux-mm@kvack.org>; Fri, 3 Feb 2017 15:33:29 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 28d16krb74-9
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:29 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 28a0562cea6911e69b7624be05956610-563696d0 for <linux-mm@kvack.org>;	Fri, 03
 Feb 2017 15:33:26 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V2 7/7] mm: add a separate RSS for MADV_FREE pages
Date: Fri, 3 Feb 2017 15:33:23 -0800
Message-ID: <123396e3b523e8716dfc6fc87a5cea0c124ff29d.1486163864.git.shli@fb.com>
In-Reply-To: <cover.1486163864.git.shli@fb.com>
References: <cover.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Add a separate RSS for MADV_FREE pages. The pages are charged into
MM_ANONPAGES (because they are mapped anon pages) and also charged into
the MM_LAZYFREEPAGES. /proc/pid/statm will have an extra field to
display the RSS, which userspace can use to determine the RSS excluding
MADV_FREE pages.

The basic idea is to increment the RSS in madvise and decrement in unmap
or page reclaim. There is one limitation. If a page is shared by two
processes, since madvise only has mm cotext of current process, it isn't
convenient to charge the RSS for both processes. So we don't charge the
RSS if the mapcount isn't 1. On the other hand, fork can make a
MADV_FREE page shared by two processes. To make things consistent, we
uncharge the RSS from the source mm in fork.

A new flag is added to indicate if a page is accounted into the RSS. We
can't use SwapBacked flag to do the determination because we can't
guarantee the page has SwapBacked flag cleared in madvise. We are
reusing mappedtodisk flag which should not be set for Anon pages.

There are a couple of other places we need to uncharge the RSS,
activate_page and mark_page_accessed. activate_page is used by swap,
where MADV_FREE pages are already not in lazyfree state before going
into swap. mark_page_accessed is mainly used for file pages, but there
are several places it's used by anonymous pages. I fixed gup, but not
some gpu drivers and kvm. If the drivers use MADV_FREE, we might have
inprecise RSS accounting.

Please note, the accounting is never going to be precise. MADV_FREE page
could be written by userspace without notification to the kernel. The
page can't be reclaimed like other clean lazyfree pages. The page isn't
real lazyfree page. But since kernel isn't aware of this, the page is
still accounted as lazyfree, thus the accounting could be incorrect.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 fs/proc/array.c            |  9 ++++++---
 fs/proc/internal.h         |  3 ++-
 fs/proc/task_mmu.c         |  9 +++++++--
 fs/proc/task_nommu.c       |  4 +++-
 include/linux/mm_types.h   |  1 +
 include/linux/page-flags.h |  6 ++++++
 mm/gup.c                   |  2 ++
 mm/huge_memory.c           |  8 ++++++++
 mm/khugepaged.c            |  2 ++
 mm/madvise.c               |  5 +++++
 mm/memory.c                | 13 +++++++++++--
 mm/migrate.c               |  2 ++
 mm/oom_kill.c              | 10 ++++++----
 mm/rmap.c                  |  3 +++
 14 files changed, 64 insertions(+), 13 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 51a4213..c2281f4 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -583,17 +583,19 @@ int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
 	unsigned long size = 0, resident = 0, shared = 0, text = 0, data = 0;
+	unsigned long lazyfree = 0;
 	struct mm_struct *mm = get_task_mm(task);
 
 	if (mm) {
-		size = task_statm(mm, &shared, &text, &data, &resident);
+		size = task_statm(mm, &shared, &text, &data, &resident,
+				  &lazyfree);
 		mmput(mm);
 	}
 	/*
 	 * For quick read, open code by putting numbers directly
 	 * expected format is
-	 * seq_printf(m, "%lu %lu %lu %lu 0 %lu 0\n",
-	 *               size, resident, shared, text, data);
+	 * seq_printf(m, "%lu %lu %lu %lu 0 %lu 0 %lu\n",
+	 *               size, resident, shared, text, data, lazyfree);
 	 */
 	seq_put_decimal_ull(m, "", size);
 	seq_put_decimal_ull(m, " ", resident);
@@ -602,6 +604,7 @@ int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 	seq_put_decimal_ull(m, " ", 0);
 	seq_put_decimal_ull(m, " ", data);
 	seq_put_decimal_ull(m, " ", 0);
+	seq_put_decimal_ull(m, " ", lazyfree);
 	seq_putc(m, '\n');
 
 	return 0;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index e2c3c46..6587b9c 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -290,5 +290,6 @@ extern const struct file_operations proc_pagemap_operations;
 extern unsigned long task_vsize(struct mm_struct *);
 extern unsigned long task_statm(struct mm_struct *,
 				unsigned long *, unsigned long *,
-				unsigned long *, unsigned long *);
+				unsigned long *, unsigned long *,
+				unsigned long *);
 extern void task_mem(struct seq_file *, struct mm_struct *);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8f2423f..f18b568 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -23,9 +23,10 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long text, lib, swap, ptes, pmds, anon, file, shmem;
+	unsigned long text, lib, swap, ptes, pmds, anon, file, shmem, lazyfree;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
+	lazyfree = get_mm_counter(mm, MM_LAZYFREEPAGES);
 	anon = get_mm_counter(mm, MM_ANONPAGES);
 	file = get_mm_counter(mm, MM_FILEPAGES);
 	shmem = get_mm_counter(mm, MM_SHMEMPAGES);
@@ -59,6 +60,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"RssAnon:\t%8lu kB\n"
 		"RssFile:\t%8lu kB\n"
 		"RssShmem:\t%8lu kB\n"
+		"RssLazyfree:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
@@ -75,6 +77,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		anon << (PAGE_SHIFT-10),
 		file << (PAGE_SHIFT-10),
 		shmem << (PAGE_SHIFT-10),
+		lazyfree << (PAGE_SHIFT-10),
 		mm->data_vm << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		ptes >> 10,
@@ -90,7 +93,8 @@ unsigned long task_vsize(struct mm_struct *mm)
 
 unsigned long task_statm(struct mm_struct *mm,
 			 unsigned long *shared, unsigned long *text,
-			 unsigned long *data, unsigned long *resident)
+			 unsigned long *data, unsigned long *resident,
+			 unsigned long *lazyfree)
 {
 	*shared = get_mm_counter(mm, MM_FILEPAGES) +
 			get_mm_counter(mm, MM_SHMEMPAGES);
@@ -98,6 +102,7 @@ unsigned long task_statm(struct mm_struct *mm,
 								>> PAGE_SHIFT;
 	*data = mm->data_vm + mm->stack_vm;
 	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
+	*lazyfree = get_mm_counter(mm, MM_LAZYFREEPAGES);
 	return mm->total_vm;
 }
 
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 1ef97cf..50426de 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -94,7 +94,8 @@ unsigned long task_vsize(struct mm_struct *mm)
 
 unsigned long task_statm(struct mm_struct *mm,
 			 unsigned long *shared, unsigned long *text,
-			 unsigned long *data, unsigned long *resident)
+			 unsigned long *data, unsigned long *resident,
+			 unsigned long *lazyfree)
 {
 	struct vm_area_struct *vma;
 	struct vm_region *region;
@@ -120,6 +121,7 @@ unsigned long task_statm(struct mm_struct *mm,
 	size >>= PAGE_SHIFT;
 	size += *text + *data;
 	*resident = size;
+	*lazyfree = 0;
 	return size;
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4f6d440..b6a1428 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -376,6 +376,7 @@ enum {
 	MM_ANONPAGES,	/* Resident anonymous pages */
 	MM_SWAPENTS,	/* Anonymous swap entries */
 	MM_SHMEMPAGES,	/* Resident shared memory pages */
+	MM_LAZYFREEPAGES, /* Lazyfree pages, also charged into MM_ANONPAGES */
 	NR_MM_COUNTERS
 };
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6b5818d..67c732b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -107,6 +107,8 @@ enum pageflags {
 #endif
 	__NR_PAGEFLAGS,
 
+	PG_lazyfreeaccounted = PG_mappedtodisk, /* only for anon MADV_FREE pages */
+
 	/* Filesystems */
 	PG_checked = PG_owner_priv_1,
 
@@ -428,6 +430,10 @@ TESTPAGEFLAG_FALSE(Ksm)
 
 u64 stable_page_flags(struct page *page);
 
+PAGEFLAG(LazyFreeAccounted, lazyfreeaccounted, PF_ANY)
+	TESTSETFLAG(LazyFreeAccounted, lazyfreeaccounted, PF_ANY)
+	TESTCLEARFLAG(LazyFreeAccounted, lazyfreeaccounted, PF_ANY)
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret;
diff --git a/mm/gup.c b/mm/gup.c
index 40abe4c..e64d990 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -171,6 +171,8 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		 * mark_page_accessed().
 		 */
 		mark_page_accessed(page);
+		if (PageAnon(page) && TestClearPageLazyFreeAccounted(page))
+			dec_mm_counter(mm, MM_LAZYFREEPAGES);
 	}
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		/* Do not mlock pte-mapped THP */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ddb9a94..951fa34 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -871,6 +871,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
 	page_dup_rmap(src_page, true);
+	if (PageAnon(src_page) && TestClearPageLazyFreeAccounted(src_page))
+		add_mm_counter(src_mm, MM_LAZYFREEPAGES, -HPAGE_PMD_NR);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 	atomic_long_inc(&dst_mm->nr_ptes);
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
@@ -1402,6 +1404,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	}
 
+	if (page_mapcount(page) == 1 && !TestSetPageLazyFreeAccounted(page))
+		add_mm_counter(mm, MM_LAZYFREEPAGES, HPAGE_PMD_NR);
 	mark_page_lazyfree(page);
 	ret = true;
 out:
@@ -1459,6 +1463,9 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			pte_free(tlb->mm, pgtable);
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			if (TestClearPageLazyFreeAccounted(page))
+				add_mm_counter(tlb->mm, MM_LAZYFREEPAGES,
+						-HPAGE_PMD_NR);
 		} else {
 			if (arch_needs_pgtable_deposit())
 				zap_deposited_table(tlb->mm, pmd);
@@ -1917,6 +1924,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_swapbacked) |
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
+			 (1L << PG_lazyfreeaccounted) |
 			 (1L << PG_active) |
 			 (1L << PG_locked) |
 			 (1L << PG_unevictable) |
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a4b499f..e4668db 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -577,6 +577,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		}
 		inc_node_page_state(page,
 				NR_ISOLATED_ANON + page_is_file_cache(page));
+		if (TestClearPageLazyFreeAccounted(page))
+			dec_mm_counter(vma->vm_mm, MM_LAZYFREEPAGES);
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/madvise.c b/mm/madvise.c
index fe40e93..3c90956 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -275,6 +275,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	struct page *page;
 	int nr_swap = 0;
 	unsigned long next;
+	int nr_lazyfree_accounted = 0;
 
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd))
@@ -380,9 +381,13 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			set_pte_at(mm, addr, pte, ptent);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
+		if (page_mapcount(page) == 1 &&
+		    !TestSetPageLazyFreeAccounted(page))
+			nr_lazyfree_accounted++;
 		mark_page_lazyfree(page);
 	}
 out:
+	add_mm_counter(mm, MM_LAZYFREEPAGES, nr_lazyfree_accounted);
 	if (nr_swap) {
 		if (current->mm == mm)
 			sync_mm_rss(mm);
diff --git a/mm/memory.c b/mm/memory.c
index cf97d88..e275de1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -850,7 +850,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 static inline unsigned long
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
-		unsigned long addr, int *rss)
+		unsigned long addr, int *rss, int *rss_src_lazyfree)
 {
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
@@ -915,6 +915,9 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page, false);
+		if (PageAnon(page) &&
+		    TestClearPageLazyFreeAccounted(page))
+			(*rss_src_lazyfree)++;
 		rss[mm_counter(page)]++;
 	}
 
@@ -932,10 +935,12 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[NR_MM_COUNTERS];
+	int rss_src_lazyfree;
 	swp_entry_t entry = (swp_entry_t){0};
 
 again:
 	init_rss_vec(rss);
+	rss_src_lazyfree = 0;
 
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
@@ -963,13 +968,14 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			continue;
 		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
-							vma, addr, rss);
+					vma, addr, rss, &rss_src_lazyfree);
 		if (entry.val)
 			break;
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
+	add_mm_counter(src_mm, MM_LAZYFREEPAGES, -rss_src_lazyfree);
 	spin_unlock(src_ptl);
 	pte_unmap(orig_src_pte);
 	add_mm_rss_vec(dst_mm, rss);
@@ -1163,6 +1169,9 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 					mark_page_accessed(page);
 			}
 			rss[mm_counter(page)]--;
+			if (PageAnon(page) &&
+			    TestClearPageLazyFreeAccounted(page))
+				rss[MM_LAZYFREEPAGES]--;
 			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
diff --git a/mm/migrate.c b/mm/migrate.c
index eb76f87..6e586d2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -642,6 +642,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
+	if (PageLazyFreeAccounted(page))
+		SetPageLazyFreeAccounted(newpage);
 
 	/* Move dirty on pages not done by migrate_page_move_mapping() */
 	if (PageDirty(page))
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 51c0918..54e0604 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -528,11 +528,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 					 NULL);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
-	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, lazyfree-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+			K(get_mm_counter(mm, MM_SHMEMPAGES)),
+			K(get_mm_counter(mm, MM_LAZYFREEPAGES)));
 	up_read(&mm->mmap_sem);
 
 	/*
@@ -878,11 +879,12 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
-	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
+	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, lazyfree-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
+		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
+		K(get_mm_counter(victim->mm, MM_LAZYFREEPAGES)));
 	task_unlock(victim);
 
 	/*
diff --git a/mm/rmap.c b/mm/rmap.c
index 5f05926..86c80d7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1585,6 +1585,9 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	put_page(page);
 
 out_unmap:
+	/* regardless of success or failure, the page isn't lazyfree */
+	if (PageAnon(page) && TestClearPageLazyFreeAccounted(page))
+		add_mm_counter(mm, MM_LAZYFREEPAGES, -hpage_nr_pages(page));
 	pte_unmap_unlock(pte, ptl);
 	if (ret != SWAP_FAIL && ret != SWAP_MLOCK && !(flags & TTU_MUNLOCK))
 		mmu_notifier_invalidate_page(mm, address);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
