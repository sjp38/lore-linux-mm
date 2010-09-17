Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9CA9C6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 00:47:58 -0400 (EDT)
Received: by iwn33 with SMTP id 33so2334797iwn.14
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 21:47:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100917023457.GA26307@sli10-conroe.sh.intel.com>
References: <1284636396.1726.5.camel@shli-laptop>
	<20100916150009.GD16115@barrios-desktop>
	<20100917023457.GA26307@sli10-conroe.sh.intel.com>
Date: Fri, 17 Sep 2010 13:47:56 +0900
Message-ID: <AANLkTi=XHGxcxcz82ccrLSUrS9NcXb6qBh0TcnGkPzYB@mail.gmail.com>
Subject: Re: [RFC]pagealloc: compensate a task for direct page reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 17, 2010 at 11:34 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Thu, Sep 16, 2010 at 11:00:10PM +0800, Minchan Kim wrote:
>> On Thu, Sep 16, 2010 at 07:26:36PM +0800, Shaohua Li wrote:
>> > A task enters into direct page reclaim, free some memory. But sometime=
s
>> > the task can't get a free page after direct page reclaim because
>> > other tasks take them (this is quite common in a multi-task workload
>> > in my test). This behavior will bring extra latency to the task and is
>> > unfair. Since the task already gets penalty, we'd better give it a com=
pensation.
>> > If a task frees some pages from direct page reclaim, we cache one free=
d page,
>> > and the task will get it soon. We only consider order 0 allocation, be=
cause
>> > it's hard to cache order > 0 page.
>> >
>> > Below is a trace output when a task frees some pages in try_to_free_pa=
ges(), but
>> > get_page_from_freelist() can't get a page in direct page reclaim.
>> >
>> > <...>-809 =A0 [004] =A0 730.218991: __alloc_pages_nodemask: progress 1=
47, order 0, pid 809, comm mmap_test
>> > <...>-806 =A0 [001] =A0 730.237969: __alloc_pages_nodemask: progress 1=
47, order 0, pid 806, comm mmap_test
>> > <...>-810 =A0 [005] =A0 730.237971: __alloc_pages_nodemask: progress 1=
47, order 0, pid 810, comm mmap_test
>> > <...>-809 =A0 [004] =A0 730.237972: __alloc_pages_nodemask: progress 1=
47, order 0, pid 809, comm mmap_test
>> > <...>-811 =A0 [006] =A0 730.241409: __alloc_pages_nodemask: progress 1=
47, order 0, pid 811, comm mmap_test
>> > <...>-809 =A0 [004] =A0 730.241412: __alloc_pages_nodemask: progress 1=
47, order 0, pid 809, comm mmap_test
>> > <...>-812 =A0 [007] =A0 730.241435: __alloc_pages_nodemask: progress 1=
47, order 0, pid 812, comm mmap_test
>> > <...>-809 =A0 [004] =A0 730.245036: __alloc_pages_nodemask: progress 1=
47, order 0, pid 809, comm mmap_test
>> > <...>-809 =A0 [004] =A0 730.260360: __alloc_pages_nodemask: progress 1=
47, order 0, pid 809, comm mmap_test
>> > <...>-805 =A0 [000] =A0 730.260362: __alloc_pages_nodemask: progress 1=
47, order 0, pid 805, comm mmap_test
>> > <...>-811 =A0 [006] =A0 730.263877: __alloc_pages_nodemask: progress 1=
47, order 0, pid 811, comm mmap_test
>> >
>>
>> The idea is good.
>>
>> I think we need to reserve at least one page for direct reclaimer who ma=
ke the effort so that
>> it can reduce latency of stalled process.
>>
>> But I don't like this implementation.
>>
>> 1. It selects random page of reclaimed pages as cached page.
>> This doesn't consider requestor's migratetype so that it causes fragment=
 problem in future.
> maybe we can limit the migratetype to MIGRATE_MOVABLE, which is the most =
common case.
>
>> 2. It skips buddy allocator. It means we lost coalescence chance so that=
 fragement problem
>> would be severe than old.
> we only cache order 0 allocation, which doesn't enter lumpy reclaim, so t=
his sounds not
> an issue to me.

I mean following as.

Old behavior.

1) return 0-order page
2) Fortunately, It fills the hole for order-1, so the page would be
promoted order-1 page
3) Fortunately, It fills the hole for order-2, so the page would be
promoted order-2 page
4) repeatedly until some order.
5) Finally, alloc_page will allocate a order-o one page(ie not
coalesce) of all which reclaimed direct reclaimer from buddy.

But your patch lost the chance on cached page.

Of course, If any pages reclaimed isn't in order 0 list(ie, all page
should be coalesce), big page have to be break with order-0 page. But
it's unlikely.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
