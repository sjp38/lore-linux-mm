Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7B39C6B0254
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 22:05:50 -0400 (EDT)
Received: by oiww128 with SMTP id w128so43656798oiw.2
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 19:05:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e69si8693018oic.96.2015.09.19.19.05.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Sep 2015 19:05:49 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2/3] mm,oom: Fix potentially killing unrelated process.
Date: Sun, 20 Sep 2015 11:04:44 +0900
Message-Id: <1442714685-14002-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1442714685-14002-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442714685-14002-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

At the for_each_process() loop in oom_kill_process(), we are comparing
address of OOM victim's mm without holding a reference to that mm.
If there are a lot of processes to compare or a lot of "Kill process
%d (%s) sharing same memory" messages to print, for_each_process() loop
could take very long time.

It is possible that meanwhile the OOM victim exits and releases its mm,
and then mm is allocated with the same address and assigned to some
unrelated process. When we hit such race, the unrelated process will be
killed by error. To make sure that the OOM victim's mm does not go away
until for_each_process() loop finishes, get a reference on the OOM
victim's mm before calling task_unlock(victim).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4487685..408aa8e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -552,8 +552,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		victim = p;
 	}
 
-	/* mm cannot safely be dereferenced after task_unlock(victim) */
+	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
+	atomic_inc(&mm->mm_users);
 	/* Send SIGKILL before setting TIF_MEMDIE. */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
@@ -587,6 +588,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		}
 	rcu_read_unlock();
 
+	mmput(mm);
 	put_task_struct(victim);
 }
 #undef K
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
