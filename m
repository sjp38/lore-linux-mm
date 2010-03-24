Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EE71D6B01B6
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 01:44:00 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:42:00 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mmotm] pagemap: add #ifdefs CONFIG_HUGETLB_PAGE on code
	walking hugetlb vma
Message-ID: <20100324054200.GA9336@spritzerA.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

If !CONFIG_HUGETLB_PAGE, pagemap_hugetlb_range() is never called.
So put it (and its calling function) into #ifdef block.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Matt Mackall <mpm@selenic.com>
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
