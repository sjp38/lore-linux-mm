Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D768E6B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:05:48 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so1319217pad.15
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:05:48 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id xj14si9799432pac.113.2014.10.27.00.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 00:05:47 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1828220pdb.13
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:05:47 -0700 (PDT)
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: [PATCH v2] smaps should deal with huge zero page exactly same as normal zero page.
Date: Mon, 27 Oct 2014 23:02:13 +0800
Message-Id: <1414422133-7929-1-git-send-email-yfw.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

We could see following memory info in /proc/xxxx/smaps with THP enabled.
  7bea458b3000-7fea458b3000 r--p 00000000 00:13 39989  /dev/zero
  Size:           4294967296 kB
  Rss:            10612736 kB
  Pss:            10612736 kB
  Shared_Clean:          0 kB
  Shared_Dirty:          0 kB
  Private_Clean:  10612736 kB
  Private_Dirty:         0 kB
  Referenced:     10612736 kB
  Anonymous:             0 kB
  AnonHugePages:  10612736 kB
  Swap:                  0 kB
  KernelPageSize:        4 kB
  MMUPageSize:           4 kB
  Locked:                0 kB
  VmFlags: rd mr mw me
which is wrong becuase just huge_zero_page/normal_zero_page is used for
/dev/zero. Most of the value should be 0.

This patch detects huge_zero_page (original implementation just detect
normal_zero_page) and avoids to update the wrong value for huge_zero_page.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Fengwei Yin <yfw.kernel@gmail.com>
---

Hi Andrew,
The patch was reviewed as http://lkml.org/lkml/2014/10/9/109. I didn't get
further comments. So I suppose it's ok to send the patch to you for merging.

Regards
Yin, Fengwei


 fs/proc/task_mmu.c      | 6 ++++--
 include/linux/huge_mm.h | 2 ++
 mm/huge_memory.c        | 5 +++++
 mm/memory.c             | 4 ++++
 4 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4e0388c..735b389 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -474,8 +474,11 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	if (!page)
 		return;
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
 		mss->anonymous += ptent_size;
+		if (PageTransHuge(page))
+			mss->anonymous_thp += HPAGE_PMD_SIZE;
+	}
 
 	if (page->index != pgoff)
 		mss->nonlinear += ptent_size;
@@ -511,7 +514,6 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
 		spin_unlock(ptl);
-		mss->anonymous_thp += HPAGE_PMD_SIZE;
 		return 0;
 	}
 
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad9051b..7080aa1 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -34,6 +34,8 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
 
+extern bool is_huge_zero_pfn(unsigned long pfn);
+
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74c78aa..7e7880c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -183,6 +183,11 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_page(pmd_page(pmd));
 }
 
+bool is_huge_zero_pfn(unsigned long pfn)
+{
+	return is_huge_zero_page(pfn_to_page(pfn));
+}
+
 static struct page *get_huge_zero_page(void)
 {
 	struct page *zero_page;
diff --git a/mm/memory.c b/mm/memory.c
index 1cc6bfb..eebb6c5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -41,6 +41,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
+#include <linux/huge_mm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/highmem.h>
@@ -787,6 +788,9 @@ check_pfn:
 		return NULL;
 	}
 
+	if (is_huge_zero_pfn(pfn))
+		return NULL;
+
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
