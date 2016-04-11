Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 35C3B6B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:35:46 -0400 (EDT)
Received: by mail-io0-f179.google.com with SMTP id g185so198283720ioa.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:35:46 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id po1si5173803igb.81.2016.04.11.00.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 00:35:45 -0700 (PDT)
Received: by mail-ig0-x22d.google.com with SMTP id kb1so75383135igb.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:35:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <570B10B2.2000000@hisilicon.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
	<20160407142148.GI5657@arm.com>
	<570B10B2.2000000@hisilicon.com>
Date: Mon, 11 Apr 2016 09:35:45 +0200
Message-ID: <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Will Deacon <will.deacon@arm.com>, mhocko@suse.com, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Dan Zhao <dan.zhao@hisilicon.com>, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, albert.lubing@hisilicon.com, Catalin Marinas <catalin.marinas@arm.com>, suzhuangluan@hisilicon.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, David Rientjes <rientjes@google.com>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, robin.murphy@arm.com, yudongbin@hislicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, saberlily.xia@hisilicon.com

On 11 April 2016 at 04:49, Chen Feng <puck.chen@hisilicon.com> wrote:
> Hi will,
> Thanks for review.
>
> On 2016/4/7 22:21, Will Deacon wrote:
>> On Tue, Apr 05, 2016 at 04:22:51PM +0800, Chen Feng wrote:
>>> We can reduce the memory allocated at mem-map
>>> by flatmem.
>>>
>>> currently, the default memory-model in arm64 is
>>> sparse memory. The mem-map array is not freed in
>>> this scene. If the physical address is too long,
>>> it will reserved too much memory for the mem-map
>>> array.
>>
>> Can you elaborate a bit more on this, please? We use the vmemmap, so any
>> spaces between memory banks only burns up virtual space. What exactly is
>> the problem you're seeing that makes you want to use flatmem (which is
>> probably unsuitable for the majority of arm64 machines).
>>
> The root cause we want to use flat-mem is the mam_map alloced in sparse-mem
> is not freed.
>
> take a look at here:
> arm64/mm/init.c
> void __init mem_init(void)
> {
> #ifndef CONFIG_SPARSEMEM_VMEMMAP
>         free_unused_memmap();
> #endif
> }
>
> Memory layout (3GB)
>
>  0             1.5G    2G             3.5G            4G
>  |              |      |               |              |
>  +--------------+------+---------------+--------------+
>  |    MEM       | hole |     MEM       |   IO (regs)  |
>  +--------------+------+---------------+--------------+
>
>
> Memory layout (4GB)
>
>  0                                    3.5G            4G    4.5G
>  |                                     |              |       |
>  +-------------------------------------+--------------+-------+
>  |                   MEM               |   IO (regs)  |  MEM  |
>  +-------------------------------------+--------------+-------+
>
> Currently, the sparse memory section is 1GB.
>
> 3GB ddr: the 1.5 ~2G and 3.5 ~ 4G are holes.
> 3GB ddr: the 3.5 ~ 4G and 4.5 ~ 5G are holes.
>
> This will alloc 1G/4K * (struct page) memory for mem_map array.
>

No, this is incorrect. Sparsemem vmemmap only allocates struct pages
for memory regions that are actually populated.

For instance, on the Foundation model with 4 GB of memory, you may see
something like this in the boot log

[    0.000000]     vmemmap : 0xffffffbdc0000000 - 0xffffffbfc0000000
(     8 GB maximum)
[    0.000000]               0xffffffbdc0000000 - 0xffffffbde2000000
(   544 MB actual)

but in reality, only the following regions have been allocated

---[ vmemmap start ]---
0xffffffbdc0000000-0xffffffbdc2000000          32M       RW NX SHD AF
      BLK UXN MEM/NORMAL
0xffffffbde0000000-0xffffffbde2000000          32M       RW NX SHD AF
      BLK UXN MEM/NORMAL
---[ vmemmap end ]---

so only 64 MB is used to back 4 GB of RAM with struct pages, which is
minimal. Moving to flatmem will not reduce the memory footprint at
all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
