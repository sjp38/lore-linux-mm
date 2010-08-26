Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1181F6B02CF
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 22:41:36 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L7Q00MNKNHBF2@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Aug 2010 03:41:35 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7Q00J6ENHAT2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2010 03:41:35 +0100 (BST)
Date: Thu, 26 Aug 2010 04:40:46 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100825155814.25c783c7.akpm@linux-foundation.org>
Message-id: <op.vh0xp8ix7p4s8u@localhost>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <1282310110.2605.976.camel@laptop>
 <20100825155814.25c783c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello Andrew,

I think Pawel has replied to most of your comments, so I'll just add my =
own
0.02 KRW. ;)

> Peter Zijlstra <peterz@infradead.org> wrote:
>> So the idea is to grab a large chunk of memory at boot time and then
>> later allow some device to use it?
>>
>> I'd much rather we'd improve the regular page allocator to be smarter=

>> about this. We recently added a lot of smarts to it like memory
>> compaction, which allows large gobs of contiguous memory to be freed =
for
>> things like huge pages.
>>
>> If you want guarantees you can free stuff, why not add constraints to=

>> the page allocation type and only allow MIGRATE_MOVABLE pages inside =
a
>> certain region, those pages are easily freed/moved aside to satisfy
>> large contiguous allocations.

On Thu, 26 Aug 2010 00:58:14 +0200, Andrew Morton <akpm@linux-foundation=
.org> wrote:
> That would be good.  Although I expect that the allocation would need
> to be 100% rock-solid reliable, otherwise the end user has a
> non-functioning device.  Could generic core VM provide the required le=
vel
> of service?

I think that the biggest problem is fragmentation here.  For instance,
I think that a situation where there is enough free space but it's
fragmented so no single contiguous chunk can be allocated is a serious
problem.  However, I would argue that if there's simply no space left,
a multimedia device could fail and even though it's not desirable, it
would not be such a big issue in my eyes.

So, if only movable or discardable pages are allocated in CMA managed
regions all should work well.  When a device needs memory discardable
pages would get freed and movable moved unless there is no space left
on the device in which case allocation would fail.

Critical devices (just a hypothetical entities) could have separate
regions on which only discardable pages can be allocated so that memory
can always be allocated for them.

> I agree that having two "contiguous memory allocators" floating about
> on the list is distressing.  Are we really all 100% diligently certain=

> that there is no commonality here with Zach's work?

As Pawel said, I think Zach's trying to solve a different problem.  No
matter, as I've said in response to Konrad's message, I have thought
about unifying Zach's IOMMU and CMA in such a way that devices could
work on both systems with and without IOMMU if only they would limit
the usage of the API to some subset which always works.

> Please cc me on future emails on this topic?

Not a problem.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
