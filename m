Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C05D6B0022
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:35:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u188so1436085pfb.6
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:35:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor1024673pgv.407.2018.03.28.06.35.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 06:35:09 -0700 (PDT)
Date: Wed, 28 Mar 2018 21:34:56 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: optimize find_min_pfn_for_node() by
 geting the minimal pfn directly
Message-ID: <20180328133456.GB543@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180327183757.f66f5fc200109c06b7a4b620@linux-foundation.org>
 <20180328034752.96146-1-richard.weiyang@gmail.com>
 <20180328115853.GI9275@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328115853.GI9275@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed, Mar 28, 2018 at 01:58:53PM +0200, Michal Hocko wrote:
>On Wed 28-03-18 11:47:52, Wei Yang wrote:
>[...]
>> +/**
>> + * first_mem_pfn - get the first memory pfn
>> + * @i: an integer used as an indicator
>> + * @nid: node selector, %MAX_NUMNODES for all nodes
>> + * @p_first: ptr to ulong for first pfn of the range, can be %NULL
>> + */
>> +#define first_mem_pfn(i, nid, p_first)				\
>> +	__next_mem_pfn_range(&i, nid, p_first, NULL, NULL)
>> +
>
>Is this really something that we want to export to all users? And if
>that is the case is the documenation really telling user how to use it?
>

Yep, I am not good at the documentation. I really struggled a while on it, but
you know it still looks not that good.

How about changing the document to the following in case this macro is still
alive.

/**
 * first_mem_pfn - get the first memory pfn after index i on node nid
 * @i: index to memblock.memory.regions
 * @nid: node selector, %MAX_NUMNODES for all nodes
 * @p_first: ptr to ulong for first pfn of the range, can be %NULL
 */

>>  /**
>>   * for_each_mem_pfn_range - early memory pfn range iterator
>>   * @i: an integer used as loop variable
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 635d7dd29d7f..8c964dcc3a9e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6365,14 +6365,16 @@ unsigned long __init node_map_pfn_alignment(void)
>>  /* Find the lowest pfn for a node */
>>  static unsigned long __init find_min_pfn_for_node(int nid)
>>  {
>> -	unsigned long min_pfn = ULONG_MAX;
>> -	unsigned long start_pfn;
>> -	int i;
>> +	unsigned long min_pfn;
>> +	int i = -1;
>>  
>> -	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
>> -		min_pfn = min(min_pfn, start_pfn);
>> +	/*
>> +	 * The first pfn on nid node is the minimal one, as the pfn's are
>> +	 * stored in ascending order.
>> +	 */
>> +	first_mem_pfn(i, nid, &min_pfn);
>>  
>> -	if (min_pfn == ULONG_MAX) {
>> +	if (i == -1) {
>>  		pr_warn("Could not find start_pfn for node %d\n", nid);
>>  		return 0;
>>  	}
>
>I would just open code it. Other than that I strongly suspect this will
>not have any measurable impact becauser we usually only have handfull of
>memory ranges but why not. Just make the new implementation less ugly
>than it is cuurrently - e.g. opencode first_mem_pfn and you can add

Open code here means use __next_mem_pfn_range() directly instead of using
first_mem_pfn()?

>Acked-by: Michal Hocko <mhocko@suse.com>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
