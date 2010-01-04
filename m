Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C318600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 09:05:40 -0500 (EST)
Received: by fxm28 with SMTP id 28so6040898fxm.6
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 06:05:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100104135545.GC6373@csn.ul.ie>
References: <20100104135545.GC6373@csn.ul.ie>
Date: Mon, 4 Jan 2010 16:05:37 +0200
Message-ID: <84144f021001040605pefbc9f7h276b796bdf931353@mail.gmail.com>
Subject: Re: [PATCH] page allocator: Reduce fragmentation in buddy allocator
	by adding buddies that are merging to the tail of the free lists
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Corrado Zoccolo <czoccolo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 4, 2010 at 3:55 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> From: Corrado Zoccolo <czoccolo@gmail.com>
>
> In order to reduce fragmentation, this patch classifies freed pages in
> two groups according to their probability of being part of a high order
> merge. Pages belonging to a compound whose next-highest buddy is free are
> more likely to be part of a high order merge in the near future, so they
> will be added at the tail of the freelist. The remaining pages are put at
> the front of the freelist.
>
> In this way, the pages that are more likely to cause a big merge are kept
> free longer. Consequently there is a tendency to aggregate the long-livin=
g
> allocations on a subset of the compounds, reducing the fragmentation.
>
> This heuristic was testing on three machines, x86, x86-64 and ppc64 with
> 3GB of RAM in each machine. The tests were kernbench, netperf, sysbench a=
nd
> STREAM for performance and a high-order stress test for huge page allocat=
ions.
>
> KernBench X86
> Elapsed mean =A0 =A0 374.77 ( 0.00%) =A0 375.10 (-0.09%)
> User =A0 =A0mean =A0 =A0 649.53 ( 0.00%) =A0 650.44 (-0.14%)
> System =A0mean =A0 =A0 =A054.75 ( 0.00%) =A0 =A054.18 ( 1.05%)
> CPU =A0 =A0 mean =A0 =A0 187.75 ( 0.00%) =A0 187.25 ( 0.27%)
>
> KernBench X86-64
> Elapsed mean =A0 =A0 =A094.45 ( 0.00%) =A0 =A094.01 ( 0.47%)
> User =A0 =A0mean =A0 =A0 323.27 ( 0.00%) =A0 322.66 ( 0.19%)
> System =A0mean =A0 =A0 =A036.71 ( 0.00%) =A0 =A036.50 ( 0.57%)
> CPU =A0 =A0 mean =A0 =A0 380.75 ( 0.00%) =A0 381.75 (-0.26%)
>
> KernBench PPC64
> Elapsed mean =A0 =A0 173.45 ( 0.00%) =A0 173.74 (-0.17%)
> User =A0 =A0mean =A0 =A0 587.99 ( 0.00%) =A0 587.95 ( 0.01%)
> System =A0mean =A0 =A0 =A060.60 ( 0.00%) =A0 =A060.57 ( 0.05%)
> CPU =A0 =A0 mean =A0 =A0 373.50 ( 0.00%) =A0 372.75 ( 0.20%)
>
> Nothing notable for kernbench.
>
> NetPerf UDP X86
> =A0 =A0 =A064 =A0 =A042.68 ( 0.00%) =A0 =A0 42.77 ( 0.21%)
> =A0 =A0 128 =A0 =A085.62 ( 0.00%) =A0 =A0 85.32 (-0.35%)
> =A0 =A0 256 =A0 170.01 ( 0.00%) =A0 =A0168.76 (-0.74%)
> =A0 =A01024 =A0 655.68 ( 0.00%) =A0 =A0652.33 (-0.51%)
> =A0 =A02048 =A01262.39 ( 0.00%) =A0 1248.61 (-1.10%)
> =A0 =A03312 =A01958.41 ( 0.00%) =A0 1944.61 (-0.71%)
> =A0 =A04096 =A02345.63 ( 0.00%) =A0 2318.83 (-1.16%)
> =A0 =A08192 =A04132.90 ( 0.00%) =A0 4089.50 (-1.06%)
> =A0 16384 =A06770.88 ( 0.00%) =A0 6642.05 (-1.94%)*
>
> NetPerf UDP X86-64
> =A0 =A0 =A064 =A0 148.82 ( 0.00%) =A0 =A0154.92 ( 3.94%)
> =A0 =A0 128 =A0 298.96 ( 0.00%) =A0 =A0312.95 ( 4.47%)
> =A0 =A0 256 =A0 583.67 ( 0.00%) =A0 =A0626.39 ( 6.82%)
> =A0 =A01024 =A02293.18 ( 0.00%) =A0 2371.10 ( 3.29%)
> =A0 =A02048 =A04274.16 ( 0.00%) =A0 4396.83 ( 2.79%)
> =A0 =A03312 =A06356.94 ( 0.00%) =A0 6571.35 ( 3.26%)
> =A0 =A04096 =A07422.68 ( 0.00%) =A0 7635.42 ( 2.79%)*
> =A0 =A08192 12114.81 ( 0.00%)* 12346.88 ( 1.88%)
> =A0 16384 17022.28 ( 0.00%)* 17033.19 ( 0.06%)*
> =A0 =A0 =A0 =A0 =A0 =A0 1.64% =A0 =A0 =A0 =A0 =A0 =A0 2.73%
>
> NetPerf UDP PPC64
> =A0 =A0 =A064 =A0 =A049.98 ( 0.00%) =A0 =A0 50.25 ( 0.54%)
> =A0 =A0 128 =A0 =A098.66 ( 0.00%) =A0 =A0100.95 ( 2.27%)
> =A0 =A0 256 =A0 197.33 ( 0.00%) =A0 =A0191.03 (-3.30%)
> =A0 =A01024 =A0 761.98 ( 0.00%) =A0 =A0785.07 ( 2.94%)
> =A0 =A02048 =A01493.50 ( 0.00%) =A0 1510.85 ( 1.15%)
> =A0 =A03312 =A02303.95 ( 0.00%) =A0 2271.72 (-1.42%)
> =A0 =A04096 =A02774.56 ( 0.00%) =A0 2773.06 (-0.05%)
> =A0 =A08192 =A04918.31 ( 0.00%) =A0 4793.59 (-2.60%)
> =A0 16384 =A07497.98 ( 0.00%) =A0 7749.52 ( 3.25%)
>
> The tests are run to have confidence limits within 1%. Results marked wit=
h
> a * were not confident although in this case, it's only outside by small
> amounts. Even with some results that were not confident, the netperf UDP
> results were generally positive.
>
> NetPerf TCP X86
> =A0 =A0 =A064 =A0 652.25 ( 0.00%)* =A0 648.12 (-0.64%)*
> =A0 =A0 =A0 =A0 =A0 =A023.80% =A0 =A0 =A0 =A0 =A0 =A022.82%
> =A0 =A0 128 =A01229.98 ( 0.00%)* =A01220.56 (-0.77%)*
> =A0 =A0 =A0 =A0 =A0 =A021.03% =A0 =A0 =A0 =A0 =A0 =A018.90%
> =A0 =A0 256 =A02105.88 ( 0.00%) =A0 1872.03 (-12.49%)*
> =A0 =A0 =A0 =A0 =A0 =A0 1.00% =A0 =A0 =A0 =A0 =A0 =A016.46%
> =A0 =A01024 =A03476.46 ( 0.00%)* =A03548.28 ( 2.02%)*
> =A0 =A0 =A0 =A0 =A0 =A013.37% =A0 =A0 =A0 =A0 =A0 =A011.39%
> =A0 =A02048 =A04023.44 ( 0.00%)* =A04231.45 ( 4.92%)*
> =A0 =A0 =A0 =A0 =A0 =A0 9.76% =A0 =A0 =A0 =A0 =A0 =A012.48%
> =A0 =A03312 =A04348.88 ( 0.00%)* =A04396.96 ( 1.09%)*
> =A0 =A0 =A0 =A0 =A0 =A0 6.49% =A0 =A0 =A0 =A0 =A0 =A0 8.75%
> =A0 =A04096 =A04726.56 ( 0.00%)* =A04877.71 ( 3.10%)*
> =A0 =A0 =A0 =A0 =A0 =A0 9.85% =A0 =A0 =A0 =A0 =A0 =A0 8.50%
> =A0 =A08192 =A04732.28 ( 0.00%)* =A05777.77 (18.10%)*
> =A0 =A0 =A0 =A0 =A0 =A0 9.13% =A0 =A0 =A0 =A0 =A0 =A013.04%
> =A0 16384 =A05543.05 ( 0.00%)* =A05906.24 ( 6.15%)*
> =A0 =A0 =A0 =A0 =A0 =A0 7.73% =A0 =A0 =A0 =A0 =A0 =A0 8.68%
>
> NETPERF TCP X86-64
> =A0 =A0 =A0 =A0 =A0 =A0netperf-tcp-vanilla-netperf =A0 =A0 =A0 netperf-tc=
p
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp-vanilla =A0 =A0 pgalloc-delay
> =A0 =A0 =A064 =A01895.87 ( 0.00%)* =A01775.07 (-6.81%)*
> =A0 =A0 =A0 =A0 =A0 =A0 5.79% =A0 =A0 =A0 =A0 =A0 =A0 4.78%
> =A0 =A0 128 =A03571.03 ( 0.00%)* =A03342.20 (-6.85%)*
> =A0 =A0 =A0 =A0 =A0 =A0 3.68% =A0 =A0 =A0 =A0 =A0 =A0 6.06%
> =A0 =A0 256 =A05097.21 ( 0.00%)* =A04859.43 (-4.89%)*
> =A0 =A0 =A0 =A0 =A0 =A0 3.02% =A0 =A0 =A0 =A0 =A0 =A0 2.10%
> =A0 =A01024 =A08919.10 ( 0.00%)* =A08892.49 (-0.30%)*
> =A0 =A0 =A0 =A0 =A0 =A0 5.89% =A0 =A0 =A0 =A0 =A0 =A0 6.55%
> =A0 =A02048 10255.46 ( 0.00%)* 10449.39 ( 1.86%)*
> =A0 =A0 =A0 =A0 =A0 =A0 7.08% =A0 =A0 =A0 =A0 =A0 =A0 7.44%
> =A0 =A03312 10839.90 ( 0.00%)* 10740.15 (-0.93%)*
> =A0 =A0 =A0 =A0 =A0 =A0 6.87% =A0 =A0 =A0 =A0 =A0 =A0 7.33%
> =A0 =A04096 10814.84 ( 0.00%)* 10766.97 (-0.44%)*
> =A0 =A0 =A0 =A0 =A0 =A0 6.86% =A0 =A0 =A0 =A0 =A0 =A0 8.18%
> =A0 =A08192 11606.89 ( 0.00%)* 11189.28 (-3.73%)*
> =A0 =A0 =A0 =A0 =A0 =A0 7.49% =A0 =A0 =A0 =A0 =A0 =A0 5.55%
> =A0 16384 12554.88 ( 0.00%)* 12361.22 (-1.57%)*
> =A0 =A0 =A0 =A0 =A0 =A0 7.36% =A0 =A0 =A0 =A0 =A0 =A0 6.49%
>
> NETPERF TCP PPC64
> =A0 =A0 =A0 =A0 =A0 =A0netperf-tcp-vanilla-netperf =A0 =A0 =A0 netperf-tc=
p
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp-vanilla =A0 =A0 pgalloc-delay
> =A0 =A0 =A064 =A0 594.17 ( 0.00%) =A0 =A0596.04 ( 0.31%)*
> =A0 =A0 =A0 =A0 =A0 =A0 1.00% =A0 =A0 =A0 =A0 =A0 =A0 2.29%
> =A0 =A0 128 =A01064.87 ( 0.00%)* =A01074.77 ( 0.92%)*
> =A0 =A0 =A0 =A0 =A0 =A0 1.30% =A0 =A0 =A0 =A0 =A0 =A0 1.40%
> =A0 =A0 256 =A01852.46 ( 0.00%)* =A01856.95 ( 0.24%)
> =A0 =A0 =A0 =A0 =A0 =A0 1.25% =A0 =A0 =A0 =A0 =A0 =A0 1.00%
> =A0 =A01024 =A03839.46 ( 0.00%)* =A03813.05 (-0.69%)
> =A0 =A0 =A0 =A0 =A0 =A0 1.02% =A0 =A0 =A0 =A0 =A0 =A0 1.00%
> =A0 =A02048 =A04885.04 ( 0.00%)* =A04881.97 (-0.06%)*
> =A0 =A0 =A0 =A0 =A0 =A0 1.15% =A0 =A0 =A0 =A0 =A0 =A0 1.04%
> =A0 =A03312 =A05506.90 ( 0.00%) =A0 5459.72 (-0.86%)
> =A0 =A04096 =A06449.19 ( 0.00%) =A0 6345.46 (-1.63%)
> =A0 =A08192 =A07501.17 ( 0.00%) =A0 7508.79 ( 0.10%)
> =A0 16384 =A09618.65 ( 0.00%) =A0 9490.10 (-1.35%)
>
> There was a distinct lack of confidence in the X86* figures so I included=
 what
