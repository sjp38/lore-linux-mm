Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B37296B407A
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 08:31:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u129-v6so14821415qkf.15
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:31:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l34-v6sor7941158qkh.42.2018.08.27.05.31.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 05:31:37 -0700 (PDT)
Subject: Re: [PATCH 1/2] Revert "x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved"
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
 <20180824000325.GA20143@hori1.linux.bs1.fc.nec.co.jp>
 <20180824082908.GC29735@dhcp22.suse.cz>
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Message-ID: <ffce827a-c12e-591a-715e-ae3a152b1954@gmail.com>
Date: Mon, 27 Aug 2018 08:31:35 -0400
MIME-Version: 1.0
In-Reply-To: <20180824082908.GC29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, Pavel.Tatashin@microsoft.com
Cc: linux-mm@kvack.org, m.mizuma@jp.fujitsu.com, linux-kernel@vger.kernel.org, x86@kernel.org, osalvador@techadventures.net

Hi Pavel,

I would appreciate if you could send the feedback for the patch.

Thanks!
Masa

On 08/24/2018 04:29 AM, Michal Hocko wrote:
> On Fri 24-08-18 00:03:25, Naoya Horiguchi wrote:
>> (CCed related people)
> 
> Fixup Pavel email.
> 
>>
>> Hi Mizuma-san,
>>
>> Thank you for the report.
>> The mentioned patch was created based on feedbacks from reviewers/maintainers,
>> so I'd like to hear from them about how we should handle the issue.
>>
>> And one note is that there is a follow-up patch for "x86/e820: put !E820_TYPE_RAM
>> regions into memblock.reserved" which might be affected by your changes.
>>
>>> commit e181ae0c5db9544de9c53239eb22bc012ce75033
>>> Author: Pavel Tatashin <pasha.tatashin@oracle.com>
>>> Date:   Sat Jul 14 09:15:07 2018 -0400
>>>
>>>     mm: zero unavailable pages before memmap init
>>
>> Thanks,
>> Naoya Horiguchi
>>
>> On Thu, Aug 23, 2018 at 02:25:12PM -0400, Masayoshi Mizuma wrote:
>>> From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>>>
>>> commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
>>> memblock.reserved") breaks movable_node kernel option because it
>>> changed the memory gap range to reserved memblock. So, the node
>>> is marked as Normal zone even if the SRAT has Hot plaggable affinity.
>>>
>>>     =====================================================================
>>>     kernel: BIOS-e820: [mem 0x0000180000000000-0x0000180fffffffff] usable
>>>     kernel: BIOS-e820: [mem 0x00001c0000000000-0x00001c0fffffffff] usable
>>>     ...
>>>     kernel: reserved[0x12]#011[0x0000181000000000-0x00001bffffffffff], 0x000003f000000000 bytes flags: 0x0
>>>     ...
>>>     kernel: ACPI: SRAT: Node 2 PXM 6 [mem 0x180000000000-0x1bffffffffff] hotplug
>>>     kernel: ACPI: SRAT: Node 3 PXM 7 [mem 0x1c0000000000-0x1fffffffffff] hotplug
>>>     ...
>>>     kernel: Movable zone start for each node
>>>     kernel:  Node 3: 0x00001c0000000000
>>>     kernel: Early memory node ranges
>>>     ...
>>>     =====================================================================
>>>
>>> Naoya's v1 patch [*] fixes the original issue and this movable_node
>>> issue doesn't occur.
>>> Let's revert commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM
>>> regions into memblock.reserved") and apply the v1 patch.
>>>
>>> [*] https://lkml.org/lkml/2018/6/13/27
>>>
>>> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>>> ---
>>>  arch/x86/kernel/e820.c | 15 +++------------
>>>  1 file changed, 3 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
>>> index c88c23c658c1..d1f25c831447 100644
>>> --- a/arch/x86/kernel/e820.c
>>> +++ b/arch/x86/kernel/e820.c
>>> @@ -1248,7 +1248,6 @@ void __init e820__memblock_setup(void)
>>>  {
>>>  	int i;
>>>  	u64 end;
>>> -	u64 addr = 0;
>>>  
>>>  	/*
>>>  	 * The bootstrap memblock region count maximum is 128 entries
>>> @@ -1265,21 +1264,13 @@ void __init e820__memblock_setup(void)
>>>  		struct e820_entry *entry = &e820_table->entries[i];
>>>  
>>>  		end = entry->addr + entry->size;
>>> -		if (addr < entry->addr)
>>> -			memblock_reserve(addr, entry->addr - addr);
>>> -		addr = end;
>>>  		if (end != (resource_size_t)end)
>>>  			continue;
>>>  
>>> -		/*
>>> -		 * all !E820_TYPE_RAM ranges (including gap ranges) are put
>>> -		 * into memblock.reserved to make sure that struct pages in
>>> -		 * such regions are not left uninitialized after bootup.
>>> -		 */
>>>  		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
>>> -			memblock_reserve(entry->addr, entry->size);
>>> -		else
>>> -			memblock_add(entry->addr, entry->size);
>>> +			continue;
>>> +
>>> +		memblock_add(entry->addr, entry->size);
>>>  	}
>>>  
>>>  	/* Throw away partial pages: */
>>> -- 
>>> 2.18.0
>>>
>>>
> 
