Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9E16B02AD
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 12:17:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so416175235pgq.7
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:17:37 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id j10si2708464plg.241.2016.12.19.09.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 09:17:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] mm: drop zap_details::check_swap_entries
Date: Mon, 19 Dec 2016 20:17:20 +0300
Message-Id: <20161219171722.77995-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161219171722.77995-1-kirill.shutemov@linux.intel.com>
References: <20161219171722.77995-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

detail == NULL would give the same functionality as
.check_swap_entries==true.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 1 -
 mm/memory.c        | 4 ++--
 mm/oom_kill.c      | 3 +--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7b8e425ac41c..5f6bea4c9d41 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1148,7 +1148,6 @@ struct zap_details {
 	struct address_space *check_mapping;	/* Check page->mapping if set */
 	pgoff_t	first_index;			/* Lowest page->index to unmap */
 	pgoff_t last_index;			/* Highest page->index to unmap */
-	bool check_swap_entries;		/* Check also swap entries */
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index 6ac8fa56080f..c03b18f13619 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1173,8 +1173,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			}
 			continue;
 		}
-		/* only check swap_entries if explicitly asked for in details */
-		if (unlikely(details && !details->check_swap_entries))
+		/* If details->check_mapping, we leave swap entries. */
+		if (unlikely(details))
 			continue;
 
 		entry = pte_to_swp_entry(ptent);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f101db68e760..96a53ab0c9eb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -465,7 +465,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	struct zap_details details = {.check_swap_entries = true};
 	bool ret = true;
 
 	/*
@@ -531,7 +530,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
 			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
-					 &details);
+					 NULL);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