> the devation was where the results were not confident. =A0Many of the res=
ults,
> whether gains or losses were within the standard deviation so no solid
> conclusion can be reached on performance impact. Looking at the figures,
> only the X86-64 ones look suspicious with a few losses that were outside
> the noise. However, the results were so unstable that without knowing why
> they vary so much, a solid conclusion cannot be reached.
>
> SYSBENCH X86
> =A0 =A0 =A0 =A0 =A0 =A0 =A0sysbench-vanilla =A0 =A0 pgalloc-delay
> =A0 =A0 =A0 =A0 =A0 1 =A07722.85 ( 0.00%) =A07756.79 ( 0.44%)
> =A0 =A0 =A0 =A0 =A0 2 14901.11 ( 0.00%) 13683.44 (-8.90%)
> =A0 =A0 =A0 =A0 =A0 3 15171.71 ( 0.00%) 14888.25 (-1.90%)
> =A0 =A0 =A0 =A0 =A0 4 14966.98 ( 0.00%) 15029.67 ( 0.42%)
> =A0 =A0 =A0 =A0 =A0 5 14370.47 ( 0.00%) 14865.00 ( 3.33%)
> =A0 =A0 =A0 =A0 =A0 6 14870.33 ( 0.00%) 14845.57 (-0.17%)
> =A0 =A0 =A0 =A0 =A0 7 14429.45 ( 0.00%) 14520.85 ( 0.63%)
> =A0 =A0 =A0 =A0 =A0 8 14354.35 ( 0.00%) 14362.31 ( 0.06%)
>
> SYSBENCH X86-64
> =A0 =A0 =A0 =A0 =A0 1 17448.70 ( 0.00%) 17484.41 ( 0.20%)
> =A0 =A0 =A0 =A0 =A0 2 34276.39 ( 0.00%) 34251.00 (-0.07%)
> =A0 =A0 =A0 =A0 =A0 3 50805.25 ( 0.00%) 50854.80 ( 0.10%)
> =A0 =A0 =A0 =A0 =A0 4 66667.10 ( 0.00%) 66174.69 (-0.74%)
> =A0 =A0 =A0 =A0 =A0 5 66003.91 ( 0.00%) 65685.25 (-0.49%)
> =A0 =A0 =A0 =A0 =A0 6 64981.90 ( 0.00%) 65125.60 ( 0.22%)
> =A0 =A0 =A0 =A0 =A0 7 64933.16 ( 0.00%) 64379.23 (-0.86%)
> =A0 =A0 =A0 =A0 =A0 8 63353.30 ( 0.00%) 63281.22 (-0.11%)
> =A0 =A0 =A0 =A0 =A0 9 63511.84 ( 0.00%) 63570.37 ( 0.09%)
> =A0 =A0 =A0 =A0 =A010 62708.27 ( 0.00%) 63166.25 ( 0.73%)
> =A0 =A0 =A0 =A0 =A011 62092.81 ( 0.00%) 61787.75 (-0.49%)
> =A0 =A0 =A0 =A0 =A012 61330.11 ( 0.00%) 61036.34 (-0.48%)
> =A0 =A0 =A0 =A0 =A013 61438.37 ( 0.00%) 61994.47 ( 0.90%)
> =A0 =A0 =A0 =A0 =A014 62304.48 ( 0.00%) 62064.90 (-0.39%)
> =A0 =A0 =A0 =A0 =A015 63296.48 ( 0.00%) 62875.16 (-0.67%)
> =A0 =A0 =A0 =A0 =A016 63951.76 ( 0.00%) 63769.09 (-0.29%)
>
> SYSBENCH PPC64
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 -sysbench-pgalloc=
-delay-sysbench
> =A0 =A0 =A0 =A0 =A0 =A0 =A0sysbench-vanilla =A0 =A0 pgalloc-delay
> =A0 =A0 =A0 =A0 =A0 1 =A07645.08 ( 0.00%) =A07467.43 (-2.38%)
> =A0 =A0 =A0 =A0 =A0 2 14856.67 ( 0.00%) 14558.73 (-2.05%)
> =A0 =A0 =A0 =A0 =A0 3 21952.31 ( 0.00%) 21683.64 (-1.24%)
> =A0 =A0 =A0 =A0 =A0 4 27946.09 ( 0.00%) 28623.29 ( 2.37%)
> =A0 =A0 =A0 =A0 =A0 5 28045.11 ( 0.00%) 28143.69 ( 0.35%)
> =A0 =A0 =A0 =A0 =A0 6 27477.10 ( 0.00%) 27337.45 (-0.51%)
> =A0 =A0 =A0 =A0 =A0 7 26489.17 ( 0.00%) 26590.06 ( 0.38%)
> =A0 =A0 =A0 =A0 =A0 8 26642.91 ( 0.00%) 25274.33 (-5.41%)
> =A0 =A0 =A0 =A0 =A0 9 25137.27 ( 0.00%) 24810.06 (-1.32%)
> =A0 =A0 =A0 =A0 =A010 24451.99 ( 0.00%) 24275.85 (-0.73%)
> =A0 =A0 =A0 =A0 =A011 23262.20 ( 0.00%) 23674.88 ( 1.74%)
> =A0 =A0 =A0 =A0 =A012 24234.81 ( 0.00%) 23640.89 (-2.51%)
> =A0 =A0 =A0 =A0 =A013 24577.75 ( 0.00%) 24433.50 (-0.59%)
> =A0 =A0 =A0 =A0 =A014 25640.19 ( 0.00%) 25116.52 (-2.08%)
> =A0 =A0 =A0 =A0 =A015 26188.84 ( 0.00%) 26181.36 (-0.03%)
> =A0 =A0 =A0 =A0 =A016 26782.37 ( 0.00%) 26255.99 (-2.00%)
>
> Again, there is little to conclude here. While there are a few losses,
> the results vary by +/- 8% in some cases. They are the results of most
> concern as there are some large losses but it's also within the variance
> typically seen between kernel releases.
>
> The STREAM results varied so little and are so verbose that I didn't
> include them here.
>
> The final test stressed how many huge pages can be allocated. The
> absolute number of huge pages allocated are the same with or without the
> page. However, the "unusability free space index" which is a measure of
> external fragmentation was slightly lower (lower is better) throughout th=
e
> lifetime of the system. I also measured the latency of how long it took
> to successfully allocate a huge page. The latency was slightly lower and
> on X86 and PPC64, more huge pages were allocated almost immediately from
> the free lists. The improvement is slight but there.
>
> [mel@csn.ul.ie: Tested, reworked for less branches]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
> =A0mm/page_alloc.c | =A0 27 ++++++++++++++++++++++++---
> =A01 files changed, 24 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2bc2ac6..fe7017e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -451,6 +451,7 @@ static inline void __free_one_page(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int migratetype)
> =A0{
> =A0 =A0 =A0 =A0unsigned long page_idx;
> + =A0 =A0 =A0 unsigned long combined_idx;
>
> =A0 =A0 =A0 =A0if (unlikely(PageCompound(page)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(destroy_compound_page(page, o=
rder)))
> @@ -464,7 +465,6 @@ static inline void __free_one_page(struct page *page,
> =A0 =A0 =A0 =A0VM_BUG_ON(bad_range(zone, page));
>
> =A0 =A0 =A0 =A0while (order < MAX_ORDER-1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long combined_idx;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *buddy;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buddy =3D __page_find_buddy(page, page_idx=
, order);
> @@ -481,8 +481,29 @@ static inline void __free_one_page(struct page *page=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0order++;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0set_page_order(page, order);
> - =A0 =A0 =A0 list_add(&page->lru,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 &zone->free_area[order].free_list[migratety=
pe]);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If this is not the largest possible page, check if the=
 buddy
> + =A0 =A0 =A0 =A0* of the next-highest order is free. If it is, it's poss=
ible
> + =A0 =A0 =A0 =A0* that pages are being freed that will coalesce soon. In=
 case,
> + =A0 =A0 =A0 =A0* that is happening, add the free page to the tail of th=
e list
> + =A0 =A0 =A0 =A0* so it's less likely to be used soon and more likely to=
 be merged
> + =A0 =A0 =A0 =A0* as a higher order page
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (order < MAX_ORDER-1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *higher_page, *higher_buddy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 combined_idx =3D __find_combined_index(page=
_idx, order);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 higher_page =3D page + combined_idx - page_=
idx;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 higher_buddy =3D __page_find_buddy(higher_p=
age, combined_idx, order + 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_is_buddy(higher_page, higher_buddy=
, order + 1)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&page->lru,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &zone->free=
_area[order].free_list[migratetype]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 list_add(&page->lru, &zone->free_area[order].free_list[migr=
atetype]);
> +out:
> =A0 =A0 =A0 =A0zone->free_area[order].nr_free++;
> =A0}

FWIW,

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
