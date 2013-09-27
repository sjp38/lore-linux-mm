Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id D18E9900003
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:02 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so2545275pbc.25
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:02 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/63] mm: numa: Do not account for a hinting fault if we raced
Date: Fri, 27 Sep 2013 14:26:49 +0100
Message-Id: <1380288468-5551-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If another task handled a hinting fault in parallel then do not double
account for it.

Not-signed-off-by: Peter Zijlstra
---
 mm/huge_memory.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 860a368..5c37cd2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1337,8 +1337,11 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 check_same:
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
+	if (unlikely(!pmd_same(pmd, *pmdp))) {
+		/* Someone else took our fault */
+		current_nid = -1;
 		goto out_unlock;
+	}
 clear_pmdnuma:
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
