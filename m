Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5846B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 10:53:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t193so30189402wmt.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 07:53:03 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 196si15087477wmp.155.2017.03.06.07.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 07:53:00 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id u132so6420200wmg.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 07:53:00 -0800 (PST)
Date: Mon, 6 Mar 2017 16:52:57 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 10/12] staging: android: ion: Use CMA APIs directly
Message-ID: <20170306155257.y5tnlq4orv2xkjbd@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <0541f57b-4060-ea10-7173-26ae77777518@redhat.com>
 <20170306103204.d3yf6woxpsqvdakp@phenom.ffwll.local>
 <6709093.jyTQHIiK7d@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6709093.jyTQHIiK7d@avalon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, Laura Abbott <labbott@redhat.com>, dri-devel@lists.freedesktop.org, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Mon, Mar 06, 2017 at 03:43:53PM +0200, Laurent Pinchart wrote:
> Hi Daniel,
> 
> On Monday 06 Mar 2017 11:32:04 Daniel Vetter wrote:
> > On Fri, Mar 03, 2017 at 10:50:20AM -0800, Laura Abbott wrote:
> > > On 03/03/2017 08:41 AM, Laurent Pinchart wrote:
> > >> On Thursday 02 Mar 2017 13:44:42 Laura Abbott wrote:
> > >>> When CMA was first introduced, its primary use was for DMA allocation
> > >>> and the only way to get CMA memory was to call dma_alloc_coherent. This
> > >>> put Ion in an awkward position since there was no device structure
> > >>> readily available and setting one up messed up the coherency model.
> > >>> These days, CMA can be allocated directly from the APIs. Switch to
> > >>> using this model to avoid needing a dummy device. This also avoids
> > >>> awkward caching questions.
> > >> 
> > >> If the DMA mapping API isn't suitable for today's requirements anymore,
> > >> I believe that's what needs to be fixed, instead of working around the
> > >> problem by introducing another use-case-specific API.
> > > 
> > > I don't think this is a usecase specific API. CMA has been decoupled from
> > > DMA already because it's used in other places. The trying to go through
> > > DMA was just another layer of abstraction, especially since there isn't
> > > a device available for allocation.
> > 
> > Also, we've had separation of allocation and dma-mapping since forever,
> > that's how it works almost everywhere. Not exactly sure why/how arm-soc
> > ecosystem ended up focused so much on dma_alloc_coherent.
> 
> I believe because that was the easy way to specify memory constraints. The API 
> receives a device pointer and will allocate memory suitable for DMA for that 
> device. The fact that it maps it to the device is a side-effect in my opinion.
> 
> > I think separating allocation from dma mapping/coherency is perfectly
> > fine, and the way to go.
> 
> Especially given that in many cases we'll want to share buffers between 
> multiple devices, so we'll need to map them multiple times.
> 
> My point still stands though, if we want to move towards a model where 
> allocation and mapping are decoupled, we need an allocation function that 
> takes constraints (possibly implemented with two layers, a constraint 
> resolution layer on top of a pool/heap/type/foo-based allocator), and a 
> mapping API. IOMMU handling being integrated in the DMA mapping API we're 
> currently stuck with it, which might call for brushing up that API.

Hm, maybe I wasn't clear, but that's exactly what I assume will happen:

The constraint resolver is the unix device memory allocation thing, which
happens entirely in userspace. There's a lot more than just "where to
allocate" to negotiate, e.g. pixel format, stride/size
limits/requirements, tiling formats. A lot of it the kernel doesn't even
know.

Allocation then needs to happen through the kernel ofc, but that doesn't
mean we need to have all the constraint resolving in the kernel. As long
as the kernel exposes the device /dev node -> ion heap stuff, userspace
can figure this out. Or an alternative way would be to have a cascade of
ion heaps to keep things a notch more opaque. Either way, no actaul
constraint resolving in the kernel itself, and except for a bunch more
stuff in sysfs maybe, also no other uapi changes. Once we have a place to
allocate stuff which isn't the device driver at least, aka ION.

And then once allocated you use the dma apis to instantiate the iommus
mappings.

Anyway, at least from my understanding I think there's 0 risk with merging
ION wrt the constraint resolving side (at least as discussed around XDC
last year), and for setups that need cma, it might finally enable to get
things moving forward.

Or do I miss something big here?
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
