Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B27136B0010
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 23:19:09 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x18-v6so3610045oie.7
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 20:19:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f190-v6sor4394509oih.60.2018.06.29.20.19.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 20:19:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180629193300.0ae0f25880a800bd27952b15@linux-foundation.org>
References: <20180625170259.30393-1-aryabinin@virtuozzo.com>
 <20180629164932.740-1-aryabinin@virtuozzo.com> <20180629193300.0ae0f25880a800bd27952b15@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 29 Jun 2018 20:19:07 -0700
Message-ID: <CAPcyv4hiwTsSdptKFtBYfsbd9L12RfjGdY1PDckkCY980vxXLQ@mail.gmail.com>
Subject: Re: [PATCH v2] kernel/memremap, kasan: Make ZONE_DEVICE with work
 with KASAN
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, david <david@fromorbit.com>, kasan-dev@googlegroups.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On Fri, Jun 29, 2018 at 7:33 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 29 Jun 2018 19:49:32 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>> KASAN learns about hot added memory via the memory hotplug notifier.
>> The devm_memremap_pages() intentionally skips calling memory hotplug
>> notifiers.
>
> Why does it do that?

devm_memremap_pages() deliberately does only half of memory hotplug.
Namely it only adds to the linear map and allocates / initializes
'struct page', but it never onlines the pages, so
devm_memremap_pages() generates none of the events that the hotplug
notifiers would publish.

>> So KASAN doesn't know anything about new memory added
>> by devm_memremap_pages(). This causes to crash when KASAN tries to
>> access non-existent shadow memory:
>>
>>  BUG: unable to handle kernel paging request at ffffed0078000000
>>  RIP: 0010:check_memory_region+0x82/0x1e0
>>  Call Trace:
>>   memcpy+0x1f/0x50
>>   pmem_do_bvec+0x163/0x720
>>   pmem_make_request+0x305/0xac0
>>   generic_make_request+0x54f/0xcf0
>>   submit_bio+0x9c/0x370
>>   submit_bh_wbc+0x4c7/0x700
>>   block_read_full_page+0x5ef/0x870
>>   do_read_cache_page+0x2b8/0xb30
>>   read_dev_sector+0xbd/0x3f0
>>   read_lba.isra.0+0x277/0x670
>>   efi_partition+0x41a/0x18f0
>>   check_partition+0x30d/0x5e9
>>   rescan_partitions+0x18c/0x840
>>   __blkdev_get+0x859/0x1060
>>   blkdev_get+0x23f/0x810
>>   __device_add_disk+0x9c8/0xde0
>>   pmem_attach_disk+0x9a8/0xf50
>>   nvdimm_bus_probe+0xf3/0x3c0
>>   driver_probe_device+0x493/0xbd0
>>   bus_for_each_drv+0x118/0x1b0
>>   __device_attach+0x1cd/0x2b0
>>   bus_probe_device+0x1ac/0x260
>>   device_add+0x90d/0x1380
>>   nd_async_device_register+0xe/0x50
>>   async_run_entry_fn+0xc3/0x5d0
>>   process_one_work+0xa0a/0x1810
>>   worker_thread+0x87/0xe80
>>   kthread+0x2d7/0x390
>>   ret_from_fork+0x3a/0x50
>>
>> Add kasan_add_zero_shadow()/kasan_remove_zero_shadow() - post mm_init()
>> interface to map/unmap kasan_zero_page at requested virtual addresses.
>> And use it to add/remove the shadow memory for hotpluged/unpluged
>> device memory.
>>
>> Reported-by: Dave Chinner <david@fromorbit.com>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Alexander Potapenko <glider@google.com>
>
> No cc:stable? Which kernel version(s) do you believe need the fix?

I think devm_memremap_pages() was incompatible with KASAN from the
outset, so I would say:

Fixes: 41e94a851304 ("add devm_memremap_pages")

>
>>  include/linux/kasan.h |  13 ++-
>>  kernel/memremap.c     |  10 ++
>>  mm/kasan/kasan_init.c | 316 +++++++++++++++++++++++++++++++++++++++++++++++---
>
> It's a surprisingly large amount of ode to do something which KASAN
> already does for hotplugged memory.  How come?
