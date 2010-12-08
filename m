Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B7866B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 18:10:18 -0500 (EST)
Received: by iwn1 with SMTP id 1so2541315iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 15:10:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87oc8wa063.fsf@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
	<20101208170504.1750.A69D9226@jp.fujitsu.com>
	<AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
	<87oc8wa063.fsf@gmail.com>
Date: Thu, 9 Dec 2010 08:10:17 +0900
Message-ID: <AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 10:01 PM, Ben Gamari <bgamari.foss@gmail.com> wrote:
>> Make sense to me. If Ben is busy, I will measure it and send the result.
>
> I've done measurements on the patched kernel. All that remains is to do
> measurements on the baseline unpached case. To summarize the results
> thusfar,
>
> Times:
> =3D=3D=3D=3D=3D=3D=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 user =A0 =A0sys =A0 =A0 %cpu =
=A0 =A0inputs =A0 =A0 =A0 =A0 =A0 outputs
> Patched, drop =A0 =A0 =A0 =A0 =A0142 =A0 =A0 64 =A0 =A0 =A046 =A0 =A0 =A0=
13557744 =A0 =A0 =A0 =A0 14052744
> Patched, nodrop =A0 =A0 =A0 =A055 =A0 =A0 =A057 =A0 =A0 =A033 =A0 =A0 =A0=
13557936 =A0 =A0 =A0 =A0 13556680
>
> vmstat:
> =3D=3D=3D=3D=3D=3D=3D=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_pages =A0 =A0 =A0inac=
t_anon =A0 =A0 =A0act_anon =A0 =A0 =A0 =A0inact_file =A0 =A0 =A0act_file =
=A0 =A0 =A0 =A0dirtied =A0 =A0 =A0written =A0reclaim
> Patched, drop, pre =A0 =A0 =A0306043 =A0 =A0 =A0 =A0 =A037541 =A0 =A0 =A0=
 =A0 =A0 185463 =A0 =A0 =A0 =A0 =A0276266 =A0 =A0 =A0 =A0 =A0153955 =A0 =A0=
 =A0 =A0 =A03689674 =A0 =A0 =A03604959 =A01550641
> Patched, drop, post =A0 =A0 13233 =A0 =A0 =A0 =A0 =A0 38462 =A0 =A0 =A0 =
=A0 =A0 175252 =A0 =A0 =A0 =A0 =A0536346 =A0 =A0 =A0 =A0 =A0178792 =A0 =A0 =
=A0 =A0 =A05527564 =A0 =A0 =A05371563 =A03169155
>
> Patched, nodrop, pre =A0 =A0475211 =A0 =A0 =A0 =A0 =A038602 =A0 =A0 =A0 =
=A0 =A0 175242 =A0 =A0 =A0 =A0 =A081979 =A0 =A0 =A0 =A0 =A0 178820 =A0 =A0 =
=A0 =A0 =A05527592 =A0 =A0 =A05371554 =A03169155
> Patched, nodrop, post =A0 7697 =A0 =A0 =A0 =A0 =A0 =A038959 =A0 =A0 =A0 =
=A0 =A0 176986 =A0 =A0 =A0 =A0 =A0547984 =A0 =A0 =A0 =A0 =A0180855 =A0 =A0 =
=A0 =A0 =A07324836 =A0 =A0 =A07132158 =A03169155
>
> Altogether, it seems that something is horribly wrong, most likely with
> my test (or rsync patch). I'll do the baseline benchmarks today.
>
> Thoughts?


How do you test it?
I think patch's effect would be good in big memory pressure environment.

Quickly I did it on my desktop environment.(2G DRAM)
So it's not completed result. I will test more when out of office.

Used kernel : mmotm-12-02 + my patch series
Used rsync :
1. rsync_normal : v3.0.7 vanilla
2. rsync_patch : v3.0.7 + Ben's patch(fadvise)

Test scenario :
* kernel full compile
* git clone linux-kernel
* rsync local host directory to local host dst directory


1) rsync_normal : 89.08user 127.48system 33:22.24elapsed
2) rsync_patch : 88.42user 135.26system 31:30.56elapsed

1) rsync_normal vmstat :
pgfault : 45538203
pgmajfault : 4181

pgactivate 377416
pgdeactivate 34183
pginvalidate 0
pgreclaim 0

pgsteal_dma 0
pgsteal_normal 2144469
pgsteal_high 2884412
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_normal 2149739
pgscan_kswapd_high 2909140
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_normal 647
pgscan_direct_high 716
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 1737344
kswapd_steal 5028353
kswapd_inodesteal 438910
pageoutrun 81208
allocstall 9
pgrotated 1642

2) rsync_patch vmstat:

pgfault : 47570231
pgmajfault : 2669

pgactivate 391806
pgdeactivate 36861
pginvalidate 1685065
pgreclaim 1685065

pgrefill_dma 0
pgrefill_normal 32025
pgrefill_high 9619
pgrefill_movable 0
pgsteal_dma 0
pgsteal_normal 744904
pgsteal_high 1079709
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_normal 745017
pgscan_kswapd_high 1096660
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_normal 0
pgscan_direct_high 0
pgscan_direct_movable 0
pginodesteal 0
slabs_scanned 1896960
kswapd_steal 1824613
kswapd_inodesteal 703499
pageoutrun 26828
allocstall 0
pgrotated 1681570

In summary,
Unfortunately, the number of fault is increased (47570231 - 45538203)
but pgmajfault is reduced (4181 - 2669).

The number of scanning is much reduced. 2149739 -> 745017, 2909140 ->
1096660 and even no direct reclaim in patched rsync.

The number of steal is much reduced. 2144469 -> 744904, 2884412 ->
1079709, 5028353 -> 1824613.

The elapsed time is reduced 2 minutes.

I think result is good. Reduced the steal number could imply prevent
eviction of working set pages.

It has a good result with small effort(small scanning).

I will resend with more exact measurement after repeated test.

> Thanks,
>
> - Ben
>
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
