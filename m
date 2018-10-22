Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38A3C6B000C
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:13:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t18-v6so21565380plo.16
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:13:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19-v6sor20803810pft.4.2018.10.22.00.13.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 00:13:45 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Date: Mon, 22 Oct 2018 09:13:23 +0200
Message-Id: <20181022071323.9550-3-mhocko@kernel.org>
In-Reply-To: <20181022071323.9550-1-mhocko@kernel.org>
References: <20181022071323.9550-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has reported [1] that a single process group memcg might easily
swamp the log with no-eligible oom victim reports due to race between
the memcg charge and oom_reaper

Thread 1		Thread2				oom_reaper
try_charge		try_charge
			  mem_cgroup_out_of_memory
			    mutex_lock(oom_lock)
  mem_cgroup_out_of_memory
    mutex_lock(oom_lock)
			      out_of_memory
			        select_bad_process
				oom_kill_process(current)
				  wake_oom_reaper
							  oom_reap_task
							  MMF_OOM_SKIP->victim
			    mutex_unlock(oom_lock)
    out_of_memory
      select_bad_process # no task

If Thread1 didn't race it would bail out from try_charge and force the
charge. We can achieve the same by checking tsk_is_oom_victim inside
the oom_lock and therefore close the race.

[1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59552d9..a9dfed29967b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	bool ret;
+	bool ret = true;
 
 	mutex_lock(&oom_lock);
+
+	/*
+	 * multi-threaded tasks might race with oom_reaper and gain
+	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
+	 * to out_of_memory failure if the task is the last one in
+	 * memcg which would be a false possitive failure reported
+	 */
+	if (tsk_is_oom_victim(current))
+		goto unlock;
+
 	ret = out_of_memory(&oc);
+
+unlock:
 	mutex_unlock(&oom_lock);
 	return ret;
 }
-- 
2.19.1
