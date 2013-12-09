Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id A43D86B0068
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:25 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so1334716eaj.15
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si8232098eeo.88.2013.12.08.23.09.24
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:24 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/18] mm: numa: Defer TLB flush for THP migration as long as possible
Date: Mon,  9 Dec 2013 07:09:06 +0000
Message-Id: <1386572952-1191-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

THP migration can fail for a variety of reasons. Avoid flushing the TLB
to deal with THP migration races until the copy is ready to start.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 7 -------
 mm/migrate.c     | 6 ++++++
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e3a5ee2..e3b6a75 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1377,13 +1377,6 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/*
-	 * The page_table_lock above provides a memory barrier
-	 * with change_protection_range.
-	 */
-	if (tlb_flush_pending(mm))
-		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
-
-	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and pmd_numa cleared.
 	 */
diff --git a/mm/migrate.c b/mm/migrate.c
index cfb4190..5372521 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1759,6 +1759,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_fail;
 	}
 
+	/* PTL provides a memory barrier with change_protection_range */
+	ptl = pmd_lock(mm, pmd);
+	if (tlb_flush_pending(mm))
+		flush_tlb_range(vma, mmun_start, mmun_end);
+	spin_unlock(ptl);
+
 	/* Prepare a page as a migration target */
 	__set_page_locked(new_page);
 	SetPageSwapBacked(new_page);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
