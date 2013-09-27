Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C96EC6B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 22:04:55 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so1932705pdj.26
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 19:04:55 -0700 (PDT)
Message-ID: <5244E7BA.4040408@windriver.com>
Date: Fri, 27 Sep 2013 10:04:42 +0800
From: Ming Liu <ming.liu@windriver.com>
MIME-Version: 1.0
Subject: Re: [PATCH V1] oom: avoid selecting threads sharing mm with init
References: <1380182957-3231-1-git-send-email-ming.liu@windriver.com> <alpine.DEB.2.02.1309261143160.10904@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309261143160.10904@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/27/2013 02:44 AM, David Rientjes wrote:
> On Thu, 26 Sep 2013, Ming Liu wrote:
>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 314e9d2..7e50a95 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -113,11 +113,22 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
>>   static bool oom_unkillable_task(struct task_struct *p,
>>   		const struct mem_cgroup *memcg, const nodemask_t *nodemask)
>>   {
>> +	struct task_struct *init_tsk;
>> +
>>   	if (is_global_init(p))
>>   		return true;
>>   	if (p->flags & PF_KTHREAD)
>>   		return true;
>>   
>> +	/* It won't help free memory if p is sharing mm with init */
>> +	rcu_read_lock();
>> +	init_tsk = find_task_by_pid_ns(1, &init_pid_ns);
>> +	if(p->mm == init_tsk->mm) {
>> +		rcu_read_unlock();
>> +		return true;
>> +	}
>> +	rcu_read_unlock();
>> +
>>   	/* When mem_cgroup_out_of_memory() and p is not member of the group */
>>   	if (memcg && !task_in_mem_cgroup(p, memcg))
>>   		return true;
> You're aware of init_mm?
I might mislead you, when I talked about init, I meant the pid 1 process 
but not the idle, and isn't the idle a kthread and has not this risk 
getting killed by oom?
This panic was observed in a busybox shell with a 2.6.27 kernel, MIPS 
board, but after some investigation, I think the upstream also has the 
problem, the kernel log is as following:

Out of memory: kill process 938 (crond) score 5 or a child
Killed process 938 (crond)
out_of_memory:tsk_rick info, name:init pid:1 mm:a8000001e0767700 task_struct:a8000001e0110000    //struct task_struct *tsk_rick = find_task_by_vpid(1);
out_of_memory:will close init process pid:1128 mm:a8000001e0767700 task_strct:a8000001f37e2800
Out of memory: kill process 1128 (init) score 4 or a child
oom_kill_process:will close init process pid:1128 mm:a8000001e0767700 task_struct:a8000001f37e2800
oom_kill_task:will close init process pid:1128 mm:a8000001e0767700 task_struct:a8000001f37e2800
Killed process 1128 (init)
do_exit: task_rick name:init , pid:1, mm:a8000001e0767700, &task_stuct:a8000001e0110000
do_exit: will kill process name:init , pid:1128, mm:a8000001e0767700, &task_stuct:a8000001f37e2800
do_exit: task_rick name:init , pid:1, mm:a8000001e0767700, &task_stuct:a8000001e0110000
find_new_reaper: will kill process name:init , pid:1128, mm:0000000000000000, &task_stuct:a8000001f37e2800
do_exit: will kill process name:init , pid:1, mm:a8000001e0767700, &task_stuct:a8000001e0110000
Call Trace:
[<ffffffff8143ab80>] dump_stack+0x8/0x34
[<ffffffff8116a0d4>] do_exit+0x94c/0x978
[<ffffffff8116a14c>] do_group_exit+0x4c/0xd0
[<ffffffff81177804>] get_signal_to_deliver+0x1ec/0x498
[<ffffffff81137088>] do_notify_resume+0x80/0x2b0
[<ffffffff81133184>] work_notifysig+0xc/0x14
find_new_reaper: will kill process name:init , pid:1, mm:0000000000000000, &tsk_stuct:a8000001e0110000
Kernel panic - not syncing: Attempted to kill init!

the best,
thank you
>
> Can you post the kernel log when one of these "extreme cases" happens?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
