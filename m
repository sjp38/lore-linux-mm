Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D863A8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so382088edr.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor36264614edd.23.2019.01.07.06.39.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:43 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Date: Mon,  7 Jan 2019 15:38:02 +0100
Message-Id: <20190107143802.16847-3-mhocko@kernel.org>
In-Reply-To: <20190107143802.16847-1-mhocko@kernel.org>
References: <20190107143802.16847-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
index af7f18b32389..90eb2e2093e7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1387,10 +1387,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
2.20.1
