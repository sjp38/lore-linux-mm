Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64CE66B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 09:47:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f20so8666514ioj.2
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 06:47:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i11si5390382ioa.108.2017.11.03.06.47.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 06:47:06 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: Update comment for last second allocation attempt.
Date: Fri,  3 Nov 2017 22:46:29 +0900
Message-Id: <1509716789-7218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
References: <201711022015.BBE95844.QOHtJFMLFOOSVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom() is doing last second allocation attempt using
ALLOC_WMARK_HIGH before calling out_of_memory(). This had two reasons.

The first reason is explained in the comment that it aims to catch
potential parallel OOM killing. But there is no longer parallel OOM
killing (in the sense that out_of_memory() is called "concurrently")
because we serialize out_of_memory() calls using oom_lock.

The second reason is explained by Andrea Arcangeli (who added that code)
that it aims to reduce the likelihood of OOM livelocks and be sure to
invoke the OOM killer. There was a risk of livelock or anyway of delayed
OOM killer invocation if ALLOC_WMARK_MIN is used, for relying on last
few pages which are constantly allocated and freed in the meantime will
not improve the situation. But there is no longer possibility of OOM
livelocks or failing to invoke the OOM killer because we need to mask
__GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
second allocation attempt indirectly involve from failing.

Since the OOM killer does not always kill a process consuming significant
amount of memory (the OOM killer kills a process with highest OOM score
(or instead one of its children if any)), there will be cases where
ALLOC_WMARK_HIGH fails and ALLOC_WMARK_MIN succeeds.
Since the gap between ALLOC_WMARK_HIGH and ALLOC_WMARK_MIN can be changed
by /proc/sys/vm/min_free_kbytes parameter, using ALLOC_WMARK_MIN for last
second allocation attempt might be better for minimizing number of OOM
victims. But that change should be done in a separate patch. This patch
just clarifies that ALLOC_WMARK_HIGH is an arbitrary choice.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c274960..547e9cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3312,11 +3312,10 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	}
 
 	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
+	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
+	 * already held. And since this allocation attempt does not sleep,
+	 * there is no reason we must use high watermark here.
 	 */
 	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
 				      ~__GFP_DIRECT_RECLAIM, order,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
