Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC186B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:13:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e72-v6so1780030oib.5
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:13:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c66-v6sor3548800oig.27.2018.06.29.10.13.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 10:13:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180629164932.740-1-aryabinin@virtuozzo.com>
References: <20180625170259.30393-1-aryabinin@virtuozzo.com> <20180629164932.740-1-aryabinin@virtuozzo.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 29 Jun 2018 10:13:31 -0700
Message-ID: <CAPcyv4hwgLS+=UWyORqs_dHFu2LSX6pheWVt=zyrby2wneixBA@mail.gmail.com>
Subject: Re: [PATCH v2] kernel/memremap, kasan: Make ZONE_DEVICE with work
 with KASAN
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, david <david@fromorbit.com>, kasan-dev@googlegroups.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>

On Fri, Jun 29, 2018 at 9:49 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> KASAN learns about hot added memory via the memory hotplug notifier.
> The devm_memremap_pages() intentionally skips calling memory hotplug
> notifiers. So KASAN doesn't know anything about new memory added
> by devm_memremap_pages(). This causes to crash when KASAN tries to
> access non-existent shadow memory:
>
>  BUG: unable to handle kernel paging request at ffffed0078000000
>  RIP: 0010:check_memory_region+0x82/0x1e0
>  Call Trace:
>   memcpy+0x1f/0x50
>   pmem_do_bvec+0x163/0x720
>   pmem_make_request+0x305/0xac0
>   generic_make_request+0x54f/0xcf0
>   submit_bio+0x9c/0x370
>   submit_bh_wbc+0x4c7/0x700
>   block_read_full_page+0x5ef/0x870
>   do_read_cache_page+0x2b8/0xb30
>   read_dev_sector+0xbd/0x3f0
>   read_lba.isra.0+0x277/0x670
>   efi_partition+0x41a/0x18f0
>   check_partition+0x30d/0x5e9
>   rescan_partitions+0x18c/0x840
>   __blkdev_get+0x859/0x1060
>   blkdev_get+0x23f/0x810
>   __device_add_disk+0x9c8/0xde0
>   pmem_attach_disk+0x9a8/0xf50
>   nvdimm_bus_probe+0xf3/0x3c0
>   driver_probe_device+0x493/0xbd0
>   bus_for_each_drv+0x118/0x1b0
>   __device_attach+0x1cd/0x2b0
>   bus_probe_device+0x1ac/0x260
>   device_add+0x90d/0x1380
>   nd_async_device_register+0xe/0x50
>   async_run_entry_fn+0xc3/0x5d0
>   process_one_work+0xa0a/0x1810
>   worker_thread+0x87/0xe80
>   kthread+0x2d7/0x390
>   ret_from_fork+0x3a/0x50
>
> Add kasan_add_zero_shadow()/kasan_remove_zero_shadow() - post mm_init()
> interface to map/unmap kasan_zero_page at requested virtual addresses.
> And use it to add/remove the shadow memory for hotpluged/unpluged
> device memory.
>
> Reported-by: Dave Chinner <david@fromorbit.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Alexander Potapenko <glider@google.com>

Reviewed-and-tested-by: Dan Williams <dan.j.williams@intel.com>
