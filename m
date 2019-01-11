Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id A27BD8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:41:01 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id u63so6578492oie.17
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 04:41:01 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 59si1887119ota.290.2019.01.11.04.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 04:41:00 -0800 (PST)
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
 <20190111113354.GD14956@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
Date: Fri, 11 Jan 2019 21:40:52 +0900
MIME-Version: 1.0
In-Reply-To: <20190111113354.GD14956@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 2019/01/11 20:33, Michal Hocko wrote:
> On Fri 11-01-19 19:25:22, Tetsuo Handa wrote:
>> On 2019/01/11 8:59, Tetsuo Handa wrote:
>>> Michal Hocko wrote:
>>>> On Wed 09-01-19 20:34:46, Tetsuo Handa wrote:
>>>>> On 2019/01/09 20:03, Michal Hocko wrote:
>>>>>> Tetsuo,
>>>>>> can you confirm that these two patches are fixing the issue you have
>>>>>> reported please?
>>>>>>
>>>>>
>>>>> My patch fixes the issue better than your "[PATCH 2/2] memcg: do not
>>>>> report racy no-eligible OOM tasks" does.
>>>>
>>>> OK, so we are stuck again. Hooray!
>>>
>>> Andrew, will you pick up "[PATCH 3/2] memcg: Facilitate termination of memcg OOM victims." ?
>>> Since mm-oom-marks-all-killed-tasks-as-oom-victims.patch does not call mark_oom_victim()
>>> when task_will_free_mem() == true, memcg-do-not-report-racy-no-eligible-oom-tasks.patch
>>> does not close the race whereas my patch closes the race better.
>>>
>>
>> I confirmed that mm-oom-marks-all-killed-tasks-as-oom-victims.patch and
>> memcg-do-not-report-racy-no-eligible-oom-tasks.patch are completely failing
>> to fix the issue I am reporting. :-(
> 
> OK, this is really interesting. This means that we are racing
> when marking all the tasks sharing the mm with the clone syscall.

Nothing interesting. This is NOT a race between clone() and the OOM killer. :-(
By the moment the OOM killer is invoked, all clone() requests are already completed.

Did you notice that there is no

  "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"

line between

  [   71.304703][ T9694] Memory cgroup out of memory: Kill process 9692 (a.out) score 904 or sacrifice child

and

  [   71.309149][   T54] oom_reaper: reaped process 9750 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:185532kB

? Then, you will find that [ T9694] failed to reach for_each_process(p) loop inside
__oom_kill_process() in the first round of out_of_memory() call because
find_lock_task_mm() == NULL at __oom_kill_process() because Ctrl-C made that victim
complete exit_mm() before find_lock_task_mm() is called. Then, in the second round
of out_of_memory() call, [ T9750] (which is fatal_signal_pending() == T &&
tsk_is_oom_victim() == F) hit task_will_free_mem(current) path and called
mark_oom_victim() and woke up the OOM reaper. Then, before the third round of
out_of_memory() call starts, the OOM reaper set MMF_OOM_SKIP. When the third round
of out_of_memory() call started, [ T9748] could not hit task_will_free_mem(current)
path because MMF_OOM_SKIP was already set, and oom_badness() ignored any mm which
already has MMF_OOM_SKIP. As a result, [ T9748] failed to find a candidate. And this
step repeats for up to number of threads (213 times for this run).

> Does fatal_signal_pending handle this better?
> 

Of course. My patch handles it perfectly. Even if we raced with clone() requests,
why do we need to care about threads doing clone() requests? Such threads are not
inside try_charge(), and therefore such threads can't contribute to this issue
by calling out_of_memory() from try_charge().
