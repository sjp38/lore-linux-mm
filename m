Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DA9096B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 19:43:19 -0500 (EST)
Received: by iyj17 with SMTP id 17so241996iyj.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 16:43:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
Date: Wed, 19 Jan 2011 09:43:17 +0900
Message-ID: <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is
 not allowed
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

Hi David,

On Tue, Jan 18, 2011 at 2:09 PM, David Rientjes <rientjes@google.com> wrote=
:
> Before 0e093d99763e (writeback: do not sleep on the congestion queue if
> there are no congested BDIs or if significant congestion is not being
> encountered in the current zone), preferred_zone was only used for
> statistics and to determine the zoneidx from which to allocate from given
> the type requested.
>
> wait_iff_congested(), though, uses preferred_zone to determine if the
> congestion wait should be deferred because its dirty pages are backed by
> a congested bdi. =A0This incorrectly defers the timeout and busy loops in
> the page allocator with various cond_resched() calls if preferred_zone is
> not allowed in the current context, usually consuming 100% of a cpu.
>
> This patch resets preferred_zone to an allowed zone in the slowpath if
> the allocation context is constrained by current's cpuset. =A0It also
> ensures preferred_zone is from the set of allowed nodes when called from
> within direct reclaim; allocations are always constrainted by cpusets
> since the context is always blockable.
>
> Both of these uses of cpuset_current_mems_allowed are protected by
> get_mems_allowed().
> ---
> =A0mm/page_alloc.c | =A0 12 ++++++++++++
> =A0mm/vmscan.c =A0 =A0 | =A0 =A03 ++-
> =A02 files changed, 14 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2034,6 +2034,18 @@ restart:
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0alloc_flags =3D gfp_to_alloc_flags(gfp_mask);
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If preferred_zone cannot be allocated from in this con=
text, find the
> + =A0 =A0 =A0 =A0* first allowable zone instead.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if ((alloc_flags & ALLOC_CPUSET) &&
> + =A0 =A0 =A0 =A0 =A0 !cpuset_zone_allowed_softwall(preferred_zone, gfp_m=
ask)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 first_zones_zonelist(zonelist, high_zoneidx=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &cpuset_cur=
rent_mems_allowed, &preferred_zone);

This patch is one we need. but I have a nitpick.
I am not familiar with CPUSET so I might be wrong.

I think it could make side effect of statistics of ZVM on
buffered_rmqueue since you intercept and change preferred_zone.
It could make NUMA_HIT instead of NUMA_MISS.
Is it your intention?




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
