Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0402F6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 06:54:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so24699293wmv.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:54:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f143si11874847wme.164.2017.02.07.03.54.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 03:54:50 -0800 (PST)
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
References: <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2539ac25-7e15-f91f-83ba-10556eb0360b@suse.cz>
Date: Tue, 7 Feb 2017 12:54:48 +0100
MIME-Version: 1.0
In-Reply-To: <20170207114327.GI5065@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On 02/07/2017 12:43 PM, Michal Hocko wrote:
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3b93879990fd..7af165d308c4 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2342,7 +2342,14 @@ void drain_local_pages(struct zone *zone)
>>
>>  static void drain_local_pages_wq(struct work_struct *work)
>>  {
>> +	/*
>> +	 * Ordinarily a drain operation is bound to a CPU but may be unbound
>> +	 * after a CPU hotplug operation so it's necessary to disable
>> +	 * preemption for the drain to stabilise the CPU ID.
>> +	 */
>> +	preempt_disable();
>>  	drain_local_pages(NULL);
>> +	preempt_enable_no_resched();
>>  }
>>
>>  /*
> [...]
>> @@ -6711,7 +6714,16 @@ static int page_alloc_cpu_dead(unsigned int cpu)
>>  {
>>
>>  	lru_add_drain_cpu(cpu);
>> +
>> +	/*
>> +	 * A per-cpu drain via a workqueue from drain_all_pages can be
>> +	 * rescheduled onto an unrelated CPU. That allows the hotplug
>> +	 * operation and the drain to potentially race on the same
>> +	 * CPU. Serialise hotplug versus drain using pcpu_drain_mutex
>> +	 */
>> +	mutex_lock(&pcpu_drain_mutex);
>>  	drain_pages(cpu);
>> +	mutex_unlock(&pcpu_drain_mutex);
>
> You cannot put sleepable lock inside the preempt disbaled section...
> We can make it a spinlock right?

Could we do flush_work() with a spinlock? Sounds bad too.
Maybe we could just use the fact that the whole drain happens with disabled 
irq's and obtain the current cpu under that protection?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
