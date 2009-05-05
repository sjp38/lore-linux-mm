Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0257B6B003D
	for <linux-mm@kvack.org>; Mon,  4 May 2009 22:45:28 -0400 (EDT)
Received: by gxk20 with SMTP id 20so7973527gxk.14
        for <linux-mm@kvack.org>; Mon, 04 May 2009 19:46:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090504234455.GA6324@localhost>
References: <20090504234455.GA6324@localhost>
Date: Tue, 5 May 2009 11:46:10 +0900
Message-ID: <44c63dc40905041946g1b1ea5cah21b5c2882ecd90fd@mail.gmail.com>
Subject: Re: [PATCH] vmscan: ZVC updates in shrink_active_list() can be done
	once
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

This fine-grained ZVC update in shrink_active_list was made for
determination problem of the dirty
ratio(c878538598d1e7ab41ecc0de8894e34e2fdef630).
The 32 page reclaim time in normal reclaim situation is too short to
change current VM behavior.
So I think this make sense to me.

On Tue, May 5, 2009 at 8:44 AM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> This effectively lifts the unit of nr_inactive_* and pgdeactivate updates
> from PAGEVEC_SIZE=3D14 to SWAP_CLUSTER_MAX=3D32.
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 11 +++--------
> =C2=A01 file changed, 3 insertions(+), 8 deletions(-)
>
> --- linux.orig/mm/vmscan.c
> +++ linux/mm/vmscan.c
> @@ -1228,7 +1228,6 @@ static void shrink_active_list(unsigned
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct scan_control *sc, int priority, int file)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pgmoved;
> - =C2=A0 =C2=A0 =C2=A0 int pgdeactivate =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pgscanned;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LIST_HEAD(l_hold); =C2=A0 =C2=A0 =C2=A0/* The =
pages which were snipped off */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LIST_HEAD(l_inactive);
> @@ -1257,7 +1256,7 @@ static void shrink_active_list(unsigned
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_st=
ate(zone, NR_ACTIVE_ANON, -pgmoved);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
>
> - =C2=A0 =C2=A0 =C2=A0 pgmoved =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 pgmoved =3D 0; =C2=A0/* count referenced (mapping)=
 mapped pages */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (!list_empty(&l_hold)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resched();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D lru_to_pa=
ge(&l_hold);
> @@ -1291,7 +1290,7 @@ static void shrink_active_list(unsigned
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_stat->recent_rotated[!!file] +=3D pgmo=
ved;
>
> - =C2=A0 =C2=A0 =C2=A0 pgmoved =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 pgmoved =3D 0; =C2=A0/* count pages moved to inact=
ive list */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (!list_empty(&l_inactive)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D lru_to_pa=
ge(&l_inactive);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prefetchw_prev_lru=
_page(page, &l_inactive, flags);
> @@ -1304,10 +1303,7 @@ static void shrink_active_list(unsigned
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_add_lru=
_list(page, lru);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgmoved++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pagevec_add(&=
pvec, page)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pgdeactivate +=3D pgmoved;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pgmoved =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (buffer_heads_over_limit)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pagevec_strip(&pvec);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__pagevec_release(&pvec);
> @@ -1315,9 +1311,8 @@ static void shrink_active_list(unsigned
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_LRU_BASE + lru,=
 pgmoved);
> - =C2=A0 =C2=A0 =C2=A0 pgdeactivate +=3D pgmoved;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_zone_vm_events(PGREFILL, zone, pgscann=
ed);
> - =C2=A0 =C2=A0 =C2=A0 __count_vm_events(PGDEACTIVATE, pgdeactivate);
> + =C2=A0 =C2=A0 =C2=A0 __count_vm_events(PGDEACTIVATE, pgmoved);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (buffer_heads_over_limit)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pagevec_strip(&pve=
c);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Thanks,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
