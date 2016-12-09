Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC806B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 16:42:26 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xy5so9606036wjc.0
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 13:42:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qc15si35568361wjb.233.2016.12.09.13.42.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 13:42:24 -0800 (PST)
Subject: Re: Still OOM problems with 4.9er kernels
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161209160946.GE4334@dhcp22.suse.cz>
 <fd029311-f0fe-3d1f-26d2-1f87576b14da@wiesinger.com>
 <20161209173018.GA31809@dhcp22.suse.cz>
 <a7ebcdbe-9feb-a88f-594c-161e7daa5818@wiesinger.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dce6a53e-9c13-2a17-ecef-824883506f72@suse.cz>
Date: Fri, 9 Dec 2016 22:42:09 +0100
MIME-Version: 1.0
In-Reply-To: <a7ebcdbe-9feb-a88f-594c-161e7daa5818@wiesinger.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerhard Wiesinger <lists@wiesinger.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 12/09/2016 07:01 PM, Gerhard Wiesinger wrote:
> On 09.12.2016 18:30, Michal Hocko wrote:
>> On Fri 09-12-16 17:58:14, Gerhard Wiesinger wrote:
>>> On 09.12.2016 17:09, Michal Hocko wrote:
>> [...]
>>>>> [97883.882611] Mem-Info:
>>>>> [97883.883747] active_anon:2915 inactive_anon:3376 isolated_anon:0
>>>>>                   active_file:3902 inactive_file:3639 isolated_file:0
>>>>>                   unevictable:0 dirty:205 writeback:0 unstable:0
>>>>>                   slab_reclaimable:9856 slab_unreclaimable:9682
>>>>>                   mapped:3722 shmem:59 pagetables:2080 bounce:0
>>>>>                   free:748 free_pcp:15 free_cma:0
>>>> there is still some page cache which doesn't seem to be neither dirty
>>>> nor under writeback. So it should be theoretically reclaimable but for
>>>> some reason we cannot seem to reclaim that memory.
>>>> There is still some anonymous memory and free swap so we could reclaim
>>>> it as well but it all seems pretty down and the memory pressure is
>>>> really large
>>> Yes, it might be large on the update situation, but that should be handled
>>> by a virtual memory system by the kernel, right?
>> Well this is what we try and call it memory reclaim. But if we are not
>> able to reclaim anything then we eventually have to give up and trigger
>> the OOM killer.
> 
> I'm not familiar with the Linux implementation of the VM system in 
> detail. But can't you reserve as much memory for the kernel (non 
> pageable) at least that you can swap everything out (even without 
> killing a process at least as long there is enough swap available, which 
> should be in all of my cases)?

We don't have such bulletproof reserves. In this case the amount of
anonymous memory that can be swapped out is relatively low, and either
something is pinning it in memory, or it's being swapped back in quickly.

>>   Now the information that 4.4 made a difference is
>> interesting. I do not really see any major differences in the reclaim
>> between 4.3 and 4.4 kernels. The reason might be somewhere else as well.
>> E.g. some of the subsystem consumes much more memory than before.
>>
>> Just curious, what kind of filesystem are you using?
> 
> I'm using ext4 only with virt-* drivers (storage, network). But it is 
> definitly a virtual memory allocation/swap usage issue.
> 
>>   Could you try some
>> additional debugging. Enabling reclaim related tracepoints might tell us
>> more. The following should tell us more
>> mount -t tracefs none /trace
>> echo 1 > /trace/events/vmscan/enable
>> echo 1 > /trace/events/writeback/writeback_congestion_wait/enable
>> cat /trace/trace_pipe > trace.log
>>
>> Collecting /proc/vmstat over time might be helpful as well
>> mkdir logs
>> while true
>> do
>> 	cp /proc/vmstat vmstat.$(date +%s)
>> 	sleep 1s
>> done
> 
> Activated it. But I think it should be very easy to trigger also on your 
> side. A very small configured VM with a program running RAM 
> allocations/writes (I guess you have some testing programs already) 
> should be sufficient to trigger it. You can also use the attached 
> program which I used to trigger such situations some years ago. If it 
> doesn't help try to reduce the available CPU for the VM and also I/O 
> (e.g. use all CPU/IO on the host or other VMs).

Well it's not really a surprise that if the VM is small enough and
workload large enough, OOM killer will kick in. The exact threshold
might have changed between kernel versions for a number of possible reasons.

> 
> BTW: Don't know if you have seen also my original message on the kernel 
> mailinglist only:
> 
> Linus had also OOM problems with 1kB RAM requests and a lot of free RAM 
> (use a translation service for the german page):
> https://lkml.org/lkml/2016/11/30/64
> https://marius.bloggt-in-braunschweig.de/2016/11/17/linuxkernel-4-74-8-und-der-oom-killer/
> https://www.spinics.net/lists/linux-mm/msg113661.html

Yeah we were involved in the last one. The regressions were about
high-order allocations
though (the 1kB premise turned out to be misinterpretation) and there
were regressions
for those in 4.7/4.8. But yours are order-0.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
