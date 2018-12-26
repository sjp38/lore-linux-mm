Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D74D8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:14:00 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id e141so11104814oig.11
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 02:14:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z36si14393068ota.0.2018.12.26.02.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 02:13:58 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] memcg: killed threads should not invoke memcg OOM killer
Date: Wed, 26 Dec 2018 19:13:35 +0900
Message-Id: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

It is possible that a single process group memcg easily swamps the log
with no-eligible OOM victim messages after current thread was OOM-killed,
due to race between the memcg charge and the OOM reaper [1].

Thread-1                 Thread-2                       OOM reaper
try_charge()
  mem_cgroup_out_of_memory()
    mutex_lock(oom_lock)
                        try_charge()
                          mem_cgroup_out_of_memory()
                            mutex_lock(oom_lock)
    out_of_memory()
      select_bad_process()
      oom_kill_process(current)
      wake_oom_reaper()
                                                        oom_reap_task()
                                                        # sets MMF_OOM_SKIP
    mutex_unlock(oom_lock)
                            out_of_memory()
                              select_bad_process() # no task
                            mutex_unlock(oom_lock)

We don't need to invoke the memcg OOM killer if current thread was killed
when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) and
memory_max_write() can bail out upon SIGKILL, and try_charge() allows
already killed/exiting threads to make forward progress.

Michal has a plan to use tsk_is_oom_victim() by calling mark_oom_victim()
on all thread groups sharing victim's mm. But fatal_signal_pending() in
this patch helps regardless of Michal's plan because it will avoid
needlessly calling out_of_memory() when current thread is already
terminating (e.g. got SIGINT after passing fatal_signal_pending() check
in try_charge() and mutex_lock_killable() did not block).

[1] https://lkml.kernel.org/r/ea637f9a-5dd0-f927-d26d-d0b4fd8ccb6f@i-love.sakura.ne.jp

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b860dd4f7..b0d3bf3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1389,8 +1389,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret;
 
-	mutex_lock(&oom_lock);
-	ret = out_of_memory(&oc);
+	if (mutex_lock_killable(&oom_lock))
+		return true;
+	/*
+	 * A few threads which were not waiting at mutex_lock_killable() can
+	 * fail to bail out. Therefore, check again after holding oom_lock.
+	 */
+	ret = fatal_signal_pending(current) || out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
 }
-- 
1.8.3.1
