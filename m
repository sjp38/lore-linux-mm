Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF1A6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 00:50:22 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id r203so11068000ykd.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 21:50:22 -0800 (PST)
Received: from mail-yk0-x244.google.com (mail-yk0-x244.google.com. [2607:f8b0:4002:c07::244])
        by mx.google.com with ESMTPS id z62si2089802yba.7.2016.03.08.21.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 21:50:21 -0800 (PST)
Received: by mail-yk0-x244.google.com with SMTP id w83so1097855ykf.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 21:50:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56DFA66F.2020002@gmail.com>
References: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
	<56DEE59F.7020602@gmail.com>
	<CAD8of+o9zbwae-JM2EtcEnUyZAr43+jQLz1YSVZVKfda+h+Xvg@mail.gmail.com>
	<56DFA66F.2020002@gmail.com>
Date: Wed, 9 Mar 2016 13:50:21 +0800
Message-ID: <CAD8of+o8u_vhvcO3EeL4a7jgmG1xL4yoXv9+dCK1s2c_6uJVww@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: Enable page parallel initialisation for Power
From: Li Zhang <zhlcindy@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Michael Ellerman <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On Wed, Mar 9, 2016 at 12:28 PM, Balbir Singh <bsingharora@gmail.com> wrote:
>
>
> On 09/03/16 15:17, Li Zhang wrote:
>> On Tue, Mar 8, 2016 at 10:45 PM, Balbir Singh <bsingharora@gmail.com> wrote:
>>>
>>> On 08/03/16 14:55, Li Zhang wrote:
>>>> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
>>>>
>>>> Uptream has supported page parallel initialisation for X86 and the
>>>> boot time is improved greately. Some tests have been done for Power.
>>>>
>>>> Here is the result I have done with different memory size.
>>>>
>>>> * 4GB memory:
>>>>     boot time is as the following:
>>>>     with patch vs without patch: 10.4s vs 24.5s
>>>>     boot time is improved 57%
>>>> * 200GB memory:
>>>>     boot time looks the same with and without patches.
>>>>     boot time is about 38s
>>>> * 32TB memory:
>>>>     boot time looks the same with and without patches
>>>>     boot time is about 160s.
>>>>     The boot time is much shorter than X86 with 24TB memory.
>>>>     From community discussion, it costs about 694s for X86 24T system.
>>>>
>>>> From code view, parallel initialisation improve the performance by
>>>> deferring memory initilisation to kswap with N kthreads, it should
>>>> improve the performance therotically.
>>>>
>>>> From the test result, On X86, performance is improved greatly with huge
>>>> memory. But on Power platform, it is improved greatly with less than
>>>> 100GB memory. For huge memory, it is not improved greatly. But it saves
>>>> the time with several threads at least, as the following information
>>>> shows(32TB system log):
>>>>
>>>> [   22.648169] node 9 initialised, 16607461 pages in 280ms
>>>> [   22.783772] node 3 initialised, 23937243 pages in 410ms
>>>> [   22.858877] node 6 initialised, 29179347 pages in 490ms
>>>> [   22.863252] node 2 initialised, 29179347 pages in 490ms
>>>> [   22.907545] node 0 initialised, 32049614 pages in 540ms
>>>> [   22.920891] node 15 initialised, 32212280 pages in 550ms
>>>> [   22.923236] node 4 initialised, 32306127 pages in 550ms
>>>> [   22.923384] node 12 initialised, 32314319 pages in 550ms
>>>> [   22.924754] node 8 initialised, 32314319 pages in 550ms
>>>> [   22.940780] node 13 initialised, 33353677 pages in 570ms
>>>> [   22.940796] node 11 initialised, 33353677 pages in 570ms
>>>> [   22.941700] node 5 initialised, 33353677 pages in 570ms
>>>> [   22.941721] node 10 initialised, 33353677 pages in 570ms
>>>> [   22.941876] node 7 initialised, 33353677 pages in 570ms
>>>> [   22.944946] node 14 initialised, 33353677 pages in 570ms
>>>> [   22.946063] node 1 initialised, 33345485 pages in 580ms
>>>>
>>>> It saves the time about 550*16 ms at least, although it can be ignore to compare
>>>> the boot time about 160 seconds. What's more, the boot time is much shorter
>>>> on Power even without patches than x86 for huge memory machine.
>>>>
>>>> So this patchset is still necessary to be enabled for Power.
>>>>
>>>>
>> Hi Balbir,
>>
>> Thanks for your reviewing.
>>
>>> The patchset looks good, two questions
>>>
>>> 1. The patchset is still necessary for
>>>     a. systems with smaller amount of RAM?
>>        I think it is. Currently, I tested systems for 4GB, 50GB, and
>> boot time is improved.
>>        We may test more systems with different memory size in the future.
>>>     b. Theoretically it improves boot time?
>>        The boot time is improved a little bit for huge memory system
>> and it can be ignored.
>>        But I think it's still necessary to enable this feature.
>>
>>> 2. the pgdat->node_spanned_pages >> 8 sounds arbitrary
>>>     On a system with 2TB*16 nodes, it would initialize about 8GB before calling deferred init?
>>>     Don't we need at-least 32GB + space for other early hash allocations
>>>     BTW, My expectation was that 32TB would imply 32GB+32GB of large hash allocations early on
>>       pgdat->node_spanned_pages >> 8 means that it allocates the size
>> of the memory on one node.
>>       On a system with 2TB *16nodes, it will allocate 16*8GB = 128GB.
>>       I am not sure if it can be minimised to >> 16 to make sure all
>> the architectures with different
>>       memory size work well.  And this is also mentioned in early
>> discussion for X86, so I choose  >> 8.
>>
>> *    From the code as the following:
>>
>>       free_area_init_core ->
>>                      memmap_init->
>>                               update_defer_init
>>      #define memmap_init(size, nid, zone, start_pfn) \
>>            memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
>>
>>      memmap_init_zone is based on a zone, but free_area_init_core will
>> help find the highest
>>      zone on the node. And update_defer_init() get max initialised
>> memory on highest zone for a node to
>>      reserve for early initialisation.
>>
>>      static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>>      {
>>             ...
>>            for (j = 0; j < MAX_NR_ZONES; j++) {
>>                   ....
>>                  memmap_init(size, nid, j, zone_start_fn);   //find
>> the highest zone on a node.
>>                  ...
>>            }
>>      }
>>
>> *   From the dmesg log, after applying this patchset, it has
>> 123013440K(about 117GB),
>>     which is enough for Dentry node hash table and Inode hash table in
>> this system.
>>
>>     [    0.000000] Memory: 123013440K/31739871232K available (8000K
>> kernel code, 1856K rwdata,
>>     3384K rodata, 6208K init, 2544K bss, 28531136K reserved, 0K cma-reserved)
>>
>> Thanks :)
>>
> Looks good! It seems the real benefit is for smaller systems - thanks for clarifying
> Please check if CMA is affected in any way
>

Sure, thanks.

> Acked-by: Balbir Singh <bsingharora@gmail.com>
>
> Balbir Singh.



-- 

Best Regards
-Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
