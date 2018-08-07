Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3C46B0269
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:38:55 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c18-v6so8664oiy.3
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:38:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r204-v6si1382419oih.29.2018.08.07.13.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 13:38:54 -0700 (PDT)
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
References: <20180807072553.14941-1-mhocko@kernel.org>
 <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
 <20180807201935.GB4251@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1308e0bd-e194-7b35-484c-fc18f493f8da@i-love.sakura.ne.jp>
Date: Wed, 8 Aug 2018 05:38:39 +0900
MIME-Version: 1.0
In-Reply-To: <20180807201935.GB4251@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>

On 2018/08/08 5:19, Johannes Weiner wrote:
> On Tue, Aug 07, 2018 at 07:15:11PM +0900, Tetsuo Handa wrote:
>> On 2018/08/07 16:25, Michal Hocko wrote:
>>> @@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
>>>  		return OOM_ASYNC;
>>>  	}
>>>  
>>> -	if (mem_cgroup_out_of_memory(memcg, mask, order))
>>> +	if (mem_cgroup_out_of_memory(memcg, mask, order) ||
>>> +			tsk_is_oom_victim(current))
>>>  		return OOM_SUCCESS;
>>>  
>>>  	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
>>>
>>
>> I don't think this patch is appropriate. This patch only avoids hitting WARN(1).
>> This patch does not address the root cause:
>>
>> The task_will_free_mem(current) test in out_of_memory() is returning false
>> because test_bit(MMF_OOM_SKIP, &mm->flags) test in task_will_free_mem() is
>> returning false because MMF_OOM_SKIP was already set by the OOM reaper. The OOM
>> killer does not need to start selecting next OOM victim until "current thread
>> completes __mmput()" or "it fails to complete __mmput() within reasonable
>> period".
> 
> I don't see why it matters whether the OOM victim exits or not, unless
> you count the memory consumed by struct task_struct.

We are not counting memory consumed by struct task_struct. But David is
counting memory released between set_bit(MMF_OOM_SKIP, &mm->flags) and
completion of exit_mmap().

> 
>> According to https://syzkaller.appspot.com/text?tag=CrashLog&x=15a1c770400000 ,
>> PID=23767 selected PID=23766 as an OOM victim and the OOM reaper set MMF_OOM_SKIP
>> before PID=23766 unnecessarily selects PID=23767 as next OOM victim.
>> At uptime = 366.550949, out_of_memory() should have returned true without selecting
>> next OOM victim because tsk_is_oom_victim(current) == true.
> 
> The code works just fine. We have to kill tasks until we a) free
> enough memory or b) run out of tasks or c) kill current. When one of
> these outcomes is reached, we allow the charge and return.
> 
> The only problem here is a warning in the wrong place.
> 

If forced charge contained a bug, removing this WARN(1) deprives users of chance
to know that something is going wrong.
