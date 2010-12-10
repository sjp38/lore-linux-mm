Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD60C6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 14:46:45 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oBAJkcGJ029477
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 11:46:39 -0800
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by hpaq12.eem.corp.google.com with ESMTP id oBAJkVXb005864
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 11:46:37 -0800
Received: by qwj8 with SMTP id 8so4267548qwj.38
        for <linux-mm@kvack.org>; Fri, 10 Dec 2010 11:46:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101210113717.GS20133@csn.ul.ie>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
	<AANLkTik1sqUqk061KMu8ZEn5Ai4AyTfKR3JA1ceR5qFW@mail.gmail.com>
	<20101210113717.GS20133@csn.ul.ie>
Date: Fri, 10 Dec 2010 11:46:31 -0800
Message-ID: <AANLkTi=w11B1Ku+q8pAJXihh8FEAOhXkzMXjL43w7Gib@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 3:37 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Thu, Dec 09, 2010 at 10:39:46AM -0800, Ying Han wrote:
>> On Wed, Dec 8, 2010 at 5:23 PM, Andrew Morton <akpm@linux-foundation.org=
> wrote:
>> > On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:
>> >
>> >> On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
>> >>
>> >> > Kswapd tries to rebalance zones persistently until their high
>> >> > watermarks are restored.
>> >> >
>> >> > If the amount of unreclaimable pages in a zone makes this impossibl=
e
>> >> > for reclaim, though, kswapd will end up in a busy loop without a
>> >> > chance of reaching its goal.
>> >> >
>> >> > This behaviour was observed on a virtual machine with a tiny
>> >> > Normal-zone that filled up with unreclaimable slab objects.
>> >> >
>> >> > This patch makes kswapd skip rebalancing on such 'hopeless' zones a=
nd
>> >> > leaves them to direct reclaim.
>> >>
>> >> Hi!
>> >>
>> >> We are experiencing a similar issue, though with a 757 MB Normal zone=
,
>> >> where kswapd tries to rebalance Normal after an order-3 allocation wh=
ile
>> >> page cache allocations (order-0) keep splitting it back up again. =A0=
It can
>> >> run the whole day like this (SSD storage) without sleeping.
>> >
>> > People at google have told me they've seen the same thing. =A0A fork i=
s
>> > taking 15 minutes when someone else is doing a dd, because the fork
>> > enters direct-reclaim trying for an order-one page. =A0It successfully
>> > frees some order-one pages but before it gets back to allocate one, dd
>> > has gone and stolen them, or split them apart.
>>
>> So we are running into this problem in a container environment. While
>> running dd in a container with
>> bunch of system daemons like sshd, we've seen sshd being OOM killed.
>>
>
> It's possible that containers are *particularly* vunerable to this
> problem because they don't have kswapd.
In our fake numa enviroment, we do have per-container kswapd which are
the ones in container's nodemask. We also have extension for
consolidating all kswapds per-container due to bad lock contention.

As direct reclaimers go to sleep, the race between an order-1 page
being freed and another request
breaking up the order-1 page might be far more severe.

One thing we found which affecting the OOM is the logic in
inactive_file_is_low_global(), which tries to balance Active/Inactive
into 50%. If pages being promoted to Active (dirty data) and they will
be safe for being reclaimed until the LRU becomes unbalanced. So for
streaming IO, we have pages in Active list which won't be used again
and won't be scanned by page reclaim neither.

--Ying




>
>> One of the theory which we haven't fully proven is dd keep sallocating
>> and stealing pages which just being
>> reclaimed from ttfp of sshd. We've talked with Andrew and wondering if
>> there is a way to prevent that
>> happening. And we learned that we might have something for order 0
>> pages since they got freed to per-cpu
>> list and the process triggered ttfp more likely to get it unless being
>> rescheduled. But nothing for order 1 which
>> is fork() in this case.
>>
>> --Ying
>>
>> >
>> > This problem would have got worse when slub came along doing its stupi=
d
>> > unnecessary high-order allocations.
>> >
>> > Billions of years ago a direct-reclaimer had a one-deep cache in the
>> > task_struct into which it freed the page to prevent it from getting
>> > stolen.
>> >
>> > Later, we took that out because pages were being freed into the
>> > per-cpu-pages magazine, which is effectively task-local anyway. =A0But
>> > per-cpu-pages are only for order-0 pages. =A0See slub stupidity, above=
