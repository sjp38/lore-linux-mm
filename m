Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 816766B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 10:27:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x81so17872153lfb.10
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 07:27:53 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id d137si18698993lfd.200.2017.06.05.07.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 07:27:51 -0700 (PDT)
Subject: Re: [PATCH v2] mm/oom_kill: count global and memory cgroup oom kills
References: <149570810989.203600.9492483715840752937.stgit@buzz>
 <20170605085011.GJ9248@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <80c9060f-bf80-51fb-39c0-b36f273c0c9c@yandex-team.ru>
Date: Mon, 5 Jun 2017 17:27:50 +0300
MIME-Version: 1.0
In-Reply-To: <20170605085011.GJ9248@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: ru-RU
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>, David Rientjes <rientjes@google.com>



On 05.06.2017 11:50, Michal Hocko wrote:
> On Thu 25-05-17 13:28:30, Konstantin Khlebnikov wrote:
>> Show count of oom killer invocations in /proc/vmstat and count of
>> processes killed in memory cgroup in knob "memory.events"
>> (in memory.oom_control for v1 cgroup).
>>
>> Also describe difference between "oom" and "oom_kill" in memory
>> cgroup documentation. Currently oom in memory cgroup kills tasks
>> iff shortage has happened inside page fault.
>>
>> These counters helps in monitoring oom kills - for now
>> the only way is grepping for magic words in kernel log.
> 
> Yes this is less than optimal and the counter sounds like a good step
> forward. I have 2 comments to the patch though.
> 
> [...]
> 
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 899949bbb2f9..42296f7001da 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -556,8 +556,11 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
>>   
>>   	rcu_read_lock();
>>   	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>> -	if (likely(memcg))
>> +	if (likely(memcg)) {
>>   		this_cpu_inc(memcg->stat->events[idx]);
>> +		if (idx == OOM_KILL)
>> +			cgroup_file_notify(&memcg->events_file);
>> +	}
>>   	rcu_read_unlock();
> 
> Well, this is ugly. I see how you want to share the global counter and
> the memcg event which needs the notification. But I cannot say this
> would be really easy to follow. Can we have at least a comment in
> memcg_event_item enum definition?

Yep, this is a little bit ugly.
But this funciton is static-inline and idx always constant so resulting code is fine.

> 
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 04c9143a8625..dd30a045ef5b 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>>   	/* Get a reference to safely compare mm after task_unlock(victim) */
>>   	mm = victim->mm;
>>   	mmgrab(mm);
>> +
>> +	/* Raise event before sending signal: reaper must see this */
>> +	count_vm_event(OOM_KILL);
>> +	mem_cgroup_count_vm_event(mm, OOM_KILL);
>> +
>>   	/*
>>   	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
>>   	 * the OOM victim from depleting the memory reserves from the user
> 
> Why don't you count tasks which share mm with the oom victim?

Yes, this makes sense. But these kills are not logged thus counter will differs from logged events.
Also these tasks might live in different cgroups, so counting to mm owner isn't correct.

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0e2c925e7826..9a95947a60ba 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -924,6 +924,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>   		 */
>   		if (unlikely(p->flags & PF_KTHREAD))
>   			continue;
> +		count_vm_event(OOM_KILL);
> +		count_memcg_event_mm(mm, OOM_KILL);
>   		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>   	}
>   	rcu_read_unlock();
> 
> Other than that looks good to me.
> Acked-by: Michal Hocko <mhocko@suse.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
