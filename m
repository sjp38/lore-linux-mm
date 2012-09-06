Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 9421B6B0069
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 10:37:26 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH V2 2/2] mm: Wrap calls to set_pte_at_notify with invalidate_range_start and invalidate_range_end
Date: Thu,  6 Sep 2012 17:34:55 +0300
Message-Id: <1346942095-23927-3-git-send-email-haggaie@mellanox.com>
In-Reply-To: <1346942095-23927-1-git-send-email-haggaie@mellanox.com>
References: <20120904150737.a6774600.akpm@linux-foundation.org>
 <1346942095-23927-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

In order to allow sleeping during invalidate_page mmu notifier calls, we
need to avoid calling when holding the PT lock. In addition to its
direct calls, invalidate_page can also be called as a substitute for a
change_pte call, in case the notifier client hasn't implemented
change_pte.

This patch drops the invalidate_page call from change_pte, and instead
wraps all calls to change_pte with invalidate_range_start and
invalidate_range_end calls.

Note that change_pte still cannot sleep after this patch, and that
clients implementing change_pte should not take action on it in case the
number of outstanding invalidate_range_start calls is larger than one,
otherwise they might miss a later invalidation.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 kernel/events/uprobes.c |  5 +++++
 mm/ksm.c                | 21 +++++++++++++++++++--
 mm/memory.c             | 17 +++++++++++------
 mm/mmu_notifier.c       |  6 ------
 4 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c08a22d..abe568b 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -141,10 +141,14 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *ptep;
 	int err;
+	/* For mmu_notifiers */
+	const unsigned long mmun_start = addr;
+	const unsigned long mmun_end   = addr + PAGE_SIZE;
 
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -173,6 +177,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	err = 0;
  unlock:
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..6f00463 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -709,15 +709,22 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	spinlock_t *ptl;
 	int swapped;
 	int err = -EFAULT;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
 		goto out;
 
 	BUG_ON(PageTransCompound(page));
+
+	mmun_start = addr;
+	mmun_end   = addr + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
-		goto out;
+		goto out_mn;
 
 	if (pte_write(*ptep) || pte_dirty(*ptep)) {
 		pte_t entry;
@@ -752,6 +759,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
+out_mn:
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out:
 	return err;
 }
@@ -776,6 +785,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	spinlock_t *ptl;
 	unsigned long addr;
 	int err = -EFAULT;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
@@ -794,10 +805,14 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd_present(*pmd))
 		goto out;
 
+	mmun_start = addr;
+	mmun_end   = addr + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
 		pte_unmap_unlock(ptep, ptl);
-		goto out;
+		goto out_mn;
 	}
 
 	get_page(kpage);
@@ -814,6 +829,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
+out_mn:
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index fe7948f..3c88368 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2527,6 +2527,8 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int ret = 0;
 	int page_mkwrite = 0;
 	struct page *dirty_page = NULL;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
@@ -2704,6 +2706,10 @@ gotten:
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
+	mmun_start = address & PAGE_MASK;
+	mmun_end   = (address & PAGE_MASK) + PAGE_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -2766,14 +2772,13 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
+	if (new_page)
+		page_cache_release(new_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
-	if (new_page) {
-		if (new_page == old_page)
-			/* cow happened, notify before releasing old_page */
-			mmu_notifier_invalidate_page(mm, address);
-		page_cache_release(new_page);
-	}
+	if (new_page)
+		/* Only call the end notifier if the begin was called. */
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 441dae0..89d84d0 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -137,12 +137,6 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
 			mn->ops->change_pte(mn, mm, address, pte);
-		/*
-		 * Some drivers don't have change_pte,
-		 * so we must call invalidate_page in that case.
-		 */
-		else if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address);
 	}
 	srcu_read_unlock(&srcu, id);
 }
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
