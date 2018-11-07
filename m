Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC736B04D7
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 04:45:45 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id g138-v6so10510295oib.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 01:45:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z186-v6si43982oiz.154.2018.11.07.01.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 01:45:44 -0800 (PST)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org> <20181026192551.GC18839@dhcp22.suse.cz>
 <20181026193304.GD18839@dhcp22.suse.cz>
 <dfafc626-2233-db9b-49fa-9d4bae16d4aa@i-love.sakura.ne.jp>
 <c38e352a-dd23-a5e4-ac50-75b557506479@i-love.sakura.ne.jp>
 <20181106124224.GM27423@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <8725e3b3-3752-fa7f-a88f-5ff4f5b6eace@i-love.sakura.ne.jp>
Date: Wed, 7 Nov 2018 18:45:27 +0900
MIME-Version: 1.0
In-Reply-To: <20181106124224.GM27423@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/11/06 21:42, Michal Hocko wrote:
> On Tue 06-11-18 18:44:43, Tetsuo Handa wrote:
> [...]
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 6e1469b..a97648a 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1382,8 +1382,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>  	};
>>  	bool ret;
>>  
>> -	mutex_lock(&oom_lock);
>> -	ret = out_of_memory(&oc);
>> +	if (mutex_lock_killable(&oom_lock))
>> +		return true;
>> +	/*
>> +	 * A few threads which were not waiting at mutex_lock_killable() can
>> +	 * fail to bail out. Therefore, check again after holding oom_lock.
>> +	 */
>> +	ret = fatal_signal_pending(current) || out_of_memory(&oc);
>>  	mutex_unlock(&oom_lock);
>>  	return ret;
>>  }
> 
> If we are goging with a memcg specific thingy then I really prefer
> tsk_is_oom_victim approach. Or is there any reason why this is not
> suitable?
> 

Why need to wait for mark_oom_victim() called after slow printk() messages?

If current thread got Ctrl-C and thus current thread can terminate, what is
nice with waiting for the OOM killer? If there are several OOM events in
multiple memcg domains waiting for completion of printk() messages? I don't
see points with waiting for oom_lock, for try_charge() already allows current
thread to terminate due to fatal_signal_pending() test.
