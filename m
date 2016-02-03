Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A5A33828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:14:11 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p63so164561553wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:11 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k4si9958256wje.12.2016.02.03.05.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:14:08 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id p63so7364124wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:14:08 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/5] oom reaper: handle mlocked pages
Date: Wed,  3 Feb 2016 14:13:57 +0100
Message-Id: <1454505240-23446-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__oom_reap_vmas current skips over all mlocked vmas because they need a
special treatment before they are unmapped. This is primarily done for
simplicity. There is no reason to skip over them and reduce the amount
of reclaimed memory. This is safe from the semantic point of view
because try_to_unmap_one during rmap walk would keep tell the reclaim
to cull the page back and mlock it again.

munlock_vma_pages_all is also safe to be called from the oom reaper
context because it doesn't sit on any locks but mmap_sem (for read).

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9a0e4e5f50b4..840e03986497 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -443,13 +443,6 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 			continue;
 
 		/*
-		 * mlocked VMAs require explicit munlocking before unmap.
-		 * Let's keep it simple here and skip such VMAs.
-		 */
-		if (vma->vm_flags & VM_LOCKED)
-			continue;
-
-		/*
 		 * Only anonymous pages have a good chance to be dropped
 		 * without additional steps which we cannot afford as we
 		 * are OOM already.
@@ -459,9 +452,12 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 		 * we do not want to block exit_mmap by keeping mm ref
 		 * count elevated without a good reason.
 		 */
-		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
+		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_all(vma);
 			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
 					 &details);
+		}
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	up_read(&mm->mmap_sem);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
