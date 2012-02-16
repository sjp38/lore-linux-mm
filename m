Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 41F176B0082
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:01:44 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so3088607pbc.14
        for <linux-mm@kvack.org>; Thu, 16 Feb 2012 05:01:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1202021726410.31915@eggly.anvils>
References: <CAJd=RBANeF+TTTtn=F_Yx3N5KkVb5vFPY6FNYEjVntB1pPSLBA@mail.gmail.com>
	<CAJd=RBAH4+nFQ35JcHju6eSPfDcQpbkJjMX6GBaZFECVaL2swA@mail.gmail.com>
	<20120116092745.7721ff31.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1202021726410.31915@eggly.anvils>
Date: Thu, 16 Feb 2012 21:01:43 +0800
Message-ID: <CAJd=RBCpE9TUDwr17sGc2mg_xfyCCktAyxSt1v3Tzj6dCNL0eA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: handle isolated pages with lru lock released
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 3, 2012 at 9:40 AM, Hugh Dickins <hughd@google.com> wrote:
> From: Hillf Danton <dhillf@gmail.com>
>
> When shrinking inactive lru list, isolated pages are queued on locally pr=
ivate
> list, so the lock-hold time could be reduced if pages are counted without=
 lock
> protection.
>
> To achieve that, firstly updating reclaim stat is delayed until the
> putback stage, after reacquiring the lru lock.
>
> Secondly, operations related to vm and zone stats are now proteced with
> preemption disabled as they are per-cpu operations.
>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> KAMEZAWA-san and I both admired this patch from Hillf; Rik and David
> liked its precursor: I think we'd all be glad to see it in linux-next.
>
> =C2=A0mm/vmscan.c | =C2=A0 21 ++++++++++-----------
> =C2=A01 file changed, 10 insertions(+), 11 deletions(-)
>
> --- a/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Sat Jan 14 14:02:20 2012
> +++ b/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Sat Jan 14 20:00:46 2012
> @@ -1414,7 +1414,6 @@ update_isolated_counts(struct mem_cgroup
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 unsigned long *nr_anon,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 unsigned long *nr_file)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct zone_reclaim_stat *reclaim_stat =3D get_rec=
laim_stat(mz);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D mz->zone;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int count[NR_LRU_LISTS] =3D { 0, };
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_active =3D 0;
> @@ -1435,6 +1434,7 @@ update_isolated_counts(struct mem_cgroup
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count[lru] +=3D nu=
mpages;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 preempt_disable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_vm_events(PGDEACTIVATE, nr_active);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_ACTIVE_FILE,
> @@ -1449,8 +1449,9 @@ update_isolated_counts(struct mem_cgroup
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*nr_anon =3D count[LRU_ACTIVE_ANON] + count[LR=
U_INACTIVE_ANON];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*nr_file =3D count[LRU_ACTIVE_FILE] + count[LR=
U_INACTIVE_FILE];
>
> - =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[0] +=3D *nr_anon;
> - =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[1] +=3D *nr_file;
> + =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_=
anon);
> + =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_=
file);
> + =C2=A0 =C2=A0 =C2=A0 preempt_enable();
> =C2=A0}
>
> =C2=A0/*
> @@ -1512,6 +1513,7 @@ shrink_inactive_list(unsigned long nr_to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_writeback =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0isolate_mode_t reclaim_mode =3D ISOLATE_INACTI=
VE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D mz->zone;
> + =C2=A0 =C2=A0 =C2=A0 struct zone_reclaim_stat *reclaim_stat =3D get_rec=
laim_stat(mz);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (unlikely(too_many_isolated(zone, file, =
sc))) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0congestion_wait(BL=
K_RW_ASYNC, HZ/10);
> @@ -1546,19 +1548,13 @@ shrink_inactive_list(unsigned long nr_to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0__count_zone_vm_events(PGSCAN_DIRECT, zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 nr_scanned);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_lock);
>
> - =C2=A0 =C2=A0 =C2=A0 if (nr_taken =3D=3D 0) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone-=
>lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (nr_taken =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> - =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0update_isolated_counts(mz, &page_list, &nr_ano=
n, &nr_file);
>
> - =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_a=
non);
> - =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_f=
ile);
> -
> - =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_lock);
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed =3D shrink_page_list(&page_list, =
mz, sc, priority,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0&nr_dirty, &nr_writeback);
>
> @@ -1570,6 +1566,9 @@ shrink_inactive_list(unsigned long nr_to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&zone->lru_lock);
> +
> + =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[0] +=3D nr_anon;
> + =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[1] +=3D nr_file;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (current_is_kswapd())
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_vm_events(=
KSWAPD_STEAL, nr_reclaimed);

Hi Andrew

Please consider adding this patch to -mm tree.

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
