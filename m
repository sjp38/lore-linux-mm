Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 717F66B04D9
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 04:54:46 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k10so106070047pgs.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 01:54:46 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 1si9422185ply.181.2017.08.22.01.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 01:54:45 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
 <c445dacf-ac6f-3928-fe08-8eca266ed160@intel.com>
 <20170822083945.5erdqh4bo52i4r3p@techsingularity.net>
From: kemi <kemi.wang@intel.com>
Message-ID: <3b97cda7-5b03-d110-ec18-c671881e925b@intel.com>
Date: Tue, 22 Aug 2017 16:53:28 +0800
MIME-Version: 1.0
In-Reply-To: <20170822083945.5erdqh4bo52i4r3p@techsingularity.net>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'08ae??22ae?JPY 16:39, Mel Gorman wrote:
> On Tue, Aug 22, 2017 at 11:21:31AM +0800, kemi wrote:
>>
>>
>> On 2017???08???15??? 17:58, Mel Gorman wrote:
>>> On Tue, Aug 15, 2017 at 04:45:36PM +0800, Kemi Wang wrote:
>>>>  Threshold   CPU cycles    Throughput(88 threads)
>>>>      32          799         241760478
>>>>      64          640         301628829
>>>>      125         537         358906028 <==> system by default (base)
>>>>      256         468         412397590
>>>>      512         428         450550704
>>>>      4096        399         482520943
>>>>      20000       394         489009617
>>>>      30000       395         488017817
>>>>      32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
>>>>      N/A         342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics
>>>>
>>>> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
>>>> Suggested-by: Dave Hansen <dave.hansen@intel.com>
>>>> Suggested-by: Ying Huang <ying.huang@intel.com>
>>>> ---
>>>>  include/linux/mmzone.h |  4 ++--
>>>>  include/linux/vmstat.h |  6 +++++-
>>>>  mm/vmstat.c            | 23 ++++++++++-------------
>>>>  3 files changed, 17 insertions(+), 16 deletions(-)
>>>>
>>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>>>> index 0b11ba7..7eaf0e8 100644
>>>> --- a/include/linux/mmzone.h
>>>> +++ b/include/linux/mmzone.h
>>>> @@ -282,8 +282,8 @@ struct per_cpu_pageset {
>>>>  	struct per_cpu_pages pcp;
>>>>  #ifdef CONFIG_NUMA
>>>>  	s8 expire;
>>>> -	s8 numa_stat_threshold;
>>>> -	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
>>>> +	s16 numa_stat_threshold;
>>>> +	s16 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
>>>
>>> I'm fairly sure this pushes the size of that structure into the next
>>> cache line which is not welcome.
>>>
>> Hi Mel
>>   I am refreshing this patch. Would you pls be more explicit of what "that
>> structure" indicates. 
>>   If you mean "struct per_cpu_pageset", for 64 bits machine, this structure
>> still occupies two caches line after extending s8 to s16/u16, that should
>> not be a problem.
> 
> You're right, I was in error. I miscalculated badly initially. It still
> fits in as expected.
> 
>> For 32 bits machine, we probably does not need to extend
>> the size of vm_numa_stat_diff[] since 32 bits OS nearly not be used in large
>> numa system, and s8/u8 is large enough for it, in this case, we can keep the 
>> same size of "struct per_cpu_pageset".
>>
> 
> I don't believe it's worth the complexity of making this
> bitness-specific. 32-bit takes penalties in other places and besides,
> 32-bit does not necessarily mean a change in cache line size.
> 
> Fortunately, I think you should still be able to gain a bit more with
> some special casing the fact it's always incrementing and always do full
> spill of the counters instead of half. If so, then using u16 instead of
> s16 should also reduce the update frequency. However, if you find it's
> too complex and the gain is too marginal then I'll ack without it.
> 

That's fine, it would not be too complex to change s16 to u16, 
I will adopt it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
