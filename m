Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47D106B0253
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:00:32 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so155833181lfw.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:00:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si7917357wma.123.2016.08.05.02.09.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 02:09:19 -0700 (PDT)
Subject: Re: [PATCH V2 1/2] mm/page_alloc: Replace set_dma_reserve to
 set_memory_reserve
References: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
 <09d5b30e-5956-bf64-5f4c-ea5425d7f7a5@suse.cz>
 <20160805072450.GE11268@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ac7c8d81-ffe2-a70b-4219-c0b43623ab3b@suse.cz>
Date: Fri, 5 Aug 2016 11:09:15 +0200
MIME-Version: 1.0
In-Reply-To: <20160805072450.GE11268@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

On 08/05/2016 09:24 AM, Srikar Dronamraju wrote:
> * Vlastimil Babka <vbabka@suse.cz> [2016-08-05 08:45:03]:
>
>>> @@ -5493,10 +5493,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>>> 		}
>>>
>>> 		/* Account for reserved pages */
>>> -		if (j == 0 && freesize > dma_reserve) {
>>> -			freesize -= dma_reserve;
>>> +		if (j == 0 && freesize > nr_memory_reserve) {
>>
>> Will this really work (together with patch 2) as intended?
>> This j == 0 means that we are doing this only for the first zone, which is
>> ZONE_DMA (or ZONE_DMA32) on node 0 on many systems. I.e. I don't think it's
>> really true that "dma_reserve has nothing to do with DMA or ZONE_DMA".
>>
>> This zone will have limited amount of memory, so the "freesize >
>> nr_memory_reserve" will easily be false once you set this to many gigabytes,
>> so in fact nothing will get subtracted.
>>
>> On the other hand if the kernel has both CONFIG_ZONE_DMA and
>> CONFIG_ZONE_DMA32 disabled, then j == 0 will be true for ZONE_NORMAL. This
>> zone might be present on multiple nodes (unless they are configured as
>> movable) and then the value intended to be global will be subtracted from
>> several nodes.
>>
>> I don't know what's the exact ppc64 situation here, perhaps there are indeed
>> no DMA/DMA32 zones, and the fadump kernel only uses one node, so it works in
>> the end, but it doesn't seem much robust to me?
>>
>
> At the page initialization time, powerpc seems to have just one zone
> spread across the 16 nodes.
>
> From the dmesg.
>
> [    0.000000] Memory hole size: 0MB
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000000000-0x00001f5c8fffffff]
> [    0.000000]   DMA32    empty
> [    0.000000]   Normal   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000000000-0x000001fb4fffffff]
> [    0.000000]   node   1: [mem 0x000001fb50000000-0x000003fa8fffffff]
> [    0.000000]   node   2: [mem 0x000003fa90000000-0x000005f9cfffffff]
> [    0.000000]   node   3: [mem 0x000005f9d0000000-0x000007f8efffffff]
> [    0.000000]   node   4: [mem 0x000007f8f0000000-0x000009f81fffffff]
> [    0.000000]   node   5: [mem 0x000009f820000000-0x00000bf77fffffff]
> [    0.000000]   node   6: [mem 0x00000bf780000000-0x00000df6dfffffff]
> [    0.000000]   node   7: [mem 0x00000df6e0000000-0x00000ff63fffffff]
> [    0.000000]   node   8: [mem 0x00000ff640000000-0x000011f58fffffff]
> [    0.000000]   node   9: [mem 0x000011f590000000-0x000013644fffffff]
> [    0.000000]   node  10: [mem 0x0000136450000000-0x00001563afffffff]
> [    0.000000]   node  11: [mem 0x00001563b0000000-0x000017630fffffff]
> [    0.000000]   node  12: [mem 0x0000176310000000-0x000019625fffffff]
> [    0.000000]   node  13: [mem 0x0000196260000000-0x00001b5dcfffffff]
> [    0.000000]   node  14: [mem 0x00001b5dd0000000-0x00001d5d2fffffff]
> [    0.000000]   node  15: [mem 0x00001d5d30000000-0x00001f5c8fffffff]

Hmm so it will work for ppc64 and its fadump, but I'm not happy that we 
made the function name sound like it's generic (unlike when the name 
contained "dma"), while it only works as intended in specific corner 
cases. The next user might be surprised...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
