Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 04DD16B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:31:35 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id 20so23887525wmh.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:31:34 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id la5si33931421wjb.232.2016.03.29.05.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 05:31:33 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id 191so48765596wmq.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:31:33 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] oom, oom_reaper: Do not enqueue task if it is on the oom_reaper_list head
Date: Tue, 29 Mar 2016 14:31:26 +0200
Message-Id: <1459254686-29457-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

bb29902a7515 ("oom, oom_reaper: protect oom_reaper_list using simpler
way") has simplified the check for tasks already enqueued for the oom
reaper by checking tsk->oom_reaper_list != NULL. This check is not
sufficient because the tsk might be the head of the queue without any
other tasks queued and then we would simply lockup looping on the same
task. Fix the condition by checking for the head as well.

Fixes: bb29902a7515 ("oom, oom_reaper: protect oom_reaper_list using simpler way")
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I have just noticed this after I started consolidating other oom_reaper
related changes I have here locally. I should have caught this during
the review already and I really feel ashamed I haven't because this is
really a trivial bug that should be obvious see...

 mm/oom_kill.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b34d279a7ee6..86349586eacb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -547,7 +547,11 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th || tsk->oom_reaper_list)
+	if (!oom_reaper_th)
+		return;
+
+	/* tsk is already queued? */
+	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
 		return;
 
 	get_task_struct(tsk);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
