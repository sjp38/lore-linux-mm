Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 864566B004D
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 11:54:43 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so3475065eaj.40
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 08:54:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n47si29711479eef.157.2014.01.13.08.54.42
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 08:54:42 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 10/11] pagewalk: remove argument hmask from hugetlb_entry()
Date: Mon, 13 Jan 2014 11:54:10 -0500
Message-Id: <1389632051-25159-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

hugetlb_entry() doesn't use the argument hmask any more,
so let's remove it now.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 12 ++++++------
 include/linux/mm.h |  5 ++---
 mm/pagewalk.c      |  2 +-
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git mmotm-2014-01-09-16-23.orig/fs/proc/task_mmu.c mmotm-2014-01-09-16-23/fs/proc/task_mmu.c
index a1903e4b9514..80507c589d30 100644
--- mmotm-2014-01-09-16-23.orig/fs/proc/task_mmu.c
+++ mmotm-2014-01-09-16-23/fs/proc/task_mmu.c
@@ -1030,8 +1030,7 @@ static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *
 }
 
 /* This function walks within one hugetlb entry in the single call */
-static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
-				 unsigned long addr, unsigned long end,
+static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
@@ -1039,6 +1038,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 	int err = 0;
 	int flags2;
 	pagemap_entry_t pme;
+	unsigned long hmask;
 
 	WARN_ON_ONCE(!vma);
 
@@ -1300,8 +1300,8 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
-static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
-		unsigned long addr, unsigned long end, struct mm_walk *walk)
+static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
 {
 	struct numa_maps *md;
 	struct page *page;
@@ -1319,8 +1319,8 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
-		unsigned long addr, unsigned long end, struct mm_walk *walk)
+static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
 {
 	return 0;
 }
diff --git mmotm-2014-01-09-16-23.orig/include/linux/mm.h mmotm-2014-01-09-16-23/include/linux/mm.h
index 262e9d943533..0601ce59465a 100644
--- mmotm-2014-01-09-16-23.orig/include/linux/mm.h
+++ mmotm-2014-01-09-16-23/include/linux/mm.h
@@ -1008,9 +1008,8 @@ struct mm_walk {
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_hole)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
-	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
-			     unsigned long addr, unsigned long next,
-			     struct mm_walk *walk);
+	int (*hugetlb_entry)(pte_t *pte, unsigned long addr,
+			unsigned long next, struct mm_walk *walk);
 	int (*test_walk)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
 	struct mm_struct *mm;
diff --git mmotm-2014-01-09-16-23.orig/mm/pagewalk.c mmotm-2014-01-09-16-23/mm/pagewalk.c
index 98a2385616a2..b639964c7b11 100644
--- mmotm-2014-01-09-16-23.orig/mm/pagewalk.c
+++ mmotm-2014-01-09-16-23/mm/pagewalk.c
@@ -198,7 +198,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		 * in walk->hugetlb_entry().
 		 */
 		if (pte && walk->hugetlb_entry)
-			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
+			err = walk->hugetlb_entry(pte, addr, next, walk);
 		spin_unlock(ptl);
 		if (err)
 			break;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
