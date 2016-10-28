Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6C26B0276
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 14:09:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f78so132358359oih.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 11:09:28 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id g7si9874008otd.293.2016.10.28.11.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 11:09:27 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id e12so1566343oib.3
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 11:09:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161028173430.GE5112@char.us.oracle.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
 <20161025153703.4815.13673.stgit@ahduyck-blue-test.jf.intel.com> <20161028173430.GE5112@char.us.oracle.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 28 Oct 2016 11:09:26 -0700
Message-ID: <CAKgT0UeG7HXCx7xpyFa5u5ytUEd4s3oor5AX-8b8UbDrqvOgUw@mail.gmail.com>
Subject: Re: [net-next PATCH 03/27] swiotlb: Add support for DMA_ATTR_SKIP_CPU_SYNC
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, Netdev <netdev@vger.kernel.org>, intel-wired-lan <intel-wired-lan@lists.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>

On Fri, Oct 28, 2016 at 10:34 AM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Tue, Oct 25, 2016 at 11:37:03AM -0400, Alexander Duyck wrote:
>> As a first step to making DMA_ATTR_SKIP_CPU_SYNC apply to architectures
>> beyond just ARM I need to make it so that the swiotlb will respect the
>> flag.  In order to do that I also need to update the swiotlb-xen since it
>> heavily makes use of the functionality.
>>
>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>
> I am pretty sure I acked it the RFC. Was there a particular
> reason (this is very different from the RFC?) you dropped my ACk?
>
> Thanks.

If I recall you had acked patch 1, but for 2 you had some review
comments on and suggested I change a few things.  What was patch 2 in
the RFC was split out into patches 2 and 3.  That is why I didn't
include an Ack from you for those patches.

Patch 2 is a fix for Xen to address the fact that you could return
either 0 or ~0.  It was part of patch 2 originally and I pulled it out
into a separate patch.

Patch 3 does most of what patch 2 in the RFC was doing before with
fixes to address the fact that I was moving some code to avoid going
over 80 characters.  I found a different way to fix that by just
updating attrs before using it instead of ORing in the value when
passing it as a parameter.

>> @@ -558,11 +560,12 @@ void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>>                                                                start_dma_addr,
>>                                                                sg_phys(sg),
>>                                                                sg->length,
>> -                                                              dir);
>> +                                                              dir, attrs);
>>                       if (map == SWIOTLB_MAP_ERROR) {
>>                               dev_warn(hwdev, "swiotlb buffer is full\n");
>>                               /* Don't panic here, we expect map_sg users
>>                                  to do proper error handling. */
>> +                             attrs |= DMA_ATTR_SKIP_CPU_SYNC;
>>                               xen_swiotlb_unmap_sg_attrs(hwdev, sgl, i, dir,
>>                                                          attrs);
>>                               sg_dma_len(sgl) = 0;

The biggest difference from patch 2 in the RFC is right here.  This
code before was moving this off to the end of the function and adding
a label which I then jumped to.  I just ORed the
DMA_ATTR_SKIP_CPU_SYNC into attrs and skipped the problem entirely.
It should be harmless to do this way since attrs isn't used anywhere
else once we have had the error.

I hope that helps to clear it up.  So if you want I will add your
Acked-by for patches 2 and 3, but I just wanted to make sure this
worked with the changes you suggested.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
