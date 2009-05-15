Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 898426B0062
	for <linux-mm@kvack.org>; Fri, 15 May 2009 06:06:45 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KJO00K7ZK3D46@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 May 2009 11:06:49 +0100 (BST)
Received: from amdc030 ([106.116.37.122])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0KJO00G73K37MN@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2009 11:06:49 +0100 (BST)
Date: Fri, 15 May 2009 12:06:42 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] Physical Memory Management [0/1]
In-reply-to: <1242321000.6642.1456.camel@laptop>
Message-id: <op.utyudge07p4s8u@amdc030>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 8BIT
References: <op.utu26hq77p4s8u@amdc030>
 <20090513151142.5d166b92.akpm@linux-foundation.org>
 <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
 <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop>
 <op.utw7yhv67p4s8u@amdc030>
 <20090514100718.d8c20b64.akpm@linux-foundation.org>
 <1242321000.6642.1456.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 2009-05-14 at 10:07 -0700, Andrew Morton wrote:
>> We do have capability in page reclaim to deliberately free up
>> physically contiguous pages (known as "lumpy reclaim").

Doesn't this require swap?

>> It would be interesting were someone to have a go at making that
>> available to userspace: ask the kernel to give you 1MB of physically
>> contiguous memory.  There are reasons why this can fail, but migrating
>> pages can be used to improve the success rate, and userspace can be
>> careful to not go nuts using mlock(), etc.

On Thu, 14 May 2009 19:10:00 +0200, Peter Zijlstra wrote:
> I thought we already exposed this, its called hugetlbfs ;-)

On Thu, 14 May 2009 21:33:11 +0200, Andi Kleen wrote:
> You could just define a hugepage size for that and use hugetlbfs
> with a few changes to map in pages with multiple PTEs.
> It supports boot time reservation and is a well established
> interface.
>
> On x86 that would give 2MB units, on other architectures whatever
> you prefer.

Correct me if I'm wrong, but if I understand correctly, currently only
one size of huge page may be defined, even if underlaying architecture
supports many different sizes.

So now, there are two cases: (i) either define huge page size to the
largest blocks that may ever be requested and then waste a lot of
memory when small pages are requested or (ii) define smaller huge
page size but then special handling of large regions need to be
implemented.

The first solution is not acceptable, as a lot of memory may be wasted.
If for example, you have a 4 mega pixel camera you'd have to configure
4 MiB-large huge pages but in most cases, you won't be needing that
much.  Often you will work with say 320x200x2 images (125KiB) and
more then 3MiBs will be wasted!

In the later, with (say) 128 KiB huge pages no (or little) space will be
wasted when working with 320x200x2 images but then when someone would
really need 4 MiB to take a photo the very same problem we started with
will occur -- we will have to find 32 contiguous pages.

So to sum up, if I understand everything correctly, hugetlb would be a
great solution when working with buffers of similar sizes.  However, it's
not so good when size of requested buffer may vary greatly.

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
