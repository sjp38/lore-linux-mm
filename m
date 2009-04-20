Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE7D45F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 16:25:42 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: fix pageref leak in do_swap_page()
Date: Mon, 20 Apr 2009 22:24:43 +0200
Message-Id: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

By the time the memory cgroup code is notified about a swapin we
already hold a reference on the fault page.

If the cgroup callback fails make sure to unlock AND release the page
or we leak the reference.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 366dab5..db126b6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2536,8 +2536,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
 		ret = VM_FAULT_OOM;
-		unlock_page(page);
-		goto out;
+		goto out_page;
 	}
 
 	/*
@@ -2599,6 +2598,7 @@ out:
 out_nomap:
 	mem_cgroup_cancel_charge_swapin(ptr);
 	pte_unmap_unlock(page_table, ptl);
+out_page:
 	unlock_page(page);
 	page_cache_release(page);
 	return ret;
-- 
1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
