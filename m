Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7666B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:05:44 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id m10-v6so11706171uao.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:05:44 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d26-v6si11599493uak.239.2018.07.16.10.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:05:43 -0700 (PDT)
Subject: Re: [PATCH] mm: don't do zero_resv_unavail if memmap is not allocated
References: <20180716151630.770-1-pasha.tatashin@oracle.com>
 <20180716160956.GW17280@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <4a4bd630-94f1-ab0b-6516-0955de9b0281@oracle.com>
Date: Mon, 16 Jul 2018 13:05:36 -0400
MIME-Version: 1.0
In-Reply-To: <20180716160956.GW17280@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org



On 07/16/2018 12:09 PM, Michal Hocko wrote:
> On Mon 16-07-18 11:16:30, Pavel Tatashin wrote:
>> Moving zero_resv_unavail before memmap_init_zone(), caused a regression on
>> x86-32.
>>
>> The cause is that we access struct pages before they are allocated when
>> CONFIG_FLAT_NODE_MEM_MAP is used.
>>
>> free_area_init_nodes()
>>   zero_resv_unavail()
>>     mm_zero_struct_page(pfn_to_page(pfn)); <- struct page is not alloced
>>   free_area_init_node()
>>     if CONFIG_FLAT_NODE_MEM_MAP
>>       alloc_node_mem_map()
>>         memblock_virt_alloc_node_nopanic() <- struct page alloced here
>>
>> On the other hand memblock_virt_alloc_node_nopanic() zeroes all the memory
>> that it returns, so we do not need to do zero_resv_unavail() here.
> 
> This all is subtle as hell and almost impossible to build a sane code on
> top. Your patch sounds good as a stop gap fix but we really need
> something resembling an actual design rather than ad-hoc hacks piled on
> top of each other.z

I totally agree, I started working on figuring out how to simply and improve memmap_init_zone(). But part of the mess is that we simply have too many memmap layouts. We must start removing some of them. But, that also requires an analysis of how to unify them.

> 
>> Fixes: e181ae0c5db9 ("mm: zero unavailable pages before memmap init")
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 

Thank you.

Pavel
