Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3F7526B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 06:52:12 -0400 (EDT)
Received: by fxm20 with SMTP id 20so2180585fxm.38
        for <linux-mm@kvack.org>; Fri, 16 Oct 2009 03:52:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1255689446-3858-2-git-send-email-mel@csn.ul.ie>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie>
	 <1255689446-3858-2-git-send-email-mel@csn.ul.ie>
Date: Fri, 16 Oct 2009 13:52:09 +0300
Message-ID: <84144f020910160352n3a334e84hd248b78e0093716d@mail.gmail.com>
Subject: Re: [PATCH 1/2] page allocator: Always wake kswapd when restarting an
	allocation attempt after direct reclaim failed
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Frans Pop <elendil@planet.nl>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 16, 2009 at 1:37 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> If a direct reclaim makes no forward progress, it considers whether it
> should go OOM or not. Whether OOM is triggered or not, it may retry the
> application afterwards. In times past, this would always wake kswapd as w=
ell
> but currently, kswapd is not woken up after direct reclaim fails. For ord=
er-0
> allocations, this makes little difference but if there is a heavy mix of
> higher-order allocations that direct reclaim is failing for, it might mea=
n
> that kswapd is not rewoken for higher orders as much as it did previously=
.
>
> This patch wakes up kswapd when an allocation is being retried after a di=
rect
> reclaim failure. It would be expected that kswapd is already awake, but
> this has the effect of telling kswapd to reclaim at the higher order as w=
ell.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
> =A0mm/page_alloc.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf72055..dfa4362 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1817,9 +1817,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int=
 order,
> =A0 =A0 =A0 =A0if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) =3D=3D GFP_THI=
SNODE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nopage;
>
> +restart:
> =A0 =A0 =A0 =A0wake_all_kswapd(order, zonelist, high_zoneidx);
>
> -restart:
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * OK, we're below the kswapd watermark and have kicked ba=
ckground
> =A0 =A0 =A0 =A0 * reclaim. Now things get more complex, so set up alloc_f=
lags according
> --
> 1.6.3.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
