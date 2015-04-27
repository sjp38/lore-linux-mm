Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C70E16B0078
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:06:51 -0400 (EDT)
Received: by widdi4 with SMTP id di4so111590898wid.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:06:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c5si14223116wiw.8.2015.04.27.12.06.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 12:06:44 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 9/9] mm: page_alloc: memory reserve access for OOM-killing allocations
Date: Mon, 27 Apr 2015 15:05:55 -0400
Message-Id: <1430161555-6058-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
References: <1430161555-6058-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The OOM killer connects random tasks in the system with unknown
dependencies between them, and the OOM victim might well get blocked
behind locks held by the allocating task.  That means that while
allocations can issue OOM kills to improve the low memory situation,
which generally frees more than they are going to take out, they can
not rely on their *own* OOM kills to make forward progress.

However, OOM-killing allocations currently retry forever.  Without any
extra measures the above situation will result in a deadlock; between
the allocating task and the OOM victim at first, but it can spread
once other tasks in the system start contending for the same locks.

Allow OOM-killing allocations to dip into the system's memory reserves
to avoid this deadlock scenario.  Those reserves are specifically for
operations in the memory reclaim paths which need a small amount of
memory to release a much larger amount.  Arguably, the same notion
applies to the OOM killer.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 94530db..5f3806d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2384,6 +2384,20 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 			*did_some_progress = 1;
 	}
+
+	/*
+	 * In the current implementation, an OOM-killing allocation
+	 * loops indefinitely inside the allocator.  However, it's
+	 * possible for the OOM victim to get stuck behind locks held
+	 * by the allocating task itself, so we can never rely on the
+	 * OOM killer to free memory synchroneously without risking a
+	 * deadlock.  Allow these allocations to dip into the memory
+	 * reserves to ensure forward progress once the OOM kill has
+	 * been issued.  The reserves will be replenished when the
+	 * caller releases the locks and the victim exits.
+	 */
+	if (*did_some_progress)
+		alloc_flags |= ALLOC_NO_WATERMARKS;
 out:
 	mutex_unlock(&oom_lock);
 alloc:
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
