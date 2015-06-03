Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9D66A900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:40:05 -0400 (EDT)
Received: by wibdt2 with SMTP id dt2so171837wib.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:40:05 -0700 (PDT)
Received: from lb3-smtp-cloud6.xs4all.net (lb3-smtp-cloud6.xs4all.net. [194.109.24.31])
        by mx.google.com with ESMTPS id fu5si78442wic.82.2015.06.02.23.40.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 23:40:04 -0700 (PDT)
Message-ID: <556EA13B.7080306@xs4all.nl>
Date: Wed, 03 Jun 2015 08:39:55 +0200
From: Hans Verkuil <hverkuil@xs4all.nl>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing
 attacher constraints with dma-parms
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org> <54DB12B5.4080000@samsung.com> <20150211111258.GP8656@n2100.arm.linux.org.uk> <54DB4908.10004@samsung.com> <20150211162312.GR8656@n2100.arm.linux.org.uk> <CAO_48GHf=Zt7Ju=N=FAVfaudApSV+rSfb+Wou7L1Dh3egULm9g@mail.gmail.com>
In-Reply-To: <CAO_48GHf=Zt7Ju=N=FAVfaudApSV+rSfb+Wou7L1Dh3egULm9g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rob Clark <robdclark@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

Hi Sumit,

On 05/05/2015 04:41 PM, Sumit Semwal wrote:
> Hi Russell, everyone,
> 
> First up, sincere apologies for being awol for sometime; had some
> personal / medical things to take care of, and then I thought I'd wait
> for the merge window to get over before beginning to discuss this
> again.
> 
> On 11 February 2015 at 21:53, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
>> On Wed, Feb 11, 2015 at 01:20:24PM +0100, Marek Szyprowski wrote:
>>> Hello,
>>>
>>> On 2015-02-11 12:12, Russell King - ARM Linux wrote:
>>>> Which is a damn good reason to NAK it - by that admission, it's a half-baked
>>>> idea.
>>>>
>>>> If all we want to know is whether the importer can accept only contiguous
>>>> memory or not, make a flag to do that, and allow the exporter to test this
>>>> flag.  Don't over-engineer this to make it _seem_ like it can do something
>>>> that it actually totally fails with.
>>>>
>>>> As I've already pointed out, there's a major problem if you have already
>>>> had a less restrictive attachment which has an active mapping, and a new
>>>> more restrictive attachment comes along later.
>>>>
>>>> It seems from Rob's descriptions that we also need another flag in the
>>>> importer to indicate whether it wants to have a valid struct page in the
>>>> scatter list, or whether it (correctly) uses the DMA accessors on the
>>>> scatter list - so that exporters can reject importers which are buggy.
>>>
>>> Okay, but flag-based approach also have limitations.
>>
>> Yes, the flag-based approach doesn't let you describe in detail what
>> the importer can accept - which, given the issues that I've raised
>> is a *good* thing.  We won't be misleading anyone into thinking that
>> we can do something that's really half-baked, and which we have no
>> present requirement for.
>>
>> This is precisely what Linus talks about when he says "don't over-
>> engineer" - if we over-engineer this, we end up with something that
>> sort-of works, and that's a bad thing.
>>
>> The Keep It Simple approach here makes total sense - what are our
>> current requirements - to be able to say that an importer can only accept:
>>   - contiguous memory rather than a scatterlist
>>   - scatterlists with struct page pointers
>>
>> Does solving that need us to compare all the constraints of each and
>> every importer, possibly ending up with constraints which can't be
>> satisfied?  No.  Does the flag approach satisfy the requirements?  Yes.
>>
> 
> So, for basic constraint-sharing, we'll just go with the flag based
> approach, with a flag (best place for it is still dev->dma_params I
> suppose) for denoting contiguous or scatterlist. Is that agreed, then?
> Also, with this idea, of course, there won't be any helpers for trying
> to calculate constraints; it would be totally the exporter's
> responsibility to handle it via the attach() dma_buf_op if it wishes
> to.

What's wrong with the proposed max_segment_count? Many media devices do have a
limited max_segment_count and that should be taken into account.

Although to be fair I have to say that in practice the limited segment counts
are all well above what is needed for a normal capture buffer, but it might
be reached if you have video strides > line width, so each line has its own segment
(or two, if there is a page boundary in the middle of the line). It's a somewhat
contrived use-case, though, although I have done this once myself.

Anyway, the worst-case number of segments would be:

height * ((bytesperline + PAGE_SIZE - 1) / PAGE_SIZE)

That might well exceed the max segment count for some devices.

I think I have also seen devices in the past that have a coarse-grained IOMMU that
uses very large segment sizes, but have a very limited segment count. We don't
have media drivers like that, and to be honest I am not sure whether we should
bother too much with this corner case.

