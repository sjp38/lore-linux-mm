Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B2EAC6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:20:31 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so3698424pab.3
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 04:20:31 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id kj4si594996pdb.209.2015.02.11.04.20.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 11 Feb 2015 04:20:30 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJL00EA0X4W1K50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Feb 2015 12:24:33 +0000 (GMT)
Message-id: <54DB4908.10004@samsung.com>
Date: Wed, 11 Feb 2015 13:20:24 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <54DB12B5.4080000@samsung.com> <20150211111258.GP8656@n2100.arm.linux.org.uk>
In-reply-to: <20150211111258.GP8656@n2100.arm.linux.org.uk>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, robin.murphy@arm.com, robdclark@gmail.com, linaro-kernel@lists.linaro.org, stanislawski.tomasz@googlemail.com, daniel@ffwll.ch

Hello,

On 2015-02-11 12:12, Russell King - ARM Linux wrote:
> On Wed, Feb 11, 2015 at 09:28:37AM +0100, Marek Szyprowski wrote:
>> On 2015-01-27 09:25, Sumit Semwal wrote:
>>> Add some helpers to share the constraints of devices while attaching
>>> to the dmabuf buffer.
>>>
>>> At each attach, the constraints are calculated based on the following:
>>> - max_segment_size, max_segment_count, segment_boundary_mask from
>>>     device_dma_parameters.
>>>
>>> In case the attaching device's constraints don't match up, attach() fails.
>>>
>>> At detach, the constraints are recalculated based on the remaining
>>> attached devices.
>>>
>>> Two helpers are added:
>>> - dma_buf_get_constraints - which gives the current constraints as calculated
>>>        during each attach on the buffer till the time,
>>> - dma_buf_recalc_constraints - which recalculates the constraints for all
>>>        currently attached devices for the 'paranoid' ones amongst us.
>>>
>>> The idea of this patch is largely taken from Rob Clark's RFC at
>>> https://lkml.org/lkml/2012/7/19/285, and the comments received on it.
>>>
>>> Cc: Rob Clark <robdclark@gmail.com>
>>> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
>> The code looks okay, although it will probably will work well only with
>> typical cases like 'contiguous memory needed' or 'no constraints at all'
>> (iommu).
> Which is a damn good reason to NAK it - by that admission, it's a half-baked
> idea.
>
> If all we want to know is whether the importer can accept only contiguous
> memory or not, make a flag to do that, and allow the exporter to test this
> flag.  Don't over-engineer this to make it _seem_ like it can do something
> that it actually totally fails with.
>
> As I've already pointed out, there's a major problem if you have already
> had a less restrictive attachment which has an active mapping, and a new
> more restrictive attachment comes along later.
>
> It seems from Rob's descriptions that we also need another flag in the
> importer to indicate whether it wants to have a valid struct page in the
> scatter list, or whether it (correctly) uses the DMA accessors on the
> scatter list - so that exporters can reject importers which are buggy.

Okay, but flag-based approach also have limitations.

Frankly, if we want to make it really portable and sharable between devices,
then IMO we should get rid of struct scatterlist and replace it with simple
array of pfns in dma_buf. This way at least the problem of missing struct
page will be solved and the buffer representation will be also a bit more
compact.

Such solution however also requires extending dma-mapping API to handle
mapping and unmapping of such pfn arrays. The advantage of this approach
is the fact that it will be completely new API, so it can be designed
well from the beginning.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
