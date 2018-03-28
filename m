Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBAEE6B000D
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 20:39:45 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m6-v6so487299pln.8
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 17:39:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p190sor718198pga.197.2018.03.27.17.39.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 17:39:44 -0700 (PDT)
Date: Wed, 28 Mar 2018 08:39:36 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-ID: <20180328003936.GB91956@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
 <20180327105821.GF5652@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180327105821.GF5652@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Tue, Mar 27, 2018 at 12:58:21PM +0200, Michal Hocko wrote:
>On Tue 27-03-18 11:57:07, Wei Yang wrote:
>> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
>> node. The memblock_region in memblock_type are already ordered, which means
>> the first hit in iteration is the minimum pfn.
>
>I haven't looked at the code yet but the changelog should contain the
>motivation why it exists. It seems like this is an optimization. If so,
>what is the impact?
>

Yep, this is a trivial optimization on searching the minimal pfn on a special
node. It would be better for audience to understand if I put some words in
change log.

The impact of this patch is it would accelerate the searching process when
there are many memory ranges in memblock.

For example, in the case https://lkml.org/lkml/2018/3/25/291, there are around
30 memory ranges on node 0. The original code need to iterate all those ranges
to find the minimal pfn, while after optimization it just need once.

The more memory ranges there are, the more impact this patch has.

>> This patch returns the fist hit instead of iterating the whole regions.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/page_alloc.c | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 635d7dd29d7f..a65de1ec4b91 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6365,14 +6365,14 @@ unsigned long __init node_map_pfn_alignment(void)
>>  /* Find the lowest pfn for a node */
>>  static unsigned long __init find_min_pfn_for_node(int nid)
>>  {
>> -	unsigned long min_pfn = ULONG_MAX;
>> -	unsigned long start_pfn;
>> +	unsigned long min_pfn;
>>  	int i;
>>  
>> -	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
>> -		min_pfn = min(min_pfn, start_pfn);
>> +	for_each_mem_pfn_range(i, nid, &min_pfn, NULL, NULL) {
>> +		break;
>> +	}
>>  
>> -	if (min_pfn == ULONG_MAX) {
>> +	if (i == -1) {
>>  		pr_warn("Could not find start_pfn for node %d\n", nid);
>>  		return 0;
>>  	}
>> -- 
>> 2.15.1
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
