Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id EC89C6B0006
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:16:46 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] THP: fix comment about memory barrier
Date: Fri,  5 Apr 2013 17:16:39 +0900
Message-Id: <1365149799-839-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Now, memory barrier in __do_huge_pmd_anonymous_page doesn't work.
Because lru_cache_add_lru uses pagevec so it could miss spinlock
easily so above rule was broken so user might see inconsistent data.

I was not first person who pointed out the problem. Mel and Peter
pointed out a few months ago and Peter pointed out further that
even spin_lock/unlock can't make sure it.
http://marc.info/?t=134333512700004

	In particular:

        	*A = a;
        	LOCK
        	UNLOCK
        	*B = b;

	may occur as:

        	LOCK, STORE *B, STORE *A, UNLOCK

At last, Hugh pointed out that even we don't need memory barrier
in there because __SetPageUpdate already have done it from
Nick's [1] explicitly.

So this patch fixes comment on THP and adds same comment for
do_anonymous_page, too because everybody except Hugh was missing
that. It means we needs COMMENT about that.

[1] 0ed361dec "mm: fix PageUptodate data race"

Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
* from v1
  * Add Acked-by from Andrea
  * Comment correction

 mm/huge_memory.c | 11 +++++------
 mm/memory.c      |  5 +++++
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e2f7f5aa..f2f17ff 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -713,6 +713,11 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		return VM_FAULT_OOM;
 
 	clear_huge_page(page, haddr, HPAGE_PMD_NR);
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * clear_huge_page writes become visible before the set_pmd_at()
+	 * write.
+	 */
 	__SetPageUptodate(page);
 
 	spin_lock(&mm->page_table_lock);
@@ -724,12 +729,6 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	} else {
 		pmd_t entry;
 		entry = mk_huge_pmd(page, vma);
-		/*
-		 * The spinlocking to take the lru_lock inside
-		 * page_add_new_anon_rmap() acts as a full memory
-		 * barrier to be sure clear_huge_page writes become
-		 * visible after the set_pmd_at() write.
-		 */
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		pgtable_trans_huge_deposit(mm, pgtable);
diff --git a/mm/memory.c b/mm/memory.c
index 494526a..d0da51e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3196,6 +3196,11 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	page = alloc_zeroed_user_highpage_movable(vma, address);
 	if (!page)
 		goto oom;
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * preceeding stores to the page contents become visible before
+	 * the set_pte_at() write.
+	 */
 	__SetPageUptodate(page);
 
 	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
