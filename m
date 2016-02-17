Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id C6E116B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:36:49 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id xk3so7705193obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:36:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f63si673131oic.19.2016.02.17.02.36.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 02:36:49 -0800 (PST)
Subject: [PATCH 6/6] mm,oom: wait for OOM victims when using oom_kill_allocating_task == 1
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
In-Reply-To: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
Message-Id: <201602171936.JDC18598.JHOFtLVOQSFMOF@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 19:36:36 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 0b36864d4100ecbdcaa2fc2d1927c9e270f1b629 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 16:37:59 +0900
Subject: [PATCH 6/6] mm,oom: wait for OOM victims when using oom_kill_allocating_task == 1

Currently, out_of_memory() does not wait for existing TIF_MEMDIE threads
if /proc/sys/vm/oom_kill_allocating_task is set to 1. This can result in
killing more OOM victims than needed. We can wait for the OOM reaper to
reap memory used by existing TIF_MEMDIE threads if possible. If the OOM
reaper is not available, the system will be kept OOM stalled until an
OOM-unkillable thread does a GFP_FS allocation request and calls
oom_kill_allocating_task == 0 path.

This patch changes oom_kill_allocating_task == 1 case to call
select_bad_process() in order to wait for existing TIF_MEMDIE threads.
Since "mm,oom: exclude TIF_MEMDIE processes from candidates.",
"mm,oom: don't abort on exiting processes when selecting a victim.",
"mm,oom: exclude oom_task_origin processes if they are OOM victims.",
"mm,oom: exclude oom_task_origin processes if they are OOM-unkillable."
and "mm,oom: Re-enable OOM killer using timers." made sure that we never
wait for TIF_MEMDIE threads forever, waiting for TIF_MEMDIE threads for
oom_kill_allocating_task == 1 does not cause OOM livelock problem.

After this patch, we can safely merge the OOM reaper in the simplest
form, without worrying about corner cases.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fba2c62..9cd1cd1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -737,15 +737,6 @@ bool out_of_memory(struct oom_control *oc)
 		oc->nodemask = NULL;
 	check_panic_on_oom(oc, constraint, NULL);
 
-	if (sysctl_oom_kill_allocating_task && current->mm &&
-	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
-	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages, NULL,
-				 "Out of memory (oom_kill_allocating_task)");
-		return true;
-	}
-
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p && !is_sysrq_oom(oc)) {
@@ -753,8 +744,18 @@ bool out_of_memory(struct oom_control *oc)
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (p && p != (void *)-1UL) {
-		oom_kill_process(oc, p, points, totalpages, NULL,
-				 "Out of memory");
+		const char *message = "Out of memory";
+
+		if (sysctl_oom_kill_allocating_task && current->mm &&
+		    !oom_unkillable_task(current, NULL, oc->nodemask) &&
+		    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+			put_task_struct(p);
+			p = current;
+			get_task_struct(p);
+			message = "Out of memory (oom_kill_allocating_task)";
+			points = 0;
+		}
+		oom_kill_process(oc, p, points, totalpages, NULL, message);
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
