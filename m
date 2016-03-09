Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 204BC6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 16:56:05 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n186so4547808wmn.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 13:56:05 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id p3si762121wjp.160.2016.03.09.13.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 13:56:03 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id p65so4604371wmp.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 13:56:03 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH] mm: avoid unnecessary swapin in khugepaged
Date: Wed,  9 Mar 2016 23:55:43 +0200
Message-Id: <1457560543-15910-1-git-send-email-ebru.akagunduz@gmail.com>
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
With patch    | 450964 kB |  450560 kB    | 349036 kB |    %99    |
-------------------------------------------------------------------
Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
-------------------------------------------------------------------

                        After swapped in (waiting 10 minutes)
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 637932 kB | 559104 kB     | 162068 kB |    %69    |
-------------------------------------------------------------------
Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
-------------------------------------------------------------------

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 mm/huge_memory.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7f75292..109a2af 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly;
 static unsigned int khugepaged_max_ptes_swap __read_mostly;
+static unsigned long int allocstall = 0;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -2411,6 +2412,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	unsigned long events[NR_VM_EVENT_ITEMS], swap = 0;
 	gfp_t gfp;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -2463,7 +2465,15 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out;
 	}
 
-	__collapse_huge_page_swapin(mm, vma, address, pmd);
+	all_vm_events(events);
+	swap = get_mm_counter(mm, MM_SWAPENTS);
+
+	/*
+	 * When system under pressure, don't swapin readahead.
+	 * So that avoid unnecessary resource consuming.
+	 */
+	if (allocstall == events[ALLOCSTALL] && swap != 0)
+		__collapse_huge_page_swapin(mm, vma, address, pmd);
 
 	anon_vma_lock_write(vma->anon_vma);
 
@@ -2706,6 +2716,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int progress = 0;
+	unsigned long events[NR_VM_EVENT_ITEMS];
 
 	VM_BUG_ON(!pages);
 	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
@@ -2760,6 +2771,8 @@ skip:
 			VM_BUG_ON(khugepaged_scan.address < hstart ||
 				  khugepaged_scan.address + HPAGE_PMD_SIZE >
 				  hend);
+			all_vm_events(events);
+			allocstall = events[ALLOCSTALL];
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
