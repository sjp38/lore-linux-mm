Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3F63E6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 09:38:39 -0500 (EST)
Received: by pxi5 with SMTP id 5so2294605pxi.12
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:38:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113142608.33B9.A69D9226@jp.fujitsu.com>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
	 <1258054235-3208-6-git-send-email-mel@csn.ul.ie>
	 <20091113142608.33B9.A69D9226@jp.fujitsu.com>
Date: Fri, 13 Nov 2009 23:38:37 +0900
Message-ID: <28c262360911130638l7c0becbbsd09db0fd3837ffa5@mail.gmail.com>
Subject: Re: [PATCH 5/5] vmscan: Take order into consideration when deciding
	if kswapd is in trouble
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Koskai.

I missed this patch.
I noticed this after Mel reply your patch.

On Fri, Nov 13, 2009 at 6:54 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> If reclaim fails to make sufficient progress, the priority is raised.
>> Once the priority is higher, kswapd starts waiting on congestion.
>> However, on systems with large numbers of high-order atomics due to
>> crappy network cards, it's important that kswapd keep working in
>> parallel to save their sorry ass.
>>
>> This patch takes into account the order kswapd is reclaiming at before
>> waiting on congestion. The higher the order, the longer it is before
>> kswapd considers itself to be in trouble. The impact is that kswapd
>> works harder in parallel rather than depending on direct reclaimers or
>> atomic allocations to fail.
>>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> ---
>> =A0mm/vmscan.c | =A0 14 ++++++++++++--
>> =A01 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index ffa1766..5e200f1 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1946,7 +1946,7 @@ static int sleeping_prematurely(int order, long re=
maining)
>> =A0static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>> =A0{
>> =A0 =A0 =A0 int all_zones_ok;
>> - =A0 =A0 int priority;
>> + =A0 =A0 int priority, congestion_priority;
>> =A0 =A0 =A0 int i;
>> =A0 =A0 =A0 unsigned long total_scanned;
>> =A0 =A0 =A0 struct reclaim_state *reclaim_state =3D current->reclaim_sta=
te;
>> @@ -1967,6 +1967,16 @@ static unsigned long balance_pgdat(pg_data_t *pgd=
at, int order)
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 int temp_priority[MAX_NR_ZONES];
>>
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* When priority reaches congestion_priority, kswapd will sl=
eep
>> + =A0 =A0 =A0* for a short time while congestion clears. The higher the
>> + =A0 =A0 =A0* order being reclaimed, the less likely kswapd will go to
>> + =A0 =A0 =A0* sleep as high-order allocations are harder to reclaim and
>> + =A0 =A0 =A0* stall direct reclaimers longer
>> + =A0 =A0 =A0*/
>> + =A0 =A0 congestion_priority =3D DEF_PRIORITY - 2;
>> + =A0 =A0 congestion_priority -=3D min(congestion_priority, sc.order);
>
> This calculation mean
>
> =A0 =A0 =A0 =A0sc.order =A0 =A0 =A0 =A0congestion_priority =A0 =A0 scan-p=
ages
> =A0 =A0 =A0 =A0---------------------------------------------------------
> =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A0 =A0 10 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A01/1024 * zone-mem
> =A0 =A0 =A0 =A01 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/512 =A0* zone-mem
> =A0 =A0 =A0 =A02 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/256 =A0* zone-mem
> =A0 =A0 =A0 =A03 =A0 =A0 =A0 =A0 =A0 =A0 =A0 7 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/128 =A0* zone-mem
> =A0 =A0 =A0 =A04 =A0 =A0 =A0 =A0 =A0 =A0 =A0 6 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/64 =A0 * zone-mem
> =A0 =A0 =A0 =A05 =A0 =A0 =A0 =A0 =A0 =A0 =A0 5 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/32 =A0 * zone-mem
> =A0 =A0 =A0 =A06 =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/16 =A0 * zone-mem
> =A0 =A0 =A0 =A07 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/8 =A0 =A0* zone-mem
> =A0 =A0 =A0 =A08 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/4 =A0 =A0* zone-mem
> =A0 =A0 =A0 =A09 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1/2 =A0 =A0* zone-mem
> =A0 =A0 =A0 =A010 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0* zone-mem
> =A0 =A0 =A0 =A011+ =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1 =A0 =A0 =A0* zone-mem
>
> I feel this is too agressive. The intention of this congestion_wait()
> is to prevent kswapd use 100% cpu time. but the above promotion seems
> break it.

I can't understand your point.
Mel didn't change the number of scan pages.
It denpends on priority.
He just added another one to prevent frequent contestion_wait.
Still, shrink_zone is called with priority, not congestion_priority.

> example,
> ia64 have 256MB hugepage (i.e. order=3D14). it mean kswapd never sleep.

Indeed. Good catch.

> example2,
> order-3 (i.e. PAGE_ALLOC_COSTLY_ORDER) makes one of most inefficent
> reclaim, because it doesn't use lumpy recliam.
> I've seen 128GB size zone, it mean 1/128 =3D 1GB. oh well, kswapd definit=
ely
> waste cpu time 100%.

Above I said, It depends on priority, not congestion_priority.

>
>> +
>> =A0loop_again:
>> =A0 =A0 =A0 total_scanned =3D 0;
>> =A0 =A0 =A0 sc.nr_reclaimed =3D 0;
>> @@ -2092,7 +2102,7 @@ loop_again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* OK, kswapd is getting into trouble. =A0=
Take a nap, then take
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* another pass across the zones.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < DEF_PRIORITY -=
 2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < congestion_pri=
ority)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(BLK_RW_ASYNC=
, HZ/10);
>
> Instead, How about this?
>
>
>
> ---
> =A0mm/vmscan.c | =A0 13 ++++++++++++-
> =A01 files changed, 12 insertions(+), 1 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 64e4388..937e90d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1938,6 +1938,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat=
, int order)
> =A0 =A0 =A0 =A0 * free_pages =3D=3D high_wmark_pages(zone).
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0int temp_priority[MAX_NR_ZONES];
> + =A0 =A0 =A0 int has_under_min_watermark_zone =3D 0;

Let's make the shorter.
How about "under_min_watermark"?

>
> =A0loop_again:
> =A0 =A0 =A0 =A0total_scanned =3D 0;
> @@ -2057,6 +2058,15 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (total_scanned > SWAP_C=
LUSTER_MAX * 2 &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scanned > sc=
.nr_reclaimed + sc.nr_reclaimed / 2)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.may_wri=
tepage =3D 1;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We are still under min=
 water mark. it mean we have
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* GFP_ATOMIC allocation =
failure risk. Hurry up!
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_watermark_ok(zone=
, order, min_wmark_pages(zone),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 end_zone, 0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 has_under_m=
in_watermark_zone =3D 1;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (all_zones_ok)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break; =A0 =A0 =A0 =A0 =A0=
/* kswapd: all done */
> @@ -2064,7 +2074,8 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * OK, kswapd is getting into trouble. =A0=
Take a nap, then take
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * another pass across the zones.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < DEF_PRIORIT=
Y - 2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && (priority < DEF_PRIORI=
TY - 2) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !has_under_min_watermark_zone)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0congestion_wait(BLK_RW_ASY=
NC, HZ/10);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> --
> 1.6.2.5

Anyway, Looks good to me.
It's more straightforward than Mel's one, I think.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
