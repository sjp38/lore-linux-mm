Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DB8D6B02B9
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 21:23:12 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7Q0077HJUMRD20@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 02:23:10 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q00KV1JUM7Q@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 02:23:10 +0100 (BST)
Date: Thu, 26 Aug 2010 10:22:08 +0900
From: Pawel Osciak <p.osciak@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100825155814.25c783c7.akpm@linux-foundation.org>
Message-id: <4C75C1C0.8050805@samsung.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
 <20100825155814.25c783c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Thank you for your comments and interest in this!

On 08/26/2010 07:58 AM, Andrew Morton wrote:
> On Fri, 20 Aug 2010 15:15:10 +0200
> Peter Zijlstra<peterz@infradead.org>  wrote:
>
>    
>> On Fri, 2010-08-20 at 11:50 +0200, Michal Nazarewicz wrote:
>>      
>>> Hello everyone,
>>>
>>> The following patchset implements a Contiguous Memory Allocator.  For
>>> those who have not yet stumbled across CMA an excerpt from
>>> documentation:
>>>
>>>     The Contiguous Memory Allocator (CMA) is a framework, which allows
>>>     setting up a machine-specific configuration for physically-contiguous
>>>     memory management. Memory for devices is then allocated according
>>>     to that configuration.
>>>
>>>     The main role of the framework is not to allocate memory, but to
>>>     parse and manage memory configurations, as well as to act as an
>>>     in-between between device drivers and pluggable allocators. It is
>>>     thus not tied to any memory allocation method or strategy.
>>>
>>> For more information please refer to the second patch from the
>>> patchset which contains the documentation.
>>>        
>> So the idea is to grab a large chunk of memory at boot time and then
>> later allow some device to use it?
>>
>> I'd much rather we'd improve the regular page allocator to be smarter
>> about this. We recently added a lot of smarts to it like memory
>> compaction, which allows large gobs of contiguous memory to be freed for
>> things like huge pages.
>>
>> If you want guarantees you can free stuff, why not add constraints to
>> the page allocation type and only allow MIGRATE_MOVABLE pages inside a
>> certain region, those pages are easily freed/moved aside to satisfy
>> large contiguous allocations.
>>      
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

This is encouraging, thanks. Merging a contiguous allocator seems like a 
lost cause, with a relative disinterest of non-embedded people, and on 
the other hand because of the difficulty to satisfy those actually 
interested. With virtually everybody having their own, custom solutions, 
agreeing on one is nearly impossible.

> I agree that having two "contiguous memory allocators" floating about
> on the list is distressing.  Are we really all 100% diligently certain
> that there is no commonality here with Zach's work?
>    

I think Zach's work is more focused on IOMMU and on unifying virtual 
memory handling. As far as I understand, any physical allocator can be 
plugged into it, including CMA. CMA solves a different set of problems.

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

As a media developer myself, I talked with people and many have 
expressed their interest. Among them were developers from ST-Ericsson, 
Intel and TI, to name a few. Their SoCs, like ours at Samsung, require 
contiguous memory allocation schemes as well.


I am working on a driver framework for media for memory management (on 
the logical, not physical level). One of the goals is to allow plugging 
in custom allocators and memory handling functions (cache management, 
etc.). CMA is intended to be used as one of the pluggable allocators for 
it. Right now, many media drivers have to provide their own, more or 
less complicated, memory handling, which is of course undesirable. Some 
of those make it to the kernel, many are maintained outside the mainline.

The problem is that, as far as I am aware, there have already been quite 
a few proposals for such allocators and none made it to the mainline. So 
companies develop their own solutions and maintain them outside the 
mainline.

I think that the interest is definitely there, but people have their 
deadlines and assume that it is close to impossible to have a contiguous 
allocator merged.

Your help and support would be very much appreciated. Working in 
embedded Linux for some time now, I feel that the need is definitely 
there and is quite substantial.

-- 
Best regards,
Pawel Osciak
Linux Platform Group
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
