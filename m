Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C86256B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 16:49:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e24-v6so18263306pga.16
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 13:49:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 22-v6si275710pgs.410.2018.10.16.13.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 13:49:15 -0700 (PDT)
Subject: Re: [mm PATCH v3 2/6] mm: Drop meminit_pfn_in_nid as it is redundant
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202703.2171.40829.stgit@localhost.localdomain>
 <a21c1827-10ad-8ff5-c8b6-e34a3f1e8b80@gmail.com>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <e4f806d4-2527-07c2-56bc-9c41789d669c@linux.intel.com>
Date: Tue, 16 Oct 2018 13:49:14 -0700
MIME-Version: 1.0
In-Reply-To: <a21c1827-10ad-8ff5-c8b6-e34a3f1e8b80@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 10/16/2018 1:33 PM, Pavel Tatashin wrote:
> 
> 
> On 10/15/18 4:27 PM, Alexander Duyck wrote:
>> As best as I can tell the meminit_pfn_in_nid call is completely redundant.
>> The deferred memory initialization is already making use of
>> for_each_free_mem_range which in turn will call into __next_mem_range which
>> will only return a memory range if it matches the node ID provided assuming
>> it is not NUMA_NO_NODE.
>>
>> I am operating on the assumption that there are no zones or pgdata_t
>> structures that have a NUMA node of NUMA_NO_NODE associated with them. If
>> that is the case then __next_mem_range will never return a memory range
>> that doesn't match the zone's node ID and as such the check is redundant.
>>
>> So one piece I would like to verfy on this is if this works for ia64.
>> Technically it was using a different approach to get the node ID, but it
>> seems to have the node ID also encoded into the memblock. So I am
>> assuming this is okay, but would like to get confirmation on that.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> If I am not mistaken, this code is for systems with memory interleaving.
> Quick looks shows that x86, powerpc, s390, and sparc have it set.
> 
> I am not sure about other arches, but at least on SPARC, there are some
> processors with memory interleaving feature:
> 
> http://www.fujitsu.com/global/products/computing/servers/unix/sparc-enterprise/technology/performance/memory.html
> 
> Pavel

I get what it is for. However as best I can tell the check is actually 
redundant. In the case of the deferred page initialization we are 
already pulling the memory regions via "for_each_free_mem_range". That 
function is already passed a NUMA node ID. Because of that we are 
already checking the memory range to determine if it is in the node or 
not. As such it doesn't really make sense to go through for each PFN and 
then go back to the memory range and see if the node matches or not.

You can take a look at __next_mem_range which is called by 
for_each_free_mem_range and passed &memblock.memory and 
&memblock.reserved to avoid:
https://elixir.bootlin.com/linux/latest/source/mm/memblock.c#L899

Then you can work your way through:
meminit_pfn_in_nid(pfn, node, state)
  __early_pfn_to_nid(pfn, state)
   memblock_search_pfn_nid(pfn, &start_pfn, &end_pfn)
    memblock_search(&memblock.memory, pfn)

 From what I can tell the deferred init is going back through the 
memblock.memory list we pulled this range from and just validating it 
against itself. This makes sense for the standard init as that is just 
going from start_pfn->end_pfn, but for the deferred init we are pulling 
the memory ranges ahead of time so we shouldn't need to re-validate the 
memory that is contained within that range.
