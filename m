Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E98FA6B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 23:13:11 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id v15-v6so6954884ply.20
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 20:13:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t19-v6si9885876plj.334.2018.08.10.20.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 20:13:09 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
 <20180810111604.GA1644@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
Date: Sat, 11 Aug 2018 12:12:52 +0900
MIME-Version: 1.0
In-Reply-To: <20180810111604.GA1644@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On 2018/08/10 20:16, Michal Hocko wrote:
>> How do you decide whether oom_reaper() was not able to reclaim much?
> 
> Just a rule of thumb. If it freed at least few kBs then we should be good
> to MMF_OOM_SKIP.

I don't think so. We are talking about situations where MMF_OOM_SKIP is set
before memory enough to prevent the OOM killer from selecting next OOM victim
was reclaimed.

>> Unless oom_victim_mm_score() becomes close to 0, setting MMF_OOM_SKIP is
>> considered premature. oom_reaper() will have to keep retrying....
> 
> there absolutely have to be a cap for retrying. Otherwise you have
> lockup scenarios back when the memory is mostly consumed by page tables.

Right, we absolutely need a cap for retrying.

>>>> We could set a MMF_EXIT_MMAP in exit_mmap() to specify that it will 
>>>> complete free_pgtables() for that mm.  The problem is the same: when does 
>>>> the oom reaper decide to set MMF_OOM_SKIP because MMF_EXIT_MMAP has not 
>>>> been set in a timely manner?
>>>
>>> reuse the current retry policy which is the number of attempts rather
>>> than any timeout.
>>
>> And this is really I can't understand. The number of attempts multiplied
>> by retry interval _is_ nothing but timeout.
> 
> Yes it is a timeout but it is not the time that matters. It is that we
> have tried sufficient times. Looks at it this way. You can retry 5 times
> in 10s or just once. Depending on what is going on in the system. I
> would really prefer the behavior to be deterministic.

What is the difference between

// Reclaim attempt by the OOM reaper
	for_each_OOM_victim_mm_without_MMF_OOM_SKIP {
		for (attempts = 0; attempts < MAX_OOM_REAP_RETRIES &&
		     !test_bit(MMF_EXIT_MMAP, &mm->flags); attempts++) {
			oom_reap_task_mm(tsk, mm):
			schedule_timeout_idle(HZ/10);
		}
		// It is time to make final decision
		if (test_bit(MMF_EXIT_MMAP, &mm->flags))
			continue;
		pr_info("Gave up waiting for process %d (%s) ...\n", ...);
		set_bit(MMF_OOM_SKIP, &mm->flags); // Allow selecting next OOM victim.
	}

(I assume this is what you call "reuse the current retry policy") and

// Initialization at mark_oom_victim()
	mm->last_reap_attempted = jiffies;
	mm->reap_attempted = 0;

// Reclaim attempt by allocating thread
	// Try allocation while waiting before oom_reap_task_mm()
	page = get_page_from_freelist(...);
	if (page)
		return page;
	for_each_OOM_victim_mm_without_MMF_OOM_SKIP {
		// Check if it is time to try oom_reap_task_mm()
		if (!time_after(jiffies, mm->last_reap_attempted + HZ / 10))
			continue;
		oom_reap_task_mm(tsk, mm);
		mm->last_reap_attempted = jiffies;
		if (mm->reap_attempted++ <= MAX_OOM_REAP_RETRIES)
			continue;
		// It is time to make final decision
		if (test_bit(MMF_EXIT_MMAP, &mm->flags))
			continue;
		pr_info("Gave up waiting for process %d (%s) ...\n", ...);
		set_bit(MMF_OOM_SKIP, &mm->flags); // Allow selecting next OOM victim.
	}

(this is what I call "direct OOM reaping") ?

Apart from the former is "sequential processing" and "the OOM reaper pays the cost
for reclaiming" while the latter is "parallel (or round-robin) processing" and "the
allocating thread pays the cost for reclaiming", both are timeout based back off
with number of retry attempt with a cap.

>> We are already using timeout based decision, with some attempt to reclaim
>> memory if conditions are met.
> 
> Timeout based decision is when you, well, make a decision after a
> certain time passes. And we do not do that.

But we are talking about what we can do after oom_reap_task_mm() can no longer
make progress. Both the former and the latter will wait until a time controlled
by the number of attempts and retry interval elapses.

>>>> If this is an argument that the oom reaper should loop checking for 
>>>> MMF_EXIT_MMAP and doing schedule_timeout(1) a set number of times rather 
>>>> than just setting the jiffies in the mm itself, that's just implementing 
>>>> the same thing and doing so in a way where the oom reaper stalls operating 
>>>> on a single mm rather than round-robin iterating over mm's in my patch.
>>>
>>> I've said earlier that I do not mind doing round robin in the oom repaer
>>> but this is certainly more complex than what we do now and I haven't
>>> seen any actual example where it would matter. OOM reaper is a safely
>>> measure. Nothing should fall apart if it is slow. 
>>
>> The OOM reaper can fail if allocating threads have high priority. You seem to
>> assume that realtime threads won't trigger OOM path. But since !PF_WQ_WORKER
>> threads do only cond_resched() due to your "the cargo cult programming" refusal,
>> and like Andrew Morton commented
>>
>>   cond_resched() is a no-op in the presence of realtime policy threads
>>   and using to attempt to yield to a different thread it in this fashion
>>   is broken.
>>
>> at "mm: disable preemption before swapcache_free" thread, we can't guarantee
>> that allocating threads shall give the OOM reaper enough CPU resource for
>> making forward progress. And my direct OOM reaping proposal was also refused
>> by you. I really dislike counting OOM reaper as a safety measure.
> 
> Well, yeah, you can screw up your system with real time priority tasks
> all you want. I really fail to see why you are bringing that up now
> though. Yet another offtopic?
> 

Not offtopic at all. My direct OOM reaping proposal is exactly handling such
situation. And I already suggested how we could avoid forcing some allocating
thread to pay the full cost for reclaiming all reclaimable memory.
