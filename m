Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFE46B007E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 05:27:17 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3222691qwa.14
        for <linux-mm@kvack.org>; Tue, 12 Jul 2011 02:27:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1310389274-13995-2-git-send-email-mgorman@suse.de>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
	<1310389274-13995-2-git-send-email-mgorman@suse.de>
Date: Tue, 12 Jul 2011 18:27:13 +0900
Message-ID: <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Mel,

On Mon, Jul 11, 2011 at 10:01 PM, Mel Gorman <mgorman@suse.de> wrote:
> Zone reclaim is similar to direct reclaim in a number of respects.
> PF_SWAPWRITE is used by kswapd to avoid a write-congestion check
> but it's set also set for zone_reclaim which is inappropriate.
> Setting it potentially allows zone_reclaim users to cause large IO
> stalls which is worse than remote memory accesses.

As I read zone_reclaim_mode in vm.txt, I think it's intentional.
It has meaning of throttle the process which are writing large amounts
of data. The point is to prevent use of remote node's free memory.

And we has still the comment. If you're right, you should remove comment.
"         * and we also need to be able to write out pages for RECLAIM_WRIT=
E
         * and RECLAIM_SWAP."


And at least, we should Cc Christoph and KOSAKI.

>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 =C2=A04 ++--
> =C2=A01 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4f49535..ebef213 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3063,7 +3063,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * and we also need to be able to write out pa=
ges for RECLAIM_WRITE
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * and RECLAIM_SWAP.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 p->flags |=3D PF_MEMALLOC | PF_SWAPWRITE;
> + =C2=A0 =C2=A0 =C2=A0 p->flags |=3D PF_MEMALLOC;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lockdep_set_current_reclaim_state(gfp_mask);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_state.reclaimed_slab =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p->reclaim_state =3D &reclaim_state;
> @@ -3116,7 +3116,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t =
gfp_mask, unsigned int order)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0p->reclaim_state =3D NULL;
> - =C2=A0 =C2=A0 =C2=A0 current->flags &=3D ~(PF_MEMALLOC | PF_SWAPWRITE);
> + =C2=A0 =C2=A0 =C2=A0 current->flags &=3D ~PF_MEMALLOC;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lockdep_clear_current_reclaim_state();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return sc.nr_reclaimed >=3D nr_pages;
> =C2=A0}
> --
> 1.7.3.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
