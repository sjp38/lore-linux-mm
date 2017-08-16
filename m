Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7FDB6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 23:24:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so49147976pga.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 20:24:58 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l15si7111181pli.228.2017.08.15.20.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 20:24:57 -0700 (PDT)
Subject: Re: [PATCH 0/2] Separate NUMA statistics from zone statistics
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <20170815123636.3788230c@redhat.com>
From: kemi <kemi.wang@intel.com>
Message-ID: <7efb3a61-071b-b3cd-2f8a-a264ece9ab44@intel.com>
Date: Wed, 16 Aug 2017 11:23:46 +0800
MIME-Version: 1.0
In-Reply-To: <20170815123636.3788230c@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'08ae??15ae?JPY 18:36, Jesper Dangaard Brouer wrote:
> On Tue, 15 Aug 2017 16:45:34 +0800
> Kemi Wang <kemi.wang@intel.com> wrote:
> 
>> Each page allocation updates a set of per-zone statistics with a call to
>> zone_statistics(). As discussed in 2017 MM submit, these are a substantial
>                                              ^^^^^^ should be "summit"

Hi, Jesper
   Thanks for reporting this issue and providing the benchmark to test raw
performance of page allocation. It is really quite helpful to figure out the
root cause.
>> source of overhead in the page allocator and are very rarely consumed. This
>> significant overhead in cache bouncing caused by zone counters (NUMA
>> associated counters) update in parallel in multi-threaded page allocation
>> (pointed out by Dave Hansen).
> 
> Hi Kemi
> 
> Thanks a lot for following up on this work. A link to the MM summit slides:
>  http://people.netfilter.org/hawk/presentations/MM-summit2017/MM-summit2017-JesperBrouer.pdf
> 
Thanks for adding the link here. I should have done that in this cover letter.

>> To mitigate this overhead, this patchset separates NUMA statistics from
>> zone statistics framework, and update NUMA counter threshold to a fixed
>> size of 32765, as a small threshold greatly increases the update frequency
>> of the global counter from local per cpu counter (suggested by Ying Huang).
>> The rationality is that these statistics counters don't need to be read
>> often, unlike other VM counters, so it's not a problem to use a large
>> threshold and make readers more expensive.
>>
>> With this patchset, we see 26.6% drop of CPU cycles(537-->394, see below)
>> for per single page allocation and reclaim on Jesper's page_bench03
>> benchmark. Meanwhile, this patchset keeps the same style of virtual memory
>> statistics with little end-user-visible effects (see the first patch for
>> details), except that the number of NUMA items in each cpu
>> (vm_numa_stat_diff[]) is added to zone->vm_numa_stat[] when a user *reads*
>> the value of NUMA counter to eliminate deviation.
> 
> I'm very happy to see that you found my kernel module for benchmarking useful :-)
> 
>> I did an experiment of single page allocation and reclaim concurrently
>> using Jesper's page_bench03 benchmark on a 2-Socket Broadwell-based server
>> (88 processors with 126G memory) with different size of threshold of pcp
>> counter.
>>
>> Benchmark provided by Jesper D Broucer(increase loop times to 10000000):
>                                  ^^^^^^^
> You mis-spelled my last name, it is "Brouer".
> 
Dear Jesper, I am so sorry about it, please forgive me :)

>> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench
>>
>>    Threshold   CPU cycles    Throughput(88 threads)
>>       32        799         241760478
>>       64        640         301628829
>>       125       537         358906028 <==> system by default
>>       256       468         412397590
>>       512       428         450550704
>>       4096      399         482520943
>>       20000     394         489009617
>>       30000     395         488017817
>>       32765     394(-26.6%) 488932078(+36.2%) <==> with this patchset
>>       N/A       342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics
>>
>> Kemi Wang (2):
>>   mm: Change the call sites of numa statistics items
>>   mm: Update NUMA counter threshold size
>>
>>  drivers/base/node.c    |  22 ++++---
>>  include/linux/mmzone.h |  25 +++++---
>>  include/linux/vmstat.h |  33 ++++++++++
>>  mm/page_alloc.c        |  10 +--
>>  mm/vmstat.c            | 162 +++++++++++++++++++++++++++++++++++++++++++++++--
>>  5 files changed, 227 insertions(+), 25 deletions(-)
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
