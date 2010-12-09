Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 636F96B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 00:25:07 -0500 (EST)
Received: by iwn1 with SMTP id 1so3031273iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 21:25:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208180156.91dcd122.akpm@linux-foundation.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
	<AANLkTik3KBVZBaOxSeO01N1XXobXTOiSAsZcyv0mJraC@mail.gmail.com>
	<20101208180156.91dcd122.akpm@linux-foundation.org>
Date: Thu, 9 Dec 2010 14:18:44 +0900
Message-ID: <AANLkTi=wfKhxWPsLzzRjT088PC1dHmDCoNkPfrnLH-6r@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=001485eba1e825354f0496f35f1b
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--001485eba1e825354f0496f35f1b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 9, 2010 at 11:01 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 9 Dec 2010 10:55:24 +0900 Minchan Kim <minchan.kim@gmail.com> wro=
te:
>
>> >> > leaves them to direct reclaim.
>> >>
>> >> Hi!
>> >>
>> >> We are experiencing a similar issue, though with a 757 MB Normal zone=
,
>> >> where kswapd tries to rebalance Normal after an order-3 allocation wh=
ile
>> >> page cache allocations (order-0) keep splitting it back up again. __I=
t can
>> >> run the whole day like this (SSD storage) without sleeping.
>> >
>> > People at google have told me they've seen the same thing. __A fork is
>> > taking 15 minutes when someone else is doing a dd, because the fork
>> > enters direct-reclaim trying for an order-one page. __It successfully
>> > frees some order-one pages but before it gets back to allocate one, dd
>> > has gone and stolen them, or split them apart.
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
>> > per-cpu-pages magazine, which is effectively task-local anyway. __But
>> > per-cpu-pages are only for order-0 pages. __See slub stupidity, above.
>> >
>> > I expect that this is happening so repeatably because the
>> > direct-reclaimer is dong a sleep somewhere after freeing the pages it
>> > needs - if it wasn't doing that then surely the window wouldn't be wid=
e
>> > enough for it to happen so often. __But I didn't look.
>> >
>> > Suitable fixes might be
>> >
>> > a) don't go to sleep after the successful direct-reclaim.
>>
>> It can't make sure success since direct reclaim needs sleep with !GFP_AO=
MIC.
>
> It doesn't necessarily need to sleep *after* successfully freeing
> pages. =A0If it needs to sleep then do it before or during the freeing.
>
>> >
>> > b) reinstate the one-deep task-local free page cache.
>>
>> I like b) so how about this?
>> Just for the concept.
>>
>> @@ -1880,7 +1881,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask,
>> unsigned int order,
>> =A0 =A0 =A0 =A0 reclaim_state.reclaimed_slab =3D 0;
>> =A0 =A0 =A0 =A0 p->reclaim_state =3D &reclaim_state;
>>
>> - =A0 =A0 =A0 *did_some_progress =3D try_to_free_pages(zonelist, order,
>> gfp_mask, nodemask);
>> + =A0 =A0 =A0 *did_some_progress =3D try_to_free_pages(zonelist, order,
>> gfp_mask, nodemask, &ret_pages);
>>
>> =A0 =A0 =A0 =A0 p->reclaim_state =3D NULL;
>> =A0 =A0 =A0 =A0 lockdep_clear_current_reclaim_state();
>> @@ -1892,10 +1893,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask,
>> unsigned int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>>
>> =A0retry:
>> - =A0 =A0 =A0 page =3D get_page_from_freelist(gfp_mask, nodemask, order,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 zonelist, high_zoneidx,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 alloc_flags, preferred_zone,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 migratetype);
>> + =A0 =A0 =A0 if(!list_empty(&ret_pages)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lru_to_page(ret_pages);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page_list(&ret_pages);
>> + =A0 =A0 =A0 }
>
> Maybe. =A0Or just pass a page*.
>

I did it more detailed but It's not completed and test at all.
Please consider just RFC.

-- CUT_HERE --
--001485eba1e825354f0496f35f1b--
