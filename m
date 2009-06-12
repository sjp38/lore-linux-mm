Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BDDDB6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:02:56 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n5D0vsY8018791
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 10:57:54 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5CF2pP41151018
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 01:02:54 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5CF2okx032646
	for <linux-mm@kvack.org>; Sat, 13 Jun 2009 01:02:51 +1000
Message-ID: <4A326E16.2000001@linux.vnet.ibm.com>
Date: Fri, 12 Jun 2009 20:32:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: boot panic with memcg enabled (Was [PATCH 3/4] memcg: don't use
 bootmem allocator in setup code)
References: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI> <4A31C258.2050404@cn.fujitsu.com>
In-Reply-To: <4A31C258.2050404@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, yinghai@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> (This patch should have CCed memcg maitainers)
> 
> My box failed to boot due to initialization failure of page_cgroup, and
> it's caused by this patch:
> 
> +	page = alloc_pages_node(nid, GFP_NOWAIT | __GFP_ZERO, order);
> 
> I added a printk, and found that order == 11 == MAX_ORDER.
> 
> Pekka J Enberg wrote:
>> From: Yinghai Lu <yinghai@kernel.org>
>>
>> The bootmem allocator is no longer available for page_cgroup_init() because we
>> set up the kernel slab allocator much earlier now.
>>
>> Cc: Ingo Molnar <mingo@elte.hu>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
>> ---
>>  mm/page_cgroup.c |   12 ++++++++----
>>  1 files changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
>> index 791905c..3dd4a90 100644
>> --- a/mm/page_cgroup.c
>> +++ b/mm/page_cgroup.c
>> @@ -47,6 +47,8 @@ static int __init alloc_node_page_cgroup(int nid)
>>  	struct page_cgroup *base, *pc;
>>  	unsigned long table_size;
>>  	unsigned long start_pfn, nr_pages, index;
>> +	struct page *page;
>> +	unsigned int order;
>>  
>>  	start_pfn = NODE_DATA(nid)->node_start_pfn;
>>  	nr_pages = NODE_DATA(nid)->node_spanned_pages;
>> @@ -55,11 +57,13 @@ static int __init alloc_node_page_cgroup(int nid)
>>  		return 0;
>>  
>>  	table_size = sizeof(struct page_cgroup) * nr_pages;
>> -
>> -	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
>> -			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
>> -	if (!base)
>> +	order = get_order(table_size);
>> +	page = alloc_pages_node(nid, GFP_NOWAIT | __GFP_ZERO, order);
>> +	if (!page)
>> +		page = alloc_pages_node(-1, GFP_NOWAIT | __GFP_ZERO, order);

This should potentially come with a KERN_WARNING indicating the page_cgroup now
is allocated out of the current node rather than the desired node. It'll help
debug potential issues later.

>> +	if (!page)
>>  		return -ENOMEM;
>> +	base = page_address(page);
>>  	for (index = 0; index < nr_pages; index++) {
>>  		pc = base + index;
>>  		__init_page_cgroup(pc, start_pfn + index);

Looks good to me, does it work for you, Yinghai? Kamezawa-San  could you take a look


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
