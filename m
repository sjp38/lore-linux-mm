Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 04AF36B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:16:20 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1195857pdj.14
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 01:16:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rw8si588326pab.161.2014.07.23.01.16.19
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 01:16:19 -0700 (PDT)
Message-ID: <53CF6F4E.6030908@linux.intel.com>
Date: Wed, 23 Jul 2014 16:16:14 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 28/30] mm: Update _mem_id_[] for every possible
 CPU when memory configuration changes
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-29-git-send-email-jiang.liu@linux.intel.com> <20140721174754.GE4156@linux.vnet.ibm.com>
In-Reply-To: <20140721174754.GE4156@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org



On 2014/7/22 1:47, Nishanth Aravamudan wrote:
> On 11.07.2014 [15:37:45 +0800], Jiang Liu wrote:
>> Current kernel only updates _mem_id_[cpu] for onlined CPUs when memory
>> configuration changes. So kernel may allocate memory from remote node
>> for a CPU if the CPU is still in absent or offline state even if the
>> node associated with the CPU has already been onlined.
> 
> This just sounds like the topology information is being updated at the
> wrong place/time? That is, the memory is online, the CPU is being
> brought online, but isn't associated with any node?
Hi Nishanth,
	Yes, that's the case.

> 
>> This patch tries to improve performance by updating _mem_id_[cpu] for
>> each possible CPU when memory configuration changes, thus kernel could
>> always allocate from local node once the node is onlined.
> 
> Ok, what is the impact? Do you actually see better performance?
No real data to support this yet, just with code analysis.
Regards!
Gerry
> 
>> We check node_online(cpu_to_node(cpu)) because:
>> 1) local_memory_node(nid) needs to access NODE_DATA(nid)
>> 2) try_offline_node(nid) just zeroes out NODE_DATA(nid) instead of free it
>>
>> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
>> ---
>>  mm/page_alloc.c |   10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 0ea758b898fd..de86e941ed57 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3844,13 +3844,13 @@ static int __build_all_zonelists(void *data)
>>  		/*
>>  		 * We now know the "local memory node" for each node--
>>  		 * i.e., the node of the first zone in the generic zonelist.
>> -		 * Set up numa_mem percpu variable for on-line cpus.  During
>> -		 * boot, only the boot cpu should be on-line;  we'll init the
>> -		 * secondary cpus' numa_mem as they come on-line.  During
>> -		 * node/memory hotplug, we'll fixup all on-line cpus.
>> +		 * Set up numa_mem percpu variable for all possible cpus
>> +		 * if associated node has been onlined.
>>  		 */
>> -		if (cpu_online(cpu))
>> +		if (node_online(cpu_to_node(cpu)))
>>  			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
>> +		else
>> +			set_cpu_numa_mem(cpu, NUMA_NO_NODE);
>>  #endif
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
