Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7616B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:15:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so468286wme.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:15:45 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id n15si36799279wjw.185.2016.06.22.04.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:15:43 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 187so199671wmz.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:15:43 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH v2 1/3] mm, thp: revert allocstall comparing
Date: Wed, 22 Jun 2016 14:15:19 +0300
Message-Id: <1466594120-2905-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch takes back allocstall comparing when deciding
whether swapin worthwhile because it does not work,
if vmevent disabled.

Related commit:
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=2548306628308aa6a326640d345a737bc898941d

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
Suggested-by: Michal Hocko <mhocko@kernel.org>
---
Changes in v2:
 - Add Suggested-by tag (Minchan Kim)

 mm/huge_memory.c | 30 ++++++++----------------------
 1 file changed, 8 insertions(+), 22 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index acd374e..34fec1f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,7 +102,6 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly;
 static unsigned int khugepaged_max_ptes_swap __read_mostly;
-static unsigned long allocstall;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -2465,7 +2464,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated = 0, result = 0;
-	unsigned long swap, curr_allocstall;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2488,8 +2486,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	swap = get_mm_counter(mm, MM_SWAPENTS);
-	curr_allocstall = sum_vm_event(ALLOCSTALL);
 	down_read(&mm->mmap_sem);
 	result = hugepage_vma_revalidate(mm, address);
 	if (result) {
@@ -2507,20 +2503,14 @@ static void collapse_huge_page(struct mm_struct *mm,
 	}
 
 	/*
-	 * Don't perform swapin readahead when the system is under pressure,
-	 * to avoid unnecessary resource consumption.
+	 * __collapse_huge_page_swapin always returns with mmap_sem
+	 * locked.  If it fails, release mmap_sem and jump directly
+	 * out.  Continuing to collapse causes inconsistency.
 	 */
-	if (allocstall == curr_allocstall && swap != 0) {
-		/*
-		 * __collapse_huge_page_swapin always returns with mmap_sem
-		 * locked.  If it fails, release mmap_sem and jump directly
-		 * out.  Continuing to collapse causes inconsistency.
-		 */
-		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
-			mem_cgroup_cancel_charge(new_page, memcg, true);
-			up_read(&mm->mmap_sem);
-			goto out_nolock;
-		}
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+		mem_cgroup_cancel_charge(new_page, memcg, true);
+		up_read(&mm->mmap_sem);
+		goto out_nolock;
 	}
 
 	up_read(&mm->mmap_sem);
@@ -2935,7 +2925,6 @@ static void khugepaged_wait_work(void)
 		if (!scan_sleep_jiffies)
 			return;
 
-		allocstall = sum_vm_event(ALLOCSTALL);
 		khugepaged_sleep_expire = jiffies + scan_sleep_jiffies;
 		wait_event_freezable_timeout(khugepaged_wait,
 					     khugepaged_should_wakeup(),
@@ -2943,10 +2932,8 @@ static void khugepaged_wait_work(void)
 		return;
 	}
 
-	if (khugepaged_enabled()) {
-		allocstall = sum_vm_event(ALLOCSTALL);
+	if (khugepaged_enabled())
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
-	}
 }
 
 static int khugepaged(void *none)
@@ -2955,7 +2942,6 @@ static int khugepaged(void *none)
 
 	set_freezable();
 	set_user_nice(current, MAX_NICE);
-	allocstall = sum_vm_event(ALLOCSTALL);
 
 	while (!kthread_should_stop()) {
 		khugepaged_do_scan();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
