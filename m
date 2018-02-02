Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A8A976B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 00:17:14 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id y42so18669227qtc.19
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 21:17:14 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m66si1422737qkh.142.2018.02.01.21.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 21:17:13 -0800 (PST)
Subject: Re: [RFC PATCH v1 13/13] mm: splice local lists onto the front of the
 LRU
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180131230413.27653-14-daniel.m.jordan@oracle.com>
 <d017b716-6409-fbf2-9b33-4f5ef3192535@linux.intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <be7a9e6c-a9e3-bda0-7719-682e76f5a9a6@oracle.com>
Date: Fri, 2 Feb 2018 00:17:02 -0500
MIME-Version: 1.0
In-Reply-To: <d017b716-6409-fbf2-9b33-4f5ef3192535@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On 02/01/2018 06:30 PM, Tim Chen wrote:
> On 01/31/2018 03:04 PM, daniel.m.jordan@oracle.com wrote:
>> Now that release_pages is scaling better with concurrent removals from
>> the LRU, the performance results (included below) showed increased
>> contention on lru_lock in the add-to-LRU path.
>>
>> To alleviate some of this contention, do more work outside the LRU lock.
>> Prepare a local list of pages to be spliced onto the front of the LRU,
>> including setting PageLRU in each page, before taking lru_lock.  Since
>> other threads use this page flag in certain checks outside lru_lock,
>> ensure each page's LRU links have been properly initialized before
>> setting the flag, and use memory barriers accordingly.
>>
>> Performance Results
>>
>> This is a will-it-scale run of page_fault1 using 4 different kernels.
>>
>>              kernel     kern #
>>
>>            4.15-rc2          1
>>    large-zone-batch          2
>>       lru-lock-base          3
>>     lru-lock-splice          4
>>
>> Each kernel builds on the last.  The first is a baseline, the second
>> makes zone->lock more scalable by increasing an order-0 per-cpu
>> pagelist's 'batch' and 'high' values to 310 and 1860 respectively
>> (courtesy of Aaron Lu's patch), the third scales lru_lock without
>> splicing pages (the previous patch in this series), and the fourth adds
>> page splicing (this patch).
>>
>> N tasks mmap, fault, and munmap anonymous pages in a loop until the test
>> time has elapsed.
>>
>> The process case generally does better than the thread case most likely
>> because of mmap_sem acting as a bottleneck.  There's ongoing work
>> upstream[*] to scale this lock, however, and once it goes in, my
>> hypothesis is the thread numbers here will improve.

Neglected to mention my hardware:
   2-socket system, 44 cores, 503G memory, Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz

>>
>> kern #  ntask     proc      thr        proc    stdev         thr    stdev
>>                 speedup  speedup       pgf/s                pgf/s
>>       1      1                       705,533    1,644     705,227    1,122
>>       2      1     2.5%     2.8%     722,912      453     724,807      728
>>       3      1     2.6%     2.6%     724,215      653     723,213      941
>>       4      1     2.3%     2.8%     721,746      272     724,944      728
>>
>> kern #  ntask     proc      thr        proc    stdev         thr    stdev
>>                 speedup  speedup       pgf/s                pgf/s
>>       1      4                     2,525,487    7,428   1,973,616   12,568
>>       2      4     2.6%     7.6%   2,590,699    6,968   2,123,570   10,350
>>       3      4     2.3%     4.4%   2,584,668   12,833   2,059,822   10,748
>>       4      4     4.7%     5.2%   2,643,251   13,297   2,076,808    9,506
>>
>> kern #  ntask     proc      thr        proc    stdev         thr    stdev
>>                 speedup  speedup       pgf/s                pgf/s
>>       1     16                     6,444,656   20,528   3,226,356   32,874
>>       2     16     1.9%    10.4%   6,566,846   20,803   3,560,437   64,019
>>       3     16    18.3%     6.8%   7,624,749   58,497   3,447,109   67,734
>>       4     16    28.2%     2.5%   8,264,125   31,677   3,306,679   69,443
>>
>> kern #  ntask     proc      thr        proc    stdev         thr    stdev
>>                 speedup  speedup       pgf/s                pgf/s
>>       1     32                    11,564,988   32,211   2,456,507   38,898
>>       2     32     1.8%     1.5%  11,777,119   45,418   2,494,064   27,964
>>       3     32    16.1%    -2.7%  13,426,746   94,057   2,389,934   40,186
>>       4     32    26.2%     1.2%  14,593,745   28,121   2,486,059   42,004
>>
>> kern #  ntask     proc      thr        proc    stdev         thr    stdev
>>                 speedup  speedup       pgf/s                pgf/s
>>       1     64                    12,080,629   33,676   2,443,043   61,973
>>       2     64     3.9%     9.9%  12,551,136  206,202   2,684,632   69,483
>>       3     64    15.0%    -3.8%  13,892,933  351,657   2,351,232   67,875
>>       4     64    21.9%     1.8%  14,728,765   64,945   2,485,940   66,839
>>
>> [*] https://lwn.net/Articles/724502/  Range reader/writer locks
>>      https://lwn.net/Articles/744188/  Speculative page faults
>>
> 
> The speedup looks pretty nice and seems to peak at 16 tasks.  Do you have an explanation of what
> causes the drop from 28.2% to 21.9% going from 16 to 64 tasks?

The system I was testing on had 44 cores, so part of the decrease in % speedup is just saturating the hardware (e.g. memory bandwidth).  At 64 processes, we start having to share cores.  Page faults per second did continue to increase each time we added more processes, though, so there's no anti-scaling going on.

> Was
> the loss in performance due to increased contention on LRU lock when more tasks running
> results in a higher likelihood of hitting the sentinel?

That seems to be another factor, yes.  I used lock_stat to measure it, and it showed that wait time on lru_lock nearly tripled when going from 32 to 64 processes, but I also take lock_stat with a grain of salt as it changes the timing/interaction between processes.

> If I understand
> your patchset correctly, you will need to acquire LRU lock for sentinel page. Perhaps an increase
> in batch size could help?

Actually, I did try doing that.  In this series the batch size is PAGEVEC_SIZE (14).  When I did a run with PAGEVEC_SIZE*4, the performance stayed nearly the same for all but the 64 process case, where it dropped by ~10%.  One explanation is as a process runs through one batch, it holds the batch lock longer before it has to switch batches, creating more opportunity for contention.


By the way, we're also working on another approach to scaling this look:
     https://marc.info/?l=linux-mm&m=151746028405581

We plan to implement that idea and see how it compares performance-wise and diffstat-wise with this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
