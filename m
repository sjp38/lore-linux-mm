Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 979E96B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:52:05 -0400 (EDT)
Received: by mail-io0-f181.google.com with SMTP id o126so181073590iod.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:52:05 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id i5si16644135iof.113.2016.04.11.03.52.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 03:52:04 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com> <570B10B2.2000000@hisilicon.com>
 <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
 <570B5875.20804@hisilicon.com>
 <CAKv+Gu9aqR=E3TmbPDFEUC+Q13bAJTU5wVTTHkOr6aX6BZ1OVA@mail.gmail.com>
 <570B758E.7070005@hisilicon.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <570B8118.1010809@hisilicon.com>
Date: Mon, 11 Apr 2016 18:48:56 +0800
MIME-Version: 1.0
In-Reply-To: <570B758E.7070005@hisilicon.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>, mhocko@suse.com, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Dan Zhao <dan.zhao@hisilicon.com>, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, albert.lubing@hisilicon.com, Catalin Marinas <catalin.marinas@arm.com>, suzhuangluan@hisilicon.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, David Rientjes <rientjes@google.com>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, robin.murphy@arm.com, yudongbin@hislicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, saberlily.xia@hisilicon.com



On 2016/4/11 17:59, Chen Feng wrote:
> Hi Ard,
> 
> On 2016/4/11 16:00, Ard Biesheuvel wrote:
>> On 11 April 2016 at 09:55, Chen Feng <puck.chen@hisilicon.com> wrote:
>>> Hi Ard,
>>>
>>> On 2016/4/11 15:35, Ard Biesheuvel wrote:
>>>> On 11 April 2016 at 04:49, Chen Feng <puck.chen@hisilicon.com> wrote:
>>>>> Hi will,
>>>>> Thanks for review.
>>>>>
>>>>> On 2016/4/7 22:21, Will Deacon wrote:
>>>>>> On Tue, Apr 05, 2016 at 04:22:51PM +0800, Chen Feng wrote:
>>>>>>> We can reduce the memory allocated at mem-map
>>>>>>> by flatmem.
>>>>>>>
>>>>>>> currently, the default memory-model in arm64 is
>>>>>>> sparse memory. The mem-map array is not freed in
>>>>>>> this scene. If the physical address is too long,
>>>>>>> it will reserved too much memory for the mem-map
>>>>>>> array.
>>>>>>
>>>>>> Can you elaborate a bit more on this, please? We use the vmemmap, so any
>>>>>> spaces between memory banks only burns up virtual space. What exactly is
>>>>>> the problem you're seeing that makes you want to use flatmem (which is
>>>>>> probably unsuitable for the majority of arm64 machines).
>>>>>>
>>>>> The root cause we want to use flat-mem is the mam_map alloced in sparse-mem
>>>>> is not freed.
>>>>>
>>>>> take a look at here:
>>>>> arm64/mm/init.c
>>>>> void __init mem_init(void)
>>>>> {
>>>>> #ifndef CONFIG_SPARSEMEM_VMEMMAP
>>>>>         free_unused_memmap();
>>>>> #endif
>>>>> }
>>>>>
>>>>> Memory layout (3GB)
>>>>>
>>>>>  0             1.5G    2G             3.5G            4G
>>>>>  |              |      |               |              |
>>>>>  +--------------+------+---------------+--------------+
>>>>>  |    MEM       | hole |     MEM       |   IO (regs)  |
>>>>>  +--------------+------+---------------+--------------+
>>>>>
>>>>>
>>>>> Memory layout (4GB)
>>>>>
>>>>>  0                                    3.5G            4G    4.5G
>>>>>  |                                     |              |       |
>>>>>  +-------------------------------------+--------------+-------+
>>>>>  |                   MEM               |   IO (regs)  |  MEM  |
>>>>>  +-------------------------------------+--------------+-------+
>>>>>
>>>>> Currently, the sparse memory section is 1GB.
>>>>>
>>>>> 3GB ddr: the 1.5 ~2G and 3.5 ~ 4G are holes.
>>>>> 3GB ddr: the 3.5 ~ 4G and 4.5 ~ 5G are holes.
>>>>>
>>>>> This will alloc 1G/4K * (struct page) memory for mem_map array.
>>>>>
>>>>
>>>> No, this is incorrect. Sparsemem vmemmap only allocates struct pages
>>>> for memory regions that are actually populated.
>>>>
>>>> For instance, on the Foundation model with 4 GB of memory, you may see
>>>> something like this in the boot log
>>>>
>>>> [    0.000000]     vmemmap : 0xffffffbdc0000000 - 0xffffffbfc0000000
>>>> (     8 GB maximum)
>>>> [    0.000000]               0xffffffbdc0000000 - 0xffffffbde2000000
>>>> (   544 MB actual)
>>>>
>>>> but in reality, only the following regions have been allocated
>>>>
>>>> ---[ vmemmap start ]---
>>>> 0xffffffbdc0000000-0xffffffbdc2000000          32M       RW NX SHD AF
>>>>       BLK UXN MEM/NORMAL
>>>> 0xffffffbde0000000-0xffffffbde2000000          32M       RW NX SHD AF
>>>>       BLK UXN MEM/NORMAL
>>>> ---[ vmemmap end ]---
>>>>
>>>> so only 64 MB is used to back 4 GB of RAM with struct pages, which is
>>>> minimal. Moving to flatmem will not reduce the memory footprint at
>>>> all.
>>>
>>> Yes,but the populate is section, which is 1GB. Take a look at the above
>>> memory layout.
>>>
>>> The section 1G ~ 2G is a section. But 1.5G ~ 2G is a hole.
>>>
>>> The section 3G ~ 4G is a section. But 3.5G ~ 4G is a hole.
>>>>>  0             1.5G    2G             3.5G            4G
>>>>>  |              |      |               |              |
>>>>>  +--------------+------+---------------+--------------+
>>>>>  |    MEM       | hole |     MEM       |   IO (regs)  |
>>>>>  +--------------+------+---------------+--------------+
>>> The hole in 1.5G ~ 2G is also allocated mem-map array. And also with the 3.5G ~ 4G.
>>>
>>
>> No, it is not. It may be covered by a section, but that does not mean
>> sparsemem vmemmap will actually allocate backing for it. The
>> granularity used by sparsemem vmemmap on a 4k pages kernel is 128 MB,
>> due to the fact that the backing is performed at PMD granularity.
>>
>> Please, could you share the contents of the vmemmap section in
>> /sys/kernel/debug/kernel_page_tables of your system running with
>> sparsemem vmemmap enabled? You will need to set CONFIG_ARM64_PTDUMP=y
>>
> 
> Please see the pg-tables below.
> 
> 
> With sparse and vmemmap enable.
> 
> ---[ vmemmap start ]---
> 0xffffffbdc0200000-0xffffffbdc4800000          70M     RW NX SHD AF    UXN MEM/NORMAL
> ---[ vmemmap end ]---
> 
> 
> The board is 4GB, and the memap is 70MB
> 1G memory --- 14MB mem_map array.
> So the 4GB has 5 sections, which used 5 * 14MB memory.
> 
>
Sorry, 1G memory is 16GB
5 sections is 5 * 16 = 80MB

