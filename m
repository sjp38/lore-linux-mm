Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7A5600783
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 03:01:29 -0500 (EST)
Message-ID: <4B1CB5D9.8000504@ah.jp.nec.com>
Date: Mon, 07 Dec 2009 16:59:21 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reply-To: n-horiguchi@ah.jp.nec.com
MIME-Version: 1.0
Subject: [PATCH 1/2] mm hugetlb x86: fix hugepage memory leak in walk_page_range()
References: <1260172193-14397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1260172193-14397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: hugh.dickins@tiscali.co.uk, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/pagewalk.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index d5878be..3d88824 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -1,6 +1,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/sched.h>
+#include <linux/hugetlb.h>
 
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
@@ -107,6 +108,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	pgd_t *pgd;
 	unsigned long next;
 	int err = 0;
+	struct vm_area_struct *vma;
 
 	if (addr >= end)
 		return err;
@@ -117,11 +119,21 @@ int walk_page_range(unsigned long addr, unsigned long end,
 	pgd = pgd_offset(walk->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
+
+		/* skip hugetlb vma to avoid hugepage PMD being cleared
+		 * in pmd_none_or_clear_bad(). */
+		vma = find_vma(walk->mm, addr);
+		if (is_vm_hugetlb_page(vma)) {
+			next = (vma->vm_end < next) ? vma->vm_end : next;
+			continue;
+		}
+
 		if (pgd_none_or_clear_bad(pgd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
 				break;
+			pgd++;
 			continue;
 		}
 		if (walk->pgd_entry)
@@ -131,7 +143,8 @@ int walk_page_range(unsigned long addr, unsigned long end,
 			err = walk_pud_range(pgd, addr, next, walk);
 		if (err)
 			break;
-	} while (pgd++, addr = next, addr != end);
+		pgd++;
+	} while (addr = next, addr != end);
 
 	return err;
 }
-- 
1.6.0.6


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
