Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8D196B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 07:43:45 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so25322233wjc.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 04:43:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n19si12041711wmg.126.2017.02.07.04.43.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 04:43:44 -0800 (PST)
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
References: <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz> <20170207123708.GO5065@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0bbc50c4-b18a-a510-ba75-4d7415f15e82@suse.cz>
Date: Tue, 7 Feb 2017 13:43:39 +0100
MIME-Version: 1.0
In-Reply-To: <20170207123708.GO5065@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On 02/07/2017 01:37 PM, Michal Hocko wrote:
>> > @@ -6711,7 +6714,16 @@ static int page_alloc_cpu_dead(unsigned int cpu)
>> >  {
>> >
>> >  	lru_add_drain_cpu(cpu);
>> > +
>> > +	/*
>> > +	 * A per-cpu drain via a workqueue from drain_all_pages can be
>> > +	 * rescheduled onto an unrelated CPU. That allows the hotplug
>> > +	 * operation and the drain to potentially race on the same
>> > +	 * CPU. Serialise hotplug versus drain using pcpu_drain_mutex
>> > +	 */
>> > +	mutex_lock(&pcpu_drain_mutex);
>> >  	drain_pages(cpu);
>> > +	mutex_unlock(&pcpu_drain_mutex);
>>
>> You cannot put sleepable lock inside the preempt disbaled section...
>> We can make it a spinlock right?
>
> Scratch that! For some reason I thought that cpu notifiers are run in an
> atomic context. Now that I am checking the code again it turns out I was
> wrong. __cpu_notify uses __raw_notifier_call_chain so this is not an
> atomic context.

Good.

> Anyway, shouldn't be it sufficient to disable preemption
> on drain_local_pages_wq? The CPU hotplug callback will not preempt us
> and so we cannot work on the same cpus, right?

I thought the problem here was that the callback races with the work item that 
has been migrated to a different cpu. Once we are not working on the local cpu, 
disabling preempt/irq's won't help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
