Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A2C346B000A
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 23:01:09 -0500 (EST)
Message-ID: <5109EC79.1050604@oracle.com>
Date: Thu, 31 Jan 2013 12:00:57 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/6] memcg: bypass swap accounting for the root memcg
References: <510658E3.1020306@oracle.com> <510658EE.9050006@oracle.com> <20130129141318.GC29574@dhcp22.suse.cz> <510943D8.9000902@oracle.com> <20130130162946.GA21253@dhcp22.suse.cz>
In-Reply-To: <20130130162946.GA21253@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, handai.szj@taobao.com

On 01/31/2013 12:29 AM, Michal Hocko wrote:
> On Thu 31-01-13 00:01:28, Jeff Liu wrote:
>> On 01/29/2013 10:13 PM, Michal Hocko wrote:
>>> On Mon 28-01-13 18:54:38, Jeff Liu wrote:
>>>> Root memcg with swap cgroup is special since we only do tracking
>>>> but can not set limits against it.  In order to facilitate
>>>> the implementation of the coming swap cgroup structures delay
>>>> allocation mechanism, we can bypass the default swap statistics
>>>> upon the root memcg and figure it out through the global stats
>>>> instead as below:
>>>>
>>>> root_memcg_swap_stat: total_swap_pages - nr_swap_pages -
>>>> used_swap_pages_of_all_memcgs
>>>
>>> How do you protect from races with swap{in,out}? Or they are
>>> tolerable?
> 
>> To be honest, I previously have not taken race with swapin/out into
>> consideration.
>>
>> Yes, this patch would cause a little error since it has to iterate
>> each memcg which can introduce a bit overhead based on how many memcgs
>> are configured.
>>
>> However, considering our current implementation of swap statistics, we
>> do account when swap cache is uncharged, but it is possible that the
>> swap slot is already allocated before that.
> 
> I am not sure I follow you here. I was merely interested in races while
> there is a swapping activity while the value is calculated. The errors,
> or let's say imprecision, shouldn't be big but it would be good to think
> how big it can be and how it can be reduced 
...
> (e.g. what if we start
> accounting for root once there is another group existing - this would
> solve the problem of delayed allocation and the imprecision as well).
At first, I also tried to account for root memcg swap in this sway, i.e.
return the root_memcg css_id from swap_cgroup_cmpxchg() &&
swap_cgroup_record() if there is no children memcg exists, however, it
caused the kernel panic with deadlock...
If return 0 from both functions in this case, no panic but it's
obviously that the root memcg swap accounting number is wrong, so that's
why I choose the current idea to bypass it...

I need some time to dig into the details anyway.
> 
>> That is to say, there is a inconsistent window in swap accounting stats IMHO.
>> As a figure shows to human, I think it can be tolerated to some extents. :)
>>>
>>>> memcg_total_swap_stats: root_memcg_swap_stat + other_memcg_swap_stats
>>>
>>> I am not sure I understand and if I do then it is not true:
>>> root (swap = 10M, use_hierarchy = 0/1)
>>>  \
>>>   A (swap = 1M, use_hierarchy = 1)
>>>    \
>>>     B (swap = 2M)
>>>
>>> total for A is 3M regardless of what root has "accounted" while
>>> total for root should be 10 for use_hierarchy = 0 and 13 for the
>>> other
>>
>> I am not sure I catch your point, but I think the total for root
>> should be 13 no matter use_hierarchy = 0 or 1, and the current patch
>> is just doing that.
> 
> I do not see any reason to make root different wrt. other roots of
> hierarchy. Anyway this is not important right now.
> 
>> Originally, for_each_mem_cgroup_tree(iter, memcg) does statistics by
>> iterating all those children memcgs including the memcg itself.  But
>> now, as we don't account the root memcg swap statistics anymore(hence
>> the stats is 0), we need to add the local swap stats of root memcg
>> itself(10M) to the memcg_total_swap_stats.  So actually we don't
>> change the way of accounting memcg_total_swap_stats.
> 
> I guess you are talking about tatal_ numbers. And yes, your patch
> doesn't change that.
Yes.

Thanks you!
-Jeff
>  
>>> case (this is btw. broken in the tree already now because
>>> for_each_mem_cgroup_tree resp. mem_cgroup_iter doesn't honor
>>> use_hierarchy for the root cgroup - this is a separate topic
>>> though).
>>
>> Yes, I noticed that the for_each_mem_cgroup_tree() resp,
>> mem_cgroup_iter() don't take the root->use_hierarchy into
>> consideration, as it has the following logic:
>> if (!root->use_hierarchy && root != root_mem_cgroup) {
>>  	if (prev)
>> 		return NULL;
>> 	return root;
>> }
>>
>> As i don't change the for_each_mem_cgroup_tree(), so it is in
>> accordance with the original behavior.
> 
> True, and I was just mentioning that as I noticed this only during
> the review. It wasn't meant to dispute your patch. Sorry if this wasn't
> clear enough. We have that behavior for ages and nobody complained so it
> is probably not worth fixing (especially when use_hierarchy is on the
> way out very sloooooowly).
> 
> [...]
> 
> Thanks
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
