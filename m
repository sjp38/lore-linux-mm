Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B7D4A6B008C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:57:07 -0500 (EST)
Received: by iwn1 with SMTP id 1so2757942iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 17:57:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTik3KBVZBaOxSeO01N1XXobXTOiSAsZcyv0mJraC@mail.gmail.com>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
	<20101209003621.GB3796@hostway.ca>
	<20101208172324.d45911f4.akpm@linux-foundation.org>
	<AANLkTik3KBVZBaOxSeO01N1XXobXTOiSAsZcyv0mJraC@mail.gmail.com>
Date: Thu, 9 Dec 2010 10:57:05 +0900
Message-ID: <AANLkTi=PAdGaS03Maaxkbn7SHyj3ahgrA=i5c=P2=N9k@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Where is my code?
Resend.

On Thu, Dec 9, 2010 at 10:55 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Dec 9, 2010 at 10:23 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:
>>
>>> On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
>>>
>>> > Kswapd tries to rebalance zones persistently until their high
>>> > watermarks are restored.
>>> >
>>> > If the amount of unreclaimable pages in a zone makes this impossible
>>> > for reclaim, though, kswapd will end up in a busy loop without a
>>> > chance of reaching its goal.
>>> >
>>> > This behaviour was observed on a virtual machine with a tiny
>>> > Normal-zone that filled up with unreclaimable slab objects.
>>> >
>>> > This patch makes kswapd skip rebalancing on such 'hopeless' zones and
>>> > leaves them to direct reclaim.
>>>
>>> Hi!
>>>
>>> We are experiencing a similar issue, though with a 757 MB Normal zone,
>>> where kswapd tries to rebalance Normal after an order-3 allocation whil=
e
>>> page cache allocations (order-0) keep splitting it back up again. =A0It=
 can
>>> run the whole day like this (SSD storage) without sleeping.
>>
>> People at google have told me they've seen the same thing. =A0A fork is
>> taking 15 minutes when someone else is doing a dd, because the fork
>> enters direct-reclaim trying for an order-one page. =A0It successfully
>> frees some order-one pages but before it gets back to allocate one, dd
>> has gone and stolen them, or split them apart.
>>
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
>
> It can't make sure success since direct reclaim needs sleep with !GFP_AOM=
IC.
>
>>
>> b) reinstate the one-deep task-local free page cache.
>
> I like b) so how about this?
> Just for the concept.
>
> @@ -1880,7 +1881,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask,
> unsigned int order,
> =A0 =A0 =A0 =A0reclaim_state.reclaimed_slab =3D 0;
> =A0 =A0 =A0 =A0p->reclaim_state =3D &reclaim_state;
>
> - =A0 =A0 =A0 *did_some_progress =3D try_to_free_pages(zonelist, order,
> gfp_mask, nodemask);
> + =A0 =A0 =A0 *did_some_progress =3D try_to_free_pages(zonelist, order,
> gfp_mask, nodemask, &ret_pages);
>
> =A0 =A0 =A0 =A0p->reclaim_state =3D NULL;
> =A0 =A0 =A0 =A0lockdep_clear_current_reclaim_state();
> @@ -1892,10 +1893,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask,
> unsigned int order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> =A0retry:
> - =A0 =A0 =A0 page =3D get_page_from_freelist(gfp_mask, nodemask, order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 zonelist, high_zoneidx,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 alloc_flags, preferred_zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 migratetype);
> + =A0 =A0 =A0 if(!list_empty(&ret_pages)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lru_to_page(ret_pages);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page_list(&ret_pages);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If an allocation failed after direct reclaim, it could =
be because
>
> --
> Kind regards,
> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
