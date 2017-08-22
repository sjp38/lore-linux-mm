Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9987D280442
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 23:22:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q10so201363787pgc.15
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 20:22:47 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z11si8105687pge.66.2017.08.21.20.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 20:22:46 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
From: kemi <kemi.wang@intel.com>
Message-ID: <c445dacf-ac6f-3928-fe08-8eca266ed160@intel.com>
Date: Tue, 22 Aug 2017 11:21:31 +0800
MIME-Version: 1.0
In-Reply-To: <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'08ae??15ae?JPY 17:58, Mel Gorman wrote:
> On Tue, Aug 15, 2017 at 04:45:36PM +0800, Kemi Wang wrote:
>>  Threshold   CPU cycles    Throughput(88 threads)
>>      32          799         241760478
>>      64          640         301628829
>>      125         537         358906028 <==> system by default (base)
>>      256         468         412397590
>>      512         428         450550704
>>      4096        399         482520943
>>      20000       394         489009617
>>      30000       395         488017817
>>      32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
>>      N/A         342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics
>>
>> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
>> Suggested-by: Dave Hansen <dave.hansen@intel.com>
>> Suggested-by: Ying Huang <ying.huang@intel.com>
>> ---
>>  include/linux/mmzone.h |  4 ++--
>>  include/linux/vmstat.h |  6 +++++-
>>  mm/vmstat.c            | 23 ++++++++++-------------
>>  3 files changed, 17 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 0b11ba7..7eaf0e8 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -282,8 +282,8 @@ struct per_cpu_pageset {
>>  	struct per_cpu_pages pcp;
>>  #ifdef CONFIG_NUMA
>>  	s8 expire;
>> -	s8 numa_stat_threshold;
>> -	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
>> +	s16 numa_stat_threshold;
>> +	s16 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
> 
> I'm fairly sure this pushes the size of that structure into the next
> cache line which is not welcome.
> 
Hi Mel
  I am refreshing this patch. Would you pls be more explicit of what "that
structure" indicates. 
  If you mean "struct per_cpu_pageset", for 64 bits machine, this structure
still occupies two caches line after extending s8 to s16/u16, that should
not be a problem. For 32 bits machine, we probably does not need to extend
the size of vm_numa_stat_diff[] since 32 bits OS nearly not be used in large
numa system, and s8/u8 is large enough for it, in this case, we can keep the 
same size of "struct per_cpu_pageset".

 If you mean "s16 vm_numa_stat_diff[]", and want to keep it in a single cache
line, we probably can add some padding after "s8 expire" to achieve it.

Again, thanks for your comments to make this patch more graceful.
> vm_numa_stat_diff is an always incrementing field. How much do you gain
> if this becomes a u8 code and remove any code that deals with negative
> values? That would double the threshold without consuming another cache line.
> 
> Furthermore, the stats in question are only ever incremented by one.
> That means that any calcluation related to overlap can be removed and
> special cased that it'll never overlap by more than 1. That potentially
> removes code that is required for other stats but not locality stats.
> This may give enough savings to avoid moving to s16.
> 
> Very broadly speaking, I like what you're doing but I would like to see
> more work on reducing any unnecessary code in that path (such as dealing
> with overlaps for single increments) and treat incrasing the cache footprint
> only as a very last resort.
> 
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
