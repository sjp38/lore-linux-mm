Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3A56B0261
	for <linux-mm@kvack.org>; Sat,  5 Nov 2016 19:13:33 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q75so100791526itc.4
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 16:13:33 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id y73si2392857ita.77.2016.11.05.16.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Nov 2016 16:13:32 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id q124so3348460itd.1
        for <linux-mm@kvack.org>; Sat, 05 Nov 2016 16:13:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161105193929.GA26349@localhost.localdomain>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111252.79519.21950.stgit@ahduyck-blue-test.jf.intel.com> <20161105193929.GA26349@localhost.localdomain>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 5 Nov 2016 16:13:31 -0700
Message-ID: <CAKgT0UdjHb=49jSdzNoDaukZi6_jpqWziSDtM3Gy_6ZCC=5efQ@mail.gmail.com>
Subject: Re: [mm PATCH v2 03/26] swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Sat, Nov 5, 2016 at 12:39 PM, Konrad Rzeszutek Wilk
<konrad@darnok.org> wrote:
> .. snip..
>> @@ -561,6 +565,7 @@ void swiotlb_tbl_unmap_single(struct device *hwdev, phys_addr_t tlb_addr,
>>        * First, sync the memory before unmapping the entry
>>        */
>>       if (orig_addr != INVALID_PHYS_ADDR &&
>> +         !(attrs & DMA_ATTR_SKIP_CPU_SYNC) &&
>>           ((dir == DMA_FROM_DEVICE) || (dir == DMA_BIDIRECTIONAL)))
>>               swiotlb_bounce(orig_addr, tlb_addr, size, DMA_FROM_DEVICE);
>>
>> @@ -654,7 +659,8 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
>>                * GFP_DMA memory; fall back on map_single(), which
>>                * will grab memory from the lowest available address range.
>>                */
>> -             phys_addr_t paddr = map_single(hwdev, 0, size, DMA_FROM_DEVICE);
>> +             phys_addr_t paddr = map_single(hwdev, 0, size,
>> +                                            DMA_FROM_DEVICE, 0);
>>               if (paddr == SWIOTLB_MAP_ERROR)
>>                       goto err_warn;
>>
>> @@ -669,7 +675,8 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
>>
>>                       /* DMA_TO_DEVICE to avoid memcpy in unmap_single */
>>                       swiotlb_tbl_unmap_single(hwdev, paddr,
>> -                                              size, DMA_TO_DEVICE);
>> +                                              size, DMA_TO_DEVICE,
>> +                                              DMA_ATTR_SKIP_CPU_SYNC);
>
> This I believe is redundant. That is swiotlb_tbl_unmap_single only
> does an bounce if the dir is DMA_FROM_DEVICE or DMA_BIDIRECTIONAL.
>
> I added /* optional. */

You are probably right.  I don't need to add the DMA_ATTR_SKIP_CPU_SYNC here.

>>                       goto err_warn;
>>               }
>>       }
>> @@ -699,7 +706,7 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
>>               free_pages((unsigned long)vaddr, get_order(size));
>>       else
>>               /* DMA_TO_DEVICE to avoid memcpy in swiotlb_tbl_unmap_single */
>> -             swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE);
>> +             swiotlb_tbl_unmap_single(hwdev, paddr, size, DMA_TO_DEVICE, 0);
>
> .. but here you choose to put 0? I changed that to
> DMA_ATTR_SKIP_CPU_SYNC and expanded the comment above.
>
> Time to test the patches.

I think I had probably realized the fact that I didn't need it above
and so just used 0 here.  I can clean this up and resubmit if you
want.

Do you want me to just split this patch set up so that I submit the
swiotlb patches to you and leave the rest of the patches for the mm
tree?

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
