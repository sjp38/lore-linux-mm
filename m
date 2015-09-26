Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 359296B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 05:32:55 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so127970856pac.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 02:32:55 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id rs4si11483775pbb.50.2015.09.26.02.32.53
        for <linux-mm@kvack.org>;
        Sat, 26 Sep 2015 02:32:54 -0700 (PDT)
Message-ID: <560665DB.7020301@cn.fujitsu.com>
Date: Sat, 26 Sep 2015 17:31:07 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/7] x86, gfp: Cache best near node for memory allocation.
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com> <1441859269-25831-4-git-send-email-tangchen@cn.fujitsu.com> <20150910192935.GI8114@mtj.duckdns.org>
In-Reply-To: <20150910192935.GI8114@mtj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tangchen@cn.fujitsu.com

Hi, tj

On 09/11/2015 03:29 AM, Tejun Heo wrote:
> Hello,
>
> On Thu, Sep 10, 2015 at 12:27:45PM +0800, Tang Chen wrote:
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index ad35f30..1a1324f 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -307,13 +307,19 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>>   	if (nid < 0)
>>   		nid = numa_node_id();
>>   
>> +	if (!node_online(nid))
>> +		nid = get_near_online_node(nid);
>> +
>>   	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>>   }
> Why not just update node_data[]->node_zonelist in the first place?

zonelist will be rebuilt in __offline_pages() when the zone is not 
populated any more.

Here, getting the best near online node is for those cpus on memory-less 
nodes.

In the original code, if nid is NUMA_NO_NODE, the node the current cpu 
resides in
will be chosen. And if the node is memory-less node, the cpu will be 
mapped to its
best near online node.

But this patch-set will map the cpu to its original node, so 
numa_node_id() may return
a memory-less node to allocator. And then memory allocation may fail.

> Also, what's the synchronization rule here?  How are allocators
> synchronized against node hot [un]plugs?

The rule is: node_to_near_node_map[] array will be updated each time 
node [un]hotplug happens.

Now it is not protected by a lock. But I think acquiring a lock may 
cause performance regression
to memory allocator.

When rebuilding zonelist, stop_machine is used. So I think maybe 
updating the
node_to_near_node_map[] array at the same time when zonelist is rebuilt 
could be a good idea.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
