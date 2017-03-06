Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1466B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:43:18 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u108so53121426wrb.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:43:18 -0800 (PST)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [185.26.127.97])
        by mx.google.com with ESMTPS id i79si14686822wme.61.2017.03.06.05.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:43:17 -0800 (PST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [RFC PATCH 10/12] staging: android: ion: Use CMA APIs directly
Date: Mon, 06 Mar 2017 15:43:53 +0200
Message-ID: <6709093.jyTQHIiK7d@avalon>
In-Reply-To: <20170306103204.d3yf6woxpsqvdakp@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com> <0541f57b-4060-ea10-7173-26ae77777518@redhat.com> <20170306103204.d3yf6woxpsqvdakp@phenom.ffwll.local>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Laura Abbott <labbott@redhat.com>, dri-devel@lists.freedesktop.org, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hi Daniel,

On Monday 06 Mar 2017 11:32:04 Daniel Vetter wrote:
> On Fri, Mar 03, 2017 at 10:50:20AM -0800, Laura Abbott wrote:
> > On 03/03/2017 08:41 AM, Laurent Pinchart wrote:
> >> On Thursday 02 Mar 2017 13:44:42 Laura Abbott wrote:
> >>> When CMA was first introduced, its primary use was for DMA allocation
> >>> and the only way to get CMA memory was to call dma_alloc_coherent. This
> >>> put Ion in an awkward position since there was no device structure
> >>> readily available and setting one up messed up the coherency model.
> >>> These days, CMA can be allocated directly from the APIs. Switch to
> >>> using this model to avoid needing a dummy device. This also avoids
> >>> awkward caching questions.
> >> 
> >> If the DMA mapping API isn't suitable for today's requirements anymore,
> >> I believe that's what needs to be fixed, instead of working around the
> >> problem by introducing another use-case-specific API.
> > 
> > I don't think this is a usecase specific API. CMA has been decoupled from
> > DMA already because it's used in other places. The trying to go through
> > DMA was just another layer of abstraction, especially since there isn't
> > a device available for allocation.
> 
> Also, we've had separation of allocation and dma-mapping since forever,
> that's how it works almost everywhere. Not exactly sure why/how arm-soc
> ecosystem ended up focused so much on dma_alloc_coherent.

I believe because that was the easy way to specify memory constraints. The API 
receives a device pointer and will allocate memory suitable for DMA for that 
device. The fact that it maps it to the device is a side-effect in my opinion.

> I think separating allocation from dma mapping/coherency is perfectly
> fine, and the way to go.

Especially given that in many cases we'll want to share buffers between 
multiple devices, so we'll need to map them multiple times.

My point still stands though, if we want to move towards a model where 
allocation and mapping are decoupled, we need an allocation function that 
takes constraints (possibly implemented with two layers, a constraint 
resolution layer on top of a pool/heap/type/foo-based allocator), and a 
mapping API. IOMMU handling being integrated in the DMA mapping API we're 
currently stuck with it, which might call for brushing up that API.

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
