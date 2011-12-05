Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5DFC06B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 17:04:47 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Date: Mon, 05 Dec 2011 23:04:09 +0100
Message-ID: <1438420.NYDLGGgKNc@wuerfel>
In-Reply-To: <CAKMK7uG2U2gn-LW7Cozumfza8XngvQSWR7-S-Qiok5NA=94V=w@mail.gmail.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com> <1426302.asOzFeeJzz@wuerfel> <CAKMK7uG2U2gn-LW7Cozumfza8XngvQSWR7-S-Qiok5NA=94V=w@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Daniel Vetter <daniel@ffwll.ch>, t.stanislaws@samsung.com, linux@arm.linux.org.uk, Sumit Semwal <sumit.semwal@ti.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, jesse.barker@linaro.org, rob@ti.com, linux-media@vger.kernel.org, Sumit Semwal <sumit.semwal@linaro.org>, m.szyprowski@samsung.com

On Monday 05 December 2011 21:58:39 Daniel Vetter wrote:
> On Mon, Dec 05, 2011 at 08:29:49PM +0100, Arnd Bergmann wrote:
> > ...
> 
> Thanks a lot for this excellent overview. I think at least for the first
> version of dmabuf we should drop the sync_* interfaces and simply require
> users to bracket their usage of the buffer from the attached device by
> map/unmap. A dma_buf provider is always free to cache the mapping and
> simply call sync_sg_for of the streaming dma api.

I think we still have the same problem if we allow multiple drivers
to access a noncoherent buffer using map/unmap:

	driver A				driver B

1.	read/write				
2.						read/write
3.	map()					
4.						read/write
5.	dma
6.						map()
7.	dma
8.						dma
9.	unmap()
10.						dma
11.	read/write
12.						unmap()						


In step 4, the buffer is owned by device A, but accessed by driver B, which
is a bug. In step 11, the buffer is owned by device B but accessed by driver
A, which is the same bug on the other side. In steps 7 and 8, the buffer
is owned by both device A and B, which is currently undefined but would
be ok if both devices are on the same coherency domain. Whether that point
is meaningful depends on what the devices actually do. It would be ok
if both are only reading, but not if they write into the same location
concurrently.

As I mentioned originally, the problem could be completely avoided if
we only allow consistent (e.g. uncached) mappings or buffers that
are not mapped into the kernel virtual address space at all.

Alternatively, a clearer model would be to require each access to
nonconsistent buffers to be exclusive: a map() operation would have
to block until the current mapper (if any) has done an unmap(), and
any access from the CPU would also have to call a dma_buf_ops pointer
to serialize the CPU accesses with any device accesses. User
mappings of the buffer can be easily blocked during a DMA access
by unmapping the buffer from user space at map() time and blocking the
vm_ops->fault() operation until the unmap().

> If it later turns out that we want to be able to cache the sg list also on
> the use-site in the driver (e.g. map it into some hw sg list) we can
> always add that functionality later. I just fear that sync ops among N
> devices is a bit ill-defined and we already have a plethora of ill-defined
> issues at hand. Also the proposed api doesn't quite fit into what's
> already there, I think an s/device/dma_buf_attachment/ would be more
> consistent - otherwise the dmabuf provider might need to walk the list of
> attachements to get at the right one for the device.

Right, at last for the start, let's mandate just map/unmap and not provide
sync. I do wonder however whether we should implement consistent (possibly
uncached) or streaming (cacheable, but always owned by either the device
or the CPU, not both) buffers, or who gets to make the decision which
one is used if both are implemented.

> > > The map call gets the dma_data_direction parameter, so it should be able
> > > to do the right thing. And because we keep the attachement around, any
> > > caching of mappings should be possible, too.
> > >
> > > Yours, Daniel
> > >
> > > PS: Slightly related, because it will make the coherency nightmare worse,
> > > afaict: Can we kill mmap support?
> >
> > The mmap support is required (and only make sense) for consistent mappings,
> > not for streaming mappings. The provider must ensure that if you map
> > something uncacheable into the kernel in order to provide consistency,
> > any mapping into user space must also be uncacheable. A driver
> > that wants to have the buffer mapped to user space as many do should
> > not need to know whether it is required to do cacheable or uncacheable
> > mapping because of some other driver, and it should not need to worry
> > about how to set up uncached mappings in user space.
> 
> Either I've always missed it or no one ever described it that consisely,
> but now I see the use-case for mmap: Simpler drivers (i.e. not gpus) might
> need to expose a userspace mapping and only the provider knows how to do
> that in a coherent fashion. I want this in the docs (if it's not there yet
> ...).

It's currently implemented in the ARM/PowerPC-specific dma_mmap_coherent
function and documented (hardly) in arch/arm/include/asm/dma-mapping.h.

We should make clear in that this is actually an extension of the
regular dma mapping api that first needs to be made generic.

> But even with that use-case in mind I still have some gripes with the
> current mmap interfaces as proposed:
> - This use-case explains why the dmabuf provider needs to expose an mmap
>   function. It doesn't explain why we need to expose that to userspace
>   (instead of faking whatever mmap the importing driver already exposes).
>   Imo the userspace-facing part of dmabuf should be about buffer sharing
>   and not about how to access that buffer, so I'm still missing the reason
>   for that.

AFAICT, the only reason for providing an mmap operation in the dma_buf
file descriptor is "because we can". It may in fact be better to leave
that part out and have the discussion whether this is actually a good
thing to do after the dma_buf core code has been merged upstream.

> - We need some way to tell the provider to sync all completed dma
>   operations for userspace mmap access. sync_for_cpu would serve that use.
>   But given that we strive for zero-copy I think the kernel shouldn't
>   ever need to access the contents of a dmabuf and it would therefore make
>   more sense to call it sync_for_mmap.

As I mentioned, the kernel can easily block out the user map by
transparently unmapping the buffer. I've done that in spufs for
context-switching an SPU: during the save and restore phase of the
SPU local memory to system memory, the page tables entries for
all user mappings are removed and then faulted back in after the
context switch. We can do the same during a DMA on a noncoherent
buffer.

> - And the ugly one: Assuming you want this to be coherent for (almost)
>   unchanged users of exisiting subsystem and want this to integrate
>   seamlessly with gpu driver management, we also need a
>   finish_mmap_access. We _can_ fake this by shooting down userspace ptes
>   (if the provider knows about all of them, and it should thanks to the
>   mmap interface) and we do that trick on i915 (for certain cases). But
>   this is generally slow and painful and does not integrate well with
>   other gpu memory management paradigms, where userspace is required to
>   explicit bracket access.

Yes, good point.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
