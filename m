Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ECF656B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 05:01:27 -0500 (EST)
Received: by iyj17 with SMTP id 17so233718iyj.14
        for <linux-mm@kvack.org>; Tue, 14 Dec 2010 02:01:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101210143018.29934.11893.stgit@localhost6.localdomain6>
References: <20101210142745.29934.29186.stgit@localhost6.localdomain6>
	<20101210143018.29934.11893.stgit@localhost6.localdomain6>
Date: Tue, 14 Dec 2010 19:01:26 +0900
Message-ID: <AANLkTimeecObDMQMbWzNhL1mE+UT9D3o1WWS4bmxtR4U@mail.gmail.com>
Subject: Re: [PATCH 2/3] Refactor zone_reclaim (v2)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Balbir,

On Fri, Dec 10, 2010 at 11:31 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
> Move reusable functionality outside of zone_reclaim.
> Make zone_reclaim_unmapped_pages modular
>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> =A0mm/vmscan.c | =A0 35 +++++++++++++++++++++++------------
> =A01 files changed, 23 insertions(+), 12 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e841cae..4e2ad05 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2815,6 +2815,27 @@ static long zone_pagecache_reclaimable(struct zone=
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

As I said previous version, zone_reclaim_unmapped_pages doesn't have
any functions related to reclaim unmapped pages.
The function name is rather strange.
It would be better to add scan_control setup in function inner to
reclaim only unmapped pages.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
