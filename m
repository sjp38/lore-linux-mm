Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17E596B0010
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:21:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 39-v6so10302767ple.6
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:21:29 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0107.outbound.protection.outlook.com. [104.47.1.107])
        by mx.google.com with ESMTPS id s21-v6si3240114pfk.213.2018.07.02.10.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 10:21:27 -0700 (PDT)
Subject: Re: [PATCH v2] kernel/memremap, kasan: Make ZONE_DEVICE with work
 with KASAN
References: <20180625170259.30393-1-aryabinin@virtuozzo.com>
 <20180629164932.740-1-aryabinin@virtuozzo.com>
 <20180629193300.0ae0f25880a800bd27952b15@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <788aa605-94c7-f730-6ec6-0eac53cb10cf@virtuozzo.com>
Date: Mon, 2 Jul 2018 20:22:59 +0300
MIME-Version: 1.0
In-Reply-To: <20180629193300.0ae0f25880a800bd27952b15@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: david@fromorbit.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dan.j.williams@intel.com, dvyukov@google.com, glider@google.com



On 06/30/2018 05:33 AM, Andrew Morton wrote:
> On Fri, 29 Jun 2018 19:49:32 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
>> KASAN learns about hot added memory via the memory hotplug notifier.
>> The devm_memremap_pages() intentionally skips calling memory hotplug
>> notifiers.
> 
> Why does it do that?
> 
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
> No cc:stable? 

I'm just not sure whether this should go to stable or not.
It's a gray area between a new functionality and a bug fix.
>From one POV we fixing the bug here, but on the other hand, ZONE_DEVICE and KASAN
never worked together, so we add new functionality here.

> Which kernel version(s) do you believe need the fix?

I'd say the fix needed since fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
Before that, the combination ZONE_DEVICE=Y and KASAN=y  wasn't possible.

> 
>>  include/linux/kasan.h |  13 ++-
>>  kernel/memremap.c     |  10 ++
>>  mm/kasan/kasan_init.c | 316 +++++++++++++++++++++++++++++++++++++++++++++++---
> 
> It's a surprisingly large amount of ode to do something which KASAN
> already does for hotplugged memory.  How come?

For hotplugged memory we simply use __vmalloc_node_range()/vfree() to allocate and map the shadow at desired address.
We could do the same for a device memory, but the device memory isn't like ordinary memory.
alloc_page() or slab allocators doesn't work with device memory. We don't have concept of
free/allocated device memory, for KASAN it should look like it's always allocated.
Which means that the shadow of device memory is always contains zeroes. So, instead of allocating
bunch of memory to store zeroes, we just map kasan_zero_page.

The most part of the code to map kasan_zero_page is already exists, this patch makes this code usable after mm_init().
But we didn't have the code to unmap kasan_zero_page, so almost all newly added code in the patch is to unmap kasan_zero_page
(kasan_remove_zero_shadow()).

It could be possible to not unmap kasan_zero_page, just leave it there after devm_memremap_pages_release().
But we must have some guarantee that after devm_memremap_pages()/devm_memremap_pages_release() the same
addresses can't be reused for ordinary hotpluggable memory.
