Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id EF5A36B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:48:32 -0500 (EST)
Received: by wmww144 with SMTP id w144so160032767wmw.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 05:48:32 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id 17si12615613wmg.112.2015.11.11.05.48.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 05:48:31 -0800 (PST)
Received: by wmec201 with SMTP id c201so182301479wme.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 05:48:31 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory reserves
Date: Wed, 11 Nov 2015 14:48:17 +0100
Message-Id: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Hi,
this has been posted previously as a part of larger GFP_NOFS related
patch set (http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
but Andrea was asking basically the same thing at LSF early this year
(I cannot seem to find it in any public archive though). I think the
patch makes some sense on its own.

Comments?

 mm/page_alloc.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8034909faad2..d30bce9d7ac8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2766,8 +2766,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
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
+			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
+				    " Consider increasing min_free_kbytes.\n");
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
