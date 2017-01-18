Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED2106B0266
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:25:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so14790516pgi.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:25:40 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 96si119523plz.28.2017.01.18.04.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 04:25:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RESEND 1/4] mm: drop zap_details::ignore_dirty
Date: Wed, 18 Jan 2017 15:24:26 +0300
Message-Id: <20170118122429.43661-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The only user of ignore_dirty is oom-reaper. But it doesn't really use
it.

ignore_dirty only has effect on file pages mapped with dirty pte.
But oom-repear skips shared VMAs, so there's no way we can dirty file
pte in them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 1 -
 mm/memory.c        | 6 ------
 mm/oom_kill.c      | 3 +--
 3 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b0f64c..88beebe1e695 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1148,7 +1148,6 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	bool ignore_dirty;			/* Ignore dirty pages */
 	bool check_swap_entries;		/* Check also swap entries */
 };
 
diff --git a/mm/memory.c b/mm/memory.c
index 6bf2b471e30c..1d8ef8ec1b48 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1155,12 +1155,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 
 			if (!PageAnon(page)) {
 				if (pte_dirty(ptent)) {
-					/*
-					 * oom_reaper cannot tear down dirty
-					 * pages
-					 */
-					if (unlikely(details && details->ignore_dirty))
-						continue;
 					force_flush = 1;
 					set_page_dirty(page);
 				}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..f101db68e760 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -465,8 +465,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct zap_details details = {.check_swap_entries = true,
-				      .ignore_dirty = true};
+	struct zap_details details = {.check_swap_entries = true};
 	bool ret = true;
 
 	/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
