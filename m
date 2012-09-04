Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 706856B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 04:42:10 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH V1 2/2] mm: Wrap calls to set_pte_at_notify with invalidate_range_start and invalidate_range_end
Date: Tue,  4 Sep 2012 11:41:21 +0300
Message-Id: <1346748081-1652-3-git-send-email-haggaie@mellanox.com>
In-Reply-To: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
References: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

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
 kernel/events/uprobes.c |  2 ++
 mm/ksm.c                | 13 +++++++++++--
 mm/memory.c             | 15 +++++++++------
 mm/mmu_notifier.c       |  6 ------
 4 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index c08a22d..8af2596 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -145,6 +145,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	/* For try_to_free_swap() and munlock_vma_page() below */
 	lock_page(page);
 
+	mmu_notifier_invalidate_range_start(mm, addr, addr + PAGE_SIZE);
 	err = -EAGAIN;
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
@@ -173,6 +174,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	err = 0;
  unlock:
+	mmu_notifier_invalidate_range_end(mm, addr, addr + PAGE_SIZE);
 	unlock_page(page);
 	return err;
 }
diff --git a/mm/ksm.c b/mm/ksm.c
index 47c8853..7defc02 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -715,9 +715,12 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		goto out;
 
 	BUG_ON(PageTransCompound(page));
+
+	mmu_notifier_invalidate_range_start(mm, addr, addr + PAGE_SIZE);
+
 	ptep = page_check_address(page, mm, addr, &ptl, 0);
 	if (!ptep)
-		goto out;
+		goto out_mn;
 
 	if (pte_write(*ptep) || pte_dirty(*ptep)) {
 		pte_t entry;
@@ -752,6 +755,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 out_unlock:
 	pte_unmap_unlock(ptep, ptl);
+out_mn:
+	mmu_notifier_invalidate_range_end(mm, addr, addr + PAGE_SIZE);
 out:
 	return err;
 }
@@ -794,10 +799,12 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd_present(*pmd))
 		goto out;
 
+	mmu_notifier_invalidate_range_start(mm, addr, addr + PAGE_SIZE);
+
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	if (!pte_same(*ptep, orig_pte)) {
 		pte_unmap_unlock(ptep, ptl);
-		goto out;
+		goto out_mn;
 	}
 
 	get_page(kpage);
@@ -814,6 +821,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 
 	pte_unmap_unlock(ptep, ptl);
 	err = 0;
+out_mn:
+	mmu_notifier_invalidate_range_end(mm, addr, addr + PAGE_SIZE);
 out:
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index b657a2e..402a19e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2698,6 +2698,9 @@ gotten:
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
+	mmu_notifier_invalidate_range_start(mm, address & PAGE_MASK,
+					    (address & PAGE_MASK) + PAGE_SIZE);
+
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -2760,14 +2763,14 @@ gotten:
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
+		mmu_notifier_invalidate_range_end(mm, address & PAGE_MASK,
+			(address & PAGE_MASK) + PAGE_SIZE);
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
