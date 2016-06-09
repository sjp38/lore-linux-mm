Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 805656B0261
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 07:52:40 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id rs7so14981926lbb.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:40 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id bn6si7464507wjb.32.2016.06.09.04.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 04:52:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id k184so10030238wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 04:52:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
Date: Thu,  9 Jun 2016 13:52:13 +0200
Message-Id: <1465473137-22531-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
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

[rientjes@google.com - drop printk when OOM_SCORE_ADJ_MIN killed task
 the setting is inherently racy and we cannot do much about it without
 introducing locks in hot paths]
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 02da660b7c25..38f89ac2df7f 100644
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
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
