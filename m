Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id C60446B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 08:11:57 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so1292565dad.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 05:11:57 -0800 (PST)
Message-ID: <509BAFA0.4010604@gmail.com>
Date: Thu, 08 Nov 2012 21:12:00 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg, oom: provide more precise dump info while
 memcg oom happening
References: <1352277602-21687-1-git-send-email-handai.szj@taobao.com> <1352277696-21724-1-git-send-email-handai.szj@taobao.com> <509B7658.1020807@jp.fujitsu.com>
In-Reply-To: <509B7658.1020807@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On 11/08/2012 05:07 PM, Kamezawa Hiroyuki wrote:
> (2012/11/07 17:41), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Current, when a memcg oom is happening the oom dump messages is still global
>> state and provides few useful info for users. This patch prints more pointed
>> memcg page statistics for memcg-oom.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>   mm/memcontrol.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>>   mm/oom_kill.c   |    6 +++-
>>   2 files changed, 66 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 0eab7d5..2df5e72 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -118,6 +118,14 @@ static const char * const mem_cgroup_events_names[] = {
>>   	"pgmajfault",
>>   };
>>   
>> +static const char * const mem_cgroup_lru_names[] = {
>> +	"inactive_anon",
>> +	"active_anon",
>> +	"inactive_file",
>> +	"active_file",
>> +	"unevictable",
>> +};
>> +
> Is this for the same strings with show_free_areas() ?
>

I just move the declaration here from the bottom of source file to make
the following use error-free.

>>   /*
>>    * Per memcg event counter is incremented at every pagein/pageout. With THP,
>>    * it will be incremated by the number of pages. This counter is used for
>> @@ -1501,8 +1509,59 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>>   	spin_unlock_irqrestore(&memcg->move_lock, *flags);
>>   }
>>   
>> +#define K(x) ((x) << (PAGE_SHIFT-10))
>> +static void mem_cgroup_print_oom_stat(struct mem_cgroup *memcg)
>> +{
>> +	struct mem_cgroup *mi;
>> +	unsigned int i;
>> +
>> +	if (!memcg->use_hierarchy && memcg != root_mem_cgroup) {
> Why do you need to have this condition check ?
>

Yes, the check is unnecessary... I'll remove it next version.

>> +		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>> +			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
>> +				continue;
>> +			printk(KERN_CONT "%s:%ldKB ", mem_cgroup_stat_names[i],
>> +				K(mem_cgroup_read_stat(memcg, i)));
> Hm, how about using the same style with show_free_areas() ?
>

I'm also trying do so. show_free_areas() prints the memory related info
in two style:
one is in page unit and the oher is in KB (I've no idea why we distinct
them), but
I think the KB format is more readable.


>> +		}
>> +
>> +		for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
>> +			printk(KERN_CONT "%s:%lu ", mem_cgroup_events_names[i],
>> +				mem_cgroup_read_events(memcg, i));
>> +
> I don't think EVENTS info is useful for oom.
>

It seems you're right. : )

>> +		for (i = 0; i < NR_LRU_LISTS; i++)
>> +			printk(KERN_CONT "%s:%luKB ", mem_cgroup_lru_names[i],
>> +				K(mem_cgroup_nr_lru_pages(memcg, BIT(i))));
> How far does your new information has different format than usual oom ?
> Could you show a sample and difference in changelog ?
>
> Of course, I prefer both of them has similar format.
>
>
>
The new memcg-oom info excludes global state out and prints the memcg
statistics instead
which seems more brevity. I'll add a sample next time. Thanks for
reminding me!


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
