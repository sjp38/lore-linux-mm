Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 80A4E6B0011
	for <linux-mm@kvack.org>; Tue, 17 May 2011 06:34:51 -0400 (EDT)
Received: by qwa26 with SMTP id 26so243150qwa.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 03:34:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DCDA347.9080207@cray.com>
References: <4DCDA347.9080207@cray.com>
Date: Tue, 17 May 2011 19:34:47 +0900
Message-ID: <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc: patch.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Barry <abarry@cray.com>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, May 14, 2011 at 6:31 AM, Andrew Barry <abarry@cray.com> wrote:
> I believe I found a problem in __alloc_pages_slowpath, which allows a pro=
cess to
> get stuck endlessly looping, even when lots of memory is available.
>
> Running an I/O and memory intensive stress-test I see a 0-order page allo=
cation
> with __GFP_IO and __GFP_WAIT, running on a system with very little free m=
emory.
> Right about the same time that the stress-test gets killed by the OOM-kil=
ler,
> the utility trying to allocate memory gets stuck in __alloc_pages_slowpat=
h even
> though most of the systems memory was freed by the oom-kill of the stress=
-test.
>
> The utility ends up looping from the rebalance label down through the
> wait_iff_congested continiously. Because order=3D0, __alloc_pages_direct_=
compact
> skips the call to get_page_from_freelist. Because all of the reclaimable =
memory
> on the system has already been reclaimed, __alloc_pages_direct_reclaim sk=
ips the
> call to get_page_from_freelist. Since there is no __GFP_FS flag, the bloc=
k with
> __alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, t=
hen
> jumps back to rebalance without ever trying to get_page_from_freelist. Th=
is loop
> repeats infinitely.
>
> Is there a reason that this loop is set up this way for 0 order allocatio=
ns? I
> applied the below patch, and the problem corrects itself. Does anyone hav=
e any
> thoughts on the patch, or on a better way to address this situation?
>
> The test case is pretty pathological. Running a mix of I/O stress-tests t=
hat do
> a lot of fork() and consume all of the system memory, I can pretty reliab=
ly hit
> this on 600 nodes, in about 12 hours. 32GB/node.
>

It's amazing.
I think it's _very_ rare but it's possible if test program killed by
oom has only lots of anonymous pages and allocation tasks try to
allocate order-0 page with GFP_NOFS.

When the [in]active lists are empty suddenly(But I am not sure how
come the situation happens.) and we are reclaiming order-0 page,
compaction and __alloc_pages_direct_reclaim doesn't work. compaction
doesn't work as it's order-0 page reclaiming.  In case of
__alloc_pages_direct_reclaim, it would work only if we have lru pages
in [in]active list. But unfortunately we don't have any pages in lru
list.
So, last resort is following codes in do_try_to_free_pages.

        /* top priority shrink_zones still had more to do? don't OOM, then =
*/
        if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
                return 1;

But it has a problem, too. all_unreclaimable checks zone->all_unreclaimable=
.
zone->all_unreclaimable is set by below condition.

zone->pages_scanned < zone_reclaimable_pages(zone) * 6

If lru list is completely empty, shrink_zone doesn't work so
zone->pages_scanned would be zero. But as we know, zone_page_state
isn't exact by per_cpu_pageset. So it might be positive value. After
all, zone_reclaimable always return true. It means kswapd never set
zone->all_unreclaimable.  So last resort become nop.

In this case, current allocation doesn't have a chance to call
get_page_from_freelist as Andrew Barry said.

Does it make sense?
If it is, how about this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebc7faa..4f64355 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2105,6 +2105,7 @@ restart:
                first_zones_zonelist(zonelist, high_zoneidx, NULL,
                                        &preferred_zone);

+rebalance:
        /* This is the last chance, in general, before the goto nopage. */
        page =3D get_page_from_freelist(gfp_mask, nodemask, order, zonelist=
,
                        high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
@@ -2112,7 +2113,6 @@ restart:
        if (page)
                goto got_pg;

-rebalance:
        /* Allocate without watermarks if the context allows */
        if (alloc_flags & ALLOC_NO_WATERMARKS) {
                page =3D __alloc_pages_high_priority(gfp_mask, order,


> Thanks
> Andrew Barry
>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A05 ++++-
> =C2=A01 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9f8a97b..c719664 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2158,7 +2158,10 @@ rebalance:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (should_alloc_retry(gfp_mask, order, pages_=
reclaimed)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Wait for some w=
rite requests to complete then retry */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wait_iff_congested=
(preferred_zone, BLK_RW_ASYNC, HZ/50);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto rebalance;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (did_some_progress)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto rebalance;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto restart;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * High-order allo=
cations do not necessarily loop after
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
