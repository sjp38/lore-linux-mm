Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3B9A2940001
	for <linux-mm@kvack.org>; Fri, 25 May 2012 05:53:37 -0400 (EDT)
Message-ID: <4FBF561A.7030003@parallels.com>
Date: Fri, 25 May 2012 13:51:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 1/2] Always free struct memcg through schedule_work()
References: <1337938328-11537-1-git-send-email-glommer@parallels.com> <1337938328-11537-2-git-send-email-glommer@parallels.com> <20120525095007.GA30527@tiehlicka.suse.cz>
In-Reply-To: <20120525095007.GA30527@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, David Miller <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>

On 05/25/2012 01:50 PM, Michal Hocko wrote:
> On Fri 25-05-12 13:32:07, Glauber Costa wrote:
>> Right now we free struct memcg with kfree right after a
>> rcu grace period, but defer it if we need to use vfree() to get
>> rid of that memory area. We do that by need, because we need vfree
>> to be called in a process context.
>>
>> This patch unifies this behavior, by ensuring that even kfree will
>> happen in a separate thread. The goal is to have a stable place to
>> call the upcoming jump label destruction function outside the realm
>> of the complicated and quite far-reaching cgroup lock (that can't be
>> held when calling neither the cpu_hotplug.lock nor the jump_label_mutex)
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> Acked-by: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> Acked-by: Michal Hocko<mhocko@suse.cz>
>
> Just one comment below
>
>> CC: Tejun Heo<tj@kernel.org>
>> CC: Li Zefan<lizefan@huawei.com>
>> CC: Johannes Weiner<hannes@cmpxchg.org>
>> CC: Michal Hocko<mhocko@suse.cz>
>> CC: Andrew Morton<akpm@linux-foundation.org>
>> ---
>>   mm/memcontrol.c |   24 +++++++++++++-----------
>>   1 files changed, 13 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 932a734..0b4b4c8 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
> [...]
>> @@ -4826,23 +4826,28 @@ out_free:
>>   }
>>
>>   /*
>> - * Helpers for freeing a vzalloc()ed mem_cgroup by RCU,
>> + * Helpers for freeing a kmalloc()ed/vzalloc()ed mem_cgroup by RCU,
>>    * but in process context.  The work_freeing structure is overlaid
>>    * on the rcu_freeing structure, which itself is overlaid on memsw.
>>    */
>> -static void vfree_work(struct work_struct *work)
>> +static void free_work(struct work_struct *work)
>>   {
>>   	struct mem_cgroup *memcg;
>> +	int size = sizeof(struct mem_cgroup);
>>
>>   	memcg = container_of(work, struct mem_cgroup, work_freeing);
>> -	vfree(memcg);
>> +	if (size<  PAGE_SIZE)
>
> What about
> 	if (is_vmalloc_addr(memcg))
>> +		kfree(memcg);
>> +	else
>> +		vfree(memcg);
>>   }
>
Could be, but I believe this one is already in Andrew's tree from last 
submission (might be wrong)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
