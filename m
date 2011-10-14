Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A66226B01FE
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 11:34:43 -0400 (EDT)
Received: by wyi40 with SMTP id 40so4154892wyi.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 08:34:39 -0700 (PDT)
Date: Fri, 14 Oct 2011 17:35:17 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
Message-ID: <20111014152139.GA2908@phenom.ffwll.local>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
 <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
 <4E98085A.8080803@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E98085A.8080803@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, Sumit Semwal <sumit.semwal@linaro.org>

On Fri, Oct 14, 2011 at 12:00:58PM +0200, Tomasz Stanislawski wrote:
> >+/**
> >+ * struct dma_buf_ops - operations possible on struct dma_buf
> >+ * @create: creates a struct dma_buf of a fixed size. Actual allocation
> >+ *	    does not happen here.
> 
> The 'create' ops is not present in dma_buf_ops.
> 
> >+ * @attach: allows different devices to 'attach' themselves to the given
> >+ *	    buffer. It might return -EBUSY to signal that backing storage
> >+ *	    is already allocated and incompatible with the requirements
> >+ *	    of requesting device. [optional]
> >+ * @detach: detach a given device from this buffer. [optional]
> >+ * @get_scatterlist: returns list of scatter pages allocated, increases
> >+ *		     usecount of the buffer. Requires atleast one attach to be
> >+ *		     called before. Returned sg list should already be mapped
> >+ *		     into _device_ address space.
> 
> You must add a comment that this call 'may sleep'.
> 
> I like the get_scatterlist idea. It allows the exported to create a
> valid scatterlist for a client in a elegant way.
> 
> I do not like this whole attachment idea. The problem is that
> currently there is no support in DMA framework for allocation for
> multiple devices. As long as no such a support exists, there is no
> generic way to handle attribute negotiations and buffer allocations
> that involve multiple devices. So the exporter drivers would have to
> implement more or less hacky solutions to handle memory requirements
> and choosing the device that allocated memory.
> 
> Currently, AFAIK there is even no generic way for a driver to
> acquire its own DMA memory requirements.
> 
> Therefore all logic hidden beneath 'attachment' is pointless. I
> think that support for attach/detach (and related stuff) should be
> postponed until support for multi-device allocation is added to DMA
> framework.

Imo we clearly need this to make the multi-device-driver with insane dma
requirements work on arm. And rewriting the buffer handling in
participating subsystem twice isn't really a great plan. I envision that
on platforms where we need this madness, the driver must call back to the
dma subsytem to create a dma_buf. The dma subsytem should be already aware
of all the requirements and hence should be able to handle them..

> I don't say the attachment list idea is wrong but adding attachment
> stuff creates an illusion that problem of multi-device allocations
> is somehow magically solved. We should not force the developers of
> exporter drivers to solve the problem that is not solvable yet.

Well, this is why we need to create a decent support infrastructure for
platforms (= arm madness) that needs this, so that device drivers and
subsystem don't need to invent that wheel on their own. Which as you point
out, they actually can't.

> The other problem are the APIs. For example, the V4L2 subsystem
> assumes that memory is allocated after successful VIDIOC_REQBUFS
> with V4L2_MEMORY_MMAP memory type. Therefore attach would be
> automatically followed by get_scatterlist, blocking possibility of
> any buffer migrations in future.

Well, pardon to break the news, but v4l needs to rework the buffer
handling. If you want to share buffers with a gpu driver, you _have_ to
life with the fact that gpus do fully dynamic buffer management, meaning:
- buffers get allocated and destroyed on the fly, meaning static reqbuf
  just went out the window (we obviously cache buffer objects and reuse
  them for performance, as long as the processing pipeline doesn't really
  change).
- buffers get moved around in memory, meaning you either need full-blown
  sync-objects with a callback to drivers to tear-down mappings on-demand,
  or every driver needs to guarnatee to call put_scatterlist in a
  reasonable short time. The latter is probably the more natural thing for
  v4l devices.

> The same situation happens if buffer sharing is added to framebuffer API.

You can fix that by using the gem/ttm infrastructure of drm (or whatever
the blob gpu drivers are using). Which is why I think fb should just die,
please.

> The buffer sharing mechanism is dedicated to improve cooperation
> between multiple APIs. Therefore the common denominator strategy
> should be applied that is buffer-creation == buffer-allocation.

No.

Really, there's just no way gpu's will be moving back to static buffer
management. And I know, for many use-cases we could get away with a bunch
of static buffers (e.g. a video processing pipe). But in drm-land even
scanout-buffers can get moved around - currently only when they're not
being used, but strictly speaking nothing prevents us from copying the
scanout to a new location and issueing a pageflip and so even move the
buffer around even when it's in use.

But let's look quickly at an OpenCL usecase, moving Gb's of date per
second around between the cpu and a bunch of add-on gpus (or other special
purpose processing units). We'd also need to extend dma_buf with sync
objects to make this work well, but there's simply no way this is gonna
work with statically allocated objects.

Also, gem buffer objects that are currently unused can be swapped out.

Cheers, Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
