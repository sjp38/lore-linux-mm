Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABC26B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 23:29:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so64413485pfe.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 20:29:56 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id y80si15224857pfb.47.2016.04.19.20.29.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 20:29:55 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com> <570B10B2.2000000@hisilicon.com>
 <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
 <570B5875.20804@hisilicon.com>
 <CAKv+Gu9aqR=E3TmbPDFEUC+Q13bAJTU5wVTTHkOr6aX6BZ1OVA@mail.gmail.com>
 <570B758E.7070005@hisilicon.com>
 <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
 <20160412145903.GF8066@e104818-lin.cambridge.arm.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <5716F51E.70101@hisilicon.com>
Date: Wed, 20 Apr 2016 11:18:54 +0800
MIME-Version: 1.0
In-Reply-To: <20160412145903.GF8066@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Dan Zhao <dan.zhao@hisilicon.com>, mhocko@suse.com, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, suzhuangluan@hisilicon.com, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, albert.lubing@hisilicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, David Rientjes <rientjes@google.com>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, Laura
 Abbott <labbott@redhat.com>, robin.murphy@arm.com, kirill.shutemov@linux.intel.com, saberlily.xia@hisilicon.com

Hi Catalin,

Thanks for your reply.
On 2016/4/12 22:59, Catalin Marinas wrote:
> On Mon, Apr 11, 2016 at 12:31:53PM +0200, Ard Biesheuvel wrote:
>> On 11 April 2016 at 11:59, Chen Feng <puck.chen@hisilicon.com> wrote:
>>> On 2016/4/11 16:00, Ard Biesheuvel wrote:
>>>> On 11 April 2016 at 09:55, Chen Feng <puck.chen@hisilicon.com> wrote:
>>>>> On 2016/4/11 15:35, Ard Biesheuvel wrote:
>>>>>> On 11 April 2016 at 04:49, Chen Feng <puck.chen@hisilicon.com> wrote:
>>>>>>>  0             1.5G    2G             3.5G            4G
>>>>>>>  |              |      |               |              |
>>>>>>>  +--------------+------+---------------+--------------+
>>>>>>>  |    MEM       | hole |     MEM       |   IO (regs)  |
>>>>>>>  +--------------+------+---------------+--------------+
>>>>> The hole in 1.5G ~ 2G is also allocated mem-map array. And also with the 3.5G ~ 4G.
>>>>>
>>>>
>>>> No, it is not. It may be covered by a section, but that does not mean
>>>> sparsemem vmemmap will actually allocate backing for it. The
>>>> granularity used by sparsemem vmemmap on a 4k pages kernel is 128 MB,
>>>> due to the fact that the backing is performed at PMD granularity.
>>>>
>>>> Please, could you share the contents of the vmemmap section in
>>>> /sys/kernel/debug/kernel_page_tables of your system running with
>>>> sparsemem vmemmap enabled? You will need to set CONFIG_ARM64_PTDUMP=y
>>>
>>> Please see the pg-tables below.
>>>
>>> With sparse and vmemmap enable.
>>>
>>> ---[ vmemmap start ]---
>>> 0xffffffbdc0200000-0xffffffbdc4800000          70M     RW NX SHD AF    UXN MEM/NORMAL
>>> ---[ vmemmap end ]---
> [...]
>>> The board is 4GB, and the memap is 70MB
>>> 1G memory --- 14MB mem_map array.
>>
>> No, this is incorrect. 1 GB corresponds with 16 MB worth of struct
>> pages assuming sizeof(struct page) == 64
>>
>> So you are losing 6 MB to rounding here, which I agree is significant.
>> I wonder if it makes sense to use a lower value for SECTION_SIZE_BITS
>> on 4k pages kernels, but perhaps we're better off asking the opinion
>> of the other cc'ees.
> 
> IIRC, SECTION_SIZE_BITS was chosen to be the maximum sane value we were
> thinking of at the time, assuming that 1GB RAM alignment to be fairly
> normal. For the !SPARSEMEM_VMEMMAP case, we should probably be fine with
> 29 but, as Will said, we need to be careful with the page flags. At a
> quick look, we have 25 page flags, 2 bits per zone, NUMA nodes and (48 -
> section_size_bits) for the section width. We also need to take into
> account 4 more bits for 52-bit PA support (ARMv8.2). So, without NUMA
> nodes, we are currently at 49 bits used in page->flags.
> 
> For the SPARSEMEM_VMEMMAP case, we can decrease the SECTION_SIZE_BITS in
> the MAX_ORDER limit.
> 
> An alternative would be to free the vmemmap holes later (but still keep
> the vmemmap mapping alias). Yet another option would be to change the
> sparse_mem_map_populate() logic get the actual section end rather than
> always assuming PAGES_PER_SECTION. But I don't think any of these are
> worth if we can safely reduce SECTION_SIZE_BITS.
> 
Yes,
currently,it's safely to reduce the SECTION_SIZE_BITS to match this issue
very well.

As I mentioned before, if the memory layout is not like this scene. There
will be not suitable to reduce the SECTION_SIZE_BITS.

We have 4G memory, and 64GB phys address.

There will be a lot of holes in the memory layout.
And the *holes size are not always the same*.

So,it's the reason I want to enable flat-mem in ARM64-ARCH. Why not makes
the flat-mem an optional setting for arm64i 1/4 ?






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
