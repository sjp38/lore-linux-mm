Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07A746B0038
	for <linux-mm@kvack.org>; Sat, 10 Dec 2016 08:51:11 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so1845399wme.4
        for <linux-mm@kvack.org>; Sat, 10 Dec 2016 05:51:10 -0800 (PST)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id 62si21918988wml.99.2016.12.10.05.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Dec 2016 05:51:08 -0800 (PST)
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
 <dce6a53e-9c13-2a17-ecef-824883506f72@suse.cz>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <5e7490ea-4e59-7965-bc4d-171f9d60e439@wiesinger.com>
Date: Sat, 10 Dec 2016 14:50:34 +0100
MIME-Version: 1.0
In-Reply-To: <dce6a53e-9c13-2a17-ecef-824883506f72@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 09.12.2016 22:42, Vlastimil Babka wrote:
> On 12/09/2016 07:01 PM, Gerhard Wiesinger wrote:
>> On 09.12.2016 18:30, Michal Hocko wrote:
>>> On Fri 09-12-16 17:58:14, Gerhard Wiesinger wrote:
>>>> On 09.12.2016 17:09, Michal Hocko wrote:
>>> [...]
>>>>>> [97883.882611] Mem-Info:
>>>>>> [97883.883747] active_anon:2915 inactive_anon:3376 isolated_anon:0
>>>>>>                    active_file:3902 inactive_file:3639 isolated_file:0
>>>>>>                    unevictable:0 dirty:205 writeback:0 unstable:0
>>>>>>                    slab_reclaimable:9856 slab_unreclaimable:9682
>>>>>>                    mapped:3722 shmem:59 pagetables:2080 bounce:0
>>>>>>                    free:748 free_pcp:15 free_cma:0
>>>>> there is still some page cache which doesn't seem to be neither dirty
>>>>> nor under writeback. So it should be theoretically reclaimable but for
>>>>> some reason we cannot seem to reclaim that memory.
>>>>> There is still some anonymous memory and free swap so we could reclaim
>>>>> it as well but it all seems pretty down and the memory pressure is
>>>>> really large
>>>> Yes, it might be large on the update situation, but that should be handled
>>>> by a virtual memory system by the kernel, right?
>>> Well this is what we try and call it memory reclaim. But if we are not
>>> able to reclaim anything then we eventually have to give up and trigger
>>> the OOM killer.
>> I'm not familiar with the Linux implementation of the VM system in
>> detail. But can't you reserve as much memory for the kernel (non
>> pageable) at least that you can swap everything out (even without
>> killing a process at least as long there is enough swap available, which
>> should be in all of my cases)?
> We don't have such bulletproof reserves. In this case the amount of
> anonymous memory that can be swapped out is relatively low, and either
> something is pinning it in memory, or it's being swapped back in quickly.
>
>>>    Now the information that 4.4 made a difference is
>>> interesting. I do not really see any major differences in the reclaim
>>> between 4.3 and 4.4 kernels. The reason might be somewhere else as well.
>>> E.g. some of the subsystem consumes much more memory than before.
>>>
>>> Just curious, what kind of filesystem are you using?
>> I'm using ext4 only with virt-* drivers (storage, network). But it is
>> definitly a virtual memory allocation/swap usage issue.
>>
>>>    Could you try some
>>> additional debugging. Enabling reclaim related tracepoints might tell us
>>> more. The following should tell us more
>>> mount -t tracefs none /trace
>>> echo 1 > /trace/events/vmscan/enable
>>> echo 1 > /trace/events/writeback/writeback_congestion_wait/enable
>>> cat /trace/trace_pipe > trace.log
>>>
>>> Collecting /proc/vmstat over time might be helpful as well
>>> mkdir logs
>>> while true
>>> do
>>> 	cp /proc/vmstat vmstat.$(date +%s)
>>> 	sleep 1s
>>> done
>> Activated it. But I think it should be very easy to trigger also on your
>> side. A very small configured VM with a program running RAM
>> allocations/writes (I guess you have some testing programs already)
>> should be sufficient to trigger it. You can also use the attached
>> program which I used to trigger such situations some years ago. If it
>> doesn't help try to reduce the available CPU for the VM and also I/O
>> (e.g. use all CPU/IO on the host or other VMs).
> Well it's not really a surprise that if the VM is small enough and
> workload large enough, OOM killer will kick in. The exact threshold
> might have changed between kernel versions for a number of possible reasons.

IMHO: The OOM killer should NOT kick in even on the highest workloads if 
there is swap available.

https://www.spinics.net/lists/linux-mm/msg113665.html

Yeah, but I do think that "oom when you have 156MB free and 7GB
reclaimable, and haven't even tried swapping" counts as obviously
wrong.

So Linus also thinks that trying swapping is a must have. And there always was enough swap available in my cases. Then it should swap out/swapin all the time (which worked well in kernel 2.4/2.6 times).

Another topic: Why does the kernel prefer to swap in/swap out instead of 
use cache pages/buffers (see vmstat 1 output below)?


