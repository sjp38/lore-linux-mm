Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 024446B04B1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 13:52:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r29so19006227pfi.7
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 10:52:28 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id f67si16383061pfg.687.2017.07.31.10.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 10:52:27 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v4 3/3] Revert "mm: numa: defer TLB flush for THP migration as long as possible"
Date: Mon, 31 Jul 2017 03:42:49 -0700
Message-ID: <20170731104249.233458-4-namit@vmware.com>
In-Reply-To: <20170731104249.233458-1-namit@vmware.com>
References: <20170731104249.233458-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

While deferring TLB flushes is a good practice, the reverted patch
caused pending TLB flushes to be checked while the page-table lock is
not taken. As a result, in architectures with weak memory model (PPC),
Linux may miss a memory-barrier, miss the fact TLB flushes are pending,
and cause (in theory) a memory corruption.

Since the alternative of using smp_mb__after_unlock_lock() was
considered a bit open-coded, and the performance impact is expected to
be small, the previous patch is reverted.

This reverts commit b0943d61b8fa420180f92f64ef67662b4f6cc493.

Suggested-by: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 mm/huge_memory.c | 7 +++++++
 mm/migrate.c     | 6 ------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 88c6167f194d..6172b21f330b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1496,6 +1496,13 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	}
 
 	/*
+	 * The page_table_lock above provides a memory barrier
+	 * with change_protection_range.
+	 */
+	if (mm_tlb_flush_pending(mm))
+		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+
+	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and access rights restored.
 	 */
diff --git a/mm/migrate.c b/mm/migrate.c
index 89a0a1707f4c..1f6c2f41b3cb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1935,12 +1935,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		put_page(new_page);
 		goto out_fail;
 	}
-	/*
-	 * We are not sure a pending tlb flush here is for a huge page
-	 * mapping or not. Hence use the tlb range variant
-	 */
-	if (mm_tlb_flush_pending(mm))
-		flush_tlb_range(vma, mmun_start, mmun_end);
 
 	/* Prepare a page as a migration target */
 	__SetPageLocked(new_page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
