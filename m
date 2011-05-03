Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE7DE6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 20:49:22 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4204797qwa.14
        for <linux-mm@kvack.org>; Mon, 02 May 2011 17:49:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110502102945.GA7688@localhost>
References: <20110426062535.GB19717@localhost>
	<BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
	<20110426063421.GC19717@localhost>
	<BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
	<20110426092029.GA27053@localhost>
	<20110426124743.e58d9746.akpm@linux-foundation.org>
	<20110428133644.GA12400@localhost>
	<20110429022824.GA8061@localhost>
	<20110430141741.GA4511@localhost>
	<20110501163542.GA3204@barrios-desktop>
	<20110502102945.GA7688@localhost>
Date: Tue, 3 May 2011 09:49:20 +0900
Message-ID: <BANLkTinXnhh5V0eH71=6PxZWpQxvti7QVw@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation failures
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Li Shaohua <shaohua.li@intel.com>, Hugh Dickins <hughd@google.com>

Hi Wu, Sorry for slow response.
I guess you know why I am slow. :)

On Mon, May 2, 2011 at 7:29 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> Hi Minchan,
>
> On Mon, May 02, 2011 at 12:35:42AM +0800, Minchan Kim wrote:
>> Hi Wu,
>>
>> On Sat, Apr 30, 2011 at 10:17:41PM +0800, Wu Fengguang wrote:
>> > On Fri, Apr 29, 2011 at 10:28:24AM +0800, Wu Fengguang wrote:
>> > > > Test results:
>> > > >
>> > > > - the failure rate is pretty sensible to the page reclaim size,
>> > > > =C2=A0 from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLU=
STER_MAX)
>> > > >
>> > > > - the IPIs are reduced by over 100 times
>> > >
>> > > It's reduced by 500 times indeed.
>> > >
>> > > CAL: =C2=A0 =C2=A0 220449 =C2=A0 =C2=A0 220246 =C2=A0 =C2=A0 220372 =
=C2=A0 =C2=A0 220558 =C2=A0 =C2=A0 220251 =C2=A0 =C2=A0 219740 =C2=A0 =C2=
=A0 220043 =C2=A0 =C2=A0 219968 =C2=A0 Function call interrupts
>> > > CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=A0 =C2=A0 =C2=A0 =C2=A0463 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0410 =C2=A0 =C2=A0 =C2=A0 =C2=A0540 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0298 =C2=A0 =C2=A0 =C2=A0 =C2=A0282 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0272 =C2=A0 =C2=A0 =C2=A0 =C2=A0306 =C2=A0 Function call interrupts
>> > >
>> > > > base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page all=
ocation patch
>> > > > ------------------------------------------------------------------=
-------------
>> > > > nr_alloc_fail 10496
>> > > > allocstall 1576602
>> > >
>> > > > patched (WMARK_MIN)
>> > > > -------------------
>> > > > nr_alloc_fail 704
>> > > > allocstall 105551
>> > >
>> > > > patched (WMARK_HIGH)
>> > > > --------------------
>> > > > nr_alloc_fail 282
>> > > > allocstall 53860
>> > >
>> > > > this patch (WMARK_HIGH, limited scan)
>> > > > -------------------------------------
>> > > > nr_alloc_fail 276
>> > > > allocstall 54034
>> > >
>> > > There is a bad side effect though: the much reduced "allocstall" mea=
ns
>> > > each direct reclaim will take much more time to complete. A simple s=
olution
>> > > is to terminate direct reclaim after 10ms. I noticed that an 100ms
>> > > time threshold can reduce the reclaim latency from 621ms to 358ms.
>> > > Further lowering the time threshold to 20ms does not help reducing t=
he
>> > > real latencies though.
>> >
>> > Experiments going on...
>> >
>> > I tried the more reasonable terminate condition: stop direct reclaim
>> > when the preferred zone is above high watermark (see the below chunk).
>> >
>> > This helps reduce the average reclaim latency to under 100ms in the
>> > 1000-dd case.
>> >
>> > However nr_alloc_fail is around 5000 and not ideal. The interesting
>> > thing is, even if zone watermark is high, the task still may fail to
>> > get a free page..
>> >
>> > @@ -2067,8 +2072,17 @@ static unsigned long do_try_to_free_page
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 }
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_scanned =
+=3D sc->nr_scanned;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sc->nr_reclaime=
d >=3D sc->nr_to_reclaim)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto out;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sc->nr_reclaime=
d >=3D min_reclaim) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (sc->nr_reclaimed >=3D sc->nr_to_reclaim)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (total_scanned > 2 * sc->nr_to_reclaim)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (preferred_zone &&
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 zone_watermark_ok_safe(preferred_zone, sc->order,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 high_wma=
rk_pages(preferred_zone),
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_idx=
(preferred_zone), 0))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Try to=
 write back as many pages as we just scanned. =C2=A0This