>
>> BTW: Don't know if you have seen also my original message on the kernel
>> mailinglist only:
>>
>> Linus had also OOM problems with 1kB RAM requests and a lot of free RAM
>> (use a translation service for the german page):
>> https://lkml.org/lkml/2016/11/30/64
>> https://marius.bloggt-in-braunschweig.de/2016/11/17/linuxkernel-4-74-8-und-der-oom-killer/
>> https://www.spinics.net/lists/linux-mm/msg113661.html
> Yeah we were involved in the last one. The regressions were about
> high-order allocations
> though (the 1kB premise turned out to be misinterpretation) and there
> were regressions
> for those in 4.7/4.8. But yours are order-0.
>

With kernel 4.7./4.8 it was really reaproduceable at every dnf update. 
With 4.9rc8 it has been much much better. So something must have 
changed, too.

As far as I understood it the order is 2^order kB pagesize. I don't 
think it makes a difference when swap is not used which order the memory 
allocation request is.

BTW: What were the commit that introduced the regression anf fixed it in 
4.9?

Thnx.

Ciao,

Gerhard


procs -----------memory---------- ---swap-- -----io---- -system-- 
------cpu-----
  r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy 
id wa st
  3  0  45232   9252   1956 109644  428  232  3536   416 4310 4228 38 36 
14  7  6
  2  0  45124  10524   1960 110192  124    0   528    96 2478 2243 45 29 
20  5  1
  4  1  45136   3896   1968 114388   84   64  4824   260 2689 2655 38 31 
15 12  4
  1  1  45484  10648    288 114032   88  356 20028  1132 5078 5122 24 
45  4 21  5
  2  0  44700   8092   1240 115204  728    0  2624   536 4204 4413 38 38 
18  3  4
  2  0  44852  10272   1240 111324   52  212  2736  1548 3311 2970 41 36 
12  9  2
  4  0  44844  10716   1240 111216    8    0     8    72 3067 3287 42 30 
18  7  3
  3  0  44828  10268   1248 111280   16    0    16    60 2139 1610 43 29 
11  1 17
  1  0  44828  11644   1248 111192    0    0     0     0 2367 1911 50 32 
14  0  3
  4  0  44820   9004   1248 111284    8    0     8     0 2207 1867 55 31 
14  0  1
  7  0  45664   6360   1816 109264   20  868  3076   968 4122 3783 43 37 
17  0  3
  4  4  46880   6732   1092 101960  244 1332  7968  3352 5836 6431 17 
51  1 27  4
10  2  47064   6940   1364  96340   20  196 25708  1720 7346 6447 13 70  
0 18  1
15  3  47572   3672   2156  92604   68  580 29244  1692 5640 5102  5 57  
0 37  2
12  4  48300   6740    352  87924   80  948 36208  2948 7287 7955  7 73  
0 18  2
12  9  50796   4832    584  88372    0 2496 16064  3312 3425 4185  2 30  
0 66  1
10  9  52636   3608   2068  90132   56 1840 24552  2836 4123 4099  3 43  
0 52  1
  7 11  56740  10376    424  86204  184 4152 33116  5628 7949 7952  4 
67  0 23  6
10  4  61384   8000    776  86956  644 4784 28380  5484 7965 9935  7 64  
0 26  2
11  4  68052   5260   1028  87268 1244 7164 23380  8684 10715 10863  8 
71  0 20  1
11  2  72244   3924   1052  85160  980 4264 23756  4940 7231 7930  8 62  
0 29  1
  6  1  76388   5352   4948  86204 1292 4640 27380  5244 7816 8714 10 
63  0 22  5
  8  5  77376   4168   1944  86528 3064 3684 19876  4104 9325 9076  9 
64  1 22  4
  5  4  75464   7272   1240  81684 3912 3188 25656  4100 9973 10515 11 
65  0 20  4
  5  2  77364   4440   1852  84744  528 2304 28588  3304 6605 6311  7 
61  8 18  4
  9  2  81648   3760   3188  86012  440 4588 17928  5368 6377 6320  8 
48  2 40  4
  6  2  82404   6608    668  86092 2016 2084 24396  3564 7440 7510  8 
66  1 20  4
  4  4  81728   3796   2260  87764 1392  984 18512  1684 5196 4652  6 
48  0 42  4
  8  4  84700   6436   1428  85744 1188 3708 20256  4364 6405 5998  9 
63  0 24  4
  3  1  86360   4836    924  87700 1388 2692 19460  3504 5498 6117  8 
48  0 34  9
  4  4  87916   3768    176  86592 2788 3220 19664  4032 7285 8342 19 
63  0 10  9
  4  4  89612   4952    180  88076 1516 2988 17560  3936 5737 5794  7 
46  0 37 10
  7  5  87768  12244    196  87856 3344 2544 22248  3348 6934 7497  8 
59  0 22 10
10  1  83436   4768    840  96452 4096  836 20100  1160 6191 6614 21 52  
0 13 14
  0  6  82868   6972    348  91020 1108  520  4896   568 3274 4214 11 26 
29 30  4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
