Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38E816B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 04:23:53 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so24157449wjd.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 01:23:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f53si4309525wrf.78.2017.02.07.01.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 01:23:51 -0800 (PST)
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <614e9873-c894-de42-a38a-1798fc0be039@suse.cz>
Date: Tue, 7 Feb 2017 10:23:31 +0100
MIME-Version: 1.0
In-Reply-To: <20170207084855.GC5065@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On 02/07/2017 09:48 AM, Michal Hocko wrote:
> On Mon 06-02-17 22:05:30, Mel Gorman wrote:
>>> Unfortunately it does not seem to help.
>>
>> I'm a little stuck on how to best handle this. get_online_cpus() can
>> halt forever if the hotplug operation is holding the mutex when calling
>> pcpu_alloc. One option would be to add a try_get_online_cpus() helper which
>> trylocks the mutex. However, given that drain is so unlikely to actually
>> make that make a difference when racing against parallel allocations,
>> I think this should be acceptable.
>>
>> Any objections?
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3b93879990fd..a3192447e906 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3432,7 +3432,17 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>>  	 */
>>  	if (!page && !drained) {
>>  		unreserve_highatomic_pageblock(ac, false);
>> -		drain_all_pages(NULL);
>> +
>> +		/*
>> +		 * Only drain from contexts allocating for user allocations.
>> +		 * Kernel allocations could be holding a CPU hotplug-related
>> +		 * mutex, particularly hot-add allocating per-cpu structures
>> +		 * while hotplug-related mutex's are held which would prevent
>> +		 * get_online_cpus ever returning.
>> +		 */
>> +		if (gfp_mask & __GFP_HARDWALL)
>> +			drain_all_pages(NULL);
>> +
> 
> This wouldn't work AFAICS. If you look at the lockdep splat, the path
> which reverses the locking order (takes pcpu_alloc_mutex prior to
> cpu_hotplug.lock is bpf_array_alloc_percpu which is GFP_USER and thus
> __GFP_HARDWALL.
> 
> I believe we shouldn't pull any dependency on the hotplug locks inside
> the allocator. This is just too fragile! Can we simply drop the
> get_online_cpus()? Why do we need it, anyway? Say we are racing with the

It was added after I noticed in review that queue_work_on() has a
comment that caller must ensure that cpu can't go away, and wondered
about it. Also noted that a similar lru_add_drain_all() does it too.

> cpu offlining. I have to check the code but my impression was that WQ
> code will ignore the cpu requested by the work item when the cpu is
> going offline. If the offline happens while the worker function already
> executes then it has to wait as we run with preemption disabled so we
> should be safe here. Or am I missing something obvious?

Tejun suggested an alternative solution to avoiding get_online_cpus() in
this thread:
https://lkml.kernel.org/r/<20170123170329.GA7820@htj.duckdns.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
