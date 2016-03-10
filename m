Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 434366B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 09:54:58 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id tt10so69190349pab.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 06:54:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ll1si6533281pab.144.2016.03.10.06.54.57
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 06:54:57 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: fix deadlock in split_huge_pmd()
Date: Thu, 10 Mar 2016 17:54:06 +0300
Message-Id: <1457621646-119268-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

split_huge_pmd() tries to munlock page with munlock_vma_page(). That
requires the page to locked.

If the is locked by caller, we would get a deadlock:

	Unable to find swap-space signature
	INFO: task trinity-c85:1907 blocked for more than 120 seconds.
	      Not tainted 4.4.0-00032-gf19d0bdced41-dirty #1606
	"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
	trinity-c85     D ffff88084d997608     0  1907    309 0x00000000
	 ffff88084d997608 ffff880800000002 ffff880800000001 ffffffff8348eb60
	 ffffffff82a41be0 1ffff10109b32eb0 ffff88084e18de98 ffff88085635e858
	 ffff88085635e840 ffff8802b63f16c0 ffff88084e18db00 0000000041b58ab3
	Call Trace:
	 [<ffffffff828ac670>] ? __sched_text_start+0x8/0x8
	 [<ffffffff811e9f70>] ? debug_show_all_locks+0x280/0x280
	 [<ffffffff81234a67>] ? debug_lockdep_rcu_enabled+0x77/0x90
	 [<ffffffff828af07f>] schedule+0x9f/0x1c0
	 [<ffffffff828b921e>] schedule_timeout+0x48e/0x600
	 [<ffffffff828b8d90>] ? console_conditional_schedule+0x40/0x40
	 [<ffffffff8126b423>] ? ktime_get+0x143/0x190
	 [<ffffffff811e5f55>] ? trace_hardirqs_on_caller+0x405/0x590
	 [<ffffffff811e60ed>] ? trace_hardirqs_on+0xd/0x10
	 [<ffffffff8126b3db>] ? ktime_get+0xfb/0x190
	 [<ffffffff812f0ce6>] ? __delayacct_blkio_start+0x46/0x90
	 [<ffffffff828afc73>] io_schedule_timeout+0x1c3/0x390
	 [<ffffffff828b0689>] bit_wait_io+0x29/0xd0
	 [<ffffffff828b0004>] __wait_on_bit_lock+0x94/0x140
	 [<ffffffff828b0660>] ? bit_wait+0xc0/0xc0
	 [<ffffffff813aaa24>] __lock_page+0x1d4/0x280
	 [<ffffffff813aa850>] ? page_endio+0x2f0/0x2f0
	 [<ffffffff811d0390>] ? wake_atomic_t_function+0x220/0x220
	 [<ffffffff81181095>] ? __might_sleep+0x95/0x1a0
	 [<ffffffff814f0238>] __split_huge_pmd+0x5a8/0x10f0
	 [<ffffffff814f3849>] split_huge_pmd_address+0x1d9/0x230
	 [<ffffffff81473ef0>] try_to_unmap_one+0x540/0xc70
	 [<ffffffff814739b0>] ? page_remove_rmap+0x8d0/0x8d0
	 [<ffffffff8146f3b4>] rmap_walk_anon+0x284/0x810
	 [<ffffffff8146d9f0>] ? invalid_mkclean_vma+0x50/0x50
	 [<ffffffff8147815e>] rmap_walk_locked+0x11e/0x190
	 [<ffffffff81478381>] try_to_unmap+0x1b1/0x4b0
	 [<ffffffff814781d0>] ? rmap_walk_locked+0x190/0x190
	 [<ffffffff814739b0>] ? page_remove_rmap+0x8d0/0x8d0
	 [<ffffffff8146eac0>] ? rmap_walk_file+0x7b0/0x7b0
	 [<ffffffff81476440>] ? page_get_anon_vma+0x810/0x810
	 [<ffffffff8146d9f0>] ? invalid_mkclean_vma+0x50/0x50
	 [<ffffffff814f3bea>] ? total_mapcount+0xea/0x3e0
	 [<ffffffff814f437d>] split_huge_page_to_list+0x49d/0x18a0
	 [<ffffffff8143e386>] follow_page_mask+0xa36/0xea0
	 [<ffffffff814e0033>] SyS_move_pages+0xaf3/0x1570
	 [<ffffffff814df64c>] ? SyS_move_pages+0x10c/0x1570
	 [<ffffffff814df540>] ? migrate_pages+0x4be0/0x4be0
	 [<ffffffff812346a3>] ? rcu_read_lock_sched_held+0xa3/0x130
	 [<ffffffff814cb80f>] ? kmem_cache_free+0x31f/0x370
	 [<ffffffff8154382d>] ? putname+0x5d/0x140
	 [<ffffffff81002004>] ? lockdep_sys_exit_thunk+0x12/0x14
	 [<ffffffff828bbc17>] entry_SYSCALL_64_fastpath+0x12/0x6b
	2 locks held by trinity-c85/1907:
	 #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff814dfe73>] SyS_move_pages+0x933/0x1570
	 #1:  (&anon_vma->rwsem){++++..}, at: [<ffffffff814f42e2>] split_huge_page_to_list+0x402/0x18a0

I don't think the deadlock is triggerable without split_huge_page()
simplifilcation patchset.

But munlock_vma_page() here is wrong: we want to munlock the page
unconditionally, no need in rmap lookup, that munlock_vma_page() does.

Let's use clear_page_mlock() instead. It can be called under ptl.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: ee0b79212791 ("thp: allow mlocked THP again")
---
 mm/huge_memory.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 76d8c55854b9..305dd0fd4a2f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3054,29 +3054,20 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
-	struct page *page = NULL;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_trans_huge(*pmd)) {
-		page = pmd_page(*pmd);
+		struct page *page = pmd_page(*pmd);
 		if (PageMlocked(page))
-			get_page(page);
-		else
-			page = NULL;
+			clear_page_mlock(page);
 	} else if (!pmd_devmap(*pmd))
 		goto out;
 	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
 out:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
-	if (page) {
-		lock_page(page);
-		munlock_vma_page(page);
-		unlock_page(page);
-		put_page(page);
-	}
 }
 
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
