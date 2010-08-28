Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DC0216B01F0
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 09:09:15 -0400 (EDT)
From: Hans Verkuil <hverkuil@xs4all.nl>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Date: Sat, 28 Aug 2010 15:08:19 +0200
References: <cover.1282286941.git.m.nazarewicz@samsung.com> <1282310110.2605.976.camel@laptop> <20100825155814.25c783c7.akpm@linux-foundation.org>
In-Reply-To: <20100825155814.25c783c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201008281508.19756.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thursday, August 26, 2010 00:58:14 Andrew Morton wrote:
> On Fri, 20 Aug 2010 15:15:10 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Fri, 2010-08-20 at 11:50 +0200, Michal Nazarewicz wrote:
> > > Hello everyone,
> > > 
> > > The following patchset implements a Contiguous Memory Allocator.  For
> > > those who have not yet stumbled across CMA an excerpt from
> > > documentation:
> > > 
> > >    The Contiguous Memory Allocator (CMA) is a framework, which allows
> > >    setting up a machine-specific configuration for physically-contiguous
> > >    memory management. Memory for devices is then allocated according
> > >    to that configuration.
> > > 
> > >    The main role of the framework is not to allocate memory, but to
> > >    parse and manage memory configurations, as well as to act as an
> > >    in-between between device drivers and pluggable allocators. It is
> > >    thus not tied to any memory allocation method or strategy.
> > > 
> > > For more information please refer to the second patch from the
> > > patchset which contains the documentation.
> > 
> > So the idea is to grab a large chunk of memory at boot time and then
> > later allow some device to use it?
> > 
> > I'd much rather we'd improve the regular page allocator to be smarter
> > about this. We recently added a lot of smarts to it like memory
> > compaction, which allows large gobs of contiguous memory to be freed for
> > things like huge pages.
> > 
> > If you want guarantees you can free stuff, why not add constraints to
> > the page allocation type and only allow MIGRATE_MOVABLE pages inside a
> > certain region, those pages are easily freed/moved aside to satisfy
> > large contiguous allocations.
> 
> That would be good.  Although I expect that the allocation would need
> to be 100% rock-solid reliable, otherwise the end user has a
> non-functioning device.

Yes, indeed. And you have to be careful as well how you move pages around.
Say that you have a capture and an output v4l device: the first one needs
64 MB contiguous memory and so it allocates that amount, moving pages around
as needed. Once allocated that memory is pinned in place since it is needed
for DMA. So if the output device also needs 64 MB, then you must have a
guarantee that the first allocation didn't fragment the available contiguous
memory.

I also wonder how expensive it is to move all the pages around. E.g. if you
have a digital camera and want to make a hires picture, then it wouldn't
do if it takes a second to move all the pages around making room for the
captured picture. The CPUs in many SoCs are not very powerful compared to
your average desktop.

And how would memory allocations in specific memory ranges (e.g. memory
banks) work?

Note also that these issues are not limited to embedded systems, also PCI(e)
boards can sometimes require massive amounts of DMA-able memory. I have had
this happen in the past with the ivtv driver with customers that had 15 or so
capture cards in one box. And I'm sure it will happen in the future as well,
esp. with upcoming 4k video formats.

Video is a major memory consumer, particularly in embedded systems. And there
usually is no room for failure.

> Could generic core VM provide the required level
> of service?
> 
> Anyway, these patches are going to be hard to merge but not impossible.
> Keep going.  Part of the problem is cultural, really: the consumers of
> this interface are weird dinky little devices which the core MM guys
> tend not to work with a lot, and it adds code which they wouldn't use.

It's not really that weird. The same problems can actually occur as well
with the more 'mainstream' consumer level video boards, although you need
more extreme environments for these problems to surface.

> I agree that having two "contiguous memory allocators" floating about
> on the list is distressing.  Are we really all 100% diligently certain
> that there is no commonality here with Zach's work?
> 
> I agree that Peter's above suggestion would be the best thing to do. 
> Please let's take a look at that without getting into sunk cost
> fallacies with existing code!
> 
> It would help (a lot) if we could get more attention and buyin and
> fedback from the potential clients of this code.  rmk's feedback is
> valuable.  Have we heard from the linux-media people?

I'm doing the reviewing for linux-media. It would be really nice to have a
good system for this in place. For example, the current TI davinci capture
driver will only work reliably (memory-wise) if you also use the out-of-tree
TI cmem module. Hardly a desirable situation. Basically a fair amount of
custom hacks is required at the memory to have reliable video streaming on
embedded systems due to the lack of a cma-type framework.

> What other
> subsystems might use it?  ieee1394 perhaps?  Please help identify
> specific subsystems and I can perhaps help to wake people up.

The video subsystem is the other candidate. Probably not for the current generation
of GPUs (these all have hardware IOMMUs I suspect), but definitely for the framebuffer
based devices that are often present on SoCs.

Regards,

	Hans
 
> And I agree that this code (or one of its alternatives!) would benefit
> from having a core MM person take a close interest.  Any volunteers?
> 
> Please cc me on future emails on this topic?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

-- 
Hans Verkuil - video4linux developer - sponsored by TANDBERG, part of Cisco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
