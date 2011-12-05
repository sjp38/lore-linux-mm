Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id B17096B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 15:58:40 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2179377vbb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 12:58:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1426302.asOzFeeJzz@wuerfel>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<201112051718.48324.arnd@arndb.de>
	<CAKMK7uE-ZJ-VQRWy+zJJWsvr9nARWuf-4nupXhTJ0CLqC88CEw@mail.gmail.com>
	<1426302.asOzFeeJzz@wuerfel>
Date: Mon, 5 Dec 2011 21:58:39 +0100
Message-ID: <CAKMK7uG2U2gn-LW7Cozumfza8XngvQSWR7-S-Qiok5NA=94V=w@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Daniel Vetter <daniel@ffwll.ch>, t.stanislaws@samsung.com, linux@arm.linux.org.uk, Sumit Semwal <sumit.semwal@ti.com>, jesse.barker@linaro.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, rob@ti.com, m.szyprowski@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>, linux-media@vger.kernel.org

On Mon, Dec 05, 2011 at 08:29:49PM +0100, Arnd Bergmann wrote:
> On Monday 05 December 2011 19:55:44 Daniel Vetter wrote:
> > > The only way to solve this that I can think of right now is to
> > > mandate that the mappings are all coherent (i.e. noncachable
> > > on noncoherent architectures like ARM). If you do that, you no
> > > longer need the sync_sg_for_* calls.
> >
> > Woops, totally missed the addition of these. Can somebody explain to used
> > to rather coherent x86 what we need these for and the code-flow would look
> > like in a typical example. I was kinda assuming that devices would bracket
> > their use of a buffer with the attachment_map/unmap calls and any cache
> > coherency magic that might be needed would be somewhat transparent to
> > users of the interface?
>
> I'll describe how the respective functions work in the streaming mapping
> API (dma_map_*): You start out with a buffer that is owned by the CPU,
> i.e. the kernel can access it freely. When you call dma_map_sg or similar,
> a noncoherent device reading the buffer requires the cache to be flushed
> in order to see the data that was written by the CPU into the cache.
>
> After dma_map_sg, the device can perform both read and write accesses
> (depending on the flag to the map call), but the CPU is no longer allowed
> to read (which would allocate a cache line that may become invalid but
> remain marked as clean) or write (which would create a dirty cache line
> without writing it back) that buffer.
>
> Once the device is done, the driver calls dma_unmap_* and the buffer is
> again owned by the CPU. The device can no longer access it (in fact
> the address may be no longer be backed if there is an iommu) and the CPU
> can again read and write the buffer. On ARMv6 and higher, possibly some
> other architectures, dma_unmap_* also needs to invalidate the cache
> for the buffer, because due to speculative prefetching, there may also
> be a new clean cache line with stale data from an earlier version of
> the buffer.
>
> Since map/unmap is an expensive operation, the interface was extended
> to pass back the ownership to the CPU and back to the device while leaving
> the buffer mapped. dma_sync_sg_for_cpu invalidates the cache in the same
> way as dma_unmap_sg, so the CPU can access the buffer, and
> dma_sync_sg_for_device hands it back to the device by performing the
> same cache flush that dma_map_sg would do.
>
> You could for example do this if you want video input with a
> cacheable buffer, or in an rdma scenario with a buffer accessed
> by a remote machine.
>
> In case of software iommu (swiotlb, dmabounce), the map and sync
> functions don't do cache management but instead copy data between
> a buffer accessed by hardware and a different buffer accessed
> by the user.

Thanks a lot for this excellent overview. I think at least for the first
version of dmabuf we should drop the sync_* interfaces and simply require
users to bracket their usage of the buffer from the attached device by
map/unmap. A dma_buf provider is always free to cache the mapping and
simply call sync_sg_for of the streaming dma api.

If it later turns out that we want to be able to cache the sg list also on
the use-site in the driver (e.g. map it into some hw sg list) we can
always add that functionality later. I just fear that sync ops among N
devices is a bit ill-defined and we already have a plethora of ill-defined
issues at hand. Also the proposed api doesn't quite fit into what's
already there, I think an s/device/dma_buf_attachment/ would be more
consistent - otherwise the dmabuf provider might need to walk the list of
attachements to get at the right one for the device.

> > The map call gets the dma_data_direction parameter, so it should be able
> > to do the right thing. And because we keep the attachement around, any
> > caching of mappings should be possible, too.
> >
> > Yours, Daniel
> >
> > PS: Slightly related, because it will make the coherency nightmare worse,
> > afaict: Can we kill mmap support?
>
> The mmap support is required (and only make sense) for consistent mappings,
> not for streaming mappings. The provider must ensure that if you map
> something uncacheable into the kernel in order to provide consistency,
> any mapping into user space must also be uncacheable. A driver
> that wants to have the buffer mapped to user space as many do should
> not need to know whether it is required to do cacheable or uncacheable
> mapping because of some other driver, and it should not need to worry
> about how to set up uncached mappings in user space.

Either I've always missed it or no one ever described it that consisely,
but now I see the use-case for mmap: Simpler drivers (i.e. not gpus) might
need to expose a userspace mapping and only the provider knows how to do
that in a coherent fashion. I want this in the docs (if it's not there yet
...).

But even with that use-case in mind I still have some gripes with the
current mmap interfaces as proposed:
- This use-case explains why the dmabuf provider needs to expose an mmap
  function. It doesn't explain why we need to expose that to userspace
  (instead of faking whatever mmap the importing driver already exposes).
  Imo the userspace-facing part of dmabuf should be about buffer sharing
  and not about how to access that buffer, so I'm still missing the reason
  for that.
- We need some way to tell the provider to sync all completed dma
  operations for userspace mmap access. sync_for_cpu would serve that use.
  But given that we strive for zero-copy I think the kernel shouldn't
  ever need to access the contents of a dmabuf and it would therefore make
  more sense to call it sync_for_mmap.
- And the ugly one: Assuming you want this to be coherent for (almost)
  unchanged users of exisiting subsystem and want this to integrate
  seamlessly with gpu driver management, we also need a
  finish_mmap_access. We _can_ fake this by shooting down userspace ptes
  (if the provider knows about all of them, and it should thanks to the
  mmap interface) and we do that trick on i915 (for certain cases). But
  this is generally slow and painful and does not integrate well with
  other gpu memory management paradigms, where userspace is required to
  explicit bracket access.

Yours, Daniel
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
