Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id A77086B006C
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 18:54:58 -0500 (EST)
Received: by wevk48 with SMTP id k48so9616989wev.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 15:54:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jx2si10210765wjc.7.2015.03.05.15.54.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 15:54:57 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: thp: Return the correct value for change_huge_pmd
Date: Thu,  5 Mar 2015 23:54:51 +0000
Message-Id: <1425599692-32445-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1425599692-32445-1-git-send-email-mgorman@suse.de>
References: <1425599692-32445-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

The wrong value is being returned by change_huge_pmd since commit
10c1045f28e8 ("mm: numa: avoid unnecessary TLB flushes when setting
NUMA hinting entries") which allows a fallthrough that tries to adjust
non-existent PTEs. This patch corrects it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fc00c8cb5a82..194c0f019774 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1482,6 +1482,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pmd_t entry;
+		ret = 1;
 
 		/*
 		 * Avoid trapping faults against the zero page. The read-only
@@ -1490,11 +1491,10 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		 */
 		if (prot_numa && is_huge_zero_pmd(*pmd)) {
 			spin_unlock(ptl);
-			return 0;
+			return ret;
 		}
 
 		if (!prot_numa || !pmd_protnone(*pmd)) {
-			ret = 1;
 			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
