Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 427876B016A
	for <linux-mm@kvack.org>; Sat, 27 Aug 2011 04:32:09 -0400 (EDT)
Received: by fxg9 with SMTP id 9so4194390fxg.14
        for <linux-mm@kvack.org>; Sat, 27 Aug 2011 01:32:05 -0700 (PDT)
Subject: [PATCH] mm: fix page-faults detection in swap-token logic
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 27 Aug 2011 12:32:01 +0300
Message-ID: <20110827083201.21854.56111.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

After commit v2.6.36-5896-gd065bd8 "mm: retry page fault when blocking on disk transfer"
we usually wait in page-faults without mmap_sem held, so all swap-token logic was broken,
because it based on using rwsem_is_locked(&mm->mmap_sem) as sign of in progress page-faults.

This patch adds to mm_struct atomic counter of in progress page-faults for mm with swap-token.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm_types.h |    1 +
 include/linux/swap.h     |   34 ++++++++++++++++++++++++++++++++++
 kernel/fork.c            |    1 +
 mm/memory.c              |   13 +++++++++++++
 mm/rmap.c                |    3 +--
 5 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 774b895..1b299a3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -312,6 +312,7 @@ struct mm_struct {
 	unsigned int faultstamp;
 	unsigned int token_priority;
 	unsigned int last_interval;
+	atomic_t active_swap_token;
 
 	/* How many tasks sharing this mm are OOM_DISABLE */
 	atomic_t oom_disable_count;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 14d6249..3f40636 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -360,6 +360,26 @@ static inline void put_swap_token(struct mm_struct *mm)
 		__put_swap_token(mm);
 }
 
+static inline bool has_active_swap_token(struct mm_struct *mm)
+{
+	return has_swap_token(mm) && atomic_read(&mm->active_swap_token);
+}
+
+static inline bool activate_swap_token(struct mm_struct *mm)
+{
+	if (has_swap_token(mm)) {
+		atomic_inc(&mm->active_swap_token);
+		return true;
+	}
+	return false;
+}
+
+static inline void deactivate_swap_token(struct mm_struct *mm, bool swap_token)
+{
+	if (swap_token)
+		atomic_dec(&mm->active_swap_token);
+}
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
@@ -485,6 +505,20 @@ static inline int has_swap_token(struct mm_struct *mm)
 	return 0;
 }
 
+static inline bool has_active_swap_token(struct mm_struct *mm)
+{
+	return false;
+}
+
+static inline bool activate_swap_token(struct mm_struct *mm)
+{
+	return false;
+}
+
+static inline void deactivate_swap_token(struct mm_struct *mm, bool swap_token)
+{
+}
+
 static inline void disable_swap_token(struct mem_cgroup *memcg)
 {
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e6b6f4..494b75c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -735,6 +735,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	/* Initializing for Swap token stuff */
 	mm->token_priority = 0;
 	mm->last_interval = 0;
+	atomic_set(&mm->active_swap_token, 0);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
diff --git a/mm/memory.c b/mm/memory.c
index a56e3ba..6f42218 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2861,6 +2861,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct mem_cgroup *ptr;
 	int exclusive = 0;
 	int ret = 0;
+	bool swap_token;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		goto out;
@@ -2909,7 +2910,12 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_release;
 	}
 
+	swap_token = activate_swap_token(mm);
+
 	locked = lock_page_or_retry(page, mm, flags);
+
+	deactivate_swap_token(mm, swap_token);
+
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
 		ret |= VM_FAULT_RETRY;
@@ -3156,6 +3162,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_fault vmf;
 	int ret;
 	int page_mkwrite = 0;
+	bool swap_token;
 
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
@@ -3177,6 +3184,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		cow_page = NULL;
 
+	swap_token = activate_swap_token(mm);
+
 	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
@@ -3245,6 +3254,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	}
 
+	deactivate_swap_token(mm, swap_token);
+
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/*
@@ -3316,9 +3327,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 
 unwritable_page:
+	deactivate_swap_token(mm, swap_token);
 	page_cache_release(page);
 	return ret;
 uncharge_out:
+	deactivate_swap_token(mm, swap_token);
 	/* fs's fault handler get error */
 	if (cow_page) {
 		mem_cgroup_uncharge_page(cow_page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 8005080..f54a6dd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -715,8 +715,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_swap_token(mm) &&
-			rwsem_is_locked(&mm->mmap_sem))
+	if (mm != current->mm && has_active_swap_token(mm))
 		referenced++;
 
 	(*mapcount)--;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
