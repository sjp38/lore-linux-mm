Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 984A59003C7
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 05:51:48 -0400 (EDT)
Received: by wibcd8 with SMTP id cd8so16044842wib.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 02:51:48 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id j2si27650382wiz.27.2015.08.05.02.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 02:51:47 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so15971762wib.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 02:51:47 -0700 (PDT)
From: mhocko@kernel.org
Subject: [RFC 1/8] mm, oom: Give __GFP_NOFAIL allocations access to memory reserves
Date: Wed,  5 Aug 2015 11:51:17 +0200
Message-Id: <1438768284-30927-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__GFP_NOFAIL is a big hammer used to ensure that the allocation
request can never fail. This is a strong requirement and as such
it also deserves a special treatment when the system is OOM. The
primary problem here is that the allocation request might have
come with some locks held and the oom victim might be blocked
on the same locks. This is basically an OOM deadlock situation.

This patch tries to reduce the risk of such a deadlocks by giving
__GFP_NOFAIL allocations a special treatment and let them dive into
memory reserves after oom killer invocation. This should help them
to make a progress and release resources they are holding. The OOM
victim should compensate for the reserves consumption.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1f9ffbb087cb..ee69c338ca2a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2732,8 +2732,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	}
 	/* Exhausted what can be done so it's blamo time */
 	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
-			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
+			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
+
+		if (gfp_mask & __GFP_NOFAIL) {
+			page = get_page_from_freelist(gfp_mask, order,
+					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
+				    " Consider increasing min_free_kbytes.\n");
+		}
+	}
 out:
 	mutex_unlock(&oom_lock);
 	return page;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
