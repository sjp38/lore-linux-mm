Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C1D8B6B02A9
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 03:56:09 -0400 (EDT)
Received: from epmmp1. (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L5Y00ITD8H9P320@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 22 Jul 2010 16:51:09 +0900 (KST)
Received: from AMDC159 (unknown [106.116.37.153])
 by mmp1.samsung.com (Sun Java(tm) System Messaging Server 7u3-15.01 64bit
 (built Feb 12 2010)) with ESMTPA id <0L5Y008SW8GVPR60@mmp1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 16:51:09 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <20100722045435.GD22559@codeaurora.org>
In-reply-to: <20100722045435.GD22559@codeaurora.org>
Subject: RE: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
Date: Thu, 22 Jul 2010 09:49:33 +0200
Message-id: <000401cb2972$704016d0$50c04470$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
To: 'Zach Pfeffer' <zpfeffer@codeaurora.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Pawel Osciak <p.osciak@samsung.com>, 'Xiaolin Zhang' <xiaolin.zhang@intel.com>, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'Robert Fekete' <robert.fekete@stericsson.com>, 'Marcus Lorentzon' <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello,

On Thursday, July 22, 2010 6:55 AM Zach Pfeffer wrote:

> On Tue, Jul 20, 2010 at 05:51:25PM +0200, Michal Nazarewicz wrote:
> > The Contiguous Memory Allocator framework is a set of APIs for
> > allocating physically contiguous chunks of memory.
> >
> > Various chips require contiguous blocks of memory to operate.  Those
> > chips include devices such as cameras, hardware video decoders and
> > encoders, etc.
> >
> > The code is highly modular and customisable to suit the needs of
> > various users.  Set of regions reserved for CMA can be configured on
> > run-time and it is easy to add custom allocator algorithms if one
> > has such need.
> >
> > Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > Reviewed-by: Pawel Osciak <p.osciak@samsung.com>
> > ---
> >  Documentation/cma.txt               |  435 +++++++++++++++++++
> >  Documentation/kernel-parameters.txt |    7 +
> >  include/linux/cma-int.h             |  183 ++++++++
> >  include/linux/cma.h                 |   92 ++++
> >  mm/Kconfig                          |   41 ++
> >  mm/Makefile                         |    3 +
> >  mm/cma-allocators.h                 |   42 ++
> >  mm/cma-best-fit.c                   |  360 ++++++++++++++++
> >  mm/cma.c                            |  778
> +++++++++++++++++++++++++++++++++++
> >  9 files changed, 1941 insertions(+), 0 deletions(-)
> >  create mode 100644 Documentation/cma.txt
> >  create mode 100644 include/linux/cma-int.h
> >  create mode 100644 include/linux/cma.h
> >  create mode 100644 mm/cma-allocators.h
> >  create mode 100644 mm/cma-best-fit.c
> >  create mode 100644 mm/cma.c
> >
> > diff --git a/Documentation/cma.txt b/Documentation/cma.txt
> > new file mode 100644
> > index 0000000..7edc20a
> > --- /dev/null
> > +++ b/Documentation/cma.txt
> > @@ -0,0 +1,435 @@
> > +                                                             -*- org -*-
> > +
> > +* Contiguous Memory Allocator
> > +
> > +   The Contiguous Memory Allocator (CMA) is a framework, which allows
> > +   setting up a machine-specific configuration for physically-contiguous
> > +   memory management. Memory for devices is then allocated according
> > +   to that configuration.
> > +
> > +   The main role of the framework is not to allocate memory, but to
> > +   parse and manage memory configurations, as well as to act as an
> > +   in-between between device drivers and pluggable allocators. It is
> > +   thus not tied to any memory allocation method or strategy.
> > +
> 
> This topic seems very hot lately. I recently sent out a few RFCs that
> implement something called a Virtual Contiguous Memory Manager that
> does what this patch does, and works for IOMMU and works for CPU
> mappings. It also does multihomed memory targeting (use physical set 1
> memory for A allocations and use physical memory set 2 for B
> allocations). Check out:
> 
> mm: iommu: An API to unify IOMMU, CPU and device memory management
> mm: iommu: A physical allocator for the VCMM
> mm: iommu: The Virtual Contiguous Memory Manager
> 
> It unifies IOMMU and physical mappings by creating a one-to-one
> software IOMMU for all devices that map memory physically.
> 
> It looks like you've got some good ideas though. Perhaps we can
> leverage each other's work.

We are aware of your patches. However our CMA solves the problem that is
a bit orthogonal to the setting up iommu. When you have IOMMU you don't really
need to care about memory fragmentation. In CMA approach we had to care
about it.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
