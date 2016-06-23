Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56DDE828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:24:58 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id l125so172210805ywb.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:24:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d4si1054563ith.1.2016.06.23.09.24.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 09:24:57 -0700 (PDT)
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
Date: Fri, 24 Jun 2016 01:24:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, mhocko@suse.com, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

I missed that victim != p case needs to use get_task_struct(). Patch updated.
----------------------------------------
>From 1819ec63b27df2d544f66482439e754d084cebed Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 24 Jun 2016 01:16:02 +0900
Subject: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.

Patch "mm, oom: fortify task_will_free_mem" removed p->mm != NULL test for
shortcut path in oom_kill_process(). But since commit f44666b04605d1c7
("mm,oom: speed up select_bad_process() loop") changed to iterate using
thread group leaders, the possibility of p->mm == NULL has increased
compared to when commit 83363b917a2982dd ("oom: make sure that TIF_MEMDIE
is set under task_lock") was proposed. On CONFIG_MMU=n kernels, nothing
will clear TIF_MEMDIE and the system can OOM livelock if TIF_MEMDIE was
by error set to a mm-less thread group leader.

Let's do steps for regular path except printing OOM killer messages and
sending SIGKILL.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f74..0a19a24 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -839,9 +839,19 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		put_task_struct(p);
+		p = find_lock_task_mm(victim);
+		if (!p) {
+			put_task_struct(victim);
+			return;
+		} else if (victim != p) {
+			get_task_struct(p);
+			put_task_struct(victim);
+			victim = p;
+		}
+		mark_oom_victim(victim);
+		task_unlock(victim);
+		wake_oom_reaper(victim);
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
