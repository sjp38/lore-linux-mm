Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1A36B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 15:03:16 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so46681540wgh.6
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 12:03:15 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id vv8si44913566wjc.47.2015.02.03.12.03.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 12:03:14 -0800 (PST)
Received: by mail-wi0-f182.google.com with SMTP id n3so24191275wiv.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 12:03:13 -0800 (PST)
Date: Tue, 3 Feb 2015 21:04:35 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing
 attacher constraints with dma-parms
Message-ID: <20150203200435.GX14009@phenom.ffwll.local>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <6906596.JU5vQoa1jV@wuerfel>
 <CAF6AEGsttiufoqPbDiZfUX2ndbv2XfeZzcfyaf-AcUJgJpgLkA@mail.gmail.com>
 <7233574.nKiRa7HnXU@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7233574.nKiRa7HnXU@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, Rob Clark <robdclark@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Feb 03, 2015 at 05:36:59PM +0100, Arnd Bergmann wrote:
> On Tuesday 03 February 2015 11:22:01 Rob Clark wrote:
> > On Tue, Feb 3, 2015 at 11:12 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > > I agree for the case you are describing here. From what I understood
> > > from Rob was that he is looking at something more like:
> > >
> > > Fig 3
> > > CPU--L1cache--L2cache--Memory--IOMMU---<iobus>--device
> > >
> > > where the IOMMU controls one or more contexts per device, and is
> > > shared across GPU and non-GPU devices. Here, we need to use the
> > > dmap-mapping interface to set up the IO page table for any device
> > > that is unable to address all of system RAM, and we can use it
> > > for purposes like isolation of the devices. There are also cases
> > > where using the IOMMU is not optional.
> > 
> > 
> > Actually, just to clarify, the IOMMU instance is specific to the GPU..
> > not shared with other devices.  Otherwise managing multiple contexts
> > would go quite badly..
> > 
> > But other devices have their own instance of the same IOMMU.. so same
> > driver could be used.
> 
> I think from the driver perspective, I'd view those two cases as
> identical. Not sure if Russell agrees with that.

Imo whether the iommu is private to the device and required for gpu
functionality like context switching or shared across a bunch of devices
is fairly important. Assuming I understand this discussion correctly we
have two different things pulling in opposite directions:

- From a gpu functionality perspective we want to give the gpu driver full
  control over the device-private iommu, pushing it out of the control of
  the dma api. dma_map_sg would just map to whatever bus addresses that
  iommu would need to use for generating access cycles.

  This is the design used by every gpu driver we have in upstream thus far
  (where you always have some on-gpu iommu/pagetable walker thing), on top
  of whatever system iommu that might be there or not (which is then
  managed by the dma apis).

- On many soc people love to reuse iommus with the same or similar
  interface all over the place. The solution thus far adopted on arm
  platforms is to write an iommu driver for those and then implement the
  dma-api on top of this iommu.

  But if we unconditionally do this then we rob the gpu driver's ability
  to control its private iommu like it wants to, because a lot of the
  functionality is lost behind the dma api abstraction.

Again assuming I'm not confused can't we just solve this by pushing the
dma api abstraction down one layer for just the gpu, and let it use its
private iommmu directly? Steps for binding a buffer would be:
1. dma_map_sg
2. Noodle the dma_addr_t out of the sg table and feed those into a 2nd
level mapping set up through the iommu api for the gpu-private mmu.

Again, this is what i915 and all the ttm based drivers already do, except
that we don't use the generic iommu interfaces but have our own (i915 has
its interface in i915_gem_gtt.c, ttm just calls them tt for translation
tables ...).

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
