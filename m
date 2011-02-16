Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 973368D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 18:53:01 -0500 (EST)
Received: by iwc10 with SMTP id 10so1870248iwc.14
        for <linux-mm@kvack.org>; Wed, 16 Feb 2011 15:26:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110216095048.GA4473@csn.ul.ie>
References: <20110209154606.GJ27110@cmpxchg.org>
	<20110209164656.GA1063@csn.ul.ie>
	<20110209182846.GN3347@random.random>
	<20110210102109.GB17873@csn.ul.ie>
	<20110210124838.GU3347@random.random>
	<20110210133323.GH17873@csn.ul.ie>
	<20110210141447.GW3347@random.random>
	<20110210145813.GK17873@csn.ul.ie>
	<20110216095048.GA4473@csn.ul.ie>
Date: Thu, 17 Feb 2011 08:26:19 +0900
Message-ID: <AANLkTik2iiqqOUoHGyq+QWPNZ_V=2DAJvFGG4u=QPOqT@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to
 insufficient progress if !__GFP_REPEAT
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 16, 2011 at 6:50 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> should_continue_reclaim() for reclaim/compaction allows scanning to conti=
nue
> even if pages are not being reclaimed until the full list is scanned. In
> terms of allocation success, this makes sense but potentially it introduc=
es
> unwanted latency for high-order allocations such as transparent hugepages
> and network jumbo frames that would prefer to fail the allocation attempt
> and fallback to order-0 pages. =C2=A0Worse, there is a potential that the=
 full
> LRU scan will clear all the young bits, distort page aging information an=
d
> potentially push pages into swap that would have otherwise remained resid=
ent.
>
> This patch will stop reclaim/compaction if no pages were reclaimed in the
> last SWAP_CLUSTER_MAX pages that were considered. For allocations such as
> hugetlbfs that use GFP_REPEAT and have fewer fallback options, the full L=
RU
> list may still be scanned.
>
> To test this, a tool was developed based on ftrace that tracked the laten=
cy of
> high-order allocations while transparent hugepage support was enabled and=
 three
> benchmarks were run. The "fix-infinite" figures are 2.6.38-rc4 with Johan=
nes's
> patch "vmscan: fix zone shrinking exit when scan work is done" applied.
>
> STREAM Highorder Allocation Latency Statistics
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fix-infinite =C2=A0 =C2=
=A0 break-early
> 1 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A010298 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 10229
> 1 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.4560 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.4640
> 1 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.0589 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A01.0183
> 1 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A014.5990 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 11.7510
> 1 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.5208 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00.4719
> 2 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1
> 2 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.8610 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A03.7240
> 2 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.4325 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A03.7240
> 2 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5.0040 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A03.7240
> 2 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.5715 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00.0000
> 9 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 111696 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0111694
> 9 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.5230 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.4110
> 9 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10.5831 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 10.5718
> 9 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A038.4480 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 43.2900
> 9 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.1147 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A01.1325
>
> Mean time for order-1 allocations is reduced. order-2 looks increased
> but with so few allocations, it's not particularly significant. THP mean
> allocation latency is also reduced. That said, allocation time varies so
> significantly that the reductions are within noise.
>
> Max allocation time is reduced by a significant amount for low-order
> allocations but reduced for THP allocations which presumably are now
> breaking before reclaim has done enough work.
>
> SysBench Highorder Allocation Latency Statistics
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fix-infinite =C2=A0 =C2=
=A0 break-early
> 1 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A015745 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 15677
> 1 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.4250 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.4550
> 1 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.1023 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A01.0810
> 1 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A014.4590 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 10.8220
> 1 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.5117 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00.5100
> 2 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1
> 2 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 3.0040 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A02.1530
> 2 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.0040 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A02.1530
> 2 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 3.0040 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A02.1530
> 2 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.0000 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00.0000
> 9 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2017 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A01931
> 9 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.4980 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.7480
> 9 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10.4717 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 10.3840
> 9 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A024.9460 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 26.2500
> 9 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.1726 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A01.1966
>
> Again, mean time for order-1 allocations is reduced while order-2 allocat=
ions
> are too few to draw conclusions from. The mean time for THP allocations i=
s
> also slightly reduced albeit the reductions are within varianes.
>
> Once again, our maximum allocation time is significantly reduced for
> low-order allocations and slightly increased for THP allocations.
>
> Anon stream mmap reference Highorder Allocation Latency Statistics
> 1 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1376 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A01790
> 1 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.4940 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.5010
> 1 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.0289 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.9732
> 1 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6.2670 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A04.2540
> 1 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.4142 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00.2785
> 2 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -
> 2 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.9060 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -
> 2 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01.9060 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -
> 2 :: Max =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.9060 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -
> 2 :: Stddev =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.0000 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -
> 9 :: Count =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A011266 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 11257
> 9 :: Min =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.4990 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00.4940
> 9 :: Mean =C2=A0 =C2=A0 =C2=A0 =C2=A027250.4669 =C2=A0 =C2=A0 =C2=A024256=
.1919
> 9 :: Max =C2=A0 =C2=A0 =C2=A011439211.0000 =C2=A0 =C2=A06008885.0000
> 9 :: Stddev =C2=A0 =C2=A0 226427.4624 =C2=A0 =C2=A0 186298.1430
>
> This benchmark creates one thread per CPU which references an amount of
> anonymous memory 1.5 times the size of physical RAM. This pounds swap qui=
te
> heavily and is intended to exercise THP a bit.
>
> Mean allocation time for order-1 is reduced as before. It's also reduced
> for THP allocations but the variations here are pretty massive due to swa=
p.
> As before, maximum allocation times are significantly reduced.
>
> Overall, the patch reduces the mean and maximum allocation latencies for
> the smaller high-order allocations. This was with Slab configured so it
> would be expected to be more significant with Slub which uses these size
> allocations more aggressively.
>
> The mean allocation times for THP allocations are also slightly reduced.
> The maximum latency was slightly increased as predicted by the comments d=
ue
> to reclaim/compaction breaking early. However, workloads care more about =
the
> latency of lower-order allocations than THP so it's an acceptable trade-o=
ff.
> Please consider merging for 2.6.38.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

> ---
> =C2=A0mm/vmscan.c | =C2=A0 32 ++++++++++++++++++++++----------
> =C2=A01 files changed, 22 insertions(+), 10 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 148c6e6..591b907 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1841,16 +1841,28 @@ static inline bool should_continue_reclaim(struct=
 zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(sc->reclaim_mode & RECLAIM_MODE_COMPACTI=
ON))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;
>
> - =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we failed to reclaim and have scanned t=
he full list, stop.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* NOTE: Checking just nr_reclaimed would exi=
t reclaim/compaction far
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 faster but obviously =
would be less likely to succeed
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 allocation. If this i=
s desirable, use GFP_REPEAT to decide

Typo. __GFP_REPEAT

Otherwise, looks good to me.
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>






--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
