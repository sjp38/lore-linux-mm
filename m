Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 948A06B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 23:03:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so1394147pfc.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 20:03:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s70si6335212pfg.149.2017.08.15.20.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 20:03:54 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
 <a258ea24-6830-4907-0165-fec17ccb7f9f@linux.intel.com>
From: kemi <kemi.wang@intel.com>
Message-ID: <bec999d7-098d-b6e2-a098-6a10a0f24ea2@intel.com>
Date: Wed, 16 Aug 2017 11:02:42 +0800
MIME-Version: 1.0
In-Reply-To: <a258ea24-6830-4907-0165-fec17ccb7f9f@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'08ae??16ae?JPY 00:55, Tim Chen wrote:
> On 08/15/2017 02:58 AM, Mel Gorman wrote:
>> On Tue, Aug 15, 2017 at 04:45:36PM +0800, Kemi Wang wrote:

>> I'm fairly sure this pushes the size of that structure into the next
>> cache line which is not welcome.
>>>> vm_numa_stat_diff is an always incrementing field. How much do you gain
>> if this becomes a u8 code and remove any code that deals with negative
>> values? That would double the threshold without consuming another cache line.
> 
> Doubling the threshold and counter size will help, but not as much
> as making them above u8 limit as seen in Kemi's data:
> 
>       125         537         358906028 <==> system by default (base)
>       256         468         412397590
>       32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
> 
> For small system making them u8 makes sense.  For larger ones the
> frequent local counter overflow into the global counter still
> causes a lot of cache bounce.  Kemi can perhaps collect some data
> to see what is the gain from making the counters u8. 
> 
Tim, thanks for your answer. That is what I want to clarify.

Also, pls notice that the negative threshold/2 is set to cpu local counter
(e.g. vm_numa_stat_diff[]) once per-zone counter is updated in current code
path. This weakens the benefit of changing s8 to u8 in this case. 
>>
>> Furthermore, the stats in question are only ever incremented by one.
>> That means that any calcluation related to overlap can be removed and
>> special cased that it'll never overlap by more than 1. That potentially
>> removes code that is required for other stats but not locality stats.
>> This may give enough savings to avoid moving to s16.
>>
>> Very broadly speaking, I like what you're doing but I would like to see
>> more work on reducing any unnecessary code in that path (such as dealing
>> with overlaps for single increments) and treat incrasing the cache footprint
>> only as a very last resort.
>>
Agree. I will think about it more. 

>>>  #endif
>>>  #ifdef CONFIG_SMP
>>>  	s8 stat_threshold;
>>> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
>>> index 1e19379..d97cc34 100644
>>> --- a/include/linux/vmstat.h
>>> +++ b/include/linux/vmstat.h
>>> @@ -125,10 +125,14 @@ static inline unsigned long global_numa_state(enum zone_numa_stat_item item)
>>>  	return x;
>>>  }
>>>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
