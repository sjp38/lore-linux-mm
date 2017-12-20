Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 829446B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 22:07:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z12so13614970pgv.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:07:31 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w3si4620913pgb.681.2017.12.19.19.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 19:07:29 -0800 (PST)
Subject: Re: [PATCH v2 2/5] mm: Extends local cpu counter vm_diff_nodestat
 from s8 to s16
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-3-git-send-email-kemi.wang@intel.com>
 <20171219123829.GN2787@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <aa40288b-79fe-940b-f030-85eb23b6cf4a@intel.com>
Date: Wed, 20 Dec 2017 11:05:25 +0800
MIME-Version: 1.0
In-Reply-To: <20171219123829.GN2787@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'12ae??19ae?JPY 20:38, Michal Hocko wrote:
> On Tue 19-12-17 14:39:23, Kemi Wang wrote:
>> The type s8 used for vm_diff_nodestat[] as local cpu counters has the
>> limitation of global counters update frequency, especially for those
>> monotone increasing type of counters like NUMA counters with more and more
>> cpus/nodes. This patch extends the type of vm_diff_nodestat from s8 to s16
>> without any functionality change.
>>
>>                                  before     after
>> sizeof(struct per_cpu_nodestat)    28         68
> 
> So it is 40B * num_cpus * num_nodes. Nothing really catastrophic IMHO
> but the changelog is a bit silent about any numbers. This is a
> performance optimization so it should better give us some.
>  

This patch does not have any functionality change. So no performance gain 
I suppose. 
I guess you are talking about performance gain from the third patch which 
increases threshold size of NUMA counters.

>> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
>> ---
>>  include/linux/mmzone.h |  4 ++--
>>  mm/vmstat.c            | 16 ++++++++--------
>>  2 files changed, 10 insertions(+), 10 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index c06d880..2da6b6f 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -289,8 +289,8 @@ struct per_cpu_pageset {
>>  };
>>  
>>  struct per_cpu_nodestat {
>> -	s8 stat_threshold;
>> -	s8 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
>> +	s16 stat_threshold;
>> +	s16 vm_node_stat_diff[NR_VM_NODE_STAT_ITEMS];
>>  };
>>  
>>  #endif /* !__GENERATING_BOUNDS.H */
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 1dd12ae..9c681cc 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -332,7 +332,7 @@ void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
>>  				long delta)
>>  {
>>  	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
>> -	s8 __percpu *p = pcp->vm_node_stat_diff + item;
>> +	s16 __percpu *p = pcp->vm_node_stat_diff + item;
>>  	long x;
>>  	long t;
>>  
>> @@ -390,13 +390,13 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
>>  void __inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
>>  {
>>  	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
>> -	s8 __percpu *p = pcp->vm_node_stat_diff + item;
>> -	s8 v, t;
>> +	s16 __percpu *p = pcp->vm_node_stat_diff + item;
>> +	s16 v, t;
>>  
>>  	v = __this_cpu_inc_return(*p);
>>  	t = __this_cpu_read(pcp->stat_threshold);
>>  	if (unlikely(v > t)) {
>> -		s8 overstep = t >> 1;
>> +		s16 overstep = t >> 1;
>>  
>>  		node_page_state_add(v + overstep, pgdat, item);
>>  		__this_cpu_write(*p, -overstep);
>> @@ -434,13 +434,13 @@ void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
>>  void __dec_node_state(struct pglist_data *pgdat, enum node_stat_item item)
>>  {
>>  	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
>> -	s8 __percpu *p = pcp->vm_node_stat_diff + item;
>> -	s8 v, t;
>> +	s16 __percpu *p = pcp->vm_node_stat_diff + item;
>> +	s16 v, t;
>>  
>>  	v = __this_cpu_dec_return(*p);
>>  	t = __this_cpu_read(pcp->stat_threshold);
>>  	if (unlikely(v < - t)) {
>> -		s8 overstep = t >> 1;
>> +		s16 overstep = t >> 1;
>>  
>>  		node_page_state_add(v - overstep, pgdat, item);
>>  		__this_cpu_write(*p, overstep);
>> @@ -533,7 +533,7 @@ static inline void mod_node_state(struct pglist_data *pgdat,
>>         enum node_stat_item item, int delta, int overstep_mode)
>>  {
>>  	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
>> -	s8 __percpu *p = pcp->vm_node_stat_diff + item;
>> +	s16 __percpu *p = pcp->vm_node_stat_diff + item;
>>  	long o, n, t, z;
>>  
>>  	do {
>> -- 
>> 2.7.4
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
