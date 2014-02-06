Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2570C6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 05:29:18 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id u57so1155052wes.11
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 02:29:17 -0800 (PST)
Received: from mail-we0-x22f.google.com (mail-we0-x22f.google.com [2a00:1450:400c:c03::22f])
        by mx.google.com with ESMTPS id w15si783119wie.79.2014.02.06.02.29.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 02:29:16 -0800 (PST)
Received: by mail-we0-f175.google.com with SMTP id q59so1130742wes.20
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 02:29:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
References: <20140206020757.GC5433@linux.vnet.ibm.com>
	<1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
Date: Thu, 6 Feb 2014 19:29:16 +0900
Message-ID: <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

2014-02-06 David Rientjes <rientjes@google.com>:
> On Thu, 6 Feb 2014, Joonsoo Kim wrote:
>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>
> I may be misunderstanding this patch and there's no help because there's
> no changelog.

Sorry about that.
I made this patch just for testing. :)
Thanks for looking this.

>> diff --git a/include/linux/topology.h b/include/linux/topology.h
>> index 12ae6ce..a6d5438 100644
>> --- a/include/linux/topology.h
>> +++ b/include/linux/topology.h
>> @@ -233,11 +233,20 @@ static inline int numa_node_id(void)
>>   * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
>>   */
>>  DECLARE_PER_CPU(int, _numa_mem_);
>> +int _node_numa_mem_[MAX_NUMNODES];
>>
>>  #ifndef set_numa_mem
>>  static inline void set_numa_mem(int node)
>>  {
>>       this_cpu_write(_numa_mem_, node);
>> +     _node_numa_mem_[numa_node_id()] = node;
>> +}
>> +#endif
>> +
>> +#ifndef get_numa_mem
>> +static inline int get_numa_mem(int node)
>> +{
>> +     return _node_numa_mem_[node];
>>  }
>>  #endif
>>
>> @@ -260,6 +269,7 @@ static inline int cpu_to_mem(int cpu)
>>  static inline void set_cpu_numa_mem(int cpu, int node)
>>  {
>>       per_cpu(_numa_mem_, cpu) = node;
>> +     _node_numa_mem_[numa_node_id()] = node;
>
> The intention seems to be that _node_numa_mem_[X] for a node X will return
> a node Y with memory that has the nearest distance?  In other words,
> caching the value returned by local_memory_node(X)?

Yes, you are right.

> That doesn't seem to be what it's doing since numa_node_id() is the node
> of the cpu that current is running on so this ends up getting initialized
> to whatever local_memory_node(cpu_to_node(cpu)) is for the last bit set in
> cpu_possible_mask.

Yes, I made a mistake.
Thanks for pointer.
I fix it and attach v2.
Now I'm out of office, so I'm not sure this second version is correct :(

Thanks.

----------8<--------------
