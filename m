Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C44E8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:57:09 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id t133so6062841iof.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:57:09 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j82si1888781itb.63.2019.01.09.02.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:57:08 -0800 (PST)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
 <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
 <20190107133720.GH31793@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <935ae77c-9663-c3a4-c73a-fa69f9a3065f@i-love.sakura.ne.jp>
Date: Wed, 9 Jan 2019 19:56:57 +0900
MIME-Version: 1.0
In-Reply-To: <20190107133720.GH31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 2019/01/07 22:37, Michal Hocko wrote:
> On Mon 07-01-19 22:07:43, Tetsuo Handa wrote:
>> On 2019/01/07 20:41, Michal Hocko wrote:
>>> On Sun 06-01-19 15:02:24, Tetsuo Handa wrote:
>>>> Michal and Johannes, can we please stop this stupid behavior now?
>>>
>>> I have proposed a patch with a much more limited scope which is still
>>> waiting for feedback. I haven't heard it wouldn't be working so far.
>>>
>>
>> You mean
>>
>>   mutex_lock_killable would take care of exiting task already. I would
>>   then still prefer to check for mark_oom_victim because that is not racy
>>   with the exit path clearing signals. I can update my patch to use
>>   _killable lock variant if we are really going with the memcg specific
>>   fix.
>>
>> ? No response for two months.
> 
> I mean http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
> which has died in nit picking. I am not very interested to go back there
> and spend a lot of time with it again. If you do not respect my opinion
> as the maintainer of this code then find somebody else to push it
> through.
> 

OK. It turned out that Michal's comment is independent with this patch.
We can apply both Michal's patch and my patch, and here is my patch.

>From 0fb58415770a83d6c40d471e1840f8bc4a35ca83 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 26 Dec 2018 19:13:35 +0900
Subject: [PATCH] memcg: killed threads should not invoke memcg OOM killer

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
when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) and
memory_max_write() can bail out upon SIGKILL, and try_charge() allows
already killed/exiting threads to make forward progress.

If memcg OOM events in different domains are pending, already OOM-killed
threads needlessly wait for pending memcg OOM events in different domains.
An out_of_memory() call is slow because it involves printk(). With slow
serial consoles, out_of_memory() might take more than a second. Therefore,
allowing killed processes to quickly call mmput() from exit_mm() from
do_exit() will help calling __mmput() (which can reclaim more memory than
the OOM reaper can reclaim) quickly.

At first Michal thought that fatal signal check is racy compared to
tsk_is_oom_victim() check. But actually there is no such race, for
by the moment mutex_unlock(&oom_lock) is called after returning from
out_of_memory(), fatal_signal_pending() == F && tsk_is_oom_victim() == T
can't happen if current thread is holding oom_lock inside
mem_cgroup_out_of_memory(). On the other hand,
fatal_signal_pending() == T && tsk_is_oom_victim() == F can happen, and
bailing out upon that condition will save some process from needlessly
being OOM-killed.

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
