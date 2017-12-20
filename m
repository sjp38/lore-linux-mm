Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 539216B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:54:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a13so13827479pgt.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 21:54:18 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g12si12365669pla.602.2017.12.19.21.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 21:54:17 -0800 (PST)
Subject: Re: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-4-git-send-email-kemi.wang@intel.com>
 <20171219124045.GO2787@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <439918f7-e8a3-c007-496c-99535cbc4582@intel.com>
Date: Wed, 20 Dec 2017 13:52:14 +0800
MIME-Version: 1.0
In-Reply-To: <20171219124045.GO2787@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'12ae??19ae?JPY 20:40, Michal Hocko wrote:
> On Tue 19-12-17 14:39:24, Kemi Wang wrote:
>> We have seen significant overhead in cache bouncing caused by NUMA counters
>> update in multi-threaded page allocation. See 'commit 1d90ca897cb0 ("mm:
>> update NUMA counter threshold size")' for more details.
>>
>> This patch updates NUMA counters to a fixed size of (MAX_S16 - 2) and deals
>> with global counter update using different threshold size for node page
>> stats.
> 
> Again, no numbers.

Compare to vanilla kernel, I don't think it has performance improvement, so
I didn't post performance data here.
But, if you would like to see performance gain from enlarging threshold size
for NUMA stats (compare to the first patch), I will do that later. 

> To be honest I do not really like the special casing
> here. Why are numa counters any different from PGALLOC which is
> incremented for _every_ single page allocation?
> 

I guess you meant to PGALLOC event.
The number of this event is kept in local cpu and sum up (for_each_online_cpu)
when need. It uses the similar way to what I used before for NUMA stats in V1 
patch series. Good enough.

>> ---
>>  mm/vmstat.c | 13 +++++++++++--
>>  1 file changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 9c681cc..64e08ae 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -30,6 +30,8 @@
>>  
>>  #include "internal.h"
>>  
>> +#define VM_NUMA_STAT_THRESHOLD (S16_MAX - 2)
>> +
>>  #ifdef CONFIG_NUMA
>>  int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
>>  
>> @@ -394,7 +396,11 @@ void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
>>  	s16 v, t;
>>  
>>  	v = __this_cpu_inc_return(*p);
>> -	t = __this_cpu_read(pcp->stat_threshold);
>> +	if (item >= NR_VM_NUMA_STAT_ITEMS)
>> +		t = __this_cpu_read(pcp->stat_threshold);
>> +	else
>> +		t = VM_NUMA_STAT_THRESHOLD;
>> +
>>  	if (unlikely(v > t)) {
>>  		s16 overstep = t >> 1;
>>  
>> @@ -549,7 +555,10 @@ static inline void mod_node_state(struct pglist_data *pgdat,
>>  		 * Most of the time the thresholds are the same anyways
>>  		 * for all cpus in a node.
>>  		 */
>> -		t = this_cpu_read(pcp->stat_threshold);
>> +		if (item >= NR_VM_NUMA_STAT_ITEMS)
>> +			t = this_cpu_read(pcp->stat_threshold);
>> +		else
>> +			t = VM_NUMA_STAT_THRESHOLD;
>>  
>>  		o = this_cpu_read(*p);
>>  		n = delta + o;
>> -- 
>> 2.7.4
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
