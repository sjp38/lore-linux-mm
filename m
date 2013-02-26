Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 6097E6B0023
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:59 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 18:01:57 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 933B62BB0051
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:54 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7rRWW62783694
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:53:27 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85rXL008352
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:53 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 15/24] mm/THP: HPAGE_SHIFT is not a #define on some arch
Date: Tue, 26 Feb 2013 13:35:05 +0530
Message-Id: <1361865914-13911-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On archs like powerpc that support different huge page sizes, HPAGE_SHIFT
and other derived values like HPAGE_PMD_ORDER are not constants. So move
that to hugepage_init

Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/huge_mm.h |    3 ---
 mm/huge_memory.c        |    9 ++++++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1d76f8c..0022b70 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -119,9 +119,6 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 	} while (0)
 extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd);
-#if HPAGE_PMD_ORDER > MAX_ORDER
-#error "hugepages can't be allocated by the buddy allocator"
-#endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
 extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b5783d8..1940ee0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -44,7 +44,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
-static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
+static unsigned int khugepaged_pages_to_scan __read_mostly;
 static unsigned int khugepaged_pages_collapsed;
 static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
@@ -59,7 +59,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  * it would have happened if the vma was large enough during page
  * fault.
  */
-static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
+static unsigned int khugepaged_max_ptes_none __read_mostly;
 
 static int khugepaged(void *none);
 static int mm_slots_hash_init(void);
@@ -621,11 +621,14 @@ static int __init hugepage_init(void)
 	int err;
 	struct kobject *hugepage_kobj;
 
-	if (!has_transparent_hugepage()) {
+	if (!has_transparent_hugepage() || (HPAGE_PMD_ORDER > MAX_ORDER)) {
 		transparent_hugepage_flags = 0;
 		return -EINVAL;
 	}
 
+	khugepaged_pages_to_scan = HPAGE_PMD_NR*8;
+	khugepaged_max_ptes_none = HPAGE_PMD_NR-1;
+
 	err = hugepage_init_sysfs(&hugepage_kobj);
 	if (err)
 		return err;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
