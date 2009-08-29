Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 04F8E6B004D
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 06:00:48 -0400 (EDT)
Received: by ywh33 with SMTP id 33so3871383ywh.18
        for <linux-mm@kvack.org>; Sat, 29 Aug 2009 03:00:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
References: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
Date: Sat, 29 Aug 2009 19:00:47 +0900
Message-ID: <2f11576a0908290300h155596e1y730c355ade7a671e@mail.gmail.com>
Subject: Re: [PATCH mmotm] vmscan move pgdeactivate modification to
	shrink_active_list fix
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh

2009/8/29 Hugh Dickins <hugh.dickins@tiscali.co.uk>:
> mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
> quicker than last time: one bug fixed but another bug introduced.
> vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
> forgot to add NR_LRU_BASE to lru index to make zone_page_state index.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Can I use your test case?
Currently LRU_BASE is 0. it mean

LRU_BASE =3D=3D NR_INACTIVE_ANON =3D=3D 0
LRU_ACTIVE =3D=3D NR_ACTIVE_ANON =3D=3D 1

Therefore, I doubt there are another issue in current mmotm.
Can I join your strange oom fixing works?


> ---
>
> =A0mm/vmscan.c | =A0 =A06 ++++--
> =A01 file changed, 4 insertions(+), 2 deletions(-)
>
> --- mmotm/mm/vmscan.c =A0 2009-08-28 10:07:57.000000000 +0100
> +++ linux/mm/vmscan.c =A0 2009-08-28 18:30:33.000000000 +0100
> @@ -1381,8 +1381,10 @@ static void shrink_active_list(unsigned
> =A0 =A0 =A0 =A0reclaim_stat->recent_rotated[file] +=3D nr_rotated;
> =A0 =A0 =A0 =A0__count_vm_events(PGDEACTIVATE, nr_deactivated);
> =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_t=
aken);
> - =A0 =A0 =A0 __mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, n=
r_rotated);
> - =A0 =A0 =A0 __mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_=
deactivated);
> + =A0 =A0 =A0 __mod_zone_page_state(zone, NR_ACTIVE_ANON + file * LRU_FIL=
E,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_rotated);
> + =A0 =A0 =A0 __mod_zone_page_state(zone, NR_INACTIVE_ANON + file * LRU_F=
ILE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_deactivated);
> =A0 =A0 =A0 =A0spin_unlock_irq(&zone->lru_lock);
> =A0}
>
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
