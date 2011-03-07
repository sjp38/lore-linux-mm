Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4828D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:45:54 -0500 (EST)
Received: by iwl42 with SMTP id 42so5924161iwl.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 15:45:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110307135831.9e0d7eaa.akpm@linux-foundation.org>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
Date: Tue, 8 Mar 2011 08:45:51 +0900
Message-ID: <AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 8, 2011 at 6:58 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Sun, 6 Mar 2011 02:07:59 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Sat, Mar 05, 2011 at 07:41:26PM +0300, Andrew Vagin wrote:
>> > On 03/05/2011 06:53 PM, Minchan Kim wrote:
>> > >On Sat, Mar 05, 2011 at 06:34:37PM +0300, Andrew Vagin wrote:
>> > >>On 03/05/2011 06:20 PM, Minchan Kim wrote:
>> > >>>On Sat, Mar 05, 2011 at 02:44:16PM +0300, Andrey Vagin wrote:
>> > >>>>Check zone->all_unreclaimable in all_unreclaimable(), otherwise th=
e
>> > >>>>kernel may hang up, because shrink_zones() will do nothing, but
>> > >>>>all_unreclaimable() will say, that zone has reclaimable pages.
>> > >>>>
>> > >>>>do_try_to_free_pages()
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_zones()
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for_each_=
zone
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0if (zone->all_unreclaimable)
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if !all_unreclaimable(zonelist, sc)
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1
>> > >>>>
>> > >>>>__alloc_pages_slowpath()
>> > >>>>retry:
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0did_some_progress =3D do_try_to_free_p=
ages(page)
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page&& =C2=A0 did_some_progress)
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0retry;
>> > >>>>
>> > >>>>Signed-off-by: Andrey Vagin<avagin@openvz.org>
>> > >>>>---
>> > >>>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A02 ++
>> > >>>> =C2=A01 files changed, 2 insertions(+), 0 deletions(-)
>> > >>>>
>> > >>>>diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > >>>>index 6771ea7..1c056f7 100644
>> > >>>>--- a/mm/vmscan.c
>> > >>>>+++ b/mm/vmscan.c
>> > >>>>@@ -2002,6 +2002,8 @@ static bool all_unreclaimable(struct zonelis=
t *zonelist,
>> > >>>>
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_zone_zonelist_nodemask(zone, =
z, zonelist,
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0gfp_zone(sc->gfp_mask), sc->nodemask) {
>> > >>>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (zone->all_u=
nreclaimable)
>> > >>>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 continue;
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!popul=
ated_zone(zone))
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0continue;
>> > >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cpuse=
t_zone_allowed_hardwall(zone, GFP_KERNEL))
>> > >>>zone_reclaimable checks it. Isn't it enough?
>> > >>I sent one more patch [PATCH] mm: skip zombie in OOM-killer.
>> > >>This two patches are enough.
>> > >Sorry if I confused you.
>> > >I mean zone->all_unreclaimable become true if !zone_reclaimable in ba=
lance_pgdat.
>> > >zone_reclaimable compares recent pages_scanned with the number of zon=
e lru pages.
>> > >So too many page scanning in small lru pages makes the zone to unrecl=
aimable zone.
>> > >
>> > >In all_unreclaimable, we calls zone_reclaimable to detect it.
>> > >It's the same thing with your patch.
>> > balance_pgdat set zone->all_unreclaimable, but the problem is that
>> > it is cleaned late.
>>
>> Yes. It can be delayed by pcp so (zone->all_unreclaimable =3D true) is
>> a false alram since zone have a free page and it can be returned
>> to free list by drain_all_pages in next turn.
>>
>> >
>> > The problem is that zone->all_unreclaimable =3D True, but
>> > zone_reclaimable() returns True too.
>>
>> Why is it a problem?
>> If zone->all_unreclaimable gives a false alram, we does need to check
>> it again by zone_reclaimable call.
>>
>> If we believe a false alarm and give up the reclaim, maybe we have to ma=
ke
>> unnecessary oom kill.
>>
>> >
>> > zone->all_unreclaimable will be cleaned in free_*_pages, but this
>> > may be late. It is enough allocate one page from page cache, that
>> > zone_reclaimable() returns True and zone->all_unreclaimable becomes
>> > True.
>> > >>>Does the hang up really happen or see it by code review?
>> > >>Yes. You can reproduce it for help the attached python program. It's
>> > >>not very clever:)
>> > >>It make the following actions in loop:
>> > >>1. fork
>> > >>2. mmap
>> > >>3. touch memory
>> > >>4. read memory
>> > >>5. munmmap
>> > >It seems the test program makes fork bombs and memory hogging.
>> > >If you applied this patch, the problem is gone?
>> > Yes.
>>
>> Hmm.. Although it solves the problem, I think it's not a good idea that
>> depends on false alram and give up the retry.
>
> Any alternative proposals? =C2=A0We should get the livelock fixed if poss=
ible..
>

And we should avoid unnecessary OOM kill if possible.

I think the problem is caused by (zone->pages_scanned <
zone_reclaimable_pages(zone) * 6). I am not sure (* 6) is a best. It
would be rather big on recent big DRAM machines.

I think it is a trade-off between latency and OOM kill.
If we decrease the magic value, maybe we should prevent the almost
livelock but happens unnecessary OOM kill.

And I think zone_reclaimable not fair.
For example, too many scanning makes reclaimable state to
unreclaimable state. Maybe it takes a very long time. But just some
page free makes unreclaimable state to reclaimabe with very easy. So
we need much painful reclaiming for changing reclaimable state with
unreclaimabe state. it would affect latency very much.

Maybe we need more smart zone_reclaimabe which is adaptive with memory pres=
sure.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
