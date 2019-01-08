Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 078EA8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:21:40 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id k4so3350271ioc.10
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:21:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n128si6999665itc.40.2019.01.08.06.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:21:38 -0800 (PST)
Subject: [PATCH 3/2] memcg: Facilitate termination of memcg OOM victims.
References: <20190107143802.16847-1-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a49e2b45-10b2-715c-7dcb-2eb7ec5d2cf2@i-love.sakura.ne.jp>
Date: Tue, 8 Jan 2019 23:21:23 +0900
MIME-Version: 1.0
In-Reply-To: <20190107143802.16847-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

If memcg OOM events in different domains are pending, already OOM-killed
threads needlessly wait for pending memcg OOM events in different domains.
An out_of_memory() call is slow because it involves printk(). With slow
serial consoles, out_of_memory() might take more than a second. Therefore,
allowing killed processes to quickly call mmput() from exit_mm() from
do_exit() will help calling __mmput() (which can reclaim more memory than
the OOM reaper can reclaim) quickly.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90eb2e2..a7d3ba9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1389,14 +1389,19 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret = true;
 
-	mutex_lock(&oom_lock);
-
 	/*
-	 * multi-threaded tasks might race with oom_reaper and gain
-	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
-	 * to out_of_memory failure if the task is the last one in
-	 * memcg which would be a false possitive failure reported
+	 * Multi-threaded tasks might race with oom_reaper() and gain
+	 * MMF_OOM_SKIP before reaching out_of_memory(). But if current
+	 * thread was already killed or is ready to terminate, there is
+	 * no need to call out_of_memory() nor wait for oom_reaoer() to
+	 * set MMF_OOM_SKIP. These three checks minimize possibility of
+	 * needlessly calling out_of_memory() and try to call exit_mm()
+	 * as soon as possible.
 	 */
+	if (mutex_lock_killable(&oom_lock))
+		return true;
+	if (fatal_signal_pending(current))
+		goto unlock;
 	if (tsk_is_oom_victim(current))
 		goto unlock;
 
-- 
1.8.3.1
