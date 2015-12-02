Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 401D06B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:13:22 -0500 (EST)
Received: by wmuu63 with SMTP id u63so219043155wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:13:21 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id l11si4845108wjw.184.2015.12.02.07.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 07:13:20 -0800 (PST)
Received: by wmuu63 with SMTP id u63so219042378wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:13:20 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2] mm, oom: Give __GFP_NOFAIL allocations access to memory reserves
Date: Wed,  2 Dec 2015 16:13:10 +0100
Message-Id: <1449069190-7325-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1448448054-804-2-git-send-email-mhocko@kernel.org>
References: <1448448054-804-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8034909faad2..367523b2948b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2766,8 +2766,21 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
+	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
+
+		if (gfp_mask & __GFP_NOFAIL) {
+			page = get_page_from_freelist(gfp_mask, order,
+					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+			/*
+			 * fallback to ignore cpuset restriction if our nodes
+			 * are depleted
+			 */
+			if (!page)
+				page = get_page_from_freelist(gfp_mask, order,
+					ALLOC_NO_WATERMARKS, ac);
+		}
+	}
 out:
 	mutex_unlock(&oom_lock);
 	return page;
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
