Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 99F57828DF
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:40:30 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id l68so126954957wml.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:40:30 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id q140si20930993wmg.33.2016.03.14.14.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 14:40:29 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id l68so119928667wml.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:40:29 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v3 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Date: Mon, 14 Mar 2016 23:40:11 +0200
Message-Id: <1457991611-6211-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
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
With patch    | 206608 kB |  204800 kB    | 593392 kB |    %99    |
-------------------------------------------------------------------
Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
-------------------------------------------------------------------

                        After swapped in (waiting 10 minutes)
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 551992 kB | 368640 kB     | 248008 kB |    %66    |
-------------------------------------------------------------------
Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
-------------------------------------------------------------------

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
Changes in v2:
 - Add reference to specify which patch fixed (Ebru Akagunduz)
 - Fix commit subject line (Ebru Akagunduz)

Changes in v3:
 - Remove default values of allocstall (Kirill A. Shutemov)

 mm/huge_memory.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86e9666..67a398c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly;
 static unsigned int khugepaged_max_ptes_swap __read_mostly;
+static unsigned long int allocstall;
 
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
 
@@ -2790,6 +2798,7 @@ skip:
 			VM_BUG_ON(khugepaged_scan.address < hstart ||
 				  khugepaged_scan.address + HPAGE_PMD_SIZE >
 				  hend);
+			allocstall = sum_vm_event(ALLOCSTALL);
 			ret = khugepaged_scan_pmd(mm, vma,
 						  khugepaged_scan.address,
 						  hpage);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
