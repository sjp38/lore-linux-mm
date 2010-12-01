Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2BEF16B0085
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 02:54:10 -0500 (EST)
Received: by iwn42 with SMTP id 42so2389440iwn.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 23:54:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130101520.17475.79978.stgit@localhost6.localdomain6>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
	<20101130101520.17475.79978.stgit@localhost6.localdomain6>
Date: Wed, 1 Dec 2010 16:54:08 +0900
Message-ID: <AANLkTik59zL97EqpPSNiy122YFwXqWyRqAkMJDjRtfRE@mail.gmail.com>
Subject: Re: [PATCH 2/3] Refactor zone_reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

On Tue, Nov 30, 2010 at 7:15 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> Refactor zone_reclaim, move reusable functionality outside
> of zone_reclaim. Make zone_reclaim_unmapped_pages modular
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> =A0mm/vmscan.c | =A0 35 +++++++++++++++++++++++------------
> =A01 files changed, 23 insertions(+), 12 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 325443a..0ac444f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2719,6 +2719,27 @@ static long zone_pagecache_reclaimable(struct zone=
 *zone)
> =A0}
>
> =A0/*
> + * Helper function to reclaim unmapped pages, we might add something
> + * similar to this for slab cache as well. Currently this function
> + * is shared with __zone_reclaim()
> + */
> +static inline void
> +zone_reclaim_unmapped_pages(struct zone *zone, struct scan_control *sc,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng nr_pages)
> +{
> + =A0 =A0 =A0 int priority;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Free memory by calling shrink zone with increasing
> + =A0 =A0 =A0 =A0* priorities until we have enough memory freed.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 priority =3D ZONE_RECLAIM_PRIORITY;
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority--;
> + =A0 =A0 =A0 } while (priority >=3D 0 && sc->nr_reclaimed < nr_pages);
> +}
> +

I don't see any specific logic about naming
"zone_reclaim_unmapped_pages" in your function.
Maybe, caller of this function have to handle sc->may_unmap. So, this
function's naming
is not good.
As I see your logic, the function name would be just "zone_reclaim_pages"
If you want to name it with zone_reclaim_unmapped_pages, it could be
better with setting sc->may_unmap in this function.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
