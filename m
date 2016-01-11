Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 41F68828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 00:07:38 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so38981924pfn.3
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 21:07:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id or6si36911550pab.5.2016.01.10.21.07.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 21:07:37 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM killer is disabled.
Date: Mon, 11 Jan 2016 14:07:16 +0900
Message-Id: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, rientjes@google.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

After the OOM killer is disabled during suspend operation,
any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
forced to fail as well.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3c3a5c5..214f824 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2766,7 +2766,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			 * and the OOM killer can't be invoked, but
 			 * keep looping as per tradition.
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
