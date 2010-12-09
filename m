Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CC0CC6B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 13:48:42 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oB9Imd7I025277
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 10:48:40 -0800
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by wpaz1.hot.corp.google.com with ESMTP id oB9ImcH8028291
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 10:48:38 -0800
Received: by qyj19 with SMTP id 19so76418qyj.12
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 10:48:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101209144412.GE20133@csn.ul.ie>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
	<20101209144412.GE20133@csn.ul.ie>
Date: Thu, 9 Dec 2010 10:48:37 -0800
Message-ID: <AANLkTimHrL5HnSf-rAMGdg-_ZKZ5RgJ_sEWo+BH5Q9sL@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 6:44 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, Dec 08, 2010 at 05:23:24PM -0800, Andrew Morton wrote:
>> On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:
>>
>> > On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
>> >
>> > > Kswapd tries to rebalance zones persistently until their high
>> > > watermarks are restored.
>> > >
>> > > If the amount of unreclaimable pages in a zone makes this impossible
>> > > for reclaim, though, kswapd will end up in a busy loop without a
>> > > chance of reaching its goal.
>> > >
>> > > This behaviour was observed on a virtual machine with a tiny
>> > > Normal-zone that filled up with unreclaimable slab objects.
>> > >
>> > > This patch makes kswapd skip rebalancing on such 'hopeless' zones an=
d
>> > > leaves them to direct reclaim.
>> >
>> > Hi!
>> >
>> > We are experiencing a similar issue, though with a 757 MB Normal zone,
>> > where kswapd tries to rebalance Normal after an order-3 allocation whi=
le
>> > page cache allocations (order-0) keep splitting it back up again. =A0I=
t can
>> > run the whole day like this (SSD storage) without sleeping.
>>
>> People at google have told me they've seen the same thing. =A0A fork is
>> taking 15 minutes when someone else is doing a dd, because the fork
>> enters direct-reclaim trying for an order-one page. =A0It successfully
>> frees some order-one pages but before it gets back to allocate one, dd
>> has gone and stolen them, or split them apart.
>>
>
> Is there a known test case for this or should I look at doing a
> streaming-IO test with a basic workload constantly forking in the
> background to measure the fork latency?

We were seeing some system daemons(sshd) being OOM killed while
running in the same
memory container as dd test. I assume we can generate the test case
while running dd on
10G of file in 1G container, at the same time running
unixbench(fork/exec loop)?

--Ying

>
>> This problem would have got worse when slub came along doing its stupid
>> unnecessary high-order allocations.
>>
>> Billions of years ago a direct-reclaimer had a one-deep cache in the
>> task_struct into which it freed the page to prevent it from getting
>> stolen.
>>
>> Later, we took that out because pages were being freed into the
>> per-cpu-pages magazine, which is effectively task-local anyway. =A0But
>> per-cpu-pages are only for order-0 pages. =A0See slub stupidity, above.
>>
>> I expect that this is happening so repeatably because the
>> direct-reclaimer is dong a sleep somewhere after freeing the pages it
>> needs - if it wasn't doing that then surely the window wouldn't be wide
>> enough for it to happen so often. =A0But I didn't look.
>>
>> Suitable fixes might be
>>
>> a) don't go to sleep after the successful direct-reclaim.
>>
>
> I submitted a patch for this a long time ago but at the time we didn't
> have a test case that made a difference to it. Might be worth
> revisiting. I can't find the related patch any more but it was fairly
> trivial.

If you have the patch, maybe we can give a try on our case.

--Ying
>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
