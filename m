Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 51D656B007D
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:52 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so10614975wib.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gp8si20823346wib.20.2015.03.24.23.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:51 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 11/12] mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM
Date: Wed, 25 Mar 2015 02:17:15 -0400
Message-Id: <1427264236-17249-12-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

GFP_NOFS allocations are not allowed to invoke the OOM killer since
their reclaim abilities are severely diminished.  However, without the
OOM killer available there is no hope of progress once the reclaimable
pages have been exhausted.

Don't risk hanging these allocations.  Leave it to the allocation site
to implement the fallback policy for failing allocations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 832ad1c7cd4f..9e45e97aa934 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2367,15 +2367,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 */
-			*did_some_progress = 1;
+		if (!(gfp_mask & __GFP_FS))
 			goto out;
-		}
 		if (pm_suspended_storage())
 			goto out;
 		/* The OOM killer may not free memory on a specific node */
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
