Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 904B26B0039
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:13:06 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so23880896qaq.25
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:13:06 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id b79si11197227qge.129.2014.02.18.14.13.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:13:05 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH -mm 3/3] move mmu notifier call from change_protection to change_pmd_range
Date: Tue, 18 Feb 2014 17:12:46 -0500
Message-Id: <1392761566-24834-4-git-send-email-riel@redhat.com>
In-Reply-To: <1392761566-24834-1-git-send-email-riel@redhat.com>
References: <1392761566-24834-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

From: Rik van Riel <riel@redhat.com>

The NUMA scanning code can end up iterating over many gigabytes
of unpopulated memory, especially in the case of a freshly started
KVM guest with lots of memory.

This results in the mmu notifier code being called even when
there are no mapped pages in a virtual address range. The amount
of time wasted can be enough to trigger soft lockup warnings
with very large KVM guests.

This patch moves the mmu notifier call to the pmd level, which
represents 1GB areas of memory on x86-64. Furthermore, the mmu
notifier code is only called from the address in the PMD where
present mappings are first encountered.

The hugetlbfs code is left alone for now; hugetlb mappings are
not relocatable, and as such are left alone by the NUMA code,
and should never trigger this problem to begin with.

Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Xing Gang <gang.xing@hp.com>
Tested-by: Chegu Vinod <chegu_vinod@hp.com>
---
 mm/mprotect.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 6006c05..44850ee 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -109,9 +109,11 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pgprot_t newprot, int dirty_accountable, int prot_numa)
 {
 	pmd_t *pmd;
+	struct mm_struct *mm = vma->vm_mm;
 	unsigned long next;
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
+	unsigned long mni_start = 0;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -120,6 +122,13 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		next = pmd_addr_end(addr, end);
 		if (!pmd_trans_huge(*pmd) && pmd_none_or_clear_bad(pmd))
 				continue;
+
+		/* invoke the mmu notifier if the pmd is populated */
+		if (!mni_start) {
+			mni_start = addr;
+			mmu_notifier_invalidate_range_start(mm, mni_start, end);
+		}
+
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_page_pmd(vma, addr, pmd);
@@ -143,6 +152,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pages += this_pages;
 	} while (pmd++, addr = next, addr != end);
 
+	if (mni_start)
+		mmu_notifier_invalidate_range_end(mm, mni_start, end);
+
 	if (nr_huge_updates)
 		count_vm_numa_events(NUMA_HUGE_PTE_UPDATES, nr_huge_updates);
 	return pages;
@@ -205,12 +217,12 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long pages;
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
-	if (is_vm_hugetlb_page(vma))
+	if (is_vm_hugetlb_page(vma)) {
+		mmu_notifier_invalidate_range_start(mm, start, end);
 		pages = hugetlb_change_protection(vma, start, end, newprot);
-	else
+		mmu_notifier_invalidate_range_end(mm, start, end);
+	} else
 		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
-	mmu_notifier_invalidate_range_end(mm, start, end);
 
 	return pages;
 }
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
