Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 285946B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 14:14:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so201309396pfb.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 11:14:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xy10si4944264pac.60.2016.09.09.11.14.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 11:14:58 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: Don't emit warning from pagefault_out_of_memory()
Date: Sat, 10 Sep 2016 02:28:40 +0900
Message-Id: <1473442120-7246-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Commit c32b3cbe0d067a9c ("oom, PM: make OOM detection in the freezer path
raceless") inserted a WARN_ON() into pagefault_out_of_memory() in order
to warn when we raced with disabling the OOM killer. But emitting same
backtrace forever after the OOM killer/reaper are disabled is pointless
because the system is already OOM livelocked.

Now, patch "oom, suspend: fix oom_killer_disable vs. pm suspend properly"
introduced a timeout for oom_killer_disable(). Even if we raced with
disabling the OOM killer and the system is OOM livelocked, the OOM killer
will be enabled eventually (in 20 seconds by default) and the OOM livelock
will be solved. Therefore, we no longer need to warn when we raced with
disabling the OOM killer.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0034baf..f284e92 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1069,16 +1069,6 @@ void pagefault_out_of_memory(void)
 
 	if (!mutex_trylock(&oom_lock))
 		return;
-
-	if (!out_of_memory(&oc)) {
-		/*
-		 * There shouldn't be any user tasks runnable while the
-		 * OOM killer is disabled, so the current task has to
-		 * be a racing OOM victim for which oom_killer_disable()
-		 * is waiting for.
-		 */
-		WARN_ON(test_thread_flag(TIF_MEMDIE));
-	}
-
+	out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
