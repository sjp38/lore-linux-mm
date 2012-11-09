Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id CA3166B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 07:09:26 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3047919pbb.14
        for <linux-mm@kvack.org>; Fri, 09 Nov 2012 04:09:26 -0800 (PST)
Message-ID: <509CF279.1080602@gmail.com>
Date: Fri, 09 Nov 2012 20:09:29 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3] memcg, oom: provide more precise dump info while memcg
 oom happening
References: <1352389967-23270-1-git-send-email-handai.szj@taobao.com> <20121108162539.GP31821@dhcp22.suse.cz> <509CD98B.7080503@gmail.com> <20121109105040.GA5006@dhcp22.suse.cz>
In-Reply-To: <20121109105040.GA5006@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org

On 11/09/2012 06:50 PM, Michal Hocko wrote:
> On Fri 09-11-12 18:23:07, Sha Zhengju wrote:
>> On 11/09/2012 12:25 AM, Michal Hocko wrote:
>>> On Thu 08-11-12 23:52:47, Sha Zhengju wrote:
> [...]
>>>> +	for (i = 0; i<   MEM_CGROUP_STAT_NSTATS; i++) {
>>>> +		long long val = 0;
>>>> +		if (i == MEM_CGROUP_STAT_SWAP&&   !do_swap_account)
>>>> +			continue;
>>>> +		for_each_mem_cgroup_tree(mi, memcg)
>>>> +			val += mem_cgroup_read_stat(mi, i);
>>>> +		printk(KERN_CONT "%s:%lldKB ", mem_cgroup_stat_names[i], K(val));
>>>> +	}
>>>> +
>>>> +	for (i = 0; i<   NR_LRU_LISTS; i++) {
>>>> +		unsigned long long val = 0;
>>>> +
>>>> +		for_each_mem_cgroup_tree(mi, memcg)
>>>> +			val += mem_cgroup_nr_lru_pages(mi, BIT(i));
>>>> +		printk(KERN_CONT "%s:%lluKB ", mem_cgroup_lru_names[i], K(val));
>>>> +	}
>>>> +	printk(KERN_CONT "\n");
>>> This is nice and simple I am just thinking whether it is enough. Say
>>> that you have a deeper hierarchy and the there is a safety limit in the
>>> its root
>>>          A (limit)
>>>         /|\
>>>        B C D
>>>            |\
>>> 	  E F
>>>
>>> and we trigger an OOM on the A's limit. Now we know that something blew
>>> up but what it was we do not know. Wouldn't it be better to swap the for
>>> and for_each_mem_cgroup_tree loops? Then we would see the whole
>>> hierarchy and can potentially point at the group which doesn't behave.
>>> Memory cgroup stats for A/: ...
>>> Memory cgroup stats for A/B/: ...
>>> Memory cgroup stats for A/C/: ...
>>> Memory cgroup stats for A/D/: ...
>>> Memory cgroup stats for A/D/E/: ...
>>> Memory cgroup stats for A/D/F/: ...
>>>
>>> Would it still fit in with your use case?
>>> [...]
>> We haven't used those complicate hierarchy yet, but it sounds a good
>> suggestion. :)
>> Hierarchy is a little complex to use from our experience, and the
>> three cgroups involved in memcg oom can be different: memcg of
>> invoker, killed task, memcg of going over limit.Suppose a process in
>> B triggers oom and a victim in root A is selected to be killed, we
>> may as well want to know memcg stats just local in A cgroup(excludes
>> BCD). So besides hierarchy info, does it acceptable to also print
>> the local root node stats which as I did in the V1
>> version(https://lkml.org/lkml/2012/7/30/179).
> Ohh, I probably wasn't clear enough. I didn't suggest cumulative
> numbers. Only per group. So it would be something like:
>
> 	for_each_mem_cgroup_tree(mi, memcg) {
> 		printk("Memory cgroup stats for %s", memcg_name);
> 		for (i = 0; i<   MEM_CGROUP_STAT_NSTATS; i++) {
> 			if (i == MEM_CGROUP_STAT_SWAP&&   !do_swap_account)
> 				continue;
> 			printk(KERN_CONT "%s:%lldKB ", mem_cgroup_stat_names[i],
> 				K(mem_cgroup_read_stat(mi, i)));
> 		}
> 		for (i = 0; i<   NR_LRU_LISTS; i++)
> 			printk(KERN_CONT "%s:%lluKB ", mem_cgroup_lru_names[i],
> 				K(mem_cgroup_nr_lru_pages(mi, BIT(i))));
>
> 		printk(KERN_CONT"\n");
> 	}
>

Now I catch your point and understand the above... It's smarter than I 
thought before.
Thanks for explaining!

>> Another one I'm hesitating is numa stats, it seems the output is
>> beginning to get more and more....
> NUMA stats are basically per node - per zone LRU data and that the
> for(NR_LRU_LISTS) can be easily extended to cover that.

Yes, the numa_stat cgroup file has done works here. I'll add the numa
stats if you don't feel improper.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
