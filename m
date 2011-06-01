Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 26BE76B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 09:07:52 -0400 (EDT)
Message-ID: <4DE6399C.8070802@redhat.com>
Date: Wed, 01 Jun 2011 15:07:40 +0200
From: Igor Mammedov <imammedo@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com> <20110601123913.GC4266@tiehlicka.suse.cz>
In-Reply-To: <20110601123913.GC4266@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

On 06/01/2011 02:39 PM, Michal Hocko wrote:
> On Wed 01-06-11 12:44:04, Igor Mammedov wrote:
>> Freshly allocated 'mem_cgroup_per_node' list entries must be
>> initialized before the rest of the kernel can see them. Otherwise
>> zero initialized list fields can lead to race condition at
>> mem_cgroup_force_empty_list:
>>    pc = list_entry(list->prev, struct page_cgroup, lru);
>> where 'pc' will be something like 0xfffffffc if list->prev is 0
>> and cause page fault later when 'pc' is dereferenced.
> Have you ever seen such a race? I do not see how this could happen.
> mem_cgroup_force_empty_list is called only from
> mem_cgroup_force_empty_write (aka echo whatever>  group/force_empty)
> or mem_cgroup_pre_destroy when the group is destroyed.
>
> The initialization code is, however, called before a group is
> given for use AFICS.
>
> I am not saying tha the change is bad, I like it, but I do not think it
> is a fix for potential race condition.
>

Yes I've seen it (RHBZ#700565). It causes random crashes
in virt env ocasionally. It's easier to reproduce if you overcommit
cpu.

>> Signed-off-by: Igor Mammedov<imammedo@redhat.com>
>> ---
>>   mm/memcontrol.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index bd9052a..ee7cb4c 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4707,7 +4707,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>>   	if (!pn)
>>   		return 1;
>>
>> -	mem->info.nodeinfo[node] = pn;
>>   	for (zone = 0; zone<  MAX_NR_ZONES; zone++) {
>>   		mz =&pn->zoneinfo[zone];
>>   		for_each_lru(l)
>> @@ -4716,6 +4715,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>>   		mz->on_tree = false;
>>   		mz->mem = mem;
>>   	}
>> +	mem->info.nodeinfo[node] = pn;
>>   	return 0;
>>   }
>>
>> -- 
>> 1.7.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
