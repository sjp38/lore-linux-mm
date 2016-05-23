Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF5F26B025F
	for <linux-mm@kvack.org>; Mon, 23 May 2016 13:14:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o70so24822935lfg.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:14:49 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id l127si17370310wmg.108.2016.05.23.10.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 10:14:46 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id f75so10745810wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:14:46 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH 3/3] mm, thp: make swapin readahead under down_read of mmap_sem
Date: Mon, 23 May 2016 20:14:11 +0300
Message-Id: <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Currently khugepaged makes swapin readahead under
down_write. This patch supplies to make swapin
readahead under down_read instead of down_write.

The patch was tested with a test program that allocates
800MB of memory, writes to it, and then sleeps. The system
was forced to swap out all. Afterwards, the test program
touches the area by writing, it skips a page in each
20 pages of the area.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 mm/huge_memory.c | 33 +++++++++++++++++++++++++++------
 1 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index feee44c..668bc07 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2386,13 +2386,14 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
  * but with mmap_sem held to protect against vma changes.
  */
 
-static void __collapse_huge_page_swapin(struct mm_struct *mm,
+static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd)
 {
 	unsigned long _address;
 	pte_t *pte, pteval;
 	int swapped_in = 0, ret = 0;
+	struct vm_area_struct *vma_orig = vma;
 
 	pte = pte_offset_map(pmd, address);
 	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
@@ -2402,11 +2403,19 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 			continue;
 		swapped_in++;
 		ret = do_swap_page(mm, vma, _address, pte, pmd,
-				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
+				   FAULT_FLAG_ALLOW_RETRY,
 				   pteval);
+		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
+		if (ret & VM_FAULT_RETRY) {
+			down_read(&mm->mmap_sem);
+			vma = find_vma(mm, address);
+			/* vma is no longer available, don't continue to swapin */
+			if (vma != vma_orig)
+				return false;
+		}
 		if (ret & VM_FAULT_ERROR) {
 			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
-			return;
+			return false;
 		}
 		/* pte is unmapped now, we need to map it */
 		pte = pte_offset_map(pmd, _address);
@@ -2414,6 +2423,7 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
 	pte--;
 	pte_unmap(pte);
 	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
+	return true;
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
@@ -2459,7 +2469,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * gup_fast later hanlded by the ptep_clear_flush and the VM
 	 * handled by the anon_vma lock + PG_lock.
 	 */
-	down_write(&mm->mmap_sem);
+	down_read(&mm->mmap_sem);
 	if (unlikely(khugepaged_test_exit(mm))) {
 		result = SCAN_ANY_PROCESS;
 		goto out;
@@ -2490,9 +2500,20 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * Don't perform swapin readahead when the system is under pressure,
 	 * to avoid unnecessary resource consumption.
 	 */
-	if (allocstall == curr_allocstall && swap != 0)
-		__collapse_huge_page_swapin(mm, vma, address, pmd);
+	if (allocstall == curr_allocstall && swap != 0) {
+		/*
+		 * __collapse_huge_page_swapin always returns with mmap_sem
+		 * locked. If it fails, release mmap_sem and jump directly
+		 * label out. Continuing to collapse causes inconsistency.
+		 */
+		if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+			up_read(&mm->mmap_sem);
+			goto out;
+		}
+	}
 
+	up_read(&mm->mmap_sem);
+	down_write(&mm->mmap_sem);
 	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
