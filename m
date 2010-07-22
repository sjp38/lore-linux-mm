Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 80E7B6B02A5
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:49:37 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5Y00H5VDYMD350@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 10:49:34 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5Y0043PDYLMW@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jul 2010 10:49:34 +0100 (BST)
Date: Thu, 22 Jul 2010 11:50:58 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <20100722183432U.fujita.tomonori@lab.ntt.co.jp>
Message-id: <op.vf8oa80k7p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <20100720181239.5a1fd090@bike.lwn.net>
 <20100722143652V.fujita.tomonori@lab.ntt.co.jp>
 <000001cb296f$6eba8fa0$4c2faee0$%szyprowski@samsung.com>
 <20100722183432U.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: m.szyprowski@samsung.com, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: corbet@lwn.net, linux-mm@kvack.org, p.osciak@samsung.com, xiaolin.zhang@intel.com, hvaibhav@ti.com, robert.fekete@stericsson.com, marcus.xm.lorentzon@stericsson.com, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 11:35:07 +0200, FUJITA Tomonori <fujita.tomonori@lab=
.ntt.co.jp> wrote:
> You have the feature in the wrong place.
>
> Your example: a camera driver and a video driver can share 20MB, then
> they want 20MB exclusively.
>
> You can reserve 20MB and make them share it. Then you can reserve 20MB=

> for both exclusively.
>
> You know how the whole system works. Adjust drivers (probably, with
> module parameters).

So you are talking about moving complexity from the CMA core to the driv=
ers.
Ie. instead of configuring regions and mapping via CMA command line
parameters, the whole configuration is pushed to modules.  We consider t=
hat
suboptimal because it (i) does not reduce complexity -- it just moves it=

somewhere else, (ii) spreads the complexity to many modules instead of
single core of CMA, and (iii) spreads the configuration to many modules
instead of keeping it in one place.


> When a video driver needs 20MB to work properly, what's the point of
> releasing the 20MB for others then trying to get it again later?

If you have a video driver that needs 20MiB and a camera that needs 20Mi=
B
will you reserve 40MiB total? That's 20MiB wasted if on your system thos=
e
two can never work at the same time.  So do you reserve 20MiB and share?=

That won't work if on your system the two can work at the same time.

With CMA you can configure the kernel for both cases.

> Even with the above example (two devices never use the memory at the
> same time), the driver needs memory regularly. What's the point of
> split the 20MB to small chunks and allocate them to others?

Lost you there...  If something does not make sense on your system you
don't configure CMA to do that.  That's one of the points of CMA.  What
does not make sense on your platform may make perfect sense on some
other system, with some other drivers maybe.

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
