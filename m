Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AEEA86B0265
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:08:17 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id p65so127663177wmp.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:08:17 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id n66si10375477wmb.52.2016.03.20.11.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Mar 2016 11:08:16 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id p65so17586514wmp.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:08:16 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v4 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Date: Sun, 20 Mar 2016 20:07:39 +0200
Message-Id: <1458497259-12753-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1458497259-12753-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1458497259-12753-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently khugepaged makes swapin readahead to improve
THP collapse rate. This patch checks vm statistics
to avoid workload of swapin, if unnecessary. So that
when system under pressure, khugepaged won't consume
resources to swapin.

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
With patch    | 217888 kB |  217088 kB    | 582112 kB |    %99    |
-------------------------------------------------------------------
Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
-------------------------------------------------------------------

                        After swapped in (waiting 10 minutes)
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 604440 kB | 348160 kB     | 195560 kB |    %57    |
-------------------------------------------------------------------
Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
-------------------------------------------------------------------

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Fixes: 363cd76e5b11c ("mm: make swapin readahead to improve thp collapse rate")
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

 mm/huge_memory.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86e9666..104faa1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly;
 static unsigned int khugepaged_max_ptes_swap __read_mostly;
+static unsigned long allocstall;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -2438,7 +2439,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated = 0, result = 0;
-	unsigned long hstart, hend;
+	unsigned long hstart, hend, swap, curr_allocstall;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2493,7 +2494,14 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 	}
 
-	__collapse_huge_page_swapin(mm, vma, address, pmd);
+	swap = get_mm_counter(mm, MM_SWAPENTS);
+	curr_allocstall = sum_vm_event(ALLOCSTALL);
+	/*
+	 * When system under pressure, don't swapin readahead.
+	 * So that avoid unnecessary resource consuming.
+	 */
+	if (allocstall == curr_allocstall && swap != 0)
+		__collapse_huge_page_swapin(mm, vma, address, pmd);
 
 	anon_vma_lock_write(vma->anon_vma);
 
@@ -2905,6 +2913,7 @@ static int khugepaged(void *none)
 	set_user_nice(current, MAX_NICE);
 
 	while (!kthread_should_stop()) {
+		allocstall = sum_vm_event(ALLOCSTALL);
 		khugepaged_do_scan();
 		khugepaged_wait_work();
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
