Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC2B6B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 08:57:27 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j5-v6so2121032oiw.13
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 05:57:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a143-v6si2908979oih.126.2018.08.08.05.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 05:57:26 -0700 (PDT)
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <20180807072553.14941-1-mhocko@kernel.org>
 <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
 <20180807201935.GB4251@cmpxchg.org>
 <1308e0bd-e194-7b35-484c-fc18f493f8da@i-love.sakura.ne.jp>
Message-ID: <9cea37c8-ab90-2fdf-395c-efe52ff07072@i-love.sakura.ne.jp>
Date: Wed, 8 Aug 2018 21:57:13 +0900
MIME-Version: 1.0
In-Reply-To: <1308e0bd-e194-7b35-484c-fc18f493f8da@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>

On 2018/08/08 5:38, Tetsuo Handa wrote:
> On 2018/08/08 5:19, Johannes Weiner wrote:
>> On Tue, Aug 07, 2018 at 07:15:11PM +0900, Tetsuo Handa wrote:
>>> On 2018/08/07 16:25, Michal Hocko wrote:
>>>> @@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
>>>>  		return OOM_ASYNC;
>>>>  	}
>>>>  
>>>> -	if (mem_cgroup_out_of_memory(memcg, mask, order))
>>>> +	if (mem_cgroup_out_of_memory(memcg, mask, order) ||
>>>> +			tsk_is_oom_victim(current))
>>>>  		return OOM_SUCCESS;
>>>>  
>>>>  	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
>>>>
>>>
>>> I don't think this patch is appropriate. This patch only avoids hitting WARN(1).
>>> This patch does not address the root cause:
>>>
>>> The task_will_free_mem(current) test in out_of_memory() is returning false
>>> because test_bit(MMF_OOM_SKIP, &mm->flags) test in task_will_free_mem() is
>>> returning false because MMF_OOM_SKIP was already set by the OOM reaper. The OOM
>>> killer does not need to start selecting next OOM victim until "current thread
>>> completes __mmput()" or "it fails to complete __mmput() within reasonable
>>> period".
>>
>> I don't see why it matters whether the OOM victim exits or not, unless
>> you count the memory consumed by struct task_struct.
> 
> We are not counting memory consumed by struct task_struct. But David is
> counting memory released between set_bit(MMF_OOM_SKIP, &mm->flags) and
> completion of exit_mmap().

Also, before the OOM reaper was introduced, we waited until TIF_MEMDIE is
cleared from the OOM victim thread. Compared to pre OOM reaper era, giving up
so early is certainly a regression.
