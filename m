Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6F623900015
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 10:21:03 -0500 (EST)
Received: by wiwl15 with SMTP id l15so9999898wiw.4
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 07:21:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ut8si13463293wjc.137.2015.03.07.07.20.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Mar 2015 07:20:58 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: numa: Mark huge PTEs young when clearing NUMA hinting faults
Date: Sat,  7 Mar 2015 15:20:50 +0000
Message-Id: <1425741651-29152-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1425741651-29152-1-git-send-email-mgorman@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

Base PTEs are marked young when the NUMA hinting information is cleared
but the same does not happen for huge pages which this patch addresses.
Note that migrated pages are not marked young as the base page migration
code does not assume that migrated pages have been referenced. This could
be addressed but beyond the scope of this series which is aimed at Dave
Chinners shrink workload that is unlikely to be affected by this issue.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 194c0f019774..ae13ad31e113 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1359,6 +1359,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 clear_pmdnuma:
 	BUG_ON(!PageLocked(page));
 	pmd = pmd_modify(pmd, vma->vm_page_prot);
+	pmd = pmd_mkyoung(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	update_mmu_cache_pmd(vma, addr, pmdp);
 	unlock_page(page);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
