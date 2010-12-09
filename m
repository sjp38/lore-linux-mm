Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC14D6B0089
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:55:26 -0500 (EST)
Received: by iwn1 with SMTP id 1so2755813iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 17:55:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208172324.d45911f4.akpm@linux-foundation.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
Date: Thu, 9 Dec 2010 10:55:24 +0900
Message-ID: <AANLkTik3KBVZBaOxSeO01N1XXobXTOiSAsZcyv0mJraC@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 10:23 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:
>
>> On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
>>
>> > Kswapd tries to rebalance zones persistently until their high
>> > watermarks are restored.
>> >
>> > If the amount of unreclaimable pages in a zone makes this impossible
>> > for reclaim, though, kswapd will end up in a busy loop without a
>> > chance of reaching its goal.
>> >
>> > This behaviour was observed on a virtual machine with a tiny
>> > Normal-zone that filled up with unreclaimable slab objects.
>> >
>> > This patch makes kswapd skip rebalancing on such 'hopeless' zones and
>> > leaves them to direct reclaim.
>>
>> Hi!
>>
>> We are experiencing a similar issue, though with a 757 MB Normal zone,
>> where kswapd tries to rebalance Normal after an order-3 allocation while
>> page cache allocations (order-0) keep splitting it back up again. =A0It =
can
>> run the whole day like this (SSD storage) without sleeping.
>
> People at google have told me they've seen the same thing. =A0A fork is
> taking 15 minutes when someone else is doing a dd, because the fork
> enters direct-reclaim trying for an order-one page. =A0It successfully
> frees some order-one pages but before it gets back to allocate one, dd
> has gone and stolen them, or split them apart.
>
> This problem would have got worse when slub came along doing its stupid
> unnecessary high-order allocations.
>
> Billions of years ago a direct-reclaimer had a one-deep cache in the
> task_struct into which it freed the page to prevent it from getting
> stolen.
>
> Later, we took that out because pages were being freed into the
> per-cpu-pages magazine, which is effectively task-local anyway. =A0But
> per-cpu-pages are only for order-0 pages. =A0See slub stupidity, above.
>
> I expect that this is happening so repeatably because the
> direct-reclaimer is dong a sleep somewhere after freeing the pages it
> needs - if it wasn't doing that then surely the window wouldn't be wide
> enough for it to happen so often. =A0But I didn't look.
>
> Suitable fixes might be
>
> a) don't go to sleep after the successful direct-reclaim.

It can't make sure success since direct reclaim needs sleep with !GFP_AOMIC=
