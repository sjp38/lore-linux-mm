Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22E4C8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 07:43:22 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id b21so3460461ioj.8
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 04:43:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s196si1866471itc.63.2018.12.07.04.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 04:43:20 -0800 (PST)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org> <20181026192551.GC18839@dhcp22.suse.cz>
 <20181026193304.GD18839@dhcp22.suse.cz>
 <dfafc626-2233-db9b-49fa-9d4bae16d4aa@i-love.sakura.ne.jp>
 <c38e352a-dd23-a5e4-ac50-75b557506479@i-love.sakura.ne.jp>
 <20181106124224.GM27423@dhcp22.suse.cz>
 <8725e3b3-3752-fa7f-a88f-5ff4f5b6eace@i-love.sakura.ne.jp>
 <20181107100810.GA27423@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <8a71ecd8-e7bc-25de-184f-dfda511ee0d1@i-love.sakura.ne.jp>
Date: Fri, 7 Dec 2018 21:43:07 +0900
MIME-Version: 1.0
In-Reply-To: <20181107100810.GA27423@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/11/07 19:08, Michal Hocko wrote:
> On Wed 07-11-18 18:45:27, Tetsuo Handa wrote:
>> On 2018/11/06 21:42, Michal Hocko wrote:
>>> On Tue 06-11-18 18:44:43, Tetsuo Handa wrote:
>>> [...]
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index 6e1469b..a97648a 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>>> @@ -1382,8 +1382,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>>>  	};
>>>>  	bool ret;
>>>>  
>>>> -	mutex_lock(&oom_lock);
>>>> -	ret = out_of_memory(&oc);
>>>> +	if (mutex_lock_killable(&oom_lock))
>>>> +		return true;
>>>> +	/*
>>>> +	 * A few threads which were not waiting at mutex_lock_killable() can
>>>> +	 * fail to bail out. Therefore, check again after holding oom_lock.
>>>> +	 */
>>>> +	ret = fatal_signal_pending(current) || out_of_memory(&oc);
>>>>  	mutex_unlock(&oom_lock);
>>>>  	return ret;
>>>>  }
>>>
>>> If we are goging with a memcg specific thingy then I really prefer
>>> tsk_is_oom_victim approach. Or is there any reason why this is not
>>> suitable?
>>>
>>
>> Why need to wait for mark_oom_victim() called after slow printk() messages?
>>
>> If current thread got Ctrl-C and thus current thread can terminate, what is
>> nice with waiting for the OOM killer? If there are several OOM events in
>> multiple memcg domains waiting for completion of printk() messages? I don't
>> see points with waiting for oom_lock, for try_charge() already allows current
>> thread to terminate due to fatal_signal_pending() test.
> 
> mutex_lock_killable would take care of exiting task already. I would
> then still prefer to check for mark_oom_victim because that is not racy
> with the exit path clearing signals. I can update my patch to use
> _killable lock variant if we are really going with the memcg specific
> fix.
> 
> Johaness?
> 

No response for one month. When can we get to an RCU stall problem syzbot reported?
