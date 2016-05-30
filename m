Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5A566B0262
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:06:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id w16so80206363lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:16 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id cb2si44328253wjc.188.2016.05.30.06.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 06:06:09 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q62so22583941wmg.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/6] mm, oom: kill all tasks sharing the mm
Date: Mon, 30 May 2016 15:05:55 +0200
Message-Id: <1464613556-16708-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Currently oom_kill_process skips both the oom reaper and SIG_KILL if a
process sharing the same mm is unkillable via OOM_ADJUST_MIN. After "mm,
oom_adj: make sure processes sharing mm have same view of oom_score_adj"
all such processes are sharing the same value so we shouldn't see such a
task at all (oom_badness would rule them out).

We can still encounter oom disabled vforked task which has to be killed
as well if we want to have other tasks sharing the mm reapable
because it can access the memory before doing exec. Killing such a task
should be acceptable because it is highly unlikely it has done anything
useful because it cannot modify any memory before it calls exec. An
alternative would be to keep the task alive and skip the oom reaper and
risk all the weird corner cases where the OOM killer cannot make forward
progress because the oom victim hung somewhere on the way to exit.

There is a potential race where we kill the oom disabled task which is
highly unlikely but possible. It would happen if __set_oom_adj raced
with select_bad_process and then it is OK to consider the old value or
with fork when it should be acceptable as well.
Let's add a little note to the log so that people would tell us that
this really happens in the real life and it matters.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 92bc8c3ec97b..d296f4467500 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -852,8 +852,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p)) {
 			/*
 			 * We cannot use oom_reaper for the mm shared by this
 			 * process because it wouldn't get killed and so the
@@ -862,6 +861,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			can_oom_reap = false;
 			continue;
 		}
+		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
+			pr_warn("%s pid=%d shares mm with oom disabled %s pid=%d. Seems like misconfiguration, killing anyway!"
+					" Report at linux-mm@kvack.org\n",
+					victim->comm, task_pid_nr(victim),
+					p->comm, task_pid_nr(p));
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
