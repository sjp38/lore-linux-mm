Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 541D26B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 06:53:15 -0400 (EDT)
Received: by vws1 with SMTP id 1so2736773vws.14
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 03:53:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100709191308.FA25.A69D9226@jp.fujitsu.com>
References: <20100708133152.5e556508.akpm@linux-foundation.org>
	<20100709171850.FA22.A69D9226@jp.fujitsu.com>
	<20100709191308.FA25.A69D9226@jp.fujitsu.com>
Date: Fri, 9 Jul 2010 19:53:13 +0900
Message-ID: <AANLkTins0OMGnj3JmUjIctO0dSnXPsQV1AUsbMEVt2D1@mail.gmail.com>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no
	reclaimable slab
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 9, 2010 at 7:13 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> If number of reclaimable slabs are zero, shrink_icache_memory() and
> shrink_dcache_memory() return 0. but strangely shrink_slab() ignore
> it and continue meaningless loop iteration.
>
> This patch fixes it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =A0mm/vmscan.c | =A0 =A05 +++++
> =A01 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0f9f624..8f61adb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -243,6 +243,11 @@ unsigned long shrink_slab(unsigned long scanned, gfp=
_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_before;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_before =3D (*shrinker->=
shrink)(0, gfp_mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no slab objects, no more=
 reclaim. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_before =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scan =
=3D 0;

Why do you reset totoal_scan to 0?
I don't know exact meaning of shrinker->nr.
AFAIU, it can affect next shrinker's total_scan.
Isn't it harmful?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
