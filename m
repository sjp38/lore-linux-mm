Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9834F6B02F4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:32:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b83so862076pfl.6
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:32:35 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 99si7060697pla.88.2017.08.15.19.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 19:32:34 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
From: kemi <kemi.wang@intel.com>
Message-ID: <0a0324f8-5a7e-febf-03bd-b33cf11483ad@intel.com>
Date: Wed, 16 Aug 2017 10:31:19 +0800
MIME-Version: 1.0
In-Reply-To: <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>


>>  
>> -static inline unsigned long zone_numa_state(struct zone *zone,
>> +static inline unsigned long zone_numa_state_snapshot(struct zone *zone,
>>  					enum zone_numa_stat_item item)
>>  {
>>  	long x = atomic_long_read(&zone->vm_numa_stat[item]);
>> +	int cpu;
>> +
>> +	for_each_online_cpu(cpu)
>> +		x += per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item];
>>  
>>  	return x;
>>  }
> 
> This does not appear to be related to the current patch. It either
> should be merged with the previous patch or stand on its own.
> 
OK. I can move it to an individual patch if it does not make anyone unhappy.
Since it is not graceful to introduce any functionality change in first patch.

>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 5a7fa30..c7f50ed 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -30,6 +30,8 @@
>>  
>>  #include "internal.h"
>>  
>> +#define NUMA_STAT_THRESHOLD  32765
>> +
> 
> This should be expressed in terms of the type and not a hard-coded value.
> 
OK, Thanks. I will follow it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
