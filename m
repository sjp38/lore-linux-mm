Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0186B0253
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 15:16:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so11139131wmz.1
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:16:17 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id f5si20895790wje.247.2016.06.11.12.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 12:16:15 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id n184so5831330wmn.1
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:16:15 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH 1/3] mm, thp: revert allocstall comparing
Date: Sat, 11 Jun 2016 22:15:59 +0300
Message-Id: <1465672561-29608-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
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
---
 mm/khugepaged.c | 31 ++++++++-----------------------
 1 file changed, 8 insertions(+), 23 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 0ac63f7..e3d8da7 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -68,7 +68,6 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly;
 static unsigned int khugepaged_max_ptes_swap __read_mostly;
-static unsigned long allocstall;
 
 static int khugepaged(void *none);
 
@@ -926,7 +925,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated = 0, result = 0;
-	unsigned long swap, curr_allocstall;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -955,8 +953,6 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	swap = get_mm_counter(mm, MM_SWAPENTS);
-	curr_allocstall = sum_vm_event(ALLOCSTALL);
 	down_read(&mm->mmap_sem);
 	result = hugepage_vma_revalidate(mm, address);
 	if (result) {
@@ -972,22 +968,15 @@ static void collapse_huge_page(struct mm_struct *mm,
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
 	}
-
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
@@ -1822,7 +1811,6 @@ static void khugepaged_wait_work(void)
 		if (!scan_sleep_jiffies)
 			return;
 
-		allocstall = sum_vm_event(ALLOCSTALL);
 		khugepaged_sleep_expire = jiffies + scan_sleep_jiffies;
 		wait_event_freezable_timeout(khugepaged_wait,
 					     khugepaged_should_wakeup(),
@@ -1830,10 +1818,8 @@ static void khugepaged_wait_work(void)
 		return;
 	}
 
-	if (khugepaged_enabled()) {
-		allocstall = sum_vm_event(ALLOCSTALL);
+	if (khugepaged_enabled())
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
-	}
 }
 
 static int khugepaged(void *none)
@@ -1842,7 +1828,6 @@ static int khugepaged(void *none)
 
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
