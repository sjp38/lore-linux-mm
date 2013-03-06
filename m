Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 328D76B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:31:12 -0500 (EST)
Message-ID: <5136FEC2.2050004@parallels.com>
Date: Wed, 6 Mar 2013 12:30:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-3-git-send-email-glommer@parallels.com> <51368D80.20701@jp.fujitsu.com>
In-Reply-To: <51368D80.20701@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On 03/06/2013 04:27 AM, Kamezawa Hiroyuki wrote:
> (2013/03/05 22:10), Glauber Costa wrote:
>> For the root memcg, there is no need to rely on the res_counters if hierarchy
>> is enabled The sum of all mem cgroups plus the tasks in root itself, is
>> necessarily the amount of memory used for the whole system. Since those figures
>> are already kept somewhere anyway, we can just return them here, without too
>> much hassle.
>>
>> Limit and soft limit can't be set for the root cgroup, so they are left at
>> RESOURCE_MAX. Failcnt is left at 0, because its actual meaning is how many
>> times we failed allocations due to the limit being hit. We will fail
>> allocations in the root cgroup, but the limit will never the reason.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Mel Gorman <mgorman@suse.de>
>> CC: Andrew Morton <akpm@linux-foundation.org>
> 
> I think this patch's calculation is wrong.
> 
where exactly ?

>> ---
>>   mm/memcontrol.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 64 insertions(+)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index b8b363f..bfbf1c2 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4996,6 +4996,56 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>>   	return val << PAGE_SHIFT;
>>   }
>>   
>> +static u64 memcg_read_root_rss(void)
>> +{
>> +	struct task_struct *p;
>> +
>> +	u64 rss = 0;
>> +	read_lock(&tasklist_lock);
>> +	for_each_process(p) {
>> +		if (!p->mm)
>> +			continue;
>> +		task_lock(p);
>> +		rss += get_mm_rss(p->mm);
>> +		task_unlock(p);
>> +	}
>> +	read_unlock(&tasklist_lock);
>> +	return rss;
>> +}
> 
> I think you can use rcu_read_lock() instead of tasklist_lock.
> Isn't it enough to use NR_ANON_LRU rather than this ?

Is it really just ANON_LRU ? get_mm_rss also include filepages, which
are not in this list.

Maybe if we sum up *all* LRUs we would get the right result ?

About the tasklist lock, if I get values from the LRUs, maybe. Otherwise
it is still necessary, no ?

> 
>> +
>> +static u64 mem_cgroup_read_root(enum res_type type, int name)
>> +{
>> +	if (name == RES_LIMIT)
>> +		return RESOURCE_MAX;
>> +	if (name == RES_SOFT_LIMIT)
>> +		return RESOURCE_MAX;
>> +	if (name == RES_FAILCNT)
>> +		return 0;
>> +	if (name == RES_MAX_USAGE)
>> +		return 0;
>> +
>> +	if (WARN_ON_ONCE(name != RES_USAGE))
>> +		return 0;
>> +
>> +	switch (type) {
>> +	case _MEM:
>> +		return (memcg_read_root_rss() +
>> +		atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT;
>> +	case _MEMSWAP: {
>> +		struct sysinfo i;
>> +		si_swapinfo(&i);
>> +
>> +		return ((memcg_read_root_rss() +
>> +		atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT) +
>> +		i.totalswap - i.freeswap;
> 
> How swapcache is handled ? ...and How kmem works with this calc ?
> 
I am ignoring kmem, because we don't account kmem for the root cgroup
anyway.

Setting the limit is invalid, and we don't account until the limit is
set. Then it will be 0, always.

For swapcache, I am hoping that totalswap - freeswap will cover
everything swap related. If you think I am wrong, please enlighten me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
