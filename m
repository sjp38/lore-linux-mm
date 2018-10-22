Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEADF6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 09:20:57 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id t4-v6so27334675iof.4
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 06:20:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w63-v6si8496320itd.26.2018.10.22.06.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 06:20:56 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
 <20181022120308.GB18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0a84d3de-f342-c183-579b-d672c116ba25@i-love.sakura.ne.jp>
Date: Mon, 22 Oct 2018 22:20:36 +0900
MIME-Version: 1.0
In-Reply-To: <20181022120308.GB18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/22 21:03, Michal Hocko wrote:
> On Mon 22-10-18 20:45:17, Tetsuo Handa wrote:
>> On 2018/10/22 16:13, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Tetsuo has reported [1] that a single process group memcg might easily
>>> swamp the log with no-eligible oom victim reports due to race between
>>> the memcg charge and oom_reaper
>>>
>>> Thread 1		Thread2				oom_reaper
>>> try_charge		try_charge
>>> 			  mem_cgroup_out_of_memory
>>> 			    mutex_lock(oom_lock)
>>>   mem_cgroup_out_of_memory
>>>     mutex_lock(oom_lock)
>>> 			      out_of_memory
>>> 			        select_bad_process
>>> 				oom_kill_process(current)
>>> 				  wake_oom_reaper
>>> 							  oom_reap_task
>>> 							  MMF_OOM_SKIP->victim
>>> 			    mutex_unlock(oom_lock)
>>>     out_of_memory
>>>       select_bad_process # no task
>>>
>>> If Thread1 didn't race it would bail out from try_charge and force the
>>> charge. We can achieve the same by checking tsk_is_oom_victim inside
>>> the oom_lock and therefore close the race.
>>>
>>> [1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>> ---
>>>  mm/memcontrol.c | 14 +++++++++++++-
>>>  1 file changed, 13 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index e79cb59552d9..a9dfed29967b 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>>  		.gfp_mask = gfp_mask,
>>>  		.order = order,
>>>  	};
>>> -	bool ret;
>>> +	bool ret = true;
>>>  
>>>  	mutex_lock(&oom_lock);
>>> +
>>> +	/*
>>> +	 * multi-threaded tasks might race with oom_reaper and gain
>>> +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
>>> +	 * to out_of_memory failure if the task is the last one in
>>> +	 * memcg which would be a false possitive failure reported
>>> +	 */
>>> +	if (tsk_is_oom_victim(current))
>>> +		goto unlock;
>>> +
>>
>> This is not wrong but is strange. We can use mutex_lock_killable(&oom_lock)
>> so that any killed threads no longer wait for oom_lock.
> 
> tsk_is_oom_victim is stronger because it doesn't depend on
> fatal_signal_pending which might be cleared throughout the exit process.

I mean:

 mm/memcontrol.c |   3 +-
 mm/oom_kill.c   | 111 +++++---------------------------------------------------
 2 files changed, 12 insertions(+), 102 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59..2c1e1ac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1382,7 +1382,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret;
 
-	mutex_lock(&oom_lock);
+	if (mutex_lock_killable(&oom_lock))
+		return true;
 	ret = out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..22fd6b3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -755,81 +755,6 @@ bool oom_killer_disable(signed long timeout)
 	return true;
 }
 
-static inline bool __task_will_free_mem(struct task_struct *task)
-{
-	struct signal_struct *sig = task->signal;
-
-	/*
-	 * A coredumping process may sleep for an extended period in exit_mm(),
-	 * so the oom killer cannot assume that the process will promptly exit
-	 * and release memory.
-	 */
-	if (sig->flags & SIGNAL_GROUP_COREDUMP)
-		return false;
-
-	if (sig->flags & SIGNAL_GROUP_EXIT)
-		return true;
-
-	if (thread_group_empty(task) && (task->flags & PF_EXITING))
-		return true;
-
-	return false;
-}
-
-/*
- * Checks whether the given task is dying or exiting and likely to
- * release its address space. This means that all threads and processes
- * sharing the same mm have to be killed or exiting.
- * Caller has to make sure that task->mm is stable (hold task_lock or
- * it operates on the current).
- */
-static bool task_will_free_mem(struct task_struct *task)
-{
-	struct mm_struct *mm = task->mm;
-	struct task_struct *p;
-	bool ret = true;
-
-	/*
-	 * Skip tasks without mm because it might have passed its exit_mm and
-	 * exit_oom_victim. oom_reaper could have rescued that but do not rely
-	 * on that for now. We can consider find_lock_task_mm in future.
-	 */
-	if (!mm)
-		return false;
-
-	if (!__task_will_free_mem(task))
-		return false;
-
-	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
-		return false;
-
-	if (atomic_read(&mm->mm_users) <= 1)
-		return true;
-
-	/*
-	 * Make sure that all tasks which share the mm with the given tasks
-	 * are dying as well to make sure that a) nobody pins its mm and
-	 * b) the task is also reapable by the oom reaper.
-	 */
-	rcu_read_lock();
-	for_each_process(p) {
-		if (!process_shares_mm(p, mm))
-			continue;
-		if (same_thread_group(task, p))
-			continue;
-		ret = __task_will_free_mem(p);
-		if (!ret)
-			break;
-	}
-	rcu_read_unlock();
-
-	return ret;
-}
-
 static void __oom_kill_process(struct task_struct *victim)
 {
 	struct task_struct *p;
@@ -879,6 +804,8 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
+		struct task_struct *t;
+
 		if (!process_shares_mm(p, mm))
 			continue;
 		if (same_thread_group(p, victim))
@@ -898,6 +825,11 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		mark_oom_victim(t);
+		task_unlock(t);
 	}
 	rcu_read_unlock();
 
@@ -934,21 +866,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 
-	/*
-	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just give it access to memory reserves
-	 * so it can die quickly
-	 */
-	task_lock(p);
-	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
-		task_unlock(p);
-		put_task_struct(p);
-		return;
-	}
-	task_unlock(p);
-
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
 
@@ -1055,6 +972,9 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
+		return true;
+
 	if (oom_killer_disabled)
 		return false;
 
@@ -1066,17 +986,6 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
-		return true;
-	}
-
-	/*
 	 * The OOM killer does not compensate for IO-less reclaim.
 	 * pagefault_out_of_memory lost its gfp context so we have to
 	 * make sure exclude 0 mask - all other users should have at least
-- 
1.8.3.1

> 
>> Also, closing this race for only memcg OOM path is strange. Global OOM path
>> (which are CLONE_VM without CLONE_THREAD) is still suffering this race
>> (though frequency is lower than memcg OOM due to use of mutex_trylock()). Either
>> checking before calling out_of_memory() or checking task_will_free_mem(current)
>> inside out_of_memory() will close this race for both paths.
> 
> The global case is much more complicated because we know that memcg
> might bypass the charge so we do not have to care about the potential
> endless loop like in page allocator path.

We know that the page allocator path does not do endless loop unless
__GFP_NOFAIL.
 
>                                           Moreover I am not even sure
> the race is all that interesting in the global case. I have never heard
> about a pre-mature panic due to no killable task.

I don't think this race results in

  panic("System is deadlocked on memory\n");

. But I think a few unnecessary OOM killing is possible (especially when
above patch which "eliminates the shortcuts which call mark_oom_victim()
on only one thread group" is not applied).

>                                                   The racing oom task
> would have to be the last eligible process in the system and that is
> quite unlikely. We can think about a more involved solution for that if
> we ever hear about this to be a real problem.
> 
> So a simple memcg specific fix sounds like a reasonable way forward.
> 
