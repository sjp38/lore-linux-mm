Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id BDDEF900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 05:37:54 -0400 (EDT)
Received: by wibdt2 with SMTP id dt2so5485109wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 02:37:54 -0700 (PDT)
Received: from lb1-smtp-cloud2.xs4all.net (lb1-smtp-cloud2.xs4all.net. [194.109.24.21])
        by mx.google.com with ESMTPS id hq3si868409wib.22.2015.06.03.02.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 02:37:53 -0700 (PDT)
Message-ID: <556ECACC.9000207@xs4all.nl>
Date: Wed, 03 Jun 2015 11:37:16 +0200
From: Hans Verkuil <hverkuil@xs4all.nl>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing
 attacher constraints with dma-parms
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org> <54DB12B5.4080000@samsung.com> <20150211111258.GP8656@n2100.arm.linux.org.uk> <54DB4908.10004@samsung.com> <20150211162312.GR8656@n2100.arm.linux.org.uk> <CAO_48GHf=Zt7Ju=N=FAVfaudApSV+rSfb+Wou7L1Dh3egULm9g@mail.gmail.com> <556EA13B.7080306@xs4all.nl> <20150603084115.GC7557@n2100.arm.linux.org.uk>
In-Reply-To: <20150603084115.GC7557@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rob Clark <robdclark@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On 06/03/15 10:41, Russell King - ARM Linux wrote:
> On Wed, Jun 03, 2015 at 08:39:55AM +0200, Hans Verkuil wrote:
>> Hi Sumit,
>>
>> On 05/05/2015 04:41 PM, Sumit Semwal wrote:
>>> Hi Russell, everyone,
>>>
>>> First up, sincere apologies for being awol for sometime; had some
>>> personal / medical things to take care of, and then I thought I'd wait
>>> for the merge window to get over before beginning to discuss this
>>> again.
>>>
>>> On 11 February 2015 at 21:53, Russell King - ARM Linux
>>> <linux@arm.linux.org.uk> wrote:
>>>> On Wed, Feb 11, 2015 at 01:20:24PM +0100, Marek Szyprowski wrote:
>>>>> Hello,
>>>>>
>>>>> On 2015-02-11 12:12, Russell King - ARM Linux wrote:
>>>>>> Which is a damn good reason to NAK it - by that admission, it's a half-baked
>>>>>> idea.
>>>>>>
>>>>>> If all we want to know is whether the importer can accept only contiguous
>>>>>> memory or not, make a flag to do that, and allow the exporter to test this
>>>>>> flag.  Don't over-engineer this to make it _seem_ like it can do something
>>>>>> that it actually totally fails with.
>>>>>>
>>>>>> As I've already pointed out, there's a major problem if you have already
>>>>>> had a less restrictive attachment which has an active mapping, and a new
>>>>>> more restrictive attachment comes along later.
>>>>>>
>>>>>> It seems from Rob's descriptions that we also need another flag in the
>>>>>> importer to indicate whether it wants to have a valid struct page in the
>>>>>> scatter list, or whether it (correctly) uses the DMA accessors on the
>>>>>> scatter list - so that exporters can reject importers which are buggy.
>>>>>
>>>>> Okay, but flag-based approach also have limitations.
>>>>
>>>> Yes, the flag-based approach doesn't let you describe in detail what
>>>> the importer can accept - which, given the issues that I've raised
>>>> is a *good* thing.  We won't be misleading anyone into thinking that
>>>> we can do something that's really half-baked, and which we have no
>>>> present requirement for.
>>>>
>>>> This is precisely what Linus talks about when he says "don't over-
>>>> engineer" - if we over-engineer this, we end up with something that
>>>> sort-of works, and that's a bad thing.
>>>>
>>>> The Keep It Simple approach here makes total sense - what are our
>>>> current requirements - to be able to say that an importer can only accept:
>>>>   - contiguous memory rather than a scatterlist
>>>>   - scatterlists with struct page pointers
>>>>
>>>> Does solving that need us to compare all the constraints of each and
>>>> every importer, possibly ending up with constraints which can't be
>>>> satisfied?  No.  Does the flag approach satisfy the requirements?  Yes.
>>>>
>>>
>>> So, for basic constraint-sharing, we'll just go with the flag based
>>> approach, with a flag (best place for it is still dev->dma_params I
>>> suppose) for denoting contiguous or scatterlist. Is that agreed, then?
>>> Also, with this idea, of course, there won't be any helpers for trying
>>> to calculate constraints; it would be totally the exporter's
>>> responsibility to handle it via the attach() dma_buf_op if it wishes
>>> to.
>>
>> What's wrong with the proposed max_segment_count? Many media devices do
>> have a limited max_segment_count and that should be taken into account.
> 
> So what happens if you have a dma_buf exporter, and several dma_buf
> importers.  One dma_buf importer attaches to the exporter, and asks
> for the buffer, and starts making use of the buffer.  This export has
> many scatterlist segments.
> 
> Another dma_buf importer attaches to the same buffer, and now asks for
> the buffer, but the number of scatterlist segments exceeds it's
> requirement.
> 
> You can't reallocate the buffer because it's in-use by another importer.
> There is no way to revoke the buffer from the other importer.  So there
> is no way to satisfy this importer's requirements.
> 
> What I'm showing is that the idea that exporting these parameters fixes
> some problem is just an illusion - it may work for the single importer
> case, but doesn't for the multiple importer case.
> 
> Importers really have two choices here: either they accept what the
> exporter is giving them, or they reject it.