1G / 4K * (struct page) 64B = 16MB

I don't know why the vmemap dump in pg-tables is 70MB.

I add hack code in vmemmap_populate sparse_mem_map_populate.

here is the log:
sparse_mem_map_populate 188 start ffffffbdc0000000 end ffffffbdc1000000 PAGES_PER_SECTION 40000 nid 0
vmemmap_populate 549 size 200000 total 200000 addr ffffffbdc0000000
vmemmap_populate 549 size 200000 total 400000 addr ffffffbdc0200000
vmemmap_populate 549 size 200000 total 600000 addr ffffffbdc0400000
vmemmap_populate 549 size 200000 total 800000 addr ffffffbdc0600000
vmemmap_populate 549 size 200000 total a00000 addr ffffffbdc0800000
vmemmap_populate 549 size 200000 total c00000 addr ffffffbdc0a00000
vmemmap_populate 549 size 200000 total e00000 addr ffffffbdc0c00000
vmemmap_populate 549 size 200000 total 1000000 addr ffffffbdc0e00000
sparse_mem_map_populate 188 start ffffffbdc1000000 end ffffffbdc2000000 PAGES_PER_SECTION 40000 nid 0
...
sparse_mem_map_populate 188 start ffffffbdc2000000 end ffffffbdc3000000 PAGES_PER_SECTION 40000 nid 0
sparse_mem_map_populate 188 start ffffffbdc3000000 end ffffffbdc4000000 PAGES_PER_SECTION 40000 nid 0
sparse_mem_map_populate 188 start ffffffbdc4000000 end ffffffbdc5000000 PAGES_PER_SECTION 40000 nid 0


With 4GB memory, it allocated 2MB *  8  * 5 = 80MB.
>  0                                    3.5G            4G    4.5G
>  |                                     |              |       |
>  +-------------------------------------+--------------+-------+
>  |                   MEM               |   IO (regs)  |  MEM  |
>  +-------------------------------------+--------------+-------+

4GB memory ,5 sections. 80MB mem_map allocated.

> 
> 
> 
> 
>> .
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
