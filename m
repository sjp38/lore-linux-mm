Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id D731E82F6B
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 16:25:46 -0400 (EDT)
Received: by igxx6 with SMTP id x6so66188837igx.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 13:25:46 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id 75si19745881ioq.70.2015.10.05.13.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 13:25:46 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so46105021pad.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 13:25:45 -0700 (PDT)
Subject: Re: [PATCH] ovs: do not allocate memory from offline numa node
References: <20151002101822.12499.27658.stgit@buzz> <56128238.8010305@suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <5612DCC8.4040605@gmail.com>
Date: Mon, 5 Oct 2015 13:25:44 -0700
MIME-Version: 1.0
In-Reply-To: <56128238.8010305@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/05/2015 06:59 AM, Vlastimil Babka wrote:
> On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
>> When openvswitch tries allocate memory from offline numa node 0:
>> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | 
>> __GFP_ZERO, 0)
>> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || 
>> !node_online(nid))
>> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
>> This patch disables numa affinity in this case.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> ...
>
>> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
>> index f2ea83ba4763..c7f74aab34b9 100644
>> --- a/net/openvswitch/flow_table.c
>> +++ b/net/openvswitch/flow_table.c
>> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>
>>       /* Initialize the default stat node. */
>>       stats = kmem_cache_alloc_node(flow_stats_cache,
>> -                      GFP_KERNEL | __GFP_ZERO, 0);
>> +                      GFP_KERNEL | __GFP_ZERO,
>> +                      node_online(0) ? 0 : NUMA_NO_NODE);
>
> Stupid question: can node 0 become offline between this check, and the 
> VM_WARN_ON? :) BTW what kind of system has node 0 offline?

Another question to ask would be is it possible for node 0 to be online, 
but be a memoryless node?

I would say you are better off just making this call kmem_cache_alloc.  
I don't see anything that indicates the memory has to come from node 0, 
so adding the extra overhead doesn't provide any value.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
