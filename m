Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id ADE326B005A
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 03:33:59 -0500 (EST)
From: Sumit Semwal <sumit.semwal@ti.com>
Subject: [RFC v3 0/2] Introduce DMA buffer sharing mechanism
Date: Mon, 19 Dec 2011 14:03:28 +0530
Message-ID: <1324283611-18344-1-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, patches@linaro.org, Sumit Semwal <sumit.semwal@ti.com>

Hello Everyone,

This is RFC v3 for DMA buffer sharing mechanism - changes from v2 are in the
changelog below.

Various subsystems - V4L2, GPU-accessors, DRI to name a few - have felt the 
need to have a common mechanism to share memory buffers across different
devices - ARM, video hardware, GPU.

This need comes forth from a variety of use cases including cameras, image 
processing, video recorders, sound processing, DMA engines, GPU and display
buffers, and others.

This RFC is an attempt to define such a buffer sharing mechanism- it is the
result of discussions from a couple of memory-management mini-summits held by
Linaro to understand and address common needs around memory management. [1]

A new dma_buf buffer object is added, with operations and API to allow easy
sharing of this buffer object across devices.

The framework allows:
- a new buffer-object to be created with fixed size.
- different devices to 'attach' themselves to this buffer, to facilitate
  backing storage negotiation, using dma_buf_attach() API.
- association of a file pointer with each user-buffer and associated
   allocator-defined operations on that buffer. This operation is called the
   'export' operation.
- this exported buffer-object to be shared with the other entity by asking for
   its 'file-descriptor (fd)', and sharing the fd across.
- a received fd to get the buffer object back, where it can be accessed using
   the associated exporter-defined operations.
- the exporter and user to share the scatterlist using map_dma_buf and
   unmap_dma_buf operations.

Documentation present in the patch-set gives more details.

This is based on design suggestions from many people at the mini-summits,
most notably from Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> and
Daniel Vetter <daniel@ffwll.ch>.

The implementation is inspired from proof-of-concept patch-set from
Tomasz Stanislawski <t.stanislaws@samsung.com>, who demonstrated buffer sharing
between two v4l2 devices. [2]

References:
[1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
[2]: http://lwn.net/Articles/454389

Patchset based on top of 3.2-rc3, the current version can be found at

http://git.linaro.org/gitweb?p=people/sumitsemwal/linux-3.x.git
Branch: dma-buf-upstr-v2

Earlier versions:
v2 at: https://lkml.org/lkml/2011/12/2/53
v1 at: https://lkml.org/lkml/2011/10/11/92

Best regards,
~Sumit Semwal

History:

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


Sumit Semwal (2):
  dma-buf: Introduce dma buffer sharing mechanism
  dma-buf: Documentation for buffer sharing framework

 Documentation/dma-buf-sharing.txt |  222 ++++++++++++++++++++++++++++
 drivers/base/Kconfig              |   10 ++
 drivers/base/Makefile             |    1 +
 drivers/base/dma-buf.c            |  289 +++++++++++++++++++++++++++++++++++++
 include/linux/dma-buf.h           |  172 ++++++++++++++++++++++
 5 files changed, 694 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/dma-buf-sharing.txt
 create mode 100644 drivers/base/dma-buf.c
 create mode 100644 include/linux/dma-buf.h

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
