Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A18B76B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 13:28:15 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id v188so64005341wme.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 10:28:15 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id op7si9480349wjc.120.2016.04.07.10.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 10:28:14 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id n3so114078833wmn.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 10:28:14 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v5 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Date: Thu,  7 Apr 2016 20:28:01 +0300
Message-Id: <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently khugepaged makes swapin readahead to improve
THP collapse rate. This patch checks vm statistics
to avoid workload of swapin, if unnecessary. So that
when system under pressure, khugepaged won't consume
resources to swapin and won't trigger direct reclaim
when swapin readahead.

The patch was tested with a test program that allocates
800MB of memory, writes to it, and then sleeps. The system
was forced to swap out all. Afterwards, the test program
touches the area by writing, it skips a page in each
20 pages of the area. When waiting to swapin readahead
left part of the test, the memory forced to be busy
doing page reclaim. There was enough free memory during
test, khugepaged did not swapin readahead due to business.

Test results:

                        After swapped out
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 0 kB      |  0 kB         | 800000 kB |    %100   |
-------------------------------------------------------------------
Without patch | 0 kB      |  0 kB         | 800000 kB |    %100   |
-------------------------------------------------------------------

                        After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 384812 kB | 96256 kB      | 415188 kB |    %25    |
-------------------------------------------------------------------
Without patch | 389728 kB | 194560 kB     | 410272 kB |    %49    |
-------------------------------------------------------------------

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
Changes in v2:
 - Add reference to specify which patch fixed (Ebru Akagunduz)
 - Fix commit subject line (Ebru Akagunduz)

Changes in v3:
 - Remove default values of allocstall (Kirill A. Shutemov)

Changes in v4:
 - define unsigned long allocstall instead of unsigned long int
   (Vlastimil Babka)
 - compare allocstall when khugepaged goes to sleep
   (Rik van Riel, Vlastimil Babka)

Changes in v5:
 - Drop fixes sha part because fixed patch is not in Linus's tree
   (Michal Hocko)
 - Save allocstall where khugepaged exactly sleeps (Michal Hocko)


Note: I didn't add optimistic swapin and mmap_sem in this
      patch series. I couldn't overcome yet.
      I'll send them after the series ends up.

 mm/huge_memory.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8202141..e7d905c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly;
 static unsigned int khugepaged_max_ptes_swap __read_mostly = HPAGE_PMD_NR/8;
+static unsigned long allocstall;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -2437,7 +2438,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated = 0, result = 0;
-	unsigned long hstart, hend;
+	unsigned long hstart, hend, swap, curr_allocstall;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2492,7 +2493,14 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 	}
 
-	__collapse_huge_page_swapin(mm, vma, address, pmd);
+	swap = get_mm_counter(mm, MM_SWAPENTS);
+	curr_allocstall = sum_vm_event(ALLOCSTALL);
+	/*
+	 * When system under pressure, don't swapin readahead.
+	 * So that avoid unnecessary resource consuming.
+	 */
+	if (allocstall == curr_allocstall && swap !=)
+		__collapse_huge_page_swapin(mm, vma, address, pmd);
 
 	anon_vma_lock_write(vma->anon_vma);
 
@@ -2886,14 +2894,17 @@ static void khugepaged_wait_work(void)
 		if (!khugepaged_scan_sleep_millisecs)
 			return;
 
+		allocstall = sum_vm_event(ALLOCSTALL);
 		wait_event_freezable_timeout(khugepaged_wait,
 					     kthread_should_stop(),
 			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
 		return;
 	}
 
-	if (khugepaged_enabled())
+	if (khugepaged_enabled()) {
+		allocstall = sum_vm_event(ALLOCSTALL);
 		wait_event_freezable(khugepaged_wait, khugepaged_wait_event());
+	}
 }
 
 static int khugepaged(void *none)
@@ -2902,6 +2913,7 @@ static int khugepaged(void *none)
 
 	set_freezable();
 	set_user_nice(current, MAX_NICE);
+	allocstall = sum_vm_event(ALLOCSTALL);
 
 	while (!kthread_should_stop()) {
 		khugepaged_do_scan();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