>>> Frankly, if we want to make it really portable and sharable between devices,
>>> then IMO we should get rid of struct scatterlist and replace it with simple
>>> array of pfns in dma_buf. This way at least the problem of missing struct
>>> page will be solved and the buffer representation will be also a bit more
>>> compact.
>>
>> ... and move the mapping and unmapping of the PFNs to the importer,
>> which IMHO is where it should already be (so the importer can decide
>> when it should map the buffer itself independently of getting the
>> details of the buffer.)
>>
>>> Such solution however also requires extending dma-mapping API to handle
>>> mapping and unmapping of such pfn arrays. The advantage of this approach
>>> is the fact that it will be completely new API, so it can be designed
>>> well from the beginning.
>>
>> As far as I'm aware, there was no big discussion of the dma_buf API -
>> it's something that just appeared one day (I don't remember seeing it
>> discussed.)  So, that may well be a good thing if it means we can get
>> these kinds of details better hammered out.
>>
>> However, I don't share your view of "completely new API" - that would
>> be far too disruptive.  I think we can modify the existing API, to
>> achieve our goals.
>>
>> I don't think changing the dma-mapping API just for this case is really
>> on though - if we're passed a list of PFNs, they either must be all
>> associated with a struct page - iow, pfn_valid(pfn) returns true for
>> all of them or none of them.  If none of them, then we need to be able
>> to convert those PFNs to a dma_addr_t for the target device (yes, that
>> may need the dma-mapping API augmenting.)
>>
>> However, if they are associated with a struct page, then we should use
>> the established APIs and use a scatterlist, otherwise we're looking
>> at rewriting all IOMMUs and all DMA mapping implementations to handle
>> what would become a special case for dma_buf.
>>
>> I'd rather... Keep It Simple.
>>
> +1 for Keep it simple, and the idea overall. Though I suspect more
> dma-buf users (dri / v4l friends?) should comment if this doesn't help
> solve things on some platforms / subsystems that they care about.
> 
>> So, maybe, as a first step, let's augment dma_buf with a pair of
>> functions which get the "raw" unmapped scatterlist:
>>
>> struct sg_table *dma_buf_get_scatterlist(struct dma_buf_attachment *attach)
>> {
>>         struct sg_table *sg_table;
>>
>>         might_sleep();
>>
>>         if (!attach->dmabuf->ops->get_scatterlist)
>>                 return ERR_PTR(-EINVAL);
>>
>>         sg_table = attach->dmabuf->ops->get_scatterlist(attach);
>>         if (!sg_table)
>>                 sg_table = ERR_PTR(-ENOMEM);
>>
>>         return sg_table;
>> }
>>
>> void dma_buf_put_scatterlist(struct dma_buf_attachment *attach,
>>                              struct sg_table *sg_table)
>> {
>>         might_sleep();
>>
>>         attach->dmabuf->ops->put_scatterlist(attach, sg_table);
>> }
>>
>> Implementations should arrange for dma_buf_get_scatterlist() to return
>> the EINVAL error pointer if they are unable to provide an unmapped
>> scatterlist (in other words, they are exporting a set of PFNs or
>> already-mapped dma_addr_t's.)  This can be done by either not
>> implementing the get_scatterlist method, or by implementing it and
>> returning that forementioned error pointer value.
>>
>> Where these two are implemented and used, the importer is responsible
>> for calling dma_map_sg() and dma_unmap_sg() on the returned scatterlist
>> table.
>>
>> unsigned long *dma_buf_get_pfns(struct dma_buf_attachment *attach)
>> {
>>         unsigned long *pfns;
>>
>>         might_sleep();
>>
>>         if (!attach->dmabuf->ops->get_pfns)
>>                 return ERR_PTR(-EINVAL);
>>
>>         return attach->dmabuf->ops->get_pfns(attach);
>> }
>>
>> void dma_buf_put_pfns(struct dma_buf_attachment *attach, unsigned long *pfns)
>> {
>>         might_sleep();
>>
>>         attach->dmabuf->ops->put_pfns(attach, pfns);
>> }
>>
>> Similar to the above, but this gets a list of PFNs.  Each PFN entry prior
>> to the last describes a page starting at offset 0 extending to the end of
>> the page.  The last PFN entry describes a page starting at offset 0 and
>> extending to the offset of the attachment size within the page.  Again,
>> if not implemented or it is not possible to represent the buffer as PFNs,
>> it returns -EINVAL.
>>
>> For the time being, we keep the existing dma_buf_map_attachment() and
>> dma_buf_unmap_attachment() while we transition users over to the new
>> interfaces.
>>
>> We may wish to augment struct dma_buf_attachment with a couple of flags
>> to indicate which of these the attached dma_buf supports, so that drivers
>> can deal with these themselves.
>>
> Could I please send a patchset first for the constraint-flags
> addition, and then take this up in a following patch-set, once we have
> agreement from other stake holders as well?

+1

One of the main problems end-users are faced with today is that they do not
know which device should be the exporter of buffers and which should be the
importer. This depends on the constraints and right now applications have
no way of knowing this. It's nuts that this hasn't been addressed yet since
it is the main complaint I am getting.

And it is something that the V4L2 API needs to export to userland anyway for
both the above and some other V4L2-specific reasons.

BTW, one thing I didn't see in the constraints discussion (but I didn't read
everything, so I may very well have missed it), is reporting whether memory
is opaque (i.e. cannot be mapped by non-trusted devices). No, I don't have
such hardware, but I know it exists. All the constraints mentioned so far
apply to such memory as well, but this is an additional flag (or perhaps some
trust ID). I don't think anyone made drivers for such hardware, although I
recently saw someone working on something like that.

Does anyone know about someone working in this area? Or existing code for this?

All I am saying is that this is sure to appear at some point.

Regards,

	Hans

> Russell: would it be ok if we discuss it offline more? I am afraid I
> am not as knowledgeable on this topic, and would probably request your
> help / guidance here.
> 
>> We may also wish in the longer term to keep dma_buf_map_attachment() but
>> implement it as a wrapper around get_scatterlist() as a helper to provide
>> its existing functionality - providing a mapped scatterlist.  Possibly
>> also including get_pfns() in that as well if we need to.
>>
>> However, I would still like more thought put into Rob's issue to see
>> whether we can solve his problem with using the dma_addr_t in a more
>> elegant way.  (I wish I had some hardware to experiment with for that.)
>>
>> --
>> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
>> according to speedtest.net.
> 
> Best regards,
> ~Sumit.
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> https://lists.linaro.org/mailman/listinfo/linaro-mm-sig
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
