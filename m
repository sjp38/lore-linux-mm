Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 00D676B01B4
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:05:15 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KJM004DRXOTPX@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 14 May 2009 14:05:18 +0100 (BST)
Received: from amdc030 ([106.116.37.122])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0KJM00HLAXO72E@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 14 May 2009 14:05:17 +0100 (BST)
Date: Thu, 14 May 2009 15:04:55 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] Physical Memory Management [0/1]
In-reply-to: <1242302702.6642.1140.camel@laptop>
Message-id: <op.utw7yhv67p4s8u@amdc030>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 8BIT
References: <op.utu26hq77p4s8u@amdc030>
 <20090513151142.5d166b92.akpm@linux-foundation.org>
 <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
 <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 2009-05-14 at 13:48 +0200, MichaA? Nazarewicz wrote:
>>> On Thu, 2009-05-14 at 11:00 +0200, MichaA? Nazarewicz wrote:
>>>>   PMM solves this problem since the buffers are allocated when they
>>>>   are needed.

>> On Thu, 14 May 2009 13:20:02 +0200, Peter Zijlstra wrote:
>>> Ha - only when you actually manage to allocate things. Physically
>>> contiguous allocations are exceedingly hard once the machine has been
>>> running for a while.

>> PMM reserves memory during boot time using alloc_bootmem_low_pages().
>> After this is done, it can allocate buffers from reserved pool.
>>
>> The idea here is that there are n hardware accelerators, each
>> can operate on 1MiB blocks (to simplify assume that's the case).
>> However, we know that at most m < n devices will be used at the same
>> time so instead of reserving n MiBs of memory we reserve only m MiBs.

On Thu, 14 May 2009 14:05:02 +0200, Peter Zijlstra wrote:
> And who says your pre-allocated pool won't fragment with repeated PMM
> use?

Yes, this is a good question.  What's more, there's no good answer. ;)

There is no guarantee and it depends on use cases.  The biggest problem
is a lot of small buffers allocated by different applications which get
freed at different times.  However, if in most cases one or two
applications use PMM, we can assume that buffers are allocated and
freed in groups.  If that's the case, fragmentation is less likely to
occur.

I'm not claiming that PMM is panacea for all the problems present on
systems with no scatter-gather capability -- it is an attempt to gather
different functionality and existing solutions in one place which is
easier to manage and improve if needed.

Problem with allocation of continuous blocks hos no universal solution
-- you can increased reserved area but then overall performance of the
system will decrease.  PMM is trying to find a compromise between the
two.

-- 
Best regards,                                            _     _
 .o. | Liege of Serenly Enlightened Majesty of         o' \,=./ `o
 ..o | Computer Science,  MichaA? "mina86" Nazarewicz      (o o)
 ooo +-<m.nazarewicz@samsung.com>-<mina86@jabber.org>-ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