I agree completely with that.

> The other issue here is that DMA scatterlists are _not_ really that
> determinable in terms of number of entries when it comes to systems with
> system IOMMUs.  System IOMMUs, which should be integrated into the DMA
> API, are permitted to coalesce entries in the physical page range.  For
> example:
> 
> 	nsg = 128;
> 	n = dma_map_sg(dev, sg, nsg, DMA_TO_DEVICE);
> 
> Here, n might be 4 if the system IOMMU has been able to coalesce the 128
> entries down to 4 IOMMU entries - and that means for DMA purposes, only
> the first four scatterlist entries should be walked (this is why
> dma_map_sg() returns a positive integer when mapping.)
> 
> Each struct device has a set of parameters which control how the IOMMU
> entries are coalesced:
> 
> struct device_dma_parameters {
>         /*
>          * a low level driver may set these to teach IOMMU code about
>          * sg limitations.
>          */
>         unsigned int max_segment_size;
>         unsigned long segment_boundary_mask;
> };
> 
> and this is independent of the dma_buf API.  This doesn't indicate the
> maximum number of segments, but as I've shown above, it's not something
> that you can say "I want a scatterlist for this memory with only 32
> segments" so it's totally unclear how an exporter would limit that.
> 
> The only thing an exporter could do would be to fail the export if the
> buffer didn't end up having fewer than the requested scatterlist entries,
> which is something the importer can do too.

Right.

>> One of the main problems end-users are faced with today is that they do not
>> know which device should be the exporter of buffers and which should be the
>> importer. This depends on the constraints and right now applications have
>> no way of knowing this. It's nuts that this hasn't been addressed yet since
>> it is the main complaint I am getting.
> 
> IT's nuts that we've ended up in this situation in the first place.  This
> was bound to happen as soon as the dma_buf sharing was introduced, because
> it immediately introduced this problem.  I don't think there is any easy
> solution to it, and what's being proposed with flags and other stuff is
> just trying to paper over the problem.

This was the first thing raised in the initial discussions. My suggestion at
the time was to give userspace limited information about the buffer restrictions:
Physically contiguous, scatter-gather and 'weird'. But obviously you need
segment_boundary_mask and max_segment_size as well.

And the application can decide based on that info which device has the most
restrictive requirements and make that the exporter.

I am not sure whether there is any sense in exporting the max_segment_count
to userspace (probably not), but I see no reason why we can't set it internally.
That said, a single flag is OK for me as well.

> What you're actually asking is that each dmabuf exporting subsystem needs
> to publish their DMA parameters to userspace, and userspace then gets to
> decide which dmabuf exporter should be used.

Yes, that was the initial plan.

> That's not a dmabuf problem, that's a subsystem problem,

Well, yes, but it doesn't hurt to sync which DMA parameters are exposed with
what dma-buf uses.

> but even so, we
> don't have a standardised way to export that information (and I'd suspect
> that it would be very difficult to get agreements between subsystems on
> a standard ioctl and/or data structure.)  In my experience, getting cross-
> subsystem agreement in the kernel with anything is very difficult, you
> normally end up with 60% of people agreeing, and the other 40% going off
> and doing something completely different because they object to it
> (figures vary, 90% of all statistics are made up on the spot!)

I don't care which ioctl or other mechanism a subsystem uses to expose the
information. Each subsystem should design their own method for that. Imposing
a standard API for that generally doesn't work for the reasons you give.

But deciding *which* minimum set of information is exposed, that is another
matter and that should be synced. And the easiest starting point for that is
that the device will store that information internally in device_dma_parameters.

The various subsystems can then make APIs to expose that info.

Regards,

	Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
