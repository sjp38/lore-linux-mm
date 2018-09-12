Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06BD78E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:05 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 1-v6so3108368ybe.18
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:05 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x4-v6si485449ywb.562.2018.09.12.13.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:03 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 1/6] Add check to match numa node id when gathering pte stats
Date: Wed, 12 Sep 2018 13:23:59 -0700
Message-Id: <1536783844-4145-2-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

Add support to check if numa node id matches when gathering pte stats,
to be used by later patches.

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
---
 fs/proc/task_mmu.c | 44 +++++++++++++++++++++++++++++++++++++-------
 1 file changed, 37 insertions(+), 7 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5ea1d64..0e2095c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1569,9 +1569,15 @@ struct numa_maps {
 	unsigned long mapcount_max;
 	unsigned long dirty;
 	unsigned long swapcache;
+        unsigned long nextaddr;
+		 long nid;
+		 long isvamaps;
 	unsigned long node[MAX_NUMNODES];
 };
 
+#define        NUMA_VAMAPS_NID_NOPAGES         (-1)
+#define        NUMA_VAMAPS_NID_NONE    (-2)
+
 struct numa_maps_private {
 	struct proc_maps_private proc_maps;
 	struct numa_maps md;
@@ -1653,6 +1659,20 @@ static struct page *can_gather_numa_stats_pmd(pmd_t pmd,
 }
 #endif
 
+static bool
+vamap_match_nid(struct numa_maps *md, unsigned long addr, struct page *page)
+{
+	long target = (page ? page_to_nid(page) : NUMA_VAMAPS_NID_NOPAGES);
+
+	if (md->nid == NUMA_VAMAPS_NID_NONE)
+		md->nid = target;
+	if (md->nid == target)
+		return 0;
+	/* did not match */
+	md->nextaddr = addr;
+	return 1;
+}
+
 static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
@@ -1661,6 +1681,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	pte_t *orig_pte;
 	pte_t *pte;
+	int ret = 0;
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	ptl = pmd_trans_huge_lock(pmd, vma);
@@ -1668,11 +1689,13 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		struct page *page;
 
 		page = can_gather_numa_stats_pmd(*pmd, vma, addr);
-		if (page)
+		if (md->isvamaps)
+			ret = vamap_match_nid(md, addr, page);
+		if (page && !ret)
 			gather_stats(page, md, pmd_dirty(*pmd),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
 		spin_unlock(ptl);
-		return 0;
+		return ret;
 	}
 
 	if (pmd_trans_unstable(pmd))
@@ -1681,6 +1704,10 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	do {
 		struct page *page = can_gather_numa_stats(*pte, vma, addr);
+		if (md->isvamaps && vamap_match_nid(md, addr, page)) {
+			ret = 1;
+			break;
+		}
 		if (!page)
 			continue;
 		gather_stats(page, md, pte_dirty(*pte), 1);
@@ -1688,7 +1715,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap_unlock(orig_pte, ptl);
 	cond_resched();
-	return 0;
+	return ret;
 }
 #ifdef CONFIG_HUGETLB_PAGE
 static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
@@ -1697,15 +1724,18 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
 	pte_t huge_pte = huge_ptep_get(pte);
 	struct numa_maps *md;
 	struct page *page;
+	int ret = 0;
+	md = walk->private;
 
 	if (!pte_present(huge_pte))
-		return 0;
+		return (md->isvamaps ? vamap_match_nid(md, addr, NULL) : 0);
 
 	page = pte_page(huge_pte);
-	if (!page)
-		return 0;
+	if (md->isvamaps)
+		ret = vamap_match_nid(md, addr, page);
+	if (!page || ret)
+		return ret;
 
-	md = walk->private;
 	gather_stats(page, md, pte_dirty(huge_pte), 1);
 	return 0;
 }
-- 
2.7.4
