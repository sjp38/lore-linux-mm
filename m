Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9A96B0010
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 20:51:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u1-v6so500455pls.16
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 17:51:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21sor628650pfn.115.2018.03.27.17.51.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 17:51:49 -0700 (PDT)
Date: Wed, 28 Mar 2018 08:51:42 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: break on the first hit of mem range
Message-ID: <20180328005142.GC91956@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180327035707.84113-1-richard.weiyang@gmail.com>
 <20180327154740.9a7713a74a383254b51f4d1a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180327154740.9a7713a74a383254b51f4d1a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, tj@kernel.org, linux-mm@kvack.org

On Tue, Mar 27, 2018 at 03:47:40PM -0700, Andrew Morton wrote:
>On Tue, 27 Mar 2018 11:57:07 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> find_min_pfn_for_node() iterate on pfn range to find the minimum pfn for a
>> node. The memblock_region in memblock_type are already ordered, which means
>> the first hit in iteration is the minimum pfn.
>> 
>> This patch returns the fist hit instead of iterating the whole regions.
>> 
>> ...
>>
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
>
>That would be the weirdest-looking code snippet in mm/!
>

You mean the only break in a for_each loop? Hmm..., this is really not that
nice. Haven't noticed could get a "best" in this way :-)

>Can't we just use a single and simple call to __next_mem_pfn_range(),
>or something like that?
>

Sounds a better choice, if you like this version, I would rearrange the patch
and send v2.

Have a nice day~

>>
>> ...
>>

-- 
Wei Yang
Help you, Help me
