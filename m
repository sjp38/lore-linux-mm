Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4CC6B01F1
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 04:38:16 -0400 (EDT)
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	 <1282310110.2605.976.camel@laptop>
	 <20100825155814.25c783c7.akpm@linux-foundation.org>
	 <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
	 <op.vh0wektv7p4s8u@localhost>
	 <20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
	 <AANLkTi=T1y+sQuqVTYgOkYvqrxdYB1bZmCpKafN5jPqi@mail.gmail.com>
	 <20100826133028.39d731da.kamezawa.hiroyu@jp.fujitsu.com>
	 <AANLkTimB+s0tO=wrODAU4qCaZnCBoLZ2A9pGjR_jheOj@mail.gmail.com>
	 <20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 27 Aug 2010 10:37:40 +0200
Message-ID: <1282898260.1975.1844.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-27 at 17:16 +0900, KAMEZAWA Hiroyuki wrote:
> > How about changing following this?
> > The thing is MAX_ORDER is static. But we want to avoid too big
> > MAX_ORDER of whole zones to support devices which requires big
> > allocation chunk.
> > So let's add MAX_ORDER into each zone and then, each zone can have
> > different max order.
> > For example, while DMA[32], NORMAL, HIGHMEM can have normal size 11,
> > MOVABLE zone could have a 15.
> >=20
> > This approach has a big side effect?

The side effect of increasing MAX_ORDER is that page allocations get
more expensive since the buddy tree gets larger, yielding more
splits/merges.

> Hm...need to check hard coded MAX_ORDER usages...I don't think
> side-effect is big. Hmm. But I think enlarging MAX_ORDER isn't an
> important thing. A code which strips contiguous chunks of pages from
> buddy allocator is a necessaty thing, as..

Right, once we can explicitly free the pages we want, crossing MAX_ORDER
isn't too hard like you say, we can simply continue with freeing the
next in order page.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