>> >
>> > Thanks,
>> > Fengguang
>> > ---
>> > Subject: mm: cut down __GFP_NORETRY page allocation failures
>> > Date: Thu Apr 28 13:46:39 CST 2011
>> >
>> > Concurrent page allocations are suffering from high failure rates.
>> >
>> > On a 8p, 3GB ram test box, when reading 1000 sparse files of size 1GB,
>> > the page allocation failures are
>> >
>> > nr_alloc_fail 733 =C2=A0 =C2=A0 # interleaved reads by 1 single task
>> > nr_alloc_fail 11799 =C2=A0 # concurrent reads by 1000 tasks
>> >
>> > The concurrent read test script is:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 for i in `seq 1000`
>> > =C2=A0 =C2=A0 =C2=A0 do
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 truncate -s 1G /fs/sp=
arse-$i
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dd if=3D/fs/sparse-$i=
 of=3D/dev/null &
>> > =C2=A0 =C2=A0 =C2=A0 done
>> >
>> > In order for get_page_from_freelist() to get free page,
>> >
>> > (1) try_to_free_pages() should use much higher .nr_to_reclaim than the
>> > =C2=A0 =C2=A0 current SWAP_CLUSTER_MAX=3D32, in order to draw the zone=
 out of the
>> > =C2=A0 =C2=A0 possible low watermark state as well as fill the pcp wit=
h enough free
>> > =C2=A0 =C2=A0 pages to overflow its high watermark.
>> >
>> > (2) the get_page_from_freelist() _after_ direct reclaim should use low=
er
>> > =C2=A0 =C2=A0 watermark than its normal invocations, so that it can re=
asonably
>> > =C2=A0 =C2=A0 "reserve" some free pages for itself and prevent other c=
oncurrent
>> > =C2=A0 =C2=A0 page allocators stealing all its reclaimed pages.
>>
>> Do you see my old patch? The patch want't incomplet but it's not bad for=
 showing an idea.
>> http://marc.info/?l=3Dlinux-mm&m=3D129187231129887&w=3D4
>> The idea is to keep a page at leat for direct reclaimed process.
>> Could it mitigate your problem or could you enhacne the idea?
>> I think it's very simple and fair solution.
>
> No it's not helping my problem, nr_alloc_fail and CAL are still high:

Unfortunately, my patch doesn't consider order-0 pages, as you mentioned be=
low.
I read your mail which states it doesn't help although it considers
order-0 pages and drain.
Actually, I tried to look into that but in my poor system(core2duo, 2G
ram), nr_alloc_fail never happens. :(
I will try it in other desktop but I am not sure I can reproduce it.

>
> root@fat /home/wfg# ./test-dd-sparse.sh
> start time: 246
> total time: 531
> nr_alloc_fail 14097
> allocstall 1578332
> LOC: =C2=A0 =C2=A0 542698 =C2=A0 =C2=A0 538947 =C2=A0 =C2=A0 536986 =C2=
=A0 =C2=A0 567118 =C2=A0 =C2=A0 552114 =C2=A0 =C2=A0 539605 =C2=A0 =C2=A0 5=
41201 =C2=A0 =C2=A0 537623 =C2=A0 Local timer interrupts
> RES: =C2=A0 =C2=A0 =C2=A0 3368 =C2=A0 =C2=A0 =C2=A0 1908 =C2=A0 =C2=A0 =
=C2=A0 1474 =C2=A0 =C2=A0 =C2=A0 1476 =C2=A0 =C2=A0 =C2=A0 2809 =C2=A0 =C2=
=A0 =C2=A0 1602 =C2=A0 =C2=A0 =C2=A0 1500 =C2=A0 =C2=A0 =C2=A0 1509 =C2=A0 =
Rescheduling interrupts
> CAL: =C2=A0 =C2=A0 223844 =C2=A0 =C2=A0 224198 =C2=A0 =C2=A0 224268 =C2=
=A0 =C2=A0 224436 =C2=A0 =C2=A0 223952 =C2=A0 =C2=A0 224056 =C2=A0 =C2=A0 2=
23700 =C2=A0 =C2=A0 223743 =C2=A0 Function call interrupts
> TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0381 =C2=A0 =C2=A0 =C2=A0 =C2=A0 27 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 22 =C2=A0 =C2=A0 =C2=A0 =C2=A0 19 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 96 =C2=A0 =C2=A0 =C2=A0 =C2=A0404 =C2=A0 =C2=A0 =C2=A0 =C2=A0111=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 67 =C2=A0 TLB shootdowns
>
> root@fat /home/wfg# getdelays -dip `pidof dd`
> print delayacct stats ON
> printing IO accounting
> PID =C2=A0 =C2=A0 5202
>
>
> CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real to=
tal =C2=A0virtual total =C2=A0 =C2=A0delay total
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1132 =C2=A0 =C2=
=A0 3635447328 =C2=A0 =C2=A0 3627947550 =C2=A0 276722091605
> IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0del=
ay total =C2=A0delay average
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =
=C2=A0 =C2=A0 =C2=A0187809974 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 62m=
s
> SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay to=
tal =C2=A0delay average
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A00ms
> RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=A0=
delay average
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1334 =C2=A0 =C2=
=A035304580824 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 26ms
> dd: read=3D278528, write=3D0, cancelled_write=3D0
>
> I guess your patch is mainly fixing the high order allocations while
> my workload is mainly order 0 readahead page allocations. There are
> 1000 forks, however the "start time: 246" seems to indicate that the
> order-1 reclaim latency is not improved.

Maybe, 8K * 1000 isn't big footprint so I think reclaim doesn't happen.

>
> I'll try modifying your patch and see how it works out. The obvious
> change is to apply it to the order-0 case. Hope this won't create much
> more isolated pages.
>
> Attached is your patch rebased to 2.6.39-rc3, after resolving some
> merge conflicts and fixing a trivial NULL pointer bug.

Thanks!
I would like to see detail with it in my system if I can reproduce it.

>
>> >
>> > Some notes:
>> >
>> > - commit 9ee493ce ("mm: page allocator: drain per-cpu lists after dire=
ct
>> > =C2=A0 reclaim allocation fails") has the same target, however is obvi=
ously
>> > =C2=A0 costly and less effective. It seems more clean to just remove t=
he
>> > =C2=A0 retry and drain code than to retain it.
>>
>> Tend to agree.
>> My old patch can solve it, I think.
>
> Sadly nope. See above.
>
>> >
>> > - it's a bit hacky to reclaim more than requested pages inside
>> > =C2=A0 do_try_to_free_page(), and it won't help cgroup for now
>> >
>> > - it only aims to reduce failures when there are plenty of reclaimable
>> > =C2=A0 pages, so it stops the opportunistic reclaim when scanned 2 tim=
es pages
>> >
>> > Test results:
>> >
>> > - the failure rate is pretty sensible to the page reclaim size,
>> > =C2=A0 from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER=
_MAX)
>> >
>> > - the IPIs are reduced by over 100 times
>> >
>> > base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocat=
ion patch
>> > ----------------------------------------------------------------------=
---------
>> > nr_alloc_fail 10496
>> > allocstall 1576602
>> >
>> > slabs_scanned 21632
>> > kswapd_steal 4393382
>> > kswapd_inodesteal 124
>> > kswapd_low_wmark_hit_quickly 885
>> > kswapd_high_wmark_hit_quickly 2321
>> > kswapd_skip_congestion_wait 0
>> > pageoutrun 29426
>> >
>> > CAL: =C2=A0 =C2=A0 220449 =C2=A0 =C2=A0 220246 =C2=A0 =C2=A0 220372 =
=C2=A0 =C2=A0 220558 =C2=A0 =C2=A0 220251 =C2=A0 =C2=A0 219740 =C2=A0 =C2=
=A0 220043 =C2=A0 =C2=A0 219968 =C2=A0 Function call interrupts
>> >
>> > LOC: =C2=A0 =C2=A0 536274 =C2=A0 =C2=A0 532529 =C2=A0 =C2=A0 531734 =
=C2=A0 =C2=A0 536801 =C2=A0 =C2=A0 536510 =C2=A0 =C2=A0 533676 =C2=A0 =C2=
=A0 534853 =C2=A0 =C2=A0 532038 =C2=A0 Local timer interrupts
>> > RES: =C2=A0 =C2=A0 =C2=A0 3032 =C2=A0 =C2=A0 =C2=A0 2128 =C2=A0 =C2=A0=
 =C2=A0 1792 =C2=A0 =C2=A0 =C2=A0 1765 =C2=A0 =C2=A0 =C2=A0 2184 =C2=A0 =C2=
=A0 =C2=A0 1703 =C2=A0 =C2=A0 =C2=A0 1754 =C2=A0 =C2=A0 =C2=A0 1865 =C2=A0 =
Rescheduling interrupts
>> > TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0189 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 13 =C2=A0 =C2=A0 =C2=A0 =C2=A0 17 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 64 =C2=A0 =C2=A0 =C2=A0 =C2=A0294 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 97 =C2=A0 =C2=A0 =C2=A0 =C2=A0 63 =C2=A0 TLB shootdowns
>> >
>> > patched (WMARK_MIN)
>> > -------------------
>> > nr_alloc_fail 704
>> > allocstall 105551
>> >
>> > slabs_scanned 33280
>> > kswapd_steal 4525537
>> > kswapd_inodesteal 187
>> > kswapd_low_wmark_hit_quickly 4980
>> > kswapd_high_wmark_hit_quickly 2573
>> > kswapd_skip_congestion_wait 0
>> > pageoutrun 35429
>> >
>> > CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=A0 =C2=A0 =C2=A0 =C2=A0286 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0396 =C2=A0 =C2=A0 =C2=A0 =C2=A0754 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0272 =C2=A0 =C2=A0 =C2=A0 =C2=A0297 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
275 =C2=A0 =C2=A0 =C2=A0 =C2=A0281 =C2=A0 Function call interrupts
>> >
>> > LOC: =C2=A0 =C2=A0 520550 =C2=A0 =C2=A0 517751 =C2=A0 =C2=A0 517043 =
=C2=A0 =C2=A0 522016 =C2=A0 =C2=A0 520302 =C2=A0 =C2=A0 518479 =C2=A0 =C2=
=A0 519329 =C2=A0 =C2=A0 517179 =C2=A0 Local timer interrupts
>> > RES: =C2=A0 =C2=A0 =C2=A0 2131 =C2=A0 =C2=A0 =C2=A0 1371 =C2=A0 =C2=A0=
 =C2=A0 1376 =C2=A0 =C2=A0 =C2=A0 1269 =C2=A0 =C2=A0 =C2=A0 1390 =C2=A0 =C2=
=A0 =C2=A0 1181 =C2=A0 =C2=A0 =C2=A0 1409 =C2=A0 =C2=A0 =C2=A0 1280 =C2=A0 =
Rescheduling interrupts
>> > TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0280 =C2=A0 =C2=A0 =C2=A0 =C2=A0 26 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 27 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 65 =C2=A0 =C2=A0 =C2=A0 =C2=A0305 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
134 =C2=A0 =C2=A0 =C2=A0 =C2=A0 75 =C2=A0 TLB shootdowns
>> >
>> > patched (WMARK_HIGH)
>> > --------------------
>> > nr_alloc_fail 282
>> > allocstall 53860
>> >
>> > slabs_scanned 23936
>> > kswapd_steal 4561178
>> > kswapd_inodesteal 0
>> > kswapd_low_wmark_hit_quickly 2760
>> > kswapd_high_wmark_hit_quickly 1748
>> > kswapd_skip_congestion_wait 0
>> > pageoutrun 32639
>> >
>> > CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=A0 =C2=A0 =C2=A0 =C2=A0463 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0410 =C2=A0 =C2=A0 =C2=A0 =C2=A0540 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0298 =C2=A0 =C2=A0 =C2=A0 =C2=A0282 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
272 =C2=A0 =C2=A0 =C2=A0 =C2=A0306 =C2=A0 Function call interrupts
>> >
>> > LOC: =C2=A0 =C2=A0 513956 =C2=A0 =C2=A0 510749 =C2=A0 =C2=A0 509890 =
=C2=A0 =C2=A0 514897 =C2=A0 =C2=A0 514300 =C2=A0 =C2=A0 512392 =C2=A0 =C2=
=A0 512825 =C2=A0 =C2=A0 510574 =C2=A0 Local timer interrupts
>> > RES: =C2=A0 =C2=A0 =C2=A0 1174 =C2=A0 =C2=A0 =C2=A0 2081 =C2=A0 =C2=A0=
 =C2=A0 1411 =C2=A0 =C2=A0 =C2=A0 1320 =C2=A0 =C2=A0 =C2=A0 1742 =C2=A0 =C2=
=A0 =C2=A0 2683 =C2=A0 =C2=A0 =C2=A0 1380 =C2=A0 =C2=A0 =C2=A0 1230 =C2=A0 =
Rescheduling interrupts
>> > TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0274 =C2=A0 =C2=A0 =C2=A0 =C2=A0 21 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 19 =C2=A0 =C2=A0 =C2=A0 =C2=A0 22 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 57 =C2=A0 =C2=A0 =C2=A0 =C2=A0317 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
131 =C2=A0 =C2=A0 =C2=A0 =C2=A0 61 =C2=A0 TLB shootdowns
>> >
>> > patched (WMARK_HIGH, limited scan)
>> > ----------------------------------
>> > nr_alloc_fail 276
>> > allocstall 54034
>> >
>> > slabs_scanned 24320
>> > kswapd_steal 4507482
>> > kswapd_inodesteal 262
>> > kswapd_low_wmark_hit_quickly 2638
>> > kswapd_high_wmark_hit_quickly 1710
>> > kswapd_skip_congestion_wait 0
>> > pageoutrun 32182
>> >
>> > CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0 69 =C2=A0 =C2=A0 =C2=A0 =C2=A0443 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0421 =C2=A0 =C2=A0 =C2=A0 =C2=A0567 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0273 =C2=A0 =C2=A0 =C2=A0 =C2=A0279 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
269 =C2=A0 =C2=A0 =C2=A0 =C2=A0334 =C2=A0 Function call interrupts
>>
>> Looks amazing.
>
> Yeah, I have strong feelings against drain_all_pages() in the direct
> reclaim path. The intuition is, once drain_all_pages() is called, the
> later on direct reclaims will have less chance to fill the drained
> buffers and therefore forced into drain_all_pages() again and again.
>
> drain_all_pages() is probably an overkill for preventing OOM.
> Generally speaking, it's questionable to "squeeze the last page before
> OOM".
>
> A typical desktop enters thrashing storms before OOM, as Hugh pointed
> out, this may well not the end users wanted. I agree with him and
> personally prefer some applications to be OOM killed rather than the
> whole system goes unusable thrashing like mad.

Tend to agree. The rule is applied to embedded system, too.
Couldn't we mitigate draining  just in case it is high order page.

>
>> > LOC: =C2=A0 =C2=A0 514736 =C2=A0 =C2=A0 511698 =C2=A0 =C2=A0 510993 =
=C2=A0 =C2=A0 514069 =C2=A0 =C2=A0 514185 =C2=A0 =C2=A0 512986 =C2=A0 =C2=
=A0 513838 =C2=A0 =C2=A0 511229 =C2=A0 Local timer interrupts
>> > RES: =C2=A0 =C2=A0 =C2=A0 2153 =C2=A0 =C2=A0 =C2=A0 1556 =C2=A0 =C2=A0=
 =C2=A0 1126 =C2=A0 =C2=A0 =C2=A0 1351 =C2=A0 =C2=A0 =C2=A0 3047 =C2=A0 =C2=
=A0 =C2=A0 1554 =C2=A0 =C2=A0 =C2=A0 1131 =C2=A0 =C2=A0 =C2=A0 1560 =C2=A0 =
Rescheduling interrupts
>> > TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0209 =C2=A0 =C2=A0 =C2=A0 =C2=A0 26 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 71 =C2=A0 =C2=A0 =C2=A0 =C2=A0315 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
117 =C2=A0 =C2=A0 =C2=A0 =C2=A0 71 =C2=A0 TLB shootdowns
>> >
>> > patched (WMARK_HIGH, limited scan, stop on watermark OK), 100 dd
>> > ----------------------------------------------------------------
>> >
>> > start time: 3
>> > total time: 50
>> > nr_alloc_fail 162
>> > allocstall 45523
>> >
>> > CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real=
 total =C2=A0virtual total =C2=A0 =C2=A0delay total
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 921 =C2=
=A0 =C2=A0 3024540200 =C2=A0 =C2=A0 3009244668 =C2=A0 =C2=A037123129525
>> > IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0=
delay total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay=
 total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=
=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 357 =C2=
=A0 =C2=A0 4891766796 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 13ms
>> > dd: read=3D0, write=3D0, cancelled_write=3D0
>> >
>> > patched (WMARK_HIGH, limited scan, stop on watermark OK), 1000 dd
>> > -----------------------------------------------------------------
>> >
>> > start time: 272
>> > total time: 509
>> > nr_alloc_fail 3913
>> > allocstall 541789
>> >
>> > CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real=
 total =C2=A0virtual total =C2=A0 =C2=A0delay total
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01044 =C2=
=A0 =C2=A0 3445476208 =C2=A0 =C2=A0 3437200482 =C2=A0 229919915202
>> > IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0=
delay total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay=
 total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=
=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 452 =C2=
=A0 =C2=A034691441605 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 76ms
>> > dd: read=3D0, write=3D0, cancelled_write=3D0
>> >
>> > patched (WMARK_HIGH, limited scan, stop on watermark OK, no time limit=
), 1000 dd
>> > ----------------------------------------------------------------------=
----------
>> >
>> > start time: 278
>> > total time: 513
>> > nr_alloc_fail 4737
>> > allocstall 436392
>> >
>> >
>> > CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real=
 total =C2=A0virtual total =C2=A0 =C2=A0delay total
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01024 =C2=
=A0 =C2=A0 3371487456 =C2=A0 =C2=A0 3359441487 =C2=A0 225088210977
>> > IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0=
delay total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
1 =C2=A0 =C2=A0 =C2=A0160631171 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A016=
0ms
>> > SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay=
 total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=
=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 367 =C2=
=A0 =C2=A030809994722 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 83ms
>> > dd: read=3D20480, write=3D0, cancelled_write=3D0
>> >
>> >
>> > no cond_resched():
>>
>> What's this?
>
> I tried a modified patch that also removes the cond_resched() call in
> __alloc_pages_direct_reclaim(), between try_to_free_pages() and
> get_page_from_freelist(). It seems not helping noticeably.
>
> It looks safe to remove that cond_resched() as we already have such
> calls in shrink_page_list().

I tried similar thing but Andrew have a concern about it.
https://lkml.org/lkml/2011/3/24/138

>
>> >
>> > start time: 263
>> > total time: 516
>> > nr_alloc_fail 5144
>> > allocstall 436787
>> >
>> > CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real=
 total =C2=A0virtual total =C2=A0 =C2=A0delay total
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01018 =C2=
=A0 =C2=A0 3305497488 =C2=A0 =C2=A0 3283831119 =C2=A0 241982934044
>> > IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0=
delay total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay=
 total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=
=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 328 =C2=
=A0 =C2=A031398481378 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 95ms
>> > dd: read=3D0, write=3D0, cancelled_write=3D0
>> >
>> > zone_watermark_ok_safe():
>> >
>> > start time: 266
>> > total time: 513
>> > nr_alloc_fail 4526
>> > allocstall 440246
>> >
>> > CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real=
 total =C2=A0virtual total =C2=A0 =C2=A0delay total
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01119 =C2=
=A0 =C2=A0 3640446568 =C2=A0 =C2=A0 3619184439 =C2=A0 240945024724
>> > IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0=
delay total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
3 =C2=A0 =C2=A0 =C2=A0303620082 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A010=
1ms
>> > SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay=
 total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=
=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 372 =C2=
=A0 =C2=A027320731898 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 73ms
>> > dd: read=3D77824, write=3D0, cancelled_write=3D0
>> >
>
>> > start time: 275
>>
>> What's meaing of start time?
>
> It's the time taken to start 1000 dd's.
>
>> > total time: 517
>>
>> Total time is elapsed time on your experiment?
>
> Yeah. They are generated with this script.
>
> $ cat ~/bin/test-dd-sparse.sh
>
> #!/bin/sh
>
> mount /dev/sda7 /fs
>
> tic=3D$(date +'%s')
>
> for i in `seq 1000`
> do
> =C2=A0 =C2=A0 =C2=A0 =C2=A0truncate -s 1G /fs/sparse-$i
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dd if=3D/fs/sparse-$i of=3D/dev/null &>/dev/nu=
ll &
> done
>
> tac=3D$(date +'%s')
> echo start time: $((tac-tic))
>
> wait
>
> tac=3D$(date +'%s')
> echo total time: $((tac-tic))
>
> egrep '(nr_alloc_fail|allocstall)' /proc/vmstat
> egrep '(CAL|RES|LOC|TLB)' /proc/interrupts
>
>> > nr_alloc_fail 4694
>> > allocstall 431021
>> >
>> >
>> > CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real=
 total =C2=A0virtual total =C2=A0 =C2=A0delay total
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01073 =C2=
=A0 =C2=A0 3534462680 =C2=A0 =C2=A0 3512544928 =C2=A0 234056498221
>>
>> What's meaning of CPU fields?
>
> It's "waiting for a CPU (while being runnable)" as described in
> Documentation/accounting/delay-accounting.txt.

Thanks

>
>> > IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0=
delay total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay=
 total =C2=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00ms
>> > RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=
=A0delay average
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 386 =C2=
=A0 =C2=A034751778363 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 89ms
>> > dd: read=3D0, write=3D0, cancelled_write=3D0
>> >
>>
>> Where is vanilla data for comparing latency?
>> Personally, It's hard to parse your data.
>
> Sorry it's somehow too much data and kernel revisions.. The base kernel's
> average latency is 29ms:
>
> base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation=
 patch
> -------------------------------------------------------------------------=
------
>
> CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0 real to=
tal =C2=A0virtual total =C2=A0 =C2=A0delay total
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1122 =C2=A0 =C2=
=A0 3676441096 =C2=A0 =C2=A0 3656793547 =C2=A0 274182127286
> IO =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0del=
ay total =C2=A0delay average
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =
=C2=A0 =C2=A0 =C2=A0291765493 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 97m=
s
> SWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count =C2=A0 =C2=A0delay to=
tal =C2=A0delay average
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A00ms
> RECLAIM =C2=A0 =C2=A0 =C2=A0 =C2=A0 count =C2=A0 =C2=A0delay total =C2=A0=
delay average
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1350 =C2=A0 =C2=
=A039229752193 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 29ms
> dd: read=3D45056, write=3D0, cancelled_write=3D0
>
> start time: 245
> total time: 526
> nr_alloc_fail 14586
> allocstall 1578343
> LOC: =C2=A0 =C2=A0 533981 =C2=A0 =C2=A0 529210 =C2=A0 =C2=A0 528283 =C2=
=A0 =C2=A0 532346 =C2=A0 =C2=A0 533392 =C2=A0 =C2=A0 531314 =C2=A0 =C2=A0 5=
31705 =C2=A0 =C2=A0 528983 =C2=A0 Local timer interrupts
> RES: =C2=A0 =C2=A0 =C2=A0 3123 =C2=A0 =C2=A0 =C2=A0 2177 =C2=A0 =C2=A0 =
=C2=A0 1676 =C2=A0 =C2=A0 =C2=A0 1580 =C2=A0 =C2=A0 =C2=A0 2157 =C2=A0 =C2=
=A0 =C2=A0 1974 =C2=A0 =C2=A0 =C2=A0 1606 =C2=A0 =C2=A0 =C2=A0 1696 =C2=A0 =
Rescheduling interrupts
> CAL: =C2=A0 =C2=A0 218392 =C2=A0 =C2=A0 218631 =C2=A0 =C2=A0 219167 =C2=
=A0 =C2=A0 219217 =C2=A0 =C2=A0 218840 =C2=A0 =C2=A0 218985 =C2=A0 =C2=A0 2=
18429 =C2=A0 =C2=A0 218440 =C2=A0 Function call interrupts
> TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0175 =C2=A0 =C2=A0 =C2=A0 =C2=A0 13 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 21 =C2=A0 =C2=A0 =C2=A0 =C2=A0 18 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 62 =C2=A0 =C2=A0 =C2=A0 =C2=A0309 =C2=A0 =C2=A0 =C2=A0 =C2=A0119=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 42 =C2=A0 TLB shootdowns
>
>>
>> > CC: Mel Gorman <mel@linux.vnet.ibm.com>
>> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>> > ---
>> > =C2=A0fs/buffer.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 +=
+--
>> > =C2=A0include/linux/swap.h | =C2=A0 =C2=A03 ++-
>> > =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 20 +++++-----------=
----
>> > =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 31 ++++++=
+++++++++++++++++--------
>> > =C2=A04 files changed, 32 insertions(+), 26 deletions(-)
>> > --- linux-next.orig/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 2011-04-29 10:42:=
14.000000000 +0800
>> > +++ linux-next/mm/vmscan.c =C2=A0 =C2=A02011-04-30 21:59:33.000000000 =
+0800
>> > @@ -2025,8 +2025,9 @@ static bool all_unreclaimable(struct zon
>> > =C2=A0 * returns: =C2=A00, if no pages reclaimed
>> > =C2=A0 * =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else, the number of pages =
reclaimed
>> > =C2=A0 */
>> > -static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct scan_con=
trol *sc)
>> > +static unsigned long do_try_to_free_pages(struct zone *preferred_zone=
,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct z=
onelist *zonelist,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct s=
can_control *sc)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 int priority;
>> > =C2=A0 =C2=A0 =C2=A0 unsigned long total_scanned =3D 0;
>> > @@ -2034,6 +2035,7 @@ static unsigned long do_try_to_free_page
>> > =C2=A0 =C2=A0 =C2=A0 struct zoneref *z;
>> > =C2=A0 =C2=A0 =C2=A0 struct zone *zone;
>> > =C2=A0 =C2=A0 =C2=A0 unsigned long writeback_threshold;
>> > + =C2=A0 =C2=A0 unsigned long min_reclaim =3D sc->nr_to_reclaim;
>>
>> Hmm,
>>
>> >
>> > =C2=A0 =C2=A0 =C2=A0 get_mems_allowed();
>> > =C2=A0 =C2=A0 =C2=A0 delayacct_freepages_start();
>> > @@ -2041,6 +2043,9 @@ static unsigned long do_try_to_free_page
>> > =C2=A0 =C2=A0 =C2=A0 if (scanning_global_lru(sc))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count_vm_event(ALLOCS=
TALL);
>> >
>> > + =C2=A0 =C2=A0 if (preferred_zone)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_to_reclaim +=3D pre=
ferred_zone->watermark[WMARK_HIGH];
>> > +
>>
>> Hmm, I don't like this idea.
>> The goal of direct reclaim path is to reclaim pages asap, I beleive.
>> Many thing should be achieve of background kswapd.
>> If admin changes min_free_kbytes, it can affect latency of direct reclai=
m.
>> It doesn't make sense to me.
>
> Yeah, it does increase delays.. in the 1000 dd case, roughly from 30ms
> to 90ms. This is a major drawback.

Yes.

>
>> > =C2=A0 =C2=A0 =C2=A0 for (priority =3D DEF_PRIORITY; priority >=3D 0; =
priority--) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_scanned =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!priority)
>> > @@ -2067,8 +2072,17 @@ static unsigned long do_try_to_free_page
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_scanned +=3D sc=
->nr_scanned;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sc->nr_reclaimed >=3D =
sc->nr_to_reclaim)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 goto out;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sc->nr_reclaimed >=3D =
min_reclaim) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (sc->nr_reclaimed >=3D sc->nr_to_reclaim)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>>
>> I can't understand the logic.
>> if nr_reclaimed is bigger than min_reclaim, it's always greater than
>> nr_to_reclaim. What's meaning of min_reclaim?
>
> In direct reclaim, min_reclaim will be the legacy SWAP_CLUSTER_MAX and
> sc->nr_to_reclaim will be increased to the zone's high watermark and
> is kind of "max to reclaim".
>
>>
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (total_scanned > 2 * sc->nr_to_reclaim)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>>
>> If there are lots of dirty pages in LRU?
>> If there are lots of unevictable pages in LRU?
>> If there are lots of mapped page in LRU but may_unmap =3D 0 cases?
>> I means it's rather risky early conclusion.
>
> That test means to avoid scanning too much on __GFP_NORETRY direct
> reclaims. My assumption for __GFP_NORETRY is, it should fail fast when
> the LRU pages seem hard to reclaim. And the problem in the 1000 dd
> case is, it's all easy to reclaim LRU pages but __GFP_NORETRY still
> fails from time to time, with lots of IPIs that may hurt large
> machines a lot.

I don't have  enough time and a environment to test it.
So I can't make sure of it but my concern is a latency.
If you solve latency problem considering CPU scaling, I won't oppose it. :)



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
