Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD7A90015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 03:04:25 -0400 (EDT)
From: Hans Verkuil <hverkuil@xs4all.nl>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Wed, 22 Jun 2011 09:03:30 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <000501cc2b2b$789a54b0$69cefe10$%szyprowski@samsung.com> <201106150937.18524.arnd@arndb.de>
In-Reply-To: <201106150937.18524.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106220903.31065.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

On Wednesday, June 15, 2011 09:37:18 Arnd Bergmann wrote:
> On Wednesday 15 June 2011 09:11:39 Marek Szyprowski wrote:
> > I see your concerns, but I really wonder how to determine the properties
> > of the global/default cma pool. You definitely don't want to give all
> > available memory o CMA, because it will have negative impact on kernel
> > operation (kernel really needs to allocate unmovable pages from time to
> > time). 
> 
> Exactly. This is a hard problem, so I would prefer to see a solution for
> coming up with reasonable defaults.
> 
> > The only solution I see now is to provide Kconfig entry to determine
> > the size of the global CMA pool, but this still have some issues,
> > especially for multi-board kernels (each board probably will have
> > different amount of RAM and different memory-consuming devices
> > available). It looks that each board startup code still might need to
> > tweak the size of CMA pool. I can add a kernel command line option for
> > it, but such solution also will not solve all the cases (afair there
> > was a discussion about kernel command line parameters for memory 
> > configuration and the conclusion was that it should be avoided).
> 
> The command line option can be a last resort if the heuristics fail,
> but it's not much better than a fixed Kconfig setting.
> 
> How about a Kconfig option that defines the percentage of memory
> to set aside for contiguous allocations?

I would actually like to see a cma_size kernel option of some sort. This would
be for the global CMA pool only as I don't think we should try to do anything
more complicated here.

While it is relatively easy for embedded systems to do a recompile every time
you need to change the pool size, this isn't an option on 'normal' desktop
systems.

While usually you have more than enough memory on such systems and don't need
CMA, there are a number of cases where you do want to reserve sufficient
memory. Usually these involve lots of video capture cards in one system.

What I was wondering about is how this patch series changes the allocation
in case it can't allocate from the CMA pool. Will it attempt to fall back
to a 'normal' allocation?

The reason I ask is that for desktop systems you could just start with a CMA
pool of size 0. And only in specific situations would you need to add a
cma_size kernel parameter depending on your needs. But this scheme would
require a fallback scenario in case of a global CMA pool of size 0.

Hmm, perhaps this fallback scenario is more driver specific. For SoC platform
video devices you may not want a fallback, whereas for PCI(e)/USB devices you
do. I don't know what's best, frankly.

Regards,

	Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
