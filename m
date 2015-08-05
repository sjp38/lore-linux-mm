Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8F57B9003C9
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 05:51:52 -0400 (EDT)
Received: by wibcd8 with SMTP id cd8so16047291wib.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 02:51:52 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id s20si4686959wjw.189.2015.08.05.02.51.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 02:51:50 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so58702524wib.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 02:51:50 -0700 (PDT)
From: mhocko@kernel.org
Subject: [RFC 3/8] mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM
Date: Wed,  5 Aug 2015 11:51:19 +0200
Message-Id: <1438768284-30927-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>

From: Johannes Weiner <hannes@cmpxchg.org>

GFP_NOFS allocations are not allowed to invoke the OOM killer since
their reclaim abilities are severely diminished.  However, without the
OOM killer available there is no hope of progress once the reclaimable
pages have been exhausted.

Don't risk hanging these allocations.  Leave it to the allocation site
to implement the fallback policy for failing allocations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee69c338ca2a..024d45d51700 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2715,15 +2715,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
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
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
