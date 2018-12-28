Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B12B78E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 06:01:36 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id m52so12652931otc.13
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 03:01:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g17si18848264otp.250.2018.12.28.03.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 03:01:35 -0800 (PST)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <6a52dc15-3e0a-5469-3a68-c7922a52a2d3@virtuozzo.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <16e155a5-5eff-a165-bbab-7219674683bf@i-love.sakura.ne.jp>
Date: Fri, 28 Dec 2018 20:00:50 +0900
MIME-Version: 1.0
In-Reply-To: <6a52dc15-3e0a-5469-3a68-c7922a52a2d3@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On 2018/12/28 19:22, Kirill Tkhai wrote:
>> @@ -1389,8 +1389,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
> 
> This fatal_signal_pending() check has a sense because of
> it's possible, a killed task is waking up slowly, and it
> returns from schedule(), when there are no more waiters
> for a lock.

Thanks. Michal thinks that mutex_lock_killable() would be sufficient
( https://lkml.kernel.org/r/20181107100810.GA27423@dhcp22.suse.cz ) but
I can confirm that mutex_lock_killable() is not sufficient when I test
using a VM with 8 CPUs. Thus, I'd like to keep this fatal_signal_pending()
check.

> 
> Why not make this approach generic, and add a check into
> __mutex_lock_common() after schedule_preempt_disabled()
> instead of this? This will handle all the places like
> that at once.
> 
> (The only adding a check is not enough for __mutex_lock_common(),
>  since mutex code will require to wake next waiter also. So,
>  you will need a couple of changes in mutex code).

I think that we should not assume that everybody is ready for making
mutex_lock_killable() to return -EINTR if fatal_signal_pending() is
true, and that adding below version would be a safer choice.

int __sched mutex_lock_unless_killed(struct mutex *lock)
{
	const int ret = mutex_lock_killable(lock);

	if (ret)
		return ret;
	if (fatal_signale_pending(current)) {
		mutex_unlock(lock);
		return -EINTR;
	}
	return 0;
}
