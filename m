Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D97206B0022
	for <linux-mm@kvack.org>; Tue,  3 May 2011 22:32:04 -0400 (EDT)
Received: by wyf19 with SMTP id 19so692796wyf.14
        for <linux-mm@kvack.org>; Tue, 03 May 2011 19:32:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimpT-N5--3QjcNg8CyNNwfEWxFyKA@mail.gmail.com>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
	<20110426055521.GA18473@localhost>
	<BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
	<BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
	<20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
	<BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
	<20110426092029.GA27053@localhost>
	<20110426124743.e58d9746.akpm@linux-foundation.org>
	<20110428133644.GA12400@localhost>
	<BANLkTimpT-N5--3QjcNg8CyNNwfEWxFyKA@mail.gmail.com>
Date: Wed, 4 May 2011 10:32:01 +0800
Message-ID: <BANLkTi=q6oKMewfWAN+2UgEmaVt03W_gLQ@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation failures
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Wed, May 4, 2011 at 9:56 AM, Dave Young <hidave.darkstar@gmail.com> wrot=
e:
> On Thu, Apr 28, 2011 at 9:36 PM, Wu Fengguang <fengguang.wu@intel.com> wr=
ote:
>> Concurrent page allocations are suffering from high failure rates.
>>
>> On a 8p, 3GB ram test box, when reading 1000 sparse files of size 1GB,
>> the page allocation failures are
>>
>> nr_alloc_fail 733 =C2=A0 =C2=A0 =C2=A0 # interleaved reads by 1 single t=
ask
>> nr_alloc_fail 11799 =C2=A0 =C2=A0 # concurrent reads by 1000 tasks
>>
>> The concurrent read test script is:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0for i in `seq 1000`
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0do
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0truncate -s 1G /f=
s/sparse-$i
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dd if=3D/fs/spars=
e-$i of=3D/dev/null &
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0done
>>
>
> With Core2 Duo, 3G ram, No swap partition I can not produce the alloc fai=
l

unset CONFIG_SCHED_AUTOGROUP and CONFIG_CGROUP_SCHED seems affects the
test results, now I see several nr_alloc_fail (dd is not finished
yet):

dave@darkstar-32:$ grep fail /proc/vmstat:
nr_alloc_fail 4
compact_pagemigrate_failed 0
compact_fail 3
htlb_buddy_alloc_fail 0
thp_collapse_alloc_fail 4

So the result is related to cpu scheduler.

