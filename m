Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E63D280256
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:44:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b4so6646394wmb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:44:23 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id i4si13525061wjv.214.2016.09.29.01.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 01:44:21 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id w84so9561203wmg.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:44:21 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm: warn about allocations which stall for too long
Date: Thu, 29 Sep 2016 10:44:07 +0200
Message-Id: <20160929084407.7004-3-mhocko@kernel.org>
In-Reply-To: <20160929084407.7004-1-mhocko@kernel.org>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <20160929084407.7004-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Currently we do warn only about allocation failures but small
allocations are basically nofail and they might loop in the page
allocator for a long time.  Especially when the reclaim cannot make
any progress - e.g. GFP_NOFS cannot invoke the oom killer and rely on
a different context to make a forward progress in case there is a lot
memory used by filesystems.

Give us at least a clue when something like this happens and warn about
allocations which take more than 10s. Print the basic allocation context
information along with the cumulative time spent in the allocation as
well as the allocation stack. Repeat the warning after every 10 seconds so
that we know that the problem is permanent rather than ephemeral.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 969ffc97045b..73f60ad6315f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3495,6 +3495,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+	unsigned long alloc_start = jiffies;
+	unsigned int stall_timeout = 10 * HZ;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3650,6 +3652,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
 		goto nopage;
 
+	/* Make sure we know about allocations which stall for too long */
+	if (time_after(jiffies, alloc_start + stall_timeout)) {
+		warn_alloc(gfp_mask,
+			"page alloction stalls for %ums, order:%u\n",
+			jiffies_to_msecs(jiffies-alloc_start), order);
+		stall_timeout += 10 * HZ;
+	}
+
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
 				 did_some_progress > 0, &no_progress_loops))
 		goto retry;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
