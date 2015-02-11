Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id C2AC06B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 06:23:53 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so750722iec.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 03:23:53 -0800 (PST)
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com. [209.85.223.176])
        by mx.google.com with ESMTPS id eh8si11367538igb.48.2015.02.11.03.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 03:23:53 -0800 (PST)
Received: by iecrl12 with SMTP id rl12so750677iec.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 03:23:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211111258.GP8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
	<1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
	<54DB12B5.4080000@samsung.com>
	<20150211111258.GP8656@n2100.arm.linux.org.uk>
Date: Wed, 11 Feb 2015 06:23:52 -0500
Message-ID: <CAF6AEGscETLVnhg7zTFHQbj2KmX150VPaVHsqjvyJnVfHnHkOQ@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Sumit Semwal <sumit.semwal@linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Daniel Vetter <daniel@ffwll.ch>

On Wed, Feb 11, 2015 at 6:12 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Feb 11, 2015 at 09:28:37AM +0100, Marek Szyprowski wrote:
>> Hello,
>>
>> On 2015-01-27 09:25, Sumit Semwal wrote:
>> >Add some helpers to share the constraints of devices while attaching
>> >to the dmabuf buffer.
>> >
>> >At each attach, the constraints are calculated based on the following:
>> >- max_segment_size, max_segment_count, segment_boundary_mask from
>> >    device_dma_parameters.
>> >
>> >In case the attaching device's constraints don't match up, attach() fails.
>> >
>> >At detach, the constraints are recalculated based on the remaining
>> >attached devices.
>> >
>> >Two helpers are added:
>> >- dma_buf_get_constraints - which gives the current constraints as calculated
>> >       during each attach on the buffer till the time,
>> >- dma_buf_recalc_constraints - which recalculates the constraints for all
>> >       currently attached devices for the 'paranoid' ones amongst us.
>> >
>> >The idea of this patch is largely taken from Rob Clark's RFC at
>> >https://lkml.org/lkml/2012/7/19/285, and the comments received on it.
>> >
>> >Cc: Rob Clark <robdclark@gmail.com>
>> >Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
>>
>> The code looks okay, although it will probably will work well only with
>> typical cases like 'contiguous memory needed' or 'no constraints at all'
>> (iommu).
>
> Which is a damn good reason to NAK it - by that admission, it's a half-baked
> idea.
>
> If all we want to know is whether the importer can accept only contiguous
> memory or not, make a flag to do that, and allow the exporter to test this
> flag.  Don't over-engineer this to make it _seem_ like it can do something
> that it actually totally fails with.

jfyi, I agree with that.. I think the flag is probably the right
approach to start with.  At the end of the day it *is* still just an
in-kernel API (and not something that ends up as userspace ABI) so
when we come up with the use case to make it more generic we can.  Vs.
making it look like something more generic when it isn't really yet.

> As I've already pointed out, there's a major problem if you have already
> had a less restrictive attachment which has an active mapping, and a new
> more restrictive attachment comes along later.
>
> It seems from Rob's descriptions that we also need another flag in the
> importer to indicate whether it wants to have a valid struct page in the
> scatter list, or whether it (correctly) uses the DMA accessors on the
> scatter list - so that exporters can reject importers which are buggy.

to be completely generic, we would really need a way that the device
could take over only just the last iommu (in case there were multiple
levels of address translation)..

I'm not completely sure, but I *think* the other arm gpu's have their
own internal mmu for doing context switching, etc, so if there is an
additional iommu in front of them they may actually still want to use
the normal dma api's.  Someone please contradict me if I am wrong.  If
this ends up being an issue only for msm, then I'm completely ok with
the easier option of a less generic solution..

BR,
-R

>
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
