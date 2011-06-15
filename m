Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94E996B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 07:15:04 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Wed, 15 Jun 2011 13:14:56 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106141549.29315.arnd@arndb.de> <000601cc2b32$9e2a4030$da7ec090$%szyprowski@samsung.com>
In-Reply-To: <000601cc2b32$9e2a4030$da7ec090$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106151314.57150.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

On Wednesday 15 June 2011, Marek Szyprowski wrote:

> > > If possible I would like to make cma something similar to
> > > declare_dma_coherent()&friends, so the board/platform/bus startup code
> > > will just call declare_dma_contiguous() to enable support for cma for
> > > particular devices.
> > 
> > Sounds good, I like that.
>  
> Thanks. I thought a bit more on this and decided that I want to make this
> declare_dma_contiguous() optional for the drivers. It should be used only
> for some sophisticated cases like for example our video codec with two
> memory interfaces for 2 separate banks. By default the dma-mapping will
> use system-wide cma pool.
> 
> (snipped)

Ok, good.

> > Please explain the exact requirements that lead you to defining multiple
> > contexts. My feeling is that in most cases we don't need them and can
> > simply live with a single area. Depending on how obscure the cases are
> > where we do need something beyond that, we can then come up with
> > special-case solutions for them.
> 
> Like it was already stated we need such feature for our multimedia codec
> to allocate buffers from different memory banks. I really don't see any
> problems with the possibility to have additional cma areas for special
> purposes.

It's not a problem for special cases, I just want to make sure that
the common case works well enough that we don't need too many special
cases.

> > The problem with defining CMA areas in the device tree is that it's not
> > a property of the hardware, but really policy. The device tree file
> > should not contain anything related to a specific operating system
> > because you might want to boot something on the board that doesn't
> > know about CMA, and even when you only care about using Linux, the
> > implementation might change to the point where hardcoded CMA areas
> > no longer make sense.
> 
> I really doubt that the device tree will carry only system-independent
> information.

So far, this has worked well enough.

> Anyway, the preferred or required memory areas/banks for
> buffer allocation is something that is a property of the hardware not
> the OS policy.

That is true. If there are hard requirements of the hardware, we
can and should definitely document them in the device tree. It's
totally fine to describe the layout of memory banks and affinity
of devices to specific banks where that exists in hardware.

The part that should not be in the device tree is a specific location
of a buffer inside the bank when there is no hardware reason for
the location.

I guess it's also fine to describe requirements per device regarding
how much contiguous memory it will need to operate, if you can provide
that number independent of the application you want to run. The early
boot code can walk the device tree and ensure that the region is
large enough.

> > IMHO we should first aim for a solution that works almost everywhere
> > without the kernel knowing what board it's running on, and then we
> > can add quirks for devices that have special requirements. I think
> > the situation is similar to the vmalloc virtual address space, which
> > normally has a hardcoded size that works almost everywhere, but there
> > are certain drivers etc that require much more, or there are situations
> > where you want to make it smaller in order to avoid highmem.
> 
> I'm trying to create something that will fulfill the requirements of my
> hardware, that's why I cannot focus on a generic case only.

Yes, that is the obvious conflict. My main interest is to have something
that works not just for your hardware but works as good as possible on
the widest possible range of hardware, which may mean it may run not quite
as good in some of the cases.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
