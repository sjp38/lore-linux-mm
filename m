Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B39526B02A9
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 03:32:29 -0400 (EDT)
Received: from epmmp2 (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L5Y00AG97HEB2D0@mailout3.samsung.com> for linux-mm@kvack.org;
 Thu, 22 Jul 2010 16:29:38 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp2.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0L5Y00GK37H02C@mmp2.samsung.com> for linux-mm@kvack.org; Thu,
 22 Jul 2010 16:29:38 +0900 (KST)
Date: Thu, 22 Jul 2010 09:28:02 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722143652V.fujita.tomonori@lab.ntt.co.jp>
Message-id: <000001cb296f$6eba8fa0$4c2faee0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: 
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <20100720181239.5a1fd090@bike.lwn.net>
 <20100722143652V.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>, corbet@lwn.net
Cc: m.nazarewicz@samsung.com, linux-mm@kvack.org, p.osciak@samsung.com, xiaolin.zhang@intel.com, hvaibhav@ti.com, robert.fekete@stericsson.com, marcus.xm.lorentzon@stericsson.com, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com
List-ID: <linux-mm.kvack.org>

Hello,

On Thursday, July 22, 2010 7:38 AM FUJITA Tomonori wrote:

> On Tue, 20 Jul 2010 18:12:39 -0600
> Jonathan Corbet <corbet@lwn.net> wrote:
> 
> > One other thing occurred to me as I was thinking about this...
> >
> > > +    There are four calls provided by the CMA framework to devices.  To
> > > +    allocate a chunk of memory cma_alloc() function needs to be used:
> > > +
> > > +            unsigned long cma_alloc(const struct device *dev,
> > > +                                    const char *kind,
> > > +                                    unsigned long size,
> > > +                                    unsigned long alignment);
> >
> > The purpose behind this interface, I believe, is pretty much always
> > going to be to allocate memory for DMA buffers.  Given that, might it
> > make more sense to integrate the API with the current DMA mapping
> > API?
> 
> IMO, having separate APIs for allocating memory and doing DMA mapping
> is much better. The DMA API covers the latter well. We could extend
> the current API to allocate memory or create new one similar to the
> current.
> 
> I don't see any benefit of a new abstraction that does both magically.

That's true. DMA mapping API is quite stable and already working.
 
> About the framework, it looks too complicated than we actually need
> (the command line stuff looks insane).

Well, this command line stuff was designed to provide a way to configure
memory allocation for devices with very sophisticated memory requirements.
It might look insane in first sight, but we haven't implemented it just
for fun. We have just taken the real requirements for our multimedia
devices (especially hardware video codec) tried to create a solution that
would cover all of them.

However I understand your point. It might be really good idea to set a
default mapping as a "one global memory pool for all devices". This way
the complicated cma boot argument would need to be provided only on
machines that really require it, all other can use it without any advanced
command line magic.

> Why can't we have something simpler, like using memblock to reserve
> contiguous memory at boot and using kinda mempool to share such memory
> between devices?

There are a few problems with such simple approach:

1. It does not provide all required functionality for our multimedia
devices. The main problem is the fact that our multimedia devices
require particular kind of buffers to be allocated in particular memory
bank. Then add 2 more requirements: a proper alignment (for some of them
it is even 128Kb) and particular range of addresses requirement (some
buffers must be allocated at higher addresses than the firmware).
This is very hard to achieve with such simple allocator.

2. One global memory pool heavily increases fragmentation issues and
gives no way to control or limit it. The opposite solution - like having
a separate pools per each multimedia device solves some fragmentation
issues but it's a huge waste a of the memory. Our idea was to provide
something configurable that can be placed between both solutions, that
can take advantages of both.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
