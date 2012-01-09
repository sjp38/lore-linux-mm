Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 6041E6B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 05:25:26 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so3497006wib.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 02:25:24 -0800 (PST)
Date: Mon, 9 Jan 2012 11:27:26 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Message-ID: <20120109102726.GD3723@phenom.ffwll.local>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
 <CAAQKjZPFh6666JKc-XJfKYePQ_F0MNF6FkY=zKypWb52VVX3YQ@mail.gmail.com>
 <20120109081030.GA3723@phenom.ffwll.local>
 <CAAQKjZMEsuib18RYE7OvZPUqhKnvrZ8i3+EMuZSXr9KPVygo_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAQKjZMEsuib18RYE7OvZPUqhKnvrZ8i3+EMuZSXr9KPVygo_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: InKi Dae <daeinki@gmail.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>, daniel@ffwll.ch

On Mon, Jan 09, 2012 at 07:10:25PM +0900, InKi Dae wrote:
> 2012/1/9 Daniel Vetter <daniel@ffwll.ch>:
> > On Mon, Jan 09, 2012 at 03:20:48PM +0900, InKi Dae wrote:
> >> I has test dmabuf based drm gem module for exynos and I found one problem.
> >> you can refer to this test repository:
> >> http://git.infradead.org/users/kmpark/linux-samsung/shortlog/refs/heads/exynos-drm-dmabuf
> >>
> >> at this repository, I added some exception codes for resource release
> >> in addition to Dave's patch sets.
> >>
> >> let's suppose we use dmabuf based vb2 and drm gem with physically
> >> continuous memory(no IOMMU) and we try to share allocated buffer
> >> between them(v4l2 and drm driver).
> >>
> >> 1. request memory allocation through drm gem interface.
> >> 2. request DRM_SET_PRIME ioctl with the gem handle to get a fd to the
> >> gem object.
> >> - internally, private gem based dmabuf moudle calls drm_buf_export()
> >> to register allocated gem object to fd.
> >> 3. request qbuf with the fd(got from 2) and DMABUF type to set the
> >> buffer to v4l2 based device.
> >> - internally, vb2 plug in module gets a buffer to the fd and then
> >> calls dmabuf->ops->map_dmabuf() callback to get the sg table
> >> containing physical memory info to the gem object. and then the
> >> physical memory info would be copied to vb2_xx_buf object.
> >> for DMABUF feature for v4l2 and videobuf2 framework, you can refer to
> >> this repository:
> >> git://github.com/robclark/kernel-omap4.git drmplane-dmabuf
> >>
> >> after that, if v4l2 driver want to release vb2_xx_buf object with
> >> allocated memory region by user request, how should we do?. refcount
> >> to vb2_xx_buf is dependent on videobuf2 framework. so when vb2_xx_buf
> >> object is released videobuf2 framework don't know who is using the
> >> physical memory region. so this physical memory region is released and
> >> when drm driver tries to access the region or to release it also, a
> >> problem would be induced.
> >>
> >> for this problem, I added get_shared_cnt() callback to dma-buf.h but
> >> I'm not sure that this is good way. maybe there may be better way.
> >> if there is any missing point, please let me know.
> >
> > The dma_buf object needs to hold a reference on the underlying
> > (necessarily reference-counted) buffer object when the exporter creates
> > the dma_buf handle. This reference should then get dropped in the
> > exporters dma_buf->ops->release() function, which is only getting called
> > when the last reference to the dma_buf disappears.
> >
> 
> when the exporter creates the dma_buf handle(for example, gem -> fd),
> I think the refcount of gem object should be increased at this point,
> and decreased by dma_buf->ops->release() again because when the
> dma_buf is created and dma_buf_export() is called, this dma_buf refers
> to the gem object one time. and in case of inporter(fd -> gem),
> file->f_count of the dma_buf is increased and then when this gem
> object is released by user request such as drm close or
> drn_gem_close_ioctl, dma_buf_put() should be called by
> dma_buf->ops->detach() to decrease file->f_count again because the gem
> object refers to the dma_buf. for this, you can refer to my test
> repository I mentioned above. but the problem is that when a buffer is
> released by one side, another can't know whether the buffer already
> was released or not.

Nope, dma_buf_put should not be called by ->detach. The importer gets his
reference when importing the dma_buf and needs to drop that reference
himself when it's done using the buffer by calling dma_buf_put (i.e. after
the last ->detach call). I think adding separate reference counting to
->attach and ->detach is a waste of time and only papers over buggy
importers.

Additionally the importer does _not_ control the lifetime of an dma_buf
object and it's underlying backing storage. It hence may _never_ free the
backing storage itself, that's the job of the exporter.

With that cleared up, referencing the exporters underlying buffer object
from the dma_buf will just do the right thing.

> note : in case of sharing a buffer between v4l2 and drm driver, the
> memory info would be copied vb2_xx_buf to xx_gem or xx_gem to
> vb2_xx_buf through sg table. in this case, only memory info is used to
> share, not some objects.

Hm, maybe I need to take a look at the currently proposed v4l dma_buf
patches ;-) atm I don't have an idea what exactly you're talking about.

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
