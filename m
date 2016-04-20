Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 549FC828E8
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 15:47:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so78069944pac.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:58 -0700 (PDT)
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com. [209.85.220.52])
        by mx.google.com with ESMTPS id x64si19439224pfi.208.2016.04.20.12.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 12:47:57 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id er2so20774337pad.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 09/14] mm: use compaction feedback for thp backoff conditions
Date: Wed, 20 Apr 2016 15:47:22 -0400
Message-Id: <1461181647-8039-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

THP requests skip the direct reclaim if the compaction is either
deferred or contended to reduce stalls which wouldn't help the
allocation success anyway. These checks are ignoring other potential
feedback modes which we have available now.

It clearly doesn't make much sense to go and reclaim few pages if the
previous compaction has failed.

We can also simplify the check by using compaction_withdrawn which
checks for both COMPACT_CONTENDED and COMPACT_DEFERRED. This check
is however covering more reasons why the compaction was withdrawn.
None of them should be a problem for the THP case though.

It is safe to back of if we see COMPACT_SKIPPED because that means
that compaction_suitable failed and a single round of the reclaim is
unlikely to make any difference here. We would have to be close to
the low watermark to reclaim enough and even then there is no guarantee
that the compaction would make any progress while the direct reclaim
would have caused the stall.

COMPACT_PARTIAL_SKIPPED is slightly different because that means that we
have only seen a part of the zone so a retry would make some sense. But
it would be a compaction retry not a reclaim retry to perform. We are
not doing that and that might indeed lead to situations where THP fails
but this should happen only rarely and it would be really hard to
measure.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 350d13f3709b..d551fe326c33 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3257,25 +3257,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
-	/* Checks for THP-specific high-order allocations */
-	if (is_thp_gfp_mask(gfp_mask)) {
-		/*
-		 * If compaction is deferred for high-order allocations, it is
-		 * because sync compaction recently failed. If this is the case
-		 * and the caller requested a THP allocation, we do not want
-		 * to heavily disrupt the system, so we fail the allocation
-		 * instead of entering direct reclaim.
-		 */
-		if (compact_result == COMPACT_DEFERRED)
-			goto nopage;
-
-		/*
-		 * Compaction is contended so rather back off than cause
-		 * excessive stalls.
-		 */
-		if(compact_result == COMPACT_CONTENDED)
-			goto nopage;
-	}
+	/*
+	 * Checks for THP-specific high-order allocations and back off
+	 * if the the compaction backed off or failed
+	 */
+	if (is_thp_gfp_mask(gfp_mask) &&
+			(compaction_withdrawn(compact_result) ||
+			 compaction_failed(compact_result)))
+		goto nopage;
 
 	/*
 	 * It can become very expensive to allocate transparent hugepages at
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
