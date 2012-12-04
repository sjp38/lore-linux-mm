Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id C17086B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 08:14:42 -0500 (EST)
Message-ID: <50BDF731.3050009@oracle.com>
Date: Tue, 04 Dec 2012 21:14:25 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/3] memcg: allocate pages for swap cgroup until the
 first child memcg is alive
References: <50BDB5E0.7030906@oracle.com> <50BDB601.4090205@oracle.com> <20121204125445.GC1343@dhcp22.suse.cz>
In-Reply-To: <20121204125445.GC1343@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

On 12/04/2012 08:54 PM, Michal Hocko wrote:
> On Tue 04-12-12 16:36:17, Jeff Liu wrote:
>> - Call swap_cgroup_init() when the first child memcg was created.
>> - Free pages from swap cgroup once the latest child memcg was removed.
> 
> This should be a separate patch
> 
>> - Teach swap_cgroup_record()/swap_cgroup_cmpxchg()/swap_cgroup_lookup_id()
>>   to aware of the new static variable. i.e, swap_cgroup_initialized, so that
>>   they would not perform further jobs if swap cgroup is not active.
> 
> This should be a preparatory patch.
Ok, these changes will be reflect in next round of post.
> 
>>
>> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
>> CC: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Mel Gorman <mgorman@suse.de>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>  mm/memcontrol.c  |    3 +++
>>  mm/page_cgroup.c |    9 +++++++++
>>  2 files changed, 12 insertions(+)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index dd39ba0..1f14375 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4982,6 +4982,8 @@ mem_cgroup_create(struct cgroup *cont)
>>  		}
>>  		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>>  	} else {
>> +		if (swap_cgroup_init())
>> +			goto free_out;
>>  		parent = mem_cgroup_from_cont(cont->parent);
>>  		memcg->use_hierarchy = parent->use_hierarchy;
>>  		memcg->oom_kill_disable = parent->oom_kill_disable;
>> @@ -5046,6 +5048,7 @@ static void mem_cgroup_destroy(struct cgroup *cont)
>>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>>  
>>  	kmem_cgroup_destroy(memcg);
>> +	swap_cgroup_destroy();
>>  
>>  	mem_cgroup_put(memcg);
>>  }
>> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
>> index f1b257b..63c6789 100644
>> --- a/mm/page_cgroup.c
>> +++ b/mm/page_cgroup.c
>> @@ -429,6 +429,9 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>>  	unsigned long flags;
>>  	unsigned short retval;
>>  
>> +	if (!atomic_read(&swap_cgroup_initialized))
>> +		return 0;
>> +
>>  	sc = lookup_swap_cgroup(ent, &ctrl);
>>  
>>  	spin_lock_irqsave(&ctrl->lock, flags);
>> @@ -456,6 +459,9 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>>  	unsigned short old;
>>  	unsigned long flags;
>>  
>> +	if (!atomic_read(&swap_cgroup_initialized))
>> +		return 0;
>> +
>>  	sc = lookup_swap_cgroup(ent, &ctrl);
>>  
>>  	spin_lock_irqsave(&ctrl->lock, flags);
>> @@ -474,6 +480,9 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
>>   */
>>  unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>>  {
>> +	if (!atomic_read(&swap_cgroup_initialized))
>> +		return 0;
>> +
>>  	return lookup_swap_cgroup(ent, NULL)->id;
> 
> I think that the swap_cgroup_initialized test should be stuffed into
> lookup_swap_cgroup because it would be less fragile.
Originally, I spreaded this test over those functions in order to avoid adding
additional check against the return value of lookup_swap_cgroup(), but it's
really stupid, will follow up with your suggestions.

Thanks,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
