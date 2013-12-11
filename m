Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 39AA96B0055
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:10:26 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so7802207wib.3
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:10:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 10si4233037wjp.35.2013.12.11.14.10.24
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:10:25 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 10/11] pagewalk: remove argument hmask from hugetlb_entry()
Date: Wed, 11 Dec 2013 17:09:06 -0500
Message-Id: <1386799747-31069-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
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

diff --git v3.13-rc3-mmots-2013-12-10-16-38.orig/fs/proc/task_mmu.c v3.13-rc3-mmots-2013-12-10-16-38/fs/proc/task_mmu.c
index 8b23bbcc5e04..f819d0d4a0e8 100644
--- v3.13-rc3-mmots-2013-12-10-16-38.orig/fs/proc/task_mmu.c
+++ v3.13-rc3-mmots-2013-12-10-16-38/fs/proc/task_mmu.c
@@ -1022,8 +1022,7 @@ static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *
 }
 
 /* This function walks within one hugetlb entry in the single call */
-static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
-				 unsigned long addr, unsigned long end,
+static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
 				 struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
@@ -1031,6 +1030,7 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
 	int err = 0;
 	int flags2;
 	pagemap_entry_t pme;
+	unsigned long hmask;
 
 	WARN_ON_ONCE(!vma);
 
@@ -1292,8 +1292,8 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
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
@@ -1311,8 +1311,8 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
-		unsigned long addr, unsigned long end, struct mm_walk *walk)
+static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
 {
 	return 0;
 }
diff --git v3.13-rc3-mmots-2013-12-10-16-38.orig/include/linux/mm.h v3.13-rc3-mmots-2013-12-10-16-38/include/linux/mm.h
index 8d1a3659419d..8008afa6dd64 100644
--- v3.13-rc3-mmots-2013-12-10-16-38.orig/include/linux/mm.h
+++ v3.13-rc3-mmots-2013-12-10-16-38/include/linux/mm.h
@@ -1088,9 +1088,8 @@ struct mm_walk {
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
diff --git v3.13-rc3-mmots-2013-12-10-16-38.orig/mm/pagewalk.c v3.13-rc3-mmots-2013-12-10-16-38/mm/pagewalk.c
index f4ba2c212330..31333473c725 100644
--- v3.13-rc3-mmots-2013-12-10-16-38.orig/mm/pagewalk.c
+++ v3.13-rc3-mmots-2013-12-10-16-38/mm/pagewalk.c
@@ -189,7 +189,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 		 * in walk->hugetlb_entry().
 		 */
 		if (pte && walk->hugetlb_entry)
-			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
+			err = walk->hugetlb_entry(pte, addr, next, walk);
 		spin_unlock(ptl);
 		if (err)
 			break;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
