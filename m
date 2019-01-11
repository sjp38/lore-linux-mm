Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id CAEFA8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:31:34 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id n22so6072138otq.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:31:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l13si36430876otl.309.2019.01.11.06.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 06:31:33 -0800 (PST)
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
 <20190111113354.GD14956@dhcp22.suse.cz>
 <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
 <20190111133401.GA6997@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d9f7b139-d51b-93ae-b5ad-856fd9f2c168@i-love.sakura.ne.jp>
Date: Fri, 11 Jan 2019 23:31:18 +0900
MIME-Version: 1.0
In-Reply-To: <20190111133401.GA6997@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 2019/01/11 22:34, Michal Hocko wrote:
> On Fri 11-01-19 21:40:52, Tetsuo Handa wrote:
> [...]
>> Did you notice that there is no
>>
>>   "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
>>
>> line between
>>
>>   [   71.304703][ T9694] Memory cgroup out of memory: Kill process 9692 (a.out) score 904 or sacrifice child
>>
>> and
>>
>>   [   71.309149][   T54] oom_reaper: reaped process 9750 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:185532kB
>>
>> ? Then, you will find that [ T9694] failed to reach for_each_process(p) loop inside
>> __oom_kill_process() in the first round of out_of_memory() call because
>> find_lock_task_mm() == NULL at __oom_kill_process() because Ctrl-C made that victim
>> complete exit_mm() before find_lock_task_mm() is called.
> 
> OK, so we haven't killed anything because the victim has exited by the
> time we wanted to do so. We still have other tasks sharing that mm
> pending and not killed because nothing has killed them yet, right?

The OOM killer invoked by [ T9694] called printk() but didn't kill anything.
Instead, SIGINT from Ctrl-C killed all thread groups sharing current->mm.

> 
> How come the oom reaper could act on this oom event at all then?
> 
> What am I missing?
> 

The OOM killer invoked by [ T9750] did not call printk() but hit
task_will_free_mem(current) in out_of_memory() and invoked the OOM reaper,
without calling mark_oom_victim() on all thread groups sharing current->mm.
Did you notice that I wrote that

  Since mm-oom-marks-all-killed-tasks-as-oom-victims.patch does not call mark_oom_victim()
  when task_will_free_mem() == true,

? :-(
