Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 38D426B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 05:24:43 -0400 (EDT)
From: Sumit Semwal <sumit.semwal@ti.com>
Subject: [RFC 0/2] Introduce dma buffer sharing mechanism
Date: Tue, 11 Oct 2011 14:53:51 +0530
Message-ID: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@ti.com>

Hello Everyone,

Various subsystems - V4L2, GPU-accessors, DRI to name a few - have felt the 
need to have a common mechanism to share memory buffers across different
devices - ARM, video hardware, GPU.

This need comes forth from a variety of use cases including cameras, image 
processing, video recorders, sound processing, DMA engines, GPU and display
buffers, and others.

This RFC is the first attempt in defining such a buffer sharing mechanism- it is
the result of discussions from a couple of memory-management mini-summits held
by Linaro to understand and address common needs around memory management. [1]

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
- the exporter and user to share the scatterlist using get_scatterlist and
   put_scatterlist operations.

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


Sumit Semwal (2):
  dma-buf: Introduce dma buffer sharing mechanism
  dma-buf: Documentation for buffer sharing framework

 Documentation/dma-buf-sharing.txt |  210 ++++++++++++++++++++++++++++++++
 drivers/base/Kconfig              |   10 ++
 drivers/base/Makefile             |    1 +
 drivers/base/dma-buf.c            |  242 +++++++++++++++++++++++++++++++++++++
 include/linux/dma-buf.h           |  162 +++++++++++++++++++++++++
 5 files changed, 625 insertions(+), 0 deletions(-)
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
