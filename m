Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C815C6B0253
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 02:44:10 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so25390067lfe.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 23:44:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si5016431wjx.217.2016.08.18.23.44.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 23:44:09 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: report compaction/migration stats for higher
 order requests
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <201608171034.54940.arekm@maven.pl> <20160817092909.GA20703@dhcp22.suse.cz>
 <201608182049.42261.a.miskiewicz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <809abac0-961d-9cc1-ce6b-3227ffc791c7@suse.cz>
Date: Fri, 19 Aug 2016 08:44:06 +0200
MIME-Version: 1.0
In-Reply-To: <201608182049.42261.a.miskiewicz@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arekm@maven.pl, Michal Hocko <mhocko@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/18/2016 08:49 PM, Arkadiusz Miskiewicz wrote:
> On Wednesday 17 of August 2016, Michal Hocko wrote:
>> On Wed 17-08-16 10:34:54, Arkadiusz MiA?kiewicz wrote:
>> [...]
>>
>>> With "[PATCH] mm, oom: report compaction/migration stats for higher order
>>> requests" patch:
>>> https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160817.txt
>>>
>>> Didn't count much - all counters are 0
>>> compaction_stall:0 compaction_fail:0 compact_migrate_scanned:0
>>> compact_free_scanned:0 compact_isolated:0 pgmigrate_success:0
>>> pgmigrate_fail:0
>>
>> Dohh, COMPACTION counters are events and those are different than other
>> counters we have. They only have per-cpu representation and so we would
>> have to do
>> +       for_each_online_cpu(cpu) {
>> +               struct vm_event_state *this = &per_cpu(vm_event_states,
>> cpu); +               ret += this->event[item];
>> +       }
>>
>> which is really nasty because, strictly speaking, we would have to do
>> {get,put}_online_cpus around that loop and that uses locking and we do
>> not want to possibly block in this path just because something is in the
>> middle of the hotplug. So let's scratch that patch for now and sorry I
>> haven't realized that earlier.
>>
>>> two processes were killed by OOM (rm and cp), the rest of rm/cp didn't
>>> finish
>>>
>>> and I'm interrupting it to try that next patch:
>>>> Could you try to test with
>>>> patch from
>>>> http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
>>>> please? Ideally on top of linux-next. You can add both the compaction
>>>> counters patch in the oom report and high order atomic reserves patch
>>>> on top.
>>>
>>> Uhm, was going to use it on top of 4.7.[01] first.
>>
>> OK
>
> So with  http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
> OOM no longer happens (all 10x rm/cp processes finished).

Is it on top of 4.7 then? That's a bit different from the other reporter 
who needed both linux-next and this patch to avoid OOM.
In any case the proper solution should restrict this disabled heuristic 
to highest compaction priority, which needs the patches from linux-next 
anyway.

So can you please also try linux-next with the patch from
http://marc.info/?l=linux-mm&m=147158805719821 ?

Thanks!

> https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160818.txt
>
> On Wednesday 17 of August 2016, Jan Kara wrote:
>> Just one more debug idea to add on top of what Michal said: Can you enable
>> mm_shrink_slab_start and mm_shrink_slab_end tracepoints (via
>> /sys/kernel/debug/tracing/events/vmscan/mm_shrink_slab_{start,end}/enable)
>> and gather output from /sys/kernel/debug/tracing/trace_pipe while the copy
>> is running?
>
> Here it is:
>
> https://ixion.pld-linux.org/~arekm/p2/ext4/log-trace_pipe-20160818.txt.gz
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
