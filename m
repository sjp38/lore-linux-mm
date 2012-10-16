Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9667D6B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 06:12:50 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so7435615vbk.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:12:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016090434.7d5e088152a3e0b0606903c8@nvidia.com>
References: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
	<CAAQKjZMYFNMEnb2ue2aR+6AEbOixnQFyggbXrThBCW5VOznePg@mail.gmail.com>
	<20121016090434.7d5e088152a3e0b0606903c8@nvidia.com>
Date: Tue, 16 Oct 2012 19:12:49 +0900
Message-ID: <CAAQKjZNQFfxpr-7dFb4cgNB2Gkrxxrswds_fSrYgssxXaqRF7g@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] DMA-mapping & IOMMU - physically
 contiguous allocations
From: Inki Dae <inki.dae@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-tegra@vger.kernel.org

Hi Hiroshi,

2012/10/16 Hiroshi Doyu <hdoyu@nvidia.com>:
> Hi Inki/Marek,
>
> On Tue, 16 Oct 2012 02:50:16 +0200
> Inki Dae <inki.dae@samsung.com> wrote:
>
>> 2012/10/15 Marek Szyprowski <m.szyprowski@samsung.com>:
>> > Hello,
>> >
>> > Some devices, which have IOMMU, for some use cases might require to
>> > allocate a buffers for DMA which is contiguous in physical memory. Such
>> > use cases appears for example in DRM subsystem when one wants to improve
>> > performance or use secure buffer protection.
>> >
>> > I would like to ask if adding a new attribute, as proposed in this RFC
>> > is a good idea? I feel that it might be an attribute just for a single
>> > driver, but I would like to know your opinion. Should we look for other
>> > solution?
>> >
>>
>> In addition, currently we have worked dma-mapping-based iommu support
>> for exynos drm driver with this patch set so this patch set has been
>> tested with iommu enabled exynos drm driver and worked fine. actually,
>> this feature is needed for secure mode such as TrustZone. in case of
>> Exynos SoC, memory region for secure mode should be physically
>> contiguous and also maybe OMAP but now dma-mapping framework doesn't
>> guarantee physically continuous memory allocation so this patch set
>> would make it possible.
>
> Agree that the contigous memory allocation is necessary for us too.
>
> In addition to those contiguous/discontiguous page allocation, is
> there any way to _import_ anonymous pages allocated by a process to be
> used in dma-mapping API later?
>
> I'm considering the following scenario, an user process allocates a
> buffer by malloc() in advance, and then it asks some driver to convert
> that buffer into IOMMU'able/DMA'able ones later. In this case, pages
> are discouguous and even they may not be yet allocated at
> malloc()/mmap().
>

I'm not sure I understand what you mean but we had already tried this
way and for this, you can refer to below link,
               http://www.mail-archive.com/dri-devel@lists.freedesktop.org/msg22555.html

but this way had been pointed out by drm guys because the pages could
be used through gem object after that pages had been freed by free()
anyway their pointing was reasonable and I'm trying another way, this
is the way that the pages to user space has same life time with dma
operation. in other word, if dma completed access to that pages then
also that pages will be freed. actually drm-based via driver of
mainline kernel is using same way


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
