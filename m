Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADDF6B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:29:04 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id h7so4278973otm.4
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 12:29:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r3-v6si2633453oia.78.2018.10.24.12.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 12:29:02 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9OJJEsi069030
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:29:01 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nax6ythg0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:29:01 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.bm.com>;
	Wed, 24 Oct 2018 13:29:00 -0600
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz> <20180912150356.642c1dab@thinkpad>
 <20180912133933.GI10951@dhcp22.suse.cz> <20180912162717.5a018bf6@thinkpad>
 <38ce1d0b-14bd-9a4a-1061-62c366cb11b5@microsoft.com>
From: Zaslonko Mikhail <zaslonko@linux.bm.com>
Date: Wed, 24 Oct 2018 21:28:51 +0200
MIME-Version: 1.0
In-Reply-To: <38ce1d0b-14bd-9a4a-1061-62c366cb11b5@microsoft.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <83c1d934-c74c-c469-8472-de21ebbf6e46@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, schwidefsky@de.ibm.com

Hello,

I hope it's still possible to revive this thread. Please find my comments below.

On 12.09.2018 16:40, Pasha Tatashin wrote:
> 
> 
> On 9/12/18 10:27 AM, Gerald Schaefer wrote:
>> On Wed, 12 Sep 2018 15:39:33 +0200
>> Michal Hocko <mhocko@kernel.org> wrote:
>>
>>> On Wed 12-09-18 15:03:56, Gerald Schaefer wrote:
>>> [...]
>>>> BTW, those sysfs attributes are world-readable, so anyone can trigger
>>>> the panic by simply reading them, or just run lsmem (also available for
>>>> x86 since util-linux 2.32). OK, you need a special not-memory-block-aligned
>>>> mem= parameter and DEBUG_VM for poison check, but w/o DEBUG_VM you would
>>>> still access uninitialized struct pages. This sounds very wrong, and I
>>>> think it really should be fixed.
>>>
>>> Ohh, absolutely. Nobody is questioning that. The thing is that the
>>> code has been likely always broken. We just haven't noticed because
>>> those unitialized parts where zeroed previously. Now that the implicit
>>> zeroying is gone it is just visible.
>>>
>>> All that I am arguing is that there are many places which assume
>>> pageblocks to be fully initialized and plugging one place that blows up
>>> at the time is just whack a mole. We need to address this much earlier.
>>> E.g. by allowing only full pageblocks when adding a memory range.
>>
>> Just to make sure we are talking about the same thing: when you say
>> "pageblocks", do you mean the MAX_ORDER_NR_PAGES / pageblock_nr_pages
>> unit of pages, or do you mean the memory (hotplug) block unit?
> 
>  From early discussion, it was about pageblock_nr_pages not about
> memory_block_size_bytes
> 
>>
>> I do not see any issue here with MAX_ORDER_NR_PAGES / pageblock_nr_pages
>> pageblocks, and if there was such an issue, of course you are right that
>> this would affect many places. If there was such an issue, I would also
>> assume that we would see the new page poison warning in many other places.
>>
>> The bug that Mikhails patch would fix only affects code that operates
>> on / iterates through memory (hotplug) blocks, and that does not happen
>> in many places, only in the two functions that his patch fixes.
> 
> Just to be clear, so memory is pageblock_nr_pages aligned, yet
> memory_block are larger and panic is still triggered?
> 
> I ask, because 3075M is not 128M aligned.
> 
>>
>> When you say "address this much earlier", do you mean changing the way
>> that free_area_init_core()/memmap_init() initialize struct pages, i.e.
>> have them not use zone->spanned_pages as limit, but rather align that
>> up to the memory block (not pageblock) boundary?
>>
> 
> This was my initial proposal, to fix memmap_init() and initialize struct
> pages beyond the "end", and before the "start" to cover the whole
> section. But, I think Michal suggested (and he might correct me) to
> simply ignore unaligned memory to section memory much earlier: so
> anything that does not align to sparse order is not added at all to the
> system.
> 

I tried both approaches but each of them has issues.

First I tried to ignore unaligned memory early by adjusting memory_end value. 
But the thing is that kernel mem parameter parsing and memory_end calculation 
take place in the architecture code and adjusting it afterwards in common code 
might be too late in my view. Also with this approach we might lose the memory 
up to the entire section(256Mb on s390) just because of unfortunate alignment.

Another approach was "to fix memmap_init() and initialize struct pages beyond 
the end". Since struct pages are allocated section-wise we can try to
round the size parameter passed to the memmap_init() function up to the 
section boundary thus forcing the mapping initialization for the entire 
section. But then it leads to another VM_BUG_ON panic due to zone_spans_pfn() 
sanity check triggered for the first page of each page block from 
set_pageblock_migratetype() function.
     page dumped because: VM_BUG_ON_PAGE(!zone_spans_pfn(page_zone(page), pfn))
      Call Trace: 

      ([<00000000003013f8>] set_pfnblock_flags_mask+0xe8/0x140) 

       [<00000000003014aa>] set_pageblock_migratetype+0x5a/0x70 

       [<0000000000bef706>] memmap_init_zone+0x25e/0x2e0 

       [<00000000010fc3d8>] free_area_init_node+0x530/0x558 

       [<00000000010fcf02>] free_area_init_nodes+0x81a/0x8f0 

       [<00000000010e7fdc>] paging_init+0x124/0x130 

       [<00000000010e4dfa>] setup_arch+0xbf2/0xcc8 

       [<00000000010de9e6>] start_kernel+0x7e/0x588 

       [<000000000010007c>] startup_continue+0x7c/0x300 

      INFO: lockdep is turned off. 

      Last Breaking-Event-Address: 

       [<00000000003013f8>] set_pfnblock_flags_mask+0xe8/0x140
We might ignore this check for the struct pages beyond the "end" but I'm not 
sure about further implications.
Why don't we stay for now with my original proposal fixing specific functions 
for memory hotplug sysfs handlers. Please, tell me what you think.

Thanks,
Mikhail Zaslonko
