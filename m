Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4742A6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 04:18:52 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id v10so3675339bkz.35
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 01:18:51 -0800 (PST)
Received: from gmmr7.centrum.cz (gmmr7.centrum.cz. [2a00:da80:0:502::5])
        by mx.google.com with ESMTPS id oe5si13386212bkb.259.2013.11.28.01.18.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 01:18:51 -0800 (PST)
Subject: =?utf-8?q?Re=3A_=5BPATCH=5D_Fix_race_between_oom_kill_and_task_exit?=
Date: Thu, 28 Nov 2013 10:18:50 +0100
From: "azurIt" <azurit@pobox.sk>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@shsmsx103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org>
In-Reply-To: <20131128063505.GN3556@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20131128101850.9F8A4575@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Ma=2C_Xindong?= <xindong.ma@intel.com>
Cc: =?utf-8?q?akpm=40linux=2Dfoundation=2Eorg?= <akpm@linux-foundation.org>, =?utf-8?q?mhocko=40suse=2Ecz?= <mhocko@suse.cz>, =?utf-8?q?rientjes=40google=2Ecom?= <rientjes@google.com>, =?utf-8?q?rusty=40rustcorp=2Ecom=2Eau?= <rusty@rustcorp.com.au>, =?utf-8?q?linux=2Dmm=40kvack=2Eorg?= <linux-mm@kvack.org>, =?utf-8?q?linux=2Dkernel=40vger=2Ekernel=2Eorg?= <linux-kernel@vger.kernel.org>, =?utf-8?q?=27Peter_Zijlstra=27?= <peterz@infradead.org>, =?utf-8?q?=27gregkh=40linuxfoundation=2Eorg=27?= <gregkh@linuxfoundation.org>, =?utf-8?q?Tu=2C_Xiaobing?= <xiaobing.tu@intel.com>, =?utf-8?q?William_Dauchy?= <wdauchy@gmail.com>

> Od: Johannes Weiner <hannes@cmpxchg.org>
> Komu: "Ma, Xindong" <xindong.ma@intel.com>
> DA!tum: 28.11.2013 07:54
> Predmet: Re: [PATCH] Fix race between oom kill and task exit
>
> CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "'Peter Zijlstra'" <peterz@infradead.org>, "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, "William Dauchy" <wdauchy@gmail.com>
>Cc William and azur who might have encountered this problem.
>
>On Thu, Nov 28, 2013 at 05:09:16AM +0000, Ma, Xindong wrote:
>> From: Leon Ma <xindong.ma@intel.com>
>> Date: Thu, 28 Nov 2013 12:46:09 +0800
>> Subject: [PATCH] Fix race between oom kill and task exit
>> 
>> There is a race between oom kill and task exit. Scenario is:
>>    TASK  A                      TASK  B
>> TASK B is selected to oom kill
>> in oom_kill_process()
>> check PF_EXITING of TASK B
>>                             task call do_exit()
>>                             task set PF_EXITING flag
>>                             write_lock_irq(&tasklist_lock);
>>                             remove TASK B from thread group in __unhash_process()
>>                             write_unlock_irq(&tasklist_lock);
>> read_lock(&tasklist_lock);
>> traverse threads of TASK B
>> read_unlock(&tasklist_lock);
>> 
>> After that, the following traversal of threads in TASK B will not end because TASK B is not in the thread group:
>> do {
>> ....
>> } while_each_thread(p, t);
>> 
>> Signed-off-by: Leon Ma <xindong.ma@intel.com>
>> Signed-off-by: xiaobing tu <xiaobing.tu@intel.com>
>> ---
>>  mm/oom_kill.c |   20 ++++++++++----------
>>  1 files changed, 10 insertions(+), 10 deletions(-)
>> 
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 1e4a600..32ec88d 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -412,16 +412,6 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>>  					      DEFAULT_RATELIMIT_BURST);
>>  
>> -	/*
>> -	 * If the task is already exiting, don't alarm the sysadmin or kill
>> -	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>> -	 */
>> -	if (p->flags & PF_EXITING) {
>> -		set_tsk_thread_flag(p, TIF_MEMDIE);
>> -		put_task_struct(p);
>> -		return;
>> -	}
>> -
>>  	if (__ratelimit(&oom_rs))
>>  		dump_header(p, gfp_mask, order, memcg, nodemask);
>>  
>> @@ -437,6 +427,16 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>>  	 * still freeing memory.
>>  	 */
>>  	read_lock(&tasklist_lock);
>> +	/*
>> +	 * If the task is already exiting, don't alarm the sysadmin or kill
>> +	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>> +	 */
>> +	if (p->flags & PF_EXITING) {
>> +		set_tsk_thread_flag(p, TIF_MEMDIE);
>> +		put_task_struct(p);
>> +		read_unlock(&tasklist_lock);
>> +		return;
>> +	}
>>  	do {
>>  		list_for_each_entry(child, &t->children, sibling) {
>>  			unsigned int child_points;
>> -- 
>> 1.7.4.1
>> 
>




Hi Johannes,

thank you very much! Fortunately, i didn't notice anything like this yet.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
