Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id CCD666B004D
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 15:25:58 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11797228pbb.14
        for <linux-mm@kvack.org>; Sun, 22 Jul 2012 12:25:58 -0700 (PDT)
Date: Sun, 22 Jul 2012 12:25:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 21/34] kswapd: assign new_order and new_classzone_idx
 after wakeup in sleeping
In-Reply-To: <1342708604-26540-22-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LSU.2.00.1207221213100.1896@eggly.anvils>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de> <1342708604-26540-22-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2068519065-1342985120=:1896"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-2068519065-1342985120=:1896
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 19 Jul 2012, Mel Gorman wrote:
> From: "Alex,Shi" <alex.shi@intel.com>
>=20
> commit d2ebd0f6b89567eb93ead4e2ca0cbe03021f344b upstream.

Thanks for assembling these, Mel: I was checking through to see if
I was missing any, and noticed that this one has the wrong upstream
SHA1: the one you give here is the same as in 20/34, but it should be

commit f0dfcde099453aa4c0dc42473828d15a6d492936 upstream.

I got quite confused by 30/34 too: interesting definition of "partial
backport" :) I've no objection, but "substitute" might be clearer there.

Hugh

>=20
> Stable note: Fixes https://bugzilla.redhat.com/show_bug.cgi?id=3D712019. =
This
> =09patch reduces kswapd CPU usage.
>=20
> There 2 places to read pgdat in kswapd.  One is return from a successful
> balance, another is waked up from kswapd sleeping.  The new_order and
> new_classzone_idx represent the balance input order and classzone_idx.
>=20
> But current new_order and new_classzone_idx are not assigned after
> kswapd_try_to_sleep(), that will cause a bug in the following scenario.
>=20
> 1: after a successful balance, kswapd goes to sleep, and new_order =3D 0;
>    new_classzone_idx =3D __MAX_NR_ZONES - 1;
>=20
> 2: kswapd waked up with order =3D 3 and classzone_idx =3D ZONE_NORMAL
>=20
> 3: in the balance_pgdat() running, a new balance wakeup happened with
>    order =3D 5, and classzone_idx =3D ZONE_NORMAL
>=20
> 4: the first wakeup(order =3D 3) finished successufly, return order =3D 3
>    but, the new_order is still 0, so, this balancing will be treated as a
>    failed balance.  And then the second tighter balancing will be missed.
>=20
> So, to avoid the above problem, the new_order and new_classzone_idx need
> to be assigned for later successful comparison.
>=20
> Signed-off-by: Alex Shi <alex.shi@intel.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Tested-by: P=C3=A1draig Brady <P@draigBrady.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/vmscan.c |    2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bf85e4d..b8c1fc0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2905,6 +2905,8 @@ static int kswapd(void *p)
>  =09=09=09=09=09=09balanced_classzone_idx);
>  =09=09=09order =3D pgdat->kswapd_max_order;
>  =09=09=09classzone_idx =3D pgdat->classzone_idx;
> +=09=09=09new_order =3D order;
> +=09=09=09new_classzone_idx =3D classzone_idx;
>  =09=09=09pgdat->kswapd_max_order =3D 0;
>  =09=09=09pgdat->classzone_idx =3D pgdat->nr_zones - 1;
>  =09=09}
> --=20
> 1.7.9.2
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
--8323584-2068519065-1342985120=:1896--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
