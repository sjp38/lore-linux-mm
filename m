Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 710168E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:17:43 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m128so2272271itd.3
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:17:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u65si1779412itu.61.2019.01.15.02.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 02:17:42 -0800 (PST)
Subject: [PATCH v2] memcg: killed threads should not invoke memcg OOM killer
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
 <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
 <20190107133720.GH31793@dhcp22.suse.cz>
 <935ae77c-9663-c3a4-c73a-fa69f9a3065f@i-love.sakura.ne.jp>
Message-ID: <01370f70-e1f6-ebe4-b95e-0df21a0bc15e@i-love.sakura.ne.jp>
Date: Tue, 15 Jan 2019 19:17:27 +0900
MIME-Version: 1.0
In-Reply-To: <935ae77c-9663-c3a4-c73a-fa69f9a3065f@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

If $N > $M, a single process with $N threads in a memcg group can easily
kill all $M processes in that memcg group, for mem_cgroup_out_of_memory()
does not check if current thread needs to invoke the memcg OOM killer.

  T1@P1     |T2...$N@P1|P2...$M   |OOM reaper
  ----------+----------+----------+----------
                        # all sleeping
  try_charge()
    mem_cgroup_out_of_memory()
      mutex_lock(oom_lock)
             try_charge()
               mem_cgroup_out_of_memory()
                 mutex_lock(oom_lock)
      out_of_memory()
        select_bad_process()
        oom_kill_process(P1)
        wake_oom_reaper()
                                   oom_reap_task() # ignores P1
      mutex_unlock(oom_lock)
                 out_of_memory()
                   select_bad_process(P2...$M)
                        # all killed by T2...$N@P1
                   wake_oom_reaper()
                                   oom_reap_task() # ignores P2...$M
                 mutex_unlock(oom_lock)

We don't need to invoke the memcg OOM killer if current thread was killed
when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) can count
on try_charge() when mem_cgroup_oom_synchronize(true) can not make forward
progress because try_charge() allows already killed/exiting threads to
make forward progress, and memory_max_write() can bail out upon signals.

At first Michal thought that fatal signal check is racy compared to
tsk_is_oom_victim() check. But an experiment showed that trying to call
mark_oom_victim() on all killed thread groups is more racy than fatal
signal check due to task_will_free_mem(current) path in out_of_memory().

Therefore, this patch changes mem_cgroup_out_of_memory() to bail out upon
should_force_charge() == T rather than upon fatal_signal_pending() == T,
for should_force_charge() == T && signal_pending(current) == F at
memory_max_write() can't happen because current thread won't call
memory_max_write() after getting PF_EXITING.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b..79a7d2a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -248,6 +248,12 @@ enum res_type {
 	     iter != NULL;				\
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
+static inline bool should_force_charge(void)
+{
+	return tsk_is_oom_victim(current) || fatal_signal_pending(current) ||
+		(current->flags & PF_EXITING);
+}
+
 /* Some nice accessors for the vmpressure. */
 struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
 {
@@ -1389,8 +1395,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
+	ret = should_force_charge() || out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
 }
@@ -2209,9 +2220,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * bypass the last charges so that they can exit quickly and
 	 * free their memory.
 	 */
-	if (unlikely(tsk_is_oom_victim(current) ||
-		     fatal_signal_pending(current) ||
-		     current->flags & PF_EXITING))
+	if (unlikely(should_force_charge()))
 		goto force;
 
 	/*
-- 
1.8.3.1
