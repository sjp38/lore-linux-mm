Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id D89666B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:01:39 -0500 (EST)
Message-ID: <510943D8.9000902@oracle.com>
Date: Thu, 31 Jan 2013 00:01:28 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/6] memcg: bypass swap accounting for the root memcg
References: <510658E3.1020306@oracle.com> <510658EE.9050006@oracle.com> <20130129141318.GC29574@dhcp22.suse.cz>
In-Reply-To: <20130129141318.GC29574@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, handai.szj@taobao.com

On 01/29/2013 10:13 PM, Michal Hocko wrote:
> On Mon 28-01-13 18:54:38, Jeff Liu wrote:
>> Root memcg with swap cgroup is special since we only do tracking but can
>> not set limits against it.  In order to facilitate the implementation of
>> the coming swap cgroup structures delay allocation mechanism, we can bypass
>> the default swap statistics upon the root memcg and figure it out through
>> the global stats instead as below:
>>
>> root_memcg_swap_stat: total_swap_pages - nr_swap_pages - used_swap_pages_of_all_memcgs
> 
> How do you protect from races with swap{in,out}? Or they are tolerable?
To be honest, I previously have not taken race with swapin/out into consideration.

Yes, this patch would cause a little error since it has to iterate each memcg which can
introduce a bit overhead based on how many memcgs are configured.

However, considering our current implementation of swap statistics, we do account when swap 
cache is uncharged, but it is possible that the swap slot is already allocated before that.
That is to say, there is a inconsistent window in swap accounting stats IMHO.
As a figure shows to human, I think it can be tolerated to some extents. :)
> 
>> memcg_total_swap_stats: root_memcg_swap_stat + other_memcg_swap_stats
> 
> I am not sure I understand and if I do then it is not true:
> root (swap = 10M, use_hierarchy = 0/1)
>  \
>   A (swap = 1M, use_hierarchy = 1)
>    \
>     B (swap = 2M)
> 
> total for A is 3M regardless of what root has "accounted" while
> total for root should be 10 for use_hierarchy = 0 and 13 for the other
I am not sure I catch your point, but I think the total for root should be 13 no matter
use_hierarchy = 0 or 1, and the current patch is just doing that.

Originally, for_each_mem_cgroup_tree(iter, memcg) does statistics by iterating
all those children memcgs including the memcg itself.  But now, as we don't account the
root memcg swap statistics anymore(hence the stats is 0), we need to add the local swap
stats of root memcg itself(10M) to the memcg_total_swap_stats.  So actually we don't change
the way of accounting memcg_total_swap_stats.

> case (this is btw. broken in the tree already now because
> for_each_mem_cgroup_tree resp. mem_cgroup_iter doesn't honor
> use_hierarchy for the root cgroup - this is a separate topic though).
Yes, I noticed that the for_each_mem_cgroup_tree() resp, mem_cgroup_iter()
don't take the root->use_hierarchy into consideration, as it has the following logic:
if (!root->use_hierarchy && root != root_mem_cgroup) {
 	if (prev)
		return NULL;
	return root;
}

As i don't change the for_each_mem_cgroup_tree(), so it is in accordance with the original
behavior.

>> In this way, we'll return an invalid CSS_ID(generally, it's 0) at swap
>> cgroup related tracking infrastructures if only the root memcg is alive.
>> That is to say, we have not yet allocate swap cgroup structures.
>> As a result, the per pages swapin/swapout stats number agains the root
>> memcg shoud be ZERO.
>>
>> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> CC: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Mel Gorman <mgorman@suse.de>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>>
>> ---
>>  mm/memcontrol.c |   35 ++++++++++++++++++++++++++++++-----
>>  1 file changed, 30 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 09255ec..afe5e86 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -5231,12 +5231,34 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>>  	struct mem_cgroup *mi;
>>  	unsigned int i;
>> +	long long root_swap_stat = 0;
>>
>>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>> -		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
>> -			continue;
>> +		long val = 0;
>> +
>> +		if (i != MEM_CGROUP_STAT_SWAP)
>> +			val = mem_cgroup_read_stat(memcg, i);
>> +		else {
>> +			if (!do_swap_account)
>> +				continue;
> 
> 
>> +			if (!mem_cgroup_is_root(memcg))
>> +				val = mem_cgroup_read_stat(memcg, i);
>> +			else {
>> +				/*
>> +				 * The corresponding stat number of swap for
>> +				 * root_mem_cgroup is 0 since we don't account
>> +				 * it in any case.  Instead, we can fake the
>> +				 * root number via: total_swap_pages -
>> +				 * nr_swap_pages - total_swap_pages_of_all_memcg
>> +				 */
>> +				for_each_mem_cgroup(mi)
>> +					val += mem_cgroup_read_stat(mi, i);
>> +				val = root_swap_stat = (total_swap_pages -
>> +							nr_swap_pages - val);
>> +			}
> 
> This calls for a helper.
Yes, Sir.
> 
>> +		}
>>  		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
>> -			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
>> +			   val * PAGE_SIZE);
>>  	}
>>  
>>  	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
>> @@ -5260,8 +5282,11 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>>  		long long val = 0;
>>  
>> -		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
>> -			continue;
>> +		if (i == MEM_CGROUP_STAT_SWAP) {
>> +			if (!do_swap_account)
>> +				continue;
>> +			val += root_swap_stat * PAGE_SIZE;
>> +		}
> 
> This doesn't seem right because you are adding root swap amount to _all_
> groups. This should be done only if (memcg == root_mem_cgroup).
Ah, I?m too dumb!

Thanks,
-Jeff
> 
>>  		for_each_mem_cgroup_tree(mi, memcg)
>>  			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
>>  		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
