Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3850F6B005C
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:46 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so2328019eek.24
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si14890872eeo.74.2013.12.10.07.51.45
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:45 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/18] mm: numa: Defer TLB flush for THP migration as long as possible
Date: Tue, 10 Dec 2013 15:51:30 +0000
Message-Id: <1386690695-27380-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
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
 mm/migrate.c     | 3 +++
 2 files changed, 3 insertions(+), 7 deletions(-)

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
index cfb4190..0c4fbf6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1759,6 +1759,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_fail;
 	}
 
+	if (tlb_flush_pending(mm))
+		flush_tlb_range(vma, mmun_start, mmun_end);
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
