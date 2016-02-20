Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2321F6B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 23:54:56 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hb3so48090602igb.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 20:54:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id hu10si17813214igb.7.2016.02.19.20.54.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 20:54:55 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: don't kill children of oom_task_origin() process.
Date: Sat, 20 Feb 2016 13:54:02 +0900
Message-Id: <1455944042-7614-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Selecting a child of the candidate which was chosen by oom_task_origin()
is pointless. We want to kill the candidate first.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 28d6a32..703537a2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -697,6 +697,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
 
+	/*
+	 * We must send SEGKILL on p rather than p's children in order to make
+	 * sure that oom_task_origin(p) becomes false. Printing the score value
+	 * which is (ULONG_MAX * 1000 / totalpages) is useless for this case.
+	 */
+	if (oom_task_origin(p))
+		goto kill;
+
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
@@ -728,6 +736,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);
 
+ kill:
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
