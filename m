Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C99926B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 02:04:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id p82-v6so928238itc.0
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 23:04:02 -0700 (PDT)
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id z84-v6si2244116itf.77.2018.07.11.23.03.59
        for <linux-mm@kvack.org>;
        Wed, 11 Jul 2018 23:04:01 -0700 (PDT)
Date: Thu, 12 Jul 2018 14:01:15 +0800
From: Chao Fan <fanc.fnst@cn.fujitsu.com>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180712060115.GD6742@localhost.localdomain>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
 <20180711104944.GG1969@MiWiFi-R3L-srv>
 <20180711124008.GF2070@MiWiFi-R3L-srv>
 <72721138-ba6a-32c9-3489-f2060f40a4c9@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <72721138-ba6a-32c9-3489-f2060f40a4c9@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Baoquan He <bhe@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, fanc.fnst@cn.fujitsu.com

On Thu, Jul 12, 2018 at 01:49:49PM +0800, Dou Liyang wrote:
>Hi Baoquan,
>
>At 07/11/2018 08:40 PM, Baoquan He wrote:
>> Please try this v3 patch:
>> >>From 9850d3de9c02e570dc7572069a9749a8add4c4c7 Mon Sep 17 00:00:00 2001
>> From: Baoquan He <bhe@redhat.com>
>> Date: Wed, 11 Jul 2018 20:31:51 +0800
>> Subject: [PATCH v3] mm, page_alloc: find movable zone after kernel text
>> 
>> In find_zone_movable_pfns_for_nodes(), when try to find the starting
>> PFN movable zone begins in each node, kernel text position is not
>> considered. KASLR may put kernel after which movable zone begins.
>> 
>> Fix it by finding movable zone after kernel text on that node.
>> 
>> Signed-off-by: Baoquan He <bhe@redhat.com>
>
>
>You fix this in the _zone_init side_. This may make the 'kernelcore=' or
>'movablecore=' failed if the KASLR puts the kernel back the tail of the
>last node, or more.

I think it may not fail.
There is a 'restart' to do another pass.

>
>Due to we have fix the mirror memory in KASLR side, and Chao is trying
>to fix the 'movable_node' in KASLR side. Have you had a chance to fix
>this in the KASLR side.
>

I think it's better to fix here, but not KASLR side.
Cause much more code will be change if doing it in KASLR side.
Since we didn't parse 'kernelcore' in compressed code, and you can see
the distribution of ZONE_MOVABLE need so much code, so we do not need
to do so much job in KASLR side. But here, several lines will be OK.

Thanks,
Chao Fan

>
>> ---
>>   mm/page_alloc.c | 20 +++++++++++++++-----
>>   1 file changed, 15 insertions(+), 5 deletions(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 1521100..390eb35 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6547,7 +6547,7 @@ static unsigned long __init early_calculate_totalpages(void)
>>   static void __init find_zone_movable_pfns_for_nodes(void)
>>   {
>>   	int i, nid;
>> -	unsigned long usable_startpfn;
>> +	unsigned long usable_startpfn, real_startpfn;
>>   	unsigned long kernelcore_node, kernelcore_remaining;
>>   	/* save the state before borrow the nodemask */
>>   	nodemask_t saved_node_state = node_states[N_MEMORY];
>> @@ -6681,10 +6681,20 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>   			if (start_pfn >= end_pfn)
>>   				continue;
>> +			/*
>> +			 * KASLR may put kernel near tail of node memory,
>> +			 * start after kernel on that node to find PFN
>> +			 * which zone begins.
>> +			 */
>> +			if (pfn_to_nid(PFN_UP(_etext)) == i)
>
>Here, did you want to check the Node id? seems may be nid.
>
>and
>
>for_each_node_state(nid, N_MEMORY) {
>
>        ... seems check here is more suitable.
>
>	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, NULL) {
>
>	}
>}
>
>Thanks,
>	dou
>
>> +				real_startpfn = max(usable_startpfn,
>> +						PFN_UP(_etext))
>> +			else
>> +				real_startpfn = usable_startpfn;
>>   			/* Account for what is only usable for kernelcore */
>> -			if (start_pfn < usable_startpfn) {
>> +			if (start_pfn < real_startpfn) {
>>   				unsigned long kernel_pages;
>> -				kernel_pages = min(end_pfn, usable_startpfn)
>> +				kernel_pages = min(end_pfn, real_startpfn)
>>   								- start_pfn;
>>   				kernelcore_remaining -= min(kernel_pages,
>> @@ -6693,7 +6703,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>   							required_kernelcore);
>>   				/* Continue if range is now fully accounted */
>> -				if (end_pfn <= usable_startpfn) {
>> +				if (end_pfn <= real_startpfn) {
>>   					/*
>>   					 * Push zone_movable_pfn to the end so
>> @@ -6704,7 +6714,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>   					zone_movable_pfn[nid] = end_pfn;
>>   					continue;
>>   				}
>> -				start_pfn = usable_startpfn;
>> +				start_pfn = real_startpfn;
>>   			}
>>   			/*
>> 
