Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C473828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:00:15 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f6so168902735ith.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:00:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y6si1677907itc.53.2016.06.23.09.00.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 09:00:14 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
Date: Fri, 24 Jun 2016 00:58:47 +0900
Message-Id: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, David Rientjes <rientjes@google.com>

Patch "mm, oom: fortify task_will_free_mem" removed p->mm != NULL test for
shortcut path in oom_kill_process(). But since commit f44666b04605d1c7
("mm,oom: speed up select_bad_process() loop") changed to iterate using
thread group leaders, the possibility of p->mm == NULL has increased
compared to when commit 83363b917a2982dd ("oom: make sure that TIF_MEMDIE
is set under task_lock") was proposed. On CONFIG_MMU=n kernels, nothing
will clear TIF_MEMDIE and the system can OOM livelock if TIF_MEMDIE was
by error set to a mm-less thread group leader.

Let's redo find_task_lock_mm() test after task_will_free_mem() returned
true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f74..846d5a7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -839,9 +839,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		put_task_struct(p);
+		p = find_lock_task_mm(p);
+		if (p) {
+			mark_oom_victim(p);
+			task_unlock(p);
+			wake_oom_reaper(p);
+		}
+		put_task_struct(victim);
 		return;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
