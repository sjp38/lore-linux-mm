Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D95326B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 10:39:31 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id yy13so57088716pab.3
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 07:39:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id af6si18018966pad.226.2016.01.23.07.39.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jan 2016 07:39:30 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM killer is disabled.
Date: Sun, 24 Jan 2016 00:38:51 +0900
Message-Id: <1453563531-4831-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>

After the OOM killer is disabled during suspend operation,
any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
forced to fail as well.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6463426..2f71caa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2749,8 +2749,12 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			 * XXX: Page reclaim didn't yield anything,
 			 * and the OOM killer can't be invoked, but
 			 * keep looping as per tradition.
+			 *
+			 * But do not keep looping if oom_killer_disable()
+			 * was already called, for the system is trying to
+			 * enter a quiescent state during suspend.
 			 */
-			*did_some_progress = 1;
+			*did_some_progress = !oom_killer_disabled;
 			goto out;
 		}
 		if (pm_suspended_storage())
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
