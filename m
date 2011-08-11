Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CBBC46B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 19:44:37 -0400 (EDT)
Received: by qyk7 with SMTP id 7so1886689qyk.14
        for <linux-mm@kvack.org>; Thu, 11 Aug 2011 16:44:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1313094715-31187-2-git-send-email-jweiner@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
	<1313094715-31187-2-git-send-email-jweiner@redhat.com>
Date: Fri, 12 Aug 2011 08:44:34 +0900
Message-ID: <CAEwNFnBp7JBWpuaT=ZKDyfQTQqOe_mT0CLFAw9LWo10GoXaFnQ@mail.gmail.com>
Subject: Re: [patch 2/2] mm: vmscan: drop nr_force_scan[] from get_scan_count
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Fri, Aug 12, 2011 at 5:31 AM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> The nr_force_scan[] tuple holds the effective scan numbers for anon
> and file pages in case the situation called for a forced scan and the
> regularly calculated scan numbers turned out zero.
>
> However, the effective scan number can always be assumed to be
> SWAP_CLUSTER_MAX right before the division into anon and file. =C2=A0The
> numerators and denominator are properly set up for all cases, be it
> force scan for just file, just anon, or both, to do the right thing.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

There is a nitpick at below.

> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Ying Han <yinghan@google.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Mel Gorman <mel@csn.ul.ie>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 24 ++----------------------
> =C2=A01 files changed, 2 insertions(+), 22 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 96061d7..45f0986 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1831,7 +1831,6 @@ static void get_scan_count(struct zone *zone, struc=
t scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0enum lru_list l;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int noswap =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool force_scan =3D false;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long nr_force_scan[2];
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* kswapd does zone balancing and need to scan=
 this zone */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (scanning_global_lru(sc) && current_is_kswa=
pd())
> @@ -1846,8 +1845,6 @@ static void get_scan_count(struct zone *zone, struc=
t scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fraction[0] =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fraction[1] =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0denominator =3D 1;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_force_scan[0] =3D 0=
;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_force_scan[1] =3D S=
WAP_CLUSTER_MAX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -1864,8 +1861,6 @@ static void get_scan_count(struct zone *zone, struc=
t scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0fraction[0] =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0fraction[1] =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0denominator =3D 1;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_force_scan[0] =3D SWAP_CLUSTER_MAX;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_force_scan[1] =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -1914,11 +1909,6 @@ static void get_scan_count(struct zone *zone, stru=
ct scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fraction[0] =3D ap;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fraction[1] =3D fp;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0denominator =3D ap + fp + 1;
> - =C2=A0 =C2=A0 =C2=A0 if (force_scan) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long scan =3D=
 SWAP_CLUSTER_MAX;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_force_scan[0] =3D d=
iv64_u64(scan * ap, denominator);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_force_scan[1] =3D d=
iv64_u64(scan * fp, denominator);
> - =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_evictable_lru(l) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int file =3D is_fi=
le_lru(l);
> @@ -1927,20 +1917,10 @@ out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D zone_nr_l=
ru_pages(zone, sc, l);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (priority || no=
swap) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0scan >>=3D priority;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (!scan && force_scan)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scan =3D SWAP_CLUSTER_MAX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0scan =3D div64_u64(scan * fraction[file], denominator);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If zone is sma=
ll or memcg is small, nr[l] can be 0.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* This results n=
o-scan on this priority and priority drop down.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* For global dir=
ect reclaim, it can visit next zone and tend
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* not to have pr=
oblems. For global kswapd, it's for zone
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* balancing and =
it need to scan a small amounts. When using
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* memcg, priorit=
y drop can cause big latency. So, it's better
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* to scan small =
amount. See may_noscan above.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/

Please move this comment with tidy-up at where making force_scan true.
Of course, we can find it by git log[246e87a9393] but as I looked the
git log, it explain this comment indirectly and it's not
understandable to newbies. I think this comment is more understandable
than changelog in git.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
