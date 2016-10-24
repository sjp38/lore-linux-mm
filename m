Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59CD06B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:16:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w11so95912444oia.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:16:18 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id w80si6623583oia.25.2016.10.24.12.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 12:16:17 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id i127so3601530oia.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:16:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161024180934.GA24840@char.us.oracle.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120437.16276.68349.stgit@ahduyck-blue-test.jf.intel.com> <20161024180934.GA24840@char.us.oracle.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 24 Oct 2016 12:16:16 -0700
Message-ID: <CAKgT0UfTSmWGBqE0uDG40sAm-LVwCJ6zM1AFJ8o_tWu+XJvfVw@mail.gmail.com>
Subject: Re: [net-next PATCH RFC 02/26] swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>

On Mon, Oct 24, 2016 at 11:09 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Mon, Oct 24, 2016 at 08:04:37AM -0400, Alexander Duyck wrote:
>> As a first step to making DMA_ATTR_SKIP_CPU_SYNC apply to architectures
>> beyond just ARM I need to make it so that the swiotlb will respect the
>> flag.  In order to do that I also need to update the swiotlb-xen since it
>> heavily makes use of the functionality.
>>
>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  drivers/xen/swiotlb-xen.c |   40 ++++++++++++++++++++++----------------
>>  include/linux/swiotlb.h   |    6 ++++--
>>  lib/swiotlb.c             |   48 +++++++++++++++++++++++++++------------------
>>  3 files changed, 56 insertions(+), 38 deletions(-)
>>
>> diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
>> index 87e6035..cf047d8 100644
>> --- a/drivers/xen/swiotlb-xen.c
>> +++ b/drivers/xen/swiotlb-xen.c
>> @@ -405,7 +405,8 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
>>        */
>>       trace_swiotlb_bounced(dev, dev_addr, size, swiotlb_force);
>>
>> -     map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir);
>> +     map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir,
>> +                                  attrs);
>>       if (map == SWIOTLB_MAP_ERROR)
>>               return DMA_ERROR_CODE;
>>
>> @@ -416,11 +417,13 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
>>       /*
>>        * Ensure that the address returned is DMA'ble
>>        */
>> -     if (!dma_capable(dev, dev_addr, size)) {
>> -             swiotlb_tbl_unmap_single(dev, map, size, dir);
>> -             dev_addr = 0;
>> -     }
>> -     return dev_addr;
>> +     if (dma_capable(dev, dev_addr, size))
>> +             return dev_addr;
>> +
>> +     swiotlb_tbl_unmap_single(dev, map, size, dir,
>> +                              attrs | DMA_ATTR_SKIP_CPU_SYNC);
>> +
>> +     return DMA_ERROR_CODE;
>
> Why? This change (re-ordering the code - and returning DMA_ERROR_CODE instead
> of 0) does not have anything to do with the title.
>
> If you really feel strongly about it - then please send it as a seperate patch.

Okay I can do that.  This was mostly just to clean up the formatting
because I was over 80 characters when I added the attribute.  Changing
the return value to DMA_ERROR_CODE from 0 was based on the fact that
earlier in the function that is the value you return if there is a
mapping error.

>>  }
>>  EXPORT_SYMBOL_GPL(xen_swiotlb_map_page);
>>
>> @@ -444,7 +447,7 @@ static void xen_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
>>
>>       /* NOTE: We use dev_addr here, not paddr! */
>>       if (is_xen_swiotlb_buffer(dev_addr)) {
>> -             swiotlb_tbl_unmap_single(hwdev, paddr, size, dir);
>> +             swiotlb_tbl_unmap_single(hwdev, paddr, size, dir, attrs);
>>               return;
>>       }
>>
>> @@ -557,16 +560,9 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>>                                                                start_dma_addr,
>>                                                                sg_phys(sg),
>>                                                                sg->length,
>> -                                                              dir);
>> -                     if (map == SWIOTLB_MAP_ERROR) {
>> -                             dev_warn(hwdev, "swiotlb buffer is full\n");
>> -                             /* Don't panic here, we expect map_sg users
>> -                                to do proper error handling. */
>> -                             xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
>> -                                                        attrs);
>> -                             sg_dma_len(sgl) = 0;
>> -                             return 0;
>> -                     }
>> +                                                              dir, attrs);
>> +                     if (map == SWIOTLB_MAP_ERROR)
>> +                             goto map_error;
>>                       xen_dma_map_page(hwdev, pfn_to_page(map >> PAGE_SHIFT),
>>                                               dev_addr,
>>                                               map & ~PAGE_MASK,
>> @@ -589,6 +585,16 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>>               sg_dma_len(sg) = sg->length;
>>       }
>>       return nelems;
>> +map_error:
>> +     dev_warn(hwdev, "swiotlb buffer is full\n");
>> +     /*
>> +      * Don't panic here, we expect map_sg users
>> +      * to do proper error handling.
>> +      */
>> +     xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
>> +                                attrs | DMA_ATTR_SKIP_CPU_SYNC);
>> +     sg_dma_len(sgl) = 0;
>> +     return 0;
>>  }
>
> This too. Why can't that be part of the existing code that was there?

Once again it was a formatting thing.  I was indented too far and
adding the attribute pushed me over 80 characters so I broke it out to
a label to avoid the problem.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
