Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id A55A96B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 09:03:10 -0400 (EDT)
Received: by mail-oi0-f51.google.com with SMTP id g201so2605173oib.38
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:03:10 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id rm3si7155154obc.59.2014.08.07.06.03.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 06:03:09 -0700 (PDT)
Received: by mail-oi0-f52.google.com with SMTP id h136so2650478oig.11
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 06:03:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdVC8aYwDEHnntshdVA24Nx3qAUXZfeRQNGqj=J6eExU-Q@mail.gmail.com>
References: <CAMuHMdW2kb=EF-Nmem_gyUu=p7hFOTe+Q2ekHh41SaHHiWDGeg@mail.gmail.com>
	<CAAmzW4MX2birtCOUxjDdQ7c3Y+RyVkBt383HEQ=XFgnhhOsQPw@mail.gmail.com>
	<CAMuHMdVC8aYwDEHnntshdVA24Nx3qAUXZfeRQNGqj=J6eExU-Q@mail.gmail.com>
Date: Thu, 7 Aug 2014 22:03:09 +0900
Message-ID: <CAAmzW4NWnMeO+Z3CQ=9Z7rUFLaPmR-w0iMhxzjO+PVgVu7OMuQ@mail.gmail.com>
Subject: Re: BUG: enable_cpucache failed for radix_tree_node, error 12 (was:
 Re: [PATCH v3 9/9] slab: remove BAD_ALIEN_MAGIC)
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

2014-08-07 21:53 GMT+09:00 Geert Uytterhoeven <geert@linux-m68k.org>:
> Hi,
>
> On Thu, Aug 7, 2014 at 2:36 PM, Joonsoo Kim <js1304@gmail.com> wrote:
>>> With latest mainline, I'm getting a crash during bootup on m68k/ARAnyM:
>>>
>>> enable_cpucache failed for radix_tree_node, error 12.
>>> kernel BUG at /scratch/geert/linux/linux-m68k/mm/slab.c:1522!
>
>>> I bisected it to commit a640616822b2c3a8009b0600f20c4a76ea8a0025
>>> Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> Date:   Wed Aug 6 16:04:38 2014 -0700
>>>
>>>     slab: remove BAD_ALIEN_MAGIC
>
>> This patch only works for !NUMA. And if num_possible_nodes() is 1,
>> then it doesn't have any effect, because alloc_alien_cache() call is always
>> skipped. Is it possible !NUMA and num_possible_nodes() != 1?
>>
>> Could you check your config for CONFIG_NUMA and
>> CONFIG_NODES_SHIFT?
>
> $ grep CONFIG_NUMA .config
> $ grep CONFIG_NODES_SHIFT .config
> CONFIG_NODES_SHIFT=3
> $
>
> There are indeed multiple nodes:
>
> On node 0 totalpages: 3584
> free_area_init_node: node 0, pgdat 003659a4, node_mem_map 00402000
>   DMA zone: 32 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 3584 pages, LIFO batch:0
> On node 1 totalpages: 65536
> free_area_init_node: node 1, pgdat 00366294, node_mem_map 00426090
>   DMA zone: 576 pages used for memmap
>   DMA zone: 0 pages reserved
>   DMA zone: 65536 pages, LIFO batch:15
>
>> And, could you check booting with boot param "noaliencache"?
>
> That fixes the boot, too.

Ah... I don't know it can be possible to be !CONFIG_NUMA and
CONFIG_NODES_SHIFT > 0 until now. If so, I should revert this patch.

After some more investigation, I will revert this patch tomorrow and
notify you.

Thanks for reporting!!! :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
