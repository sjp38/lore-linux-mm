Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C9F516B0253
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 23:37:49 -0400 (EDT)
Received: by pawu10 with SMTP id u10so27721064paw.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 20:37:49 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id f2si30128295pat.213.2015.08.03.20.37.47
        for <linux-mm@kvack.org>;
        Mon, 03 Aug 2015 20:37:48 -0700 (PDT)
Message-ID: <55C03332.2030808@cn.fujitsu.com>
Date: Tue, 4 Aug 2015 11:36:18 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86, gfp: Cache best near node for memory allocation.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com> <1436261425-29881-2-git-send-email-tangchen@cn.fujitsu.com> <20150715214802.GL15934@mtj.duckdns.org>
In-Reply-To: <20150715214802.GL15934@mtj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tangchen@cn.fujitsu.com

Hi TJ,

Sorry for the late reply.

On 07/16/2015 05:48 AM, Tejun Heo wrote:
> ......
> so in initialization pharse makes no sense any more. The best near online
> node for each cpu should be cached somewhere.
> I'm not really following.  Is this because the now offline node can
> later come online and we'd have to break the constant mapping
> invariant if we update the mapping later?  If so, it'd be nice to
> spell that out.

Yes. Will document this in the next version.

>> ......
>>   
>> +int get_near_online_node(int node)
>> +{
>> +	return per_cpu(x86_cpu_to_near_online_node,
>> +		       cpumask_first(&node_to_cpuid_mask_map[node]));
>> +}
>> +EXPORT_SYMBOL(get_near_online_node);
> Umm... this function is sitting on a fairly hot path and scanning a
> cpumask each time.  Why not just build a numa node -> numa node array?

Indeed. Will avoid to scan a cpumask.

> ......
>
>>   
>>   static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>>   						unsigned int order)
>>   {
>> -	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>> +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
>> +
>> +#if IS_ENABLED(CONFIG_X86) && IS_ENABLED(CONFIG_NUMA)
>> +	if (!node_online(nid))
>> +		nid = get_near_online_node(nid);
>> +#endif
>>   
>>   	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>>   }
> Ditto.  Also, what's the synchronization rules for NUMA node
> on/offlining.  If you end up updating the mapping later, how would
> that be synchronized against the above usages?

I think the near online node map should be updated when node online/offline
happens. But about this, I think the current numa code has a little problem.

As you know, firmware info binds a set of CPUs and memory to a node. But
at boot time, if the node has no memory (a memory-less node) , it won't 
be online.
But the CPUs on that node is available, and bound to the near online node.
(Here, I mean numa_set_node(cpu, node).)

Why does the kernel do this ? I think it is used to ensure that we can 
allocate memory
successfully by calling functions like alloc_pages_node() and 
alloc_pages_exact_node().
By these two fuctions, any CPU should be bound to a node who has memory 
so that
memory allocation can be successful.

That means, for a memory-less node at boot time, CPUs on the node is 
online,
but the node is not online.

That also means, "the node is online" equals to "the node has memory". 
Actually, there
are a lot of code in the kernel is using this rule.


But,
1) in cpu_up(), it will try to online a node, and it doesn't check if 
the node has memory.
2) in try_offline_node(), it offlines CPUs first, and then the memory.

This behavior looks a little wired, or let's say it is ambiguous. It 
seems that a NUMA node
consists of CPUs and memory. So if the CPUs are online, the node should 
be online.

And also,
The main purpose of this patch-set is to make the cpuid <-> nodeid 
mapping persistent.
After this patch-set, alloc_pages_node() and alloc_pages_exact_node() 
won't depend on
cpuid <-> nodeid mapping any more. So the node should be online if the 
CPUs on it are
online. Otherwise, we cannot setup interfaces of CPUs under /sys.


Unfortunately, since I don't have a machine a with memory-less node, I 
cannot reproduce
the problem right now.

How do you think the node online behavior should be changed ?

Thanks.





































--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
