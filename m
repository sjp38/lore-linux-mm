Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 68D0B6B02B1
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 21:04:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q145G3025780
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 10:04:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F15445DE51
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:04:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5428C45DE4D
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:04:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32E461DB8040
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:04:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3C0EE18002
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:04:04 +0900 (JST)
Date: Thu, 26 Aug 2010 09:58:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-Id: <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100825155814.25c783c7.akpm@linux-foundation.org>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 15:58:14 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

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
> non-functioning device.  Could generic core VM provide the required level
> of service?
> 
> Anyway, these patches are going to be hard to merge but not impossible.
> Keep going.  Part of the problem is cultural, really: the consumers of
> this interface are weird dinky little devices which the core MM guys
> tend not to work with a lot, and it adds code which they wouldn't use.
> 
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
> valuable.  Have we heard from the linux-media people?  What other
> subsystems might use it?  ieee1394 perhaps?  Please help identify
> specific subsystems and I can perhaps help to wake people up.
> 
> And I agree that this code (or one of its alternatives!) would benefit
> from having a core MM person take a close interest.  Any volunteers?
> 
> Please cc me on future emails on this topic?
> 

Hmm, you may not like this..but how about following kind of interface ?

Now, memoyr hotplug supports following operation to free and _isolate_
memory region.
	# echo offline > /sys/devices/system/memory/memoryX/state

Then, a region of memory will be isolated. (This succeeds if there are free
memory.)

Add a new interface.

	% echo offline > /sys/devices/system/memory/memoryX/state
	# extract memory from System RAM and make them invisible from buddy allocator.

	% echo cma > /sys/devices/system/memory/memoryX/state
	# move invisible memory to cma.

Then, a chunk of memory will be moved into contiguous-memory-allocator.

To move "cma" region as usual region,
	# echo offline > /sys/devices/system/memory/memoryX/state
	# echo online > /sys/devices/system/memory/memoryX/state

Maybe "used-for-cma" memory are can be populated via /proc/iomem
As,
	100000000-63fffffff : System RAM
	640000000-800000000 : Contiguous RAM (Used for drivers)
(And you have to skip small memory holes by seeing this file)

Of course, cma guys can keep continue to use their own boot option.
With memory hotplug, kernelcore=xxxM interface can be used for creating
ZONE_MOVABLE. Some complicated work may be needed as

	# echo movable > /sys/devices/system/memory/memoryX/state
	(online pages and move them into ZONE_MOVABLE)

If anyone interested in, I may be able to offer some help.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
