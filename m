Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4F96B007B
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:50 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so23328957wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q13si20781389wiv.91.2015.03.24.23.17.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:49 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 10/12] mm: page_alloc: emergency reserve access for __GFP_NOFAIL allocations
Date: Wed, 25 Mar 2015 02:17:14 -0400
Message-Id: <1427264236-17249-11-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

__GFP_NOFAIL allocations can deadlock the OOM killer when they're
holding locks that the OOM victim might need to exit.  When that
happens the allocation may never complete, which has disastrous
effects on things like in-flight filesystem transactions.

When the system is OOM, allow __GFP_NOFAIL allocations to dip into the
emergency reserves in the hope that this will allow transactions and
writeback to complete and the deadlock can be avoided.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3c165016175d..832ad1c7cd4f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2403,9 +2403,17 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * from exiting.  While allocations can use OOM kills to free
 	 * memory, they can not necessarily rely on their *own* kills
 	 * to make forward progress.
+	 *
+	 * This last point is crucial for __GFP_NOFAIL allocations.
+	 * Since they can't quit, they might actually deadlock, so
+	 * give them hail mary access to the emergency reserves.
 	 */
-	alloc_flags &= ~ALLOC_WMARK_MASK;
-	alloc_flags |= ALLOC_WMARK_OOM;
+	if (gfp_mask & __GFP_NOFAIL) {
+		alloc_flags |= ALLOC_NO_WATERMARKS;
+	} else {
+		alloc_flags &= ~ALLOC_WMARK_MASK;
+		alloc_flags |= ALLOC_WMARK_OOM;
+	}
 out:
 	mutex_unlock(&oom_lock);
 alloc:
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
