Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8138C6B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:29:49 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so6866342pbc.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:29:49 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/63] mm: numa: Do not account for a hinting fault if we raced
Date: Mon,  7 Oct 2013 11:28:42 +0100
Message-Id: <1381141781-10992-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If another task handled a hinting fault in parallel then do not double
account for it.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 19dbb08..dab2bab 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1325,8 +1325,11 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
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
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
