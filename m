Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1F936B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 06:19:11 -0400 (EDT)
Date: Thu, 26 Aug 2010 11:18:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-ID: <20100826101855.GF20944@csn.ul.ie>
References: <cover.1282286941.git.m.nazarewicz@samsung.com> <1282310110.2605.976.camel@laptop> <20100825155814.25c783c7.akpm@linux-foundation.org> <op.vh0xp8ix7p4s8u@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.vh0xp8ix7p4s8u@localhost>
Sender: owner-linux-mm@kvack.org
To: Micha?? Nazarewicz <m.nazarewicz@samsung.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 04:40:46AM +0200, Micha?? Nazarewicz wrote:
> Hello Andrew,
>
> I think Pawel has replied to most of your comments, so I'll just add my own
> 0.02 KRW. ;)
>
>> Peter Zijlstra <peterz@infradead.org> wrote:
>>> So the idea is to grab a large chunk of memory at boot time and then
>>> later allow some device to use it?
>>>
>>> I'd much rather we'd improve the regular page allocator to be smarter
>>> about this. We recently added a lot of smarts to it like memory
>>> compaction, which allows large gobs of contiguous memory to be freed for
>>> things like huge pages.
>>>
>>> If you want guarantees you can free stuff, why not add constraints to
>>> the page allocation type and only allow MIGRATE_MOVABLE pages inside a
>>> certain region, those pages are easily freed/moved aside to satisfy
>>> large contiguous allocations.
>
> On Thu, 26 Aug 2010 00:58:14 +0200, Andrew Morton <akpm@linux-foundation.org> wrote:
>> That would be good.  Although I expect that the allocation would need
>> to be 100% rock-solid reliable, otherwise the end user has a
>> non-functioning device.  Could generic core VM provide the required level
>> of service?
>
> I think that the biggest problem is fragmentation here.  For instance,
> I think that a situation where there is enough free space but it's
> fragmented so no single contiguous chunk can be allocated is a serious
> problem.  However, I would argue that if there's simply no space left,
> a multimedia device could fail and even though it's not desirable, it
> would not be such a big issue in my eyes.
>

For handling fragmentation, there is the option of ZONE_MOVABLE so it's
usable by normal allocations but the CMA can take action to get it
cleared out if necessary. Another option that is trickier but less
disruptive would be to select a range of memory in a normal zone for CMA
and mark it MIGRATE_MOVABLE so that movable pages are allocated from it.
The trickier part is you need to make that bit stick so that non-movable
pages are never allocated from that range. That would be trickish to
implement but possible and it would avoid the fragmentation
problem without pinning memory.

> So, if only movable or discardable pages are allocated in CMA managed
> regions all should work well.  When a device needs memory discardable
> pages would get freed and movable moved unless there is no space left
> on the device in which case allocation would fail.
>
> Critical devices (just a hypothetical entities) could have separate
> regions on which only discardable pages can be allocated so that memory
> can always be allocated for them.
>
>> I agree that having two "contiguous memory allocators" floating about
>> on the list is distressing.  Are we really all 100% diligently certain
>> that there is no commonality here with Zach's work?
>
> As Pawel said, I think Zach's trying to solve a different problem.  No
> matter, as I've said in response to Konrad's message, I have thought
> about unifying Zach's IOMMU and CMA in such a way that devices could
> work on both systems with and without IOMMU if only they would limit
> the usage of the API to some subset which always works.
>
>> Please cc me on future emails on this topic?
>
> Not a problem.
>
> -- 
> Best regards,                                        _     _
> | Humble Liege of Serenely Enlightened Majesty of  o' \,=./ `o
> | Computer Science,  Micha?? "mina86" Nazarewicz       (o o)
> +----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
