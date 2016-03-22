Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4446B0262
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:01:13 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id r129so87043587wmr.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:13 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 5si12954533wmw.30.2016.03.22.04.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:01:07 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id u125so2597106wmg.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:07 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/9] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
Date: Tue, 22 Mar 2016 12:00:23 +0100
Message-Id: <1458644426-22973-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported that oom_kill_allocating_task=1 will cause
oom_reaper_list corruption because oom_kill_process doesn't follow
standard OOM exclusion (aka ignores TIF_MEMDIE) and allows to enqueue
the same task multiple times - e.g. by sacrificing the same child
multiple times.

This patch fixes the issue by introducing a new MMF_OOM_KILLED mm flag
which is set in oom_kill_process atomically and oom reaper is disabled
if the flag was already set.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h | 2 ++
 mm/oom_kill.c         | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index bc5867296f7b..acb480b581e3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -511,6 +511,8 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 
+#define MMF_OOM_KILLED		21	/* OOM killer has chosen this mm */
+
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
 struct sighand_struct {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8e0bd279135f..b38a648558f9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -679,7 +679,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
-	bool can_oom_reap = true;
+	bool can_oom_reap;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -741,6 +741,10 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
 	atomic_inc(&mm->mm_count);
+
+	/* Make sure we do not try to oom reap the mm multiple times */
+	can_oom_reap = !test_and_set_bit(MMF_OOM_KILLED, &mm->flags);
+
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