>
>> In order for get_page_from_freelist() to get free page,
>>
>> (1) try_to_free_pages() should use much higher .nr_to_reclaim than the
>> =C2=A0 =C2=A0current SWAP_CLUSTER_MAX=3D32, in order to draw the zone ou=
t of the
>> =C2=A0 =C2=A0possible low watermark state as well as fill the pcp with e=
nough free
>> =C2=A0 =C2=A0pages to overflow its high watermark.
>>
>> (2) the get_page_from_freelist() _after_ direct reclaim should use lower
>> =C2=A0 =C2=A0watermark than its normal invocations, so that it can reaso=
nably
>> =C2=A0 =C2=A0"reserve" some free pages for itself and prevent other conc=
urrent
>> =C2=A0 =C2=A0page allocators stealing all its reclaimed pages.
>>
>> Some notes:
>>
>> - commit 9ee493ce ("mm: page allocator: drain per-cpu lists after direct
>> =C2=A0reclaim allocation fails") has the same target, however is obvious=
ly
>> =C2=A0costly and less effective. It seems more clean to just remove the
>> =C2=A0retry and drain code than to retain it.
>>
>> - it's a bit hacky to reclaim more than requested pages inside
>> =C2=A0do_try_to_free_page(), and it won't help cgroup for now
>>
>> - it only aims to reduce failures when there are plenty of reclaimable
>> =C2=A0pages, so it stops the opportunistic reclaim when scanned 2 times =
pages
>>
>> Test results:
>>
>> - the failure rate is pretty sensible to the page reclaim size,
>> =C2=A0from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER_MA=
X)
>>
>> - the IPIs are reduced by over 100 times
>>
>> base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocatio=
n patch
>> ------------------------------------------------------------------------=
-------
>> nr_alloc_fail 10496
>> allocstall 1576602
>>
>> slabs_scanned 21632
>> kswapd_steal 4393382
>> kswapd_inodesteal 124
>> kswapd_low_wmark_hit_quickly 885
>> kswapd_high_wmark_hit_quickly 2321
>> kswapd_skip_congestion_wait 0
>> pageoutrun 29426
>>
>> CAL: =C2=A0 =C2=A0 220449 =C2=A0 =C2=A0 220246 =C2=A0 =C2=A0 220372 =C2=
=A0 =C2=A0 220558 =C2=A0 =C2=A0 220251 =C2=A0 =C2=A0 219740 =C2=A0 =C2=A0 2=
20043 =C2=A0 =C2=A0 219968 =C2=A0 Function call interrupts
>>
>> LOC: =C2=A0 =C2=A0 536274 =C2=A0 =C2=A0 532529 =C2=A0 =C2=A0 531734 =C2=
=A0 =C2=A0 536801 =C2=A0 =C2=A0 536510 =C2=A0 =C2=A0 533676 =C2=A0 =C2=A0 5=
34853 =C2=A0 =C2=A0 532038 =C2=A0 Local timer interrupts
>> RES: =C2=A0 =C2=A0 =C2=A0 3032 =C2=A0 =C2=A0 =C2=A0 2128 =C2=A0 =C2=A0 =
=C2=A0 1792 =C2=A0 =C2=A0 =C2=A0 1765 =C2=A0 =C2=A0 =C2=A0 2184 =C2=A0 =C2=
=A0 =C2=A0 1703 =C2=A0 =C2=A0 =C2=A0 1754 =C2=A0 =C2=A0 =C2=A0 1865 =C2=A0 =
Rescheduling interrupts
>> TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0189 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 13 =C2=A0 =C2=A0 =C2=A0 =C2=A0 17 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 64 =C2=A0 =C2=A0 =C2=A0 =C2=A0294 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 97 =C2=A0 =C2=A0 =C2=A0 =C2=A0 63 =C2=A0 TLB shootdowns
>
> Could you tell how to get above info?
>
>>
>> patched (WMARK_MIN)
>> -------------------
>> nr_alloc_fail 704
>> allocstall 105551
>>
>> slabs_scanned 33280
>> kswapd_steal 4525537
>> kswapd_inodesteal 187
>> kswapd_low_wmark_hit_quickly 4980
>> kswapd_high_wmark_hit_quickly 2573
>> kswapd_skip_congestion_wait 0
>> pageoutrun 35429
>>
>> CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=A0 =C2=A0 =C2=A0 =C2=A0286 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0396 =C2=A0 =C2=A0 =C2=A0 =C2=A0754 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0272 =C2=A0 =C2=A0 =C2=A0 =C2=A0297 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
275 =C2=A0 =C2=A0 =C2=A0 =C2=A0281 =C2=A0 Function call interrupts
>>
>> LOC: =C2=A0 =C2=A0 520550 =C2=A0 =C2=A0 517751 =C2=A0 =C2=A0 517043 =C2=
=A0 =C2=A0 522016 =C2=A0 =C2=A0 520302 =C2=A0 =C2=A0 518479 =C2=A0 =C2=A0 5=
19329 =C2=A0 =C2=A0 517179 =C2=A0 Local timer interrupts
>> RES: =C2=A0 =C2=A0 =C2=A0 2131 =C2=A0 =C2=A0 =C2=A0 1371 =C2=A0 =C2=A0 =
=C2=A0 1376 =C2=A0 =C2=A0 =C2=A0 1269 =C2=A0 =C2=A0 =C2=A0 1390 =C2=A0 =C2=
=A0 =C2=A0 1181 =C2=A0 =C2=A0 =C2=A0 1409 =C2=A0 =C2=A0 =C2=A0 1280 =C2=A0 =
Rescheduling interrupts
>> TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0280 =C2=A0 =C2=A0 =C2=A0 =C2=A0 26 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 27 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 65 =C2=A0 =C2=A0 =C2=A0 =C2=A0305 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
134 =C2=A0 =C2=A0 =C2=A0 =C2=A0 75 =C2=A0 TLB shootdowns
>>
>> patched (WMARK_HIGH)
>> --------------------
>> nr_alloc_fail 282
>> allocstall 53860
>>
>> slabs_scanned 23936
>> kswapd_steal 4561178
>> kswapd_inodesteal 0
>> kswapd_low_wmark_hit_quickly 2760
>> kswapd_high_wmark_hit_quickly 1748
>> kswapd_skip_congestion_wait 0
>> pageoutrun 32639
>>
>> CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=A0 =C2=A0 =C2=A0 =C2=A0463 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0410 =C2=A0 =C2=A0 =C2=A0 =C2=A0540 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0298 =C2=A0 =C2=A0 =C2=A0 =C2=A0282 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
272 =C2=A0 =C2=A0 =C2=A0 =C2=A0306 =C2=A0 Function call interrupts
>>
>> LOC: =C2=A0 =C2=A0 513956 =C2=A0 =C2=A0 510749 =C2=A0 =C2=A0 509890 =C2=
=A0 =C2=A0 514897 =C2=A0 =C2=A0 514300 =C2=A0 =C2=A0 512392 =C2=A0 =C2=A0 5=
12825 =C2=A0 =C2=A0 510574 =C2=A0 Local timer interrupts
>> RES: =C2=A0 =C2=A0 =C2=A0 1174 =C2=A0 =C2=A0 =C2=A0 2081 =C2=A0 =C2=A0 =
=C2=A0 1411 =C2=A0 =C2=A0 =C2=A0 1320 =C2=A0 =C2=A0 =C2=A0 1742 =C2=A0 =C2=
=A0 =C2=A0 2683 =C2=A0 =C2=A0 =C2=A0 1380 =C2=A0 =C2=A0 =C2=A0 1230 =C2=A0 =
Rescheduling interrupts
>> TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0274 =C2=A0 =C2=A0 =C2=A0 =C2=A0 21 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 19 =C2=A0 =C2=A0 =C2=A0 =C2=A0 22 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 57 =C2=A0 =C2=A0 =C2=A0 =C2=A0317 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
131 =C2=A0 =C2=A0 =C2=A0 =C2=A0 61 =C2=A0 TLB shootdowns
>>
>> this patch (WMARK_HIGH, limited scan)
>> -------------------------------------
>> nr_alloc_fail 276
>> allocstall 54034
>>
>> slabs_scanned 24320
>> kswapd_steal 4507482
>> kswapd_inodesteal 262
>> kswapd_low_wmark_hit_quickly 2638
>> kswapd_high_wmark_hit_quickly 1710
>> kswapd_skip_congestion_wait 0
>> pageoutrun 32182
>>
>> CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 69 =C2=A0 =C2=A0 =C2=A0 =C2=A0443 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0421 =C2=A0 =C2=A0 =C2=A0 =C2=A0567 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0273 =C2=A0 =C2=A0 =C2=A0 =C2=A0279 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
269 =C2=A0 =C2=A0 =C2=A0 =C2=A0334 =C2=A0 Function call interrupts
>>
>> LOC: =C2=A0 =C2=A0 514736 =C2=A0 =C2=A0 511698 =C2=A0 =C2=A0 510993 =C2=
=A0 =C2=A0 514069 =C2=A0 =C2=A0 514185 =C2=A0 =C2=A0 512986 =C2=A0 =C2=A0 5=
13838 =C2=A0 =C2=A0 511229 =C2=A0 Local timer interrupts
>> RES: =C2=A0 =C2=A0 =C2=A0 2153 =C2=A0 =C2=A0 =C2=A0 1556 =C2=A0 =C2=A0 =
=C2=A0 1126 =C2=A0 =C2=A0 =C2=A0 1351 =C2=A0 =C2=A0 =C2=A0 3047 =C2=A0 =C2=
=A0 =C2=A0 1554 =C2=A0 =C2=A0 =C2=A0 1131 =C2=A0 =C2=A0 =C2=A0 1560 =C2=A0 =
Rescheduling interrupts
>> TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0209 =C2=A0 =C2=A0 =C2=A0 =C2=A0 26 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 71 =C2=A0 =C2=A0 =C2=A0 =C2=A0315 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
117 =C2=A0 =C2=A0 =C2=A0 =C2=A0 71 =C2=A0 TLB shootdowns
>>
>> CC: Mel Gorman <mel@linux.vnet.ibm.com>
>> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>> ---
>> =C2=A0mm/page_alloc.c | =C2=A0 17 +++--------------
>> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 | =C2=A0 =C2=A06 ++++++
>> =C2=A02 files changed, 9 insertions(+), 14 deletions(-)
>> --- linux-next.orig/mm/vmscan.c 2011-04-28 21:16:16.000000000 +0800
>> +++ linux-next/mm/vmscan.c =C2=A0 =C2=A0 =C2=A02011-04-28 21:28:57.00000=
0000 +0800
>> @@ -1978,6 +1978,8 @@ static void shrink_zones(int priority, s
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (zone->all_unreclaimable && priority !=3D DEF_PRIORITY)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue; =C2=A0 =C2=A0 =C2=A0 /* =
Let kswapd poll it */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 sc->nr_to_reclaim =3D max(sc->nr_to_reclaim,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 zone->watermark[WMARK_HIGH]);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_zone(prior=
ity, zone, sc);
>> @@ -2034,6 +2036,7 @@ static unsigned long do_try_to_free_page
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zoneref *z;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long writeback_threshold;
>> + =C2=A0 =C2=A0 =C2=A0 unsigned long min_reclaim =3D sc->nr_to_reclaim;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0get_mems_allowed();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0delayacct_freepages_start();
>> @@ -2067,6 +2070,9 @@ static unsigned long do_try_to_free_page
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0}
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0total_scanned +=
=3D sc->nr_scanned;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sc->nr_reclaimed =
>=3D min_reclaim &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_s=
canned > 2 * sc->nr_to_reclaim)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->nr_reclai=
med >=3D sc->nr_to_reclaim)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0goto out;
>>
>> --- linux-next.orig/mm/page_alloc.c =C2=A0 =C2=A0 2011-04-28 21:16:16.00=
0000000 +0800
>> +++ linux-next/mm/page_alloc.c =C2=A02011-04-28 21:16:18.000000000 +0800
>> @@ -1888,9 +1888,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nodemask_t *nodemask, int alloc_flags, struct=
 zone *preferred_zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int migratetype, unsigned long *did_some_prog=
ress)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 struct page *page =3D NULL;
>> + =C2=A0 =C2=A0 =C2=A0 struct page *page;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct reclaim_state reclaim_state;
>> - =C2=A0 =C2=A0 =C2=A0 bool drained =3D false;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resched();
>>
>> @@ -1912,22 +1911,12 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!(*did_some_progress)))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>>
>> -retry:
>> + =C2=A0 =C2=A0 =C2=A0 alloc_flags |=3D ALLOC_HARDER;
>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D get_page_from_freelist(gfp_mask, nod=
emask, order,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zoneli=
st, high_zoneidx,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0alloc_=
flags, preferred_zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0migrat=
etype);
>> -
>> - =C2=A0 =C2=A0 =C2=A0 /*
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* If an allocation failed after direct recl=
aim, it could be because
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* pages are pinned on the per-cpu lists. Dr=
ain them and try again
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> - =C2=A0 =C2=A0 =C2=A0 if (!page && !drained) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 drain_all_pages();
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 drained =3D true;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto retry;
>> - =C2=A0 =C2=A0 =C2=A0 }
>> -
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
>> =C2=A0}
>>
>>
>
>
>
> --
> Regards
> dave
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
