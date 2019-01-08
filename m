Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 264D38E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 05:40:11 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id q18so2863464ioj.5
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 02:40:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f14si5842703iog.161.2019.01.08.02.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 02:40:09 -0800 (PST)
Subject: Re: [PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190107143802.16847-3-mhocko@kernel.org>
 <fa8892d1-4a38-dccd-9597-923924aa0a66@i-love.sakura.ne.jp>
 <20190108081441.GO31793@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <3b105bba-3542-1d00-c6e2-52f6d125eff2@i-love.sakura.ne.jp>
Date: Tue, 8 Jan 2019 19:39:58 +0900
MIME-Version: 1.0
In-Reply-To: <20190108081441.GO31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2019/01/08 17:14, Michal Hocko wrote:
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index af7f18b32389..90eb2e2093e7 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -1387,10 +1387,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>>  		.gfp_mask = gfp_mask,
>>>  		.order = order,
>>>  	};
>>> -	bool ret;
>>> +	bool ret = true;
>>>  
>>>  	mutex_lock(&oom_lock);
>>
>> And because of "[PATCH 1/2] mm, oom: marks all killed tasks as oom
>> victims", mark_oom_victim() will be called on current thread even if
>> we used mutex_lock_killable(&oom_lock) here, like you said
>>
>>   mutex_lock_killable would take care of exiting task already. I would
>>   then still prefer to check for mark_oom_victim because that is not racy
>>   with the exit path clearing signals. I can update my patch to use
>>   _killable lock variant if we are really going with the memcg specific
>>   fix.
>>
>> . If current thread is not yet killed by the OOM killer but can terminate
>> without invoking the OOM killer, using mutex_lock_killable(&oom_lock) here
>> saves some processes. What is the race you are referring by "racy with the
>> exit path clearing signals" ?
> 
> This is unrelated to the patch.

Ultimately related! This is the reasoning why your patch should be preferred
over my patch.

For example, if memcg OOM events in different domains are pending, already
OOM-killed threads needlessly wait for pending memcg OOM events in different
domains. An out_of_memory() call is slow because it involves printk(). With
slow serial consoles, out_of_memory() might take more than a second. I consider
that allowing killed processes to call mmput() from exit_mm() from do_exit()
quickly (instead of waiting for pending memcg OOM events in different domains
at mem_cgroup_out_of_memory()) helps calling __mmput() (which can reclaim more
memory than the OOM reaper can reclaim) quickly. Unless what you call "racy" is
problematic, I don't see reasons not to apply my patch. So, please please answer
what you are referring to with "racy".
