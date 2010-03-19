Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 019366B00A2
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:27:59 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2] pagemap: add #ifdefs CONFIG_HUGETLB_PAGE on code walking hugetlb vma
Date: Fri, 19 Mar 2010 15:26:35 +0900
Message-Id: <1268979996-12297-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

If !CONFIG_HUGETLB_PAGE, pagemap_hugetlb_range() is never called.
So put it (and its calling function) into #ifdef block.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 183f8ff..2a3ef17 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -652,6 +652,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return err;
 }
 
+#ifdef CONFIG_HUGETLB_PAGE
 static u64 huge_pte_to_pagemap_entry(pte_t pte, int offset)
 {
 	u64 pme = 0;
@@ -695,6 +696,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long addr,
 
 	return err;
 }
+#endif /* HUGETLB_PAGE */
 
 /*
  * /proc/pid/pagemap - an array mapping virtual pages to pfns
@@ -788,7 +790,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 
 	pagemap_walk.pmd_entry = pagemap_pte_range;
 	pagemap_walk.pte_hole = pagemap_pte_hole;
+#ifdef CONFIG_HUGETLB_PAGE
 	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;
+#endif
 	pagemap_walk.mm = mm;
 	pagemap_walk.private = &pm;
 
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
