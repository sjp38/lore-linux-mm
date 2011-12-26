Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 4E6A36B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 04:24:10 -0500 (EST)
From: Sumit Semwal <sumit.semwal@ti.com>
Subject: [PATCH 0/3] Introduce DMA buffer sharing mechanism
Date: Mon, 26 Dec 2011 14:53:14 +0530
Message-ID: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, airlied@redhat.com
Cc: linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, patches@linaro.org, Sumit Semwal <sumit.semwal@ti.com>

Hello Everyone,

Post some discussion as an RFC, here is the patch for introducing 
DMA buffer sharing mechanism - change history is in the changelog below.

Various subsystems - V4L2, GPU-accessors, DRI to name a few - have felt the 
need to have a common mechanism to share memory buffers across different
devices - ARM, video hardware, GPU.

This need comes forth from a variety of use cases including cameras, image 
processing, video recorders, sound processing, DMA engines, GPU and display
buffers, amongst others.

This patch attempts to define such a buffer sharing mechanism - it is the
result of discussions from a couple of memory-management mini-summits held by
Linaro to understand and address common needs around memory management. [1]

A new dma_buf buffer object is added, with operations and API to allow easy
sharing of this buffer object across devices.

The framework allows:
- a new buffer object to be created with fixed size, associated with a file 
   pointer and allocator-defined operations for this buffer object. This
   operation is called the 'export' operation.
- different devices to 'attach' themselves to this buffer object, to facilitate
   backing storage negotiation, using dma_buf_attach() API.
- this exported buffer object to be shared with the other entity by asking for
   its 'file-descriptor (fd)', and sharing the fd across.
- a received fd to get the buffer object back, where it can be accessed using
   the associated exporter-defined operations.
- the exporter and user to share the buffer object's scatterlist using
   map_dma_buf and unmap_dma_buf operations.

Documentation present in the patch-set gives more details.

For 1st version, dma-buf is marked as an EXPERIMENTAL driver, which we can
remove for later versions with additional usage and testing.

*IMPORTANT*: [see https://lkml.org/lkml/2011/12/20/211 for more details]
For this first version, A buffer shared using the dma_buf sharing API:
- *may* be exported to user space using "mmap" *ONLY* by exporter, outside of
   this framework.
- may be used *ONLY* by importers that do not need CPU access to the buffer.

This is based on design suggestions from many people at the mini-summits,
most notably from Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
Daniel Vetter <daniel@ffwll.ch>.

The implementation is inspired from proof-of-concept patch-set from
Tomasz Stanislawski <t.stanislaws@samsung.com>, who demonstrated buffer sharing
between two v4l2 devices. [2]

Some sample implementations and WIP for dma-buf users and exporters are
available at [3] and [4]. [These are not being submitted for discussion /
inclusion right now, but are for reference only]

References:
[1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
[2]: http://lwn.net/Articles/454389
[3]: Dave Airlie's prime support:
   http://cgit.freedesktop.org/~airlied/linux/log/?h=drm-prime-dmabuf
[4]: Rob Clark's sharing between DRM and V4L2:
   https://github.com/robclark/kernel-omap4/commits/drmplane-dmabuf

Patchset based on top of 3.2-rc7, the current version can be found at

http://git.linaro.org/gitweb?p=people/sumitsemwal/linux-3.x.git
Branch: dmabuf-patch-v1

Earlier versions:
RFC:
v3 at: https://lkml.org/lkml/2011/12/19/50
v2 at: https://lkml.org/lkml/2011/12/2/53
v1 at: https://lkml.org/lkml/2011/10/11/92

Wish you all happy vacations and a very happy, joyous and prosperous new year
2012 :)

Best regards,
~Sumit Semwal

History:
v4:
- Review comments incorporated:
   - from Konrad Rzeszutek Wilk [https://lkml.org/lkml/2011/12/20/209]
     - corrected language in some comments
     - re-ordered struct definitions for readability
     - added might_sleep() call in dma_buf_map_attachment() wrapper
     
   - from Rob Clark [https://lkml.org/lkml/2011/12/23/196]
     - Made dma-buf EXPERIMENTAL for 1st version.

v3:
- Review comments incorporated:
   - from Konrad Rzeszutek Wilk [https://lkml.org/lkml/2011/12/3/45]
     - replaced BUG_ON with WARN_ON - various places
     - added some error-checks
     - replaced EXPORT_SYMBOL with EXPORT_SYMBOL_GPL
     - some cosmetic / documentation comments

   - from Arnd Bergmann, Daniel Vetter, Rob Clark
      [https://lkml.org/lkml/2011/12/5/321]
     - removed mmap() fop and dma_buf_op, also the sg_sync* operations, and
        documented that mmap is not allowed for exported buffer
     - updated documentation to clearly state when migration is allowed
     - changed kconfig
     - some error code checks

   - from Rob Clark [https://lkml.org/lkml/2011/12/5/572]
     - update documentation to allow map_dma_buf to return -EINTR

v2:
- Review comments incorporated:
   - from Tomasz Stanislawski [https://lkml.org/lkml/2011/10/14/136]
     - kzalloc moved out of critical section
     - corrected some in-code comments

   - from Dave Airlie [https://lkml.org/lkml/2011/11/25/123]

   - from Daniel Vetter and Rob Clark [https://lkml.org/lkml/2011/11/26/53]
     - use struct sg_table in place of struct scatterlist
     - rename {get,put}_scatterlist to {map,unmap}_dma_buf
     - add new wrapper APIs dma_buf_{map,unmap}_attachment for ease of users
     
- documentation updates as per review comments from Randy Dunlap
     [https://lkml.org/lkml/2011/10/12/439]

v1: original


Sumit Semwal (3):
  dma-buf: Introduce dma buffer sharing mechanism
  dma-buf: Documentation for buffer sharing framework
  dma-buf: mark EXPERIMENTAL for 1st release.

 Documentation/dma-buf-sharing.txt |  224 ++++++++++++++++++++++++++++
 drivers/base/Kconfig              |   11 ++
 drivers/base/Makefile             |    1 +
 drivers/base/dma-buf.c            |  291 +++++++++++++++++++++++++++++++++++++
 include/linux/dma-buf.h           |  176 ++++++++++++++++++++++
 5 files changed, 703 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/dma-buf-sharing.txt
 create mode 100644 drivers/base/dma-buf.c
 create mode 100644 include/linux/dma-buf.h

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
