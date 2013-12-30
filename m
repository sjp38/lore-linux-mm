Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f177.google.com (mail-gg0-f177.google.com [209.85.161.177])
	by kanga.kvack.org (Postfix) with ESMTP id 68F016B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 06:16:28 -0500 (EST)
Received: by mail-gg0-f177.google.com with SMTP id 4so2278271ggm.8
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 03:16:28 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id z48si46267818yha.106.2013.12.30.03.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Dec 2013 03:16:27 -0800 (PST)
Message-ID: <52C1635D.9070703@ti.com>
Date: Mon, 30 Dec 2013 14:13:17 +0200
From: Grygorii Strashko <grygorii.strashko@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memblock: use WARN_ONCE when MAX_NUMNODES passed as
 input parameter
References: <1387578536-18280-1-git-send-email-santosh.shilimkar@ti.com> <alpine.DEB.2.02.1312261542260.9342@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1312261542260.9342@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>

On 12/27/2013 01:45 AM, David Rientjes wrote:
> On Fri, 20 Dec 2013, Santosh Shilimkar wrote:
>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 71b11d9..6af873a 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -707,11 +707,9 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
>>   	struct memblock_type *rsv = &memblock.reserved;
>>   	int mi = *idx & 0xffffffff;
>>   	int ri = *idx >> 32;
>> -	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
>>
>> -	if (nid == MAX_NUMNODES)
>> -		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
>> -			     __func__);
>> +	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
>> +		nid = NUMA_NO_NODE;
>>
>>   	for ( ; mi < mem->cnt; mi++) {
>>   		struct memblock_region *m = &mem->regions[mi];
>
> Um, why do this at runtime?  This is only used for
> for_each_free_mem_range(), which is used rarely in x86 and memblock-only
> code.  I'm struggling to understand why we can't deterministically fix the
> callers if this condition is possible.
>


Unfortunately, It's not so simple as from first look :(
We've modified __next_free_mem_range_x() functions which are part of
Memblock APIs (like memblock_alloc_xxx()) and Nobootmem APIs.
These APIs are used as directly as indirectly (as part of callbacks from 
other MM modules like Sparse), as result, it's not trivial to identify 
all places where MAX_NUMNODES will be used as input parameter.

Same was discussed here in details:
- [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
   https://lkml.org/lkml/2013/12/2/1075
- Re: [PATCH 09/24] mm/memblock: Add memblock memory allocation apis
   https://lkml.org/lkml/2013/12/2/907

Regards,
- grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
