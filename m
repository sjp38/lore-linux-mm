Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 854E1800C7
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 10:43:12 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id u188so64764468wmu.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:43:12 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id lg10si160360671wjc.20.2016.01.06.07.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 07:43:11 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id b14so81213656wmb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:43:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] oom reaper: handle anonymous mlocked pages
Date: Wed,  6 Jan 2016 16:42:55 +0100
Message-Id: <1452094975-551-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452094975-551-1-git-send-email-mhocko@kernel.org>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__oom_reap_vmas current skips over all mlocked vmas because they need
a special treatment before they are unmapped. This is primarily done
for simplicity. There is no reason to skip over them for all mappings
though and reduce the amount of reclaimed memory. Anonymous mappings
are not visible by any other process so doing a munlock before unmap
is safe to do from the semantic point of view. munlock_vma_pages_all
is also safe to be called from the oom reaper context because it
doesn't sit on any locks but mmap_sem (for read).

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ece40b94725..913b68a44fd4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -445,11 +445,16 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
 			continue;
 
 		/*
-		 * mlocked VMAs require explicit munlocking before unmap.
-		 * Let's keep it simple here and skip such VMAs.
+		 * mlocked VMAs require explicit munlocking before unmap
+		 * and that is safe only for anonymous mappings because
+		 * nobody except for the victim will need them locked
 		 */
-		if (vma->vm_flags & VM_LOCKED)
-			continue;
+		if (vma->vm_flags & VM_LOCKED) {
+			if (vma_is_anonymous(vma))
+				munlock_vma_pages_all(vma);
+			else
+				continue;
+		}
 
 		/*
 		 * Only anonymous pages have a good chance to be dropped
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
