Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 76D5C6B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 07:05:13 -0500 (EST)
Received: by wera13 with SMTP id a13so1307077wer.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 04:05:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBANeF+TTTtn=F_Yx3N5KkVb5vFPY6FNYEjVntB1pPSLBA@mail.gmail.com>
References: <CAJd=RBANeF+TTTtn=F_Yx3N5KkVb5vFPY6FNYEjVntB1pPSLBA@mail.gmail.com>
Date: Sat, 14 Jan 2012 20:05:11 +0800
Message-ID: <CAJd=RBAH4+nFQ35JcHju6eSPfDcQpbkJjMX6GBaZFECVaL2swA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: handle isolated pages with lru lock released
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

On Fri, Jan 13, 2012 at 11:00 PM, Hillf Danton <dhillf@gmail.com> wrote:
> When shrinking inactive lru list, isolated pages are queued on locally pr=
ivate
> list, which opens a window for pulling update_isolated_counts() out of th=
e lock
> protection to reduce the lock-hold time.
>
> To achive that, firstly we have to delay updating reclaim stat, which is =
pointed
> out by Hugh, but not over the deadline where fresh data is used for setti=
ng up
> scan budget for shrinking zone in get_scan_count(). The delay is terminat=
ed in
> the putback stage after reacquiring lru lock.
>
> Secondly operations related to vm and zone stats, namely __count_vm_event=
s() and
> __mod_zone_page_state(), are proteced with preemption disabled as they
> are per-cpu
> operations.
>
> Thanks for comments and ideas recieved.
>
>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
>
> --- a/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Fri Jan 13 21:30:58 2012
> +++ b/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Fri Jan 13 22:07:14 2012
> @@ -1408,6 +1408,13 @@ putback_lru_pages(struct mem_cgroup_zone
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Put back any unfreeable pages.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Here we finish updating reclaim stat that =
is delayed in
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* update_isolated_counts()
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[0] +=3D nr_anon;
> + =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[1] +=3D nr_file;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (!list_empty(page_list)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int lru;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D lru_to_pa=
ge(page_list);
> @@ -1461,9 +1468,19 @@ update_isolated_counts(struct mem_cgroup
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_active;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D mz->zone;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int count[NR_LRU_LISTS] =3D { 0, };
> - =C2=A0 =C2=A0 =C2=A0 struct zone_reclaim_stat *reclaim_stat =3D get_rec=
laim_stat(mz);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_active =3D clear_active_flags(isolated_list=
, count);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Without lru lock held,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* 1, we have to delay updating zone reclaim =
stat, and the deadline is
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0when fresh data is used for s=
etting up scan budget for another
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0round shrinking, see get_scan=
_count(). It is actually updated in
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0the putback stage after reacq=
uiring the lock.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* 2, __count_vm_events() and __mod_zone_page=
_state() are protected
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0with preempt disabled as they=
 are per-cpu operations.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 preempt_disable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_vm_events(PGDEACTIVATE, nr_active);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_ACTIVE_FILE,
> @@ -1479,9 +1496,7 @@ update_isolated_counts(struct mem_cgroup
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*nr_file =3D count[LRU_ACTIVE_FILE] + count[LR=
U_INACTIVE_FILE];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_ISOLATED_ANON, =
*nr_anon);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_page_state(zone, NR_ISOLATED_FILE, =
*nr_file);
> -
> - =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[0] +=3D *nr_anon;
> - =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[1] +=3D *nr_file;
> + =C2=A0 =C2=A0 =C2=A0 preempt_enable();
> =C2=A0}
>
> =C2=A0/*
> @@ -1577,15 +1592,12 @@ shrink_inactive_list(unsigned long nr_to
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
> =C2=A0 =C2=A0 =C2=A0 =C2=A0update_isolated_counts(mz, sc, &nr_anon, &nr_f=
ile, &page_list);
> -
> - =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed =3D shrink_page_list(&page_list, =
mz, sc, priority,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0&nr_dirty, &nr_writeback);


Hi all

It is re-prepared based on the mainline for easy review.

Thanks
Hillf


=3D=3D=3Dcut here=3D=3D=3D
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: vmscan: handle isolated pages with lru lock released

When shrinking inactive lru list, isolated pages are queued on locally priv=
ate
list, so the lock-hold time could be reduced if pages are counted without l=
ock
protection. To achive that, firstly updating reclaim stat is delayed until =
the
putback stage, which is pointed out by Hugh, after reacquiring the lru lock=
.

Secondly operations related to vm and zone stats, are now proteced with
preemption disabled as they are per-cpu operation.

Thanks for comments and ideas received.


Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Sat Jan 14 14:02:20 2012
+++ b/mm/vmscan.c	Sat Jan 14 20:00:46 2012
@@ -1414,7 +1414,6 @@ update_isolated_counts(struct mem_cgroup
 		       unsigned long *nr_anon,
 		       unsigned long *nr_file)
 {
-	struct zone_reclaim_stat *reclaim_stat =3D get_reclaim_stat(mz);
 	struct zone *zone =3D mz->zone;
 	unsigned int count[NR_LRU_LISTS] =3D { 0, };
 	unsigned long nr_active =3D 0;
@@ -1435,6 +1434,7 @@ update_isolated_counts(struct mem_cgroup
 		count[lru] +=3D numpages;
 	}

+	preempt_disable();
 	__count_vm_events(PGDEACTIVATE, nr_active);

 	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
@@ -1449,8 +1449,9 @@ update_isolated_counts(struct mem_cgroup
 	*nr_anon =3D count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
 	*nr_file =3D count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];

-	reclaim_stat->recent_scanned[0] +=3D *nr_anon;
-	reclaim_stat->recent_scanned[1] +=3D *nr_file;
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
+	preempt_enable();
 }

 /*
@@ -1512,6 +1513,7 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_writeback =3D 0;
 	isolate_mode_t reclaim_mode =3D ISOLATE_INACTIVE;
 	struct zone *zone =3D mz->zone;
+	struct zone_reclaim_stat *reclaim_stat =3D get_reclaim_stat(mz);

 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1546,19 +1548,13 @@ shrink_inactive_list(unsigned long nr_to
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
 	}
+	spin_unlock_irq(&zone->lru_lock);

-	if (nr_taken =3D=3D 0) {
-		spin_unlock_irq(&zone->lru_lock);
+	if (nr_taken =3D=3D 0)
 		return 0;
-	}

 	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);

-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
-
-	spin_unlock_irq(&zone->lru_lock);
-
 	nr_reclaimed =3D shrink_page_list(&page_list, mz, sc, priority,
 						&nr_dirty, &nr_writeback);

@@ -1570,6 +1566,9 @@ shrink_inactive_list(unsigned long nr_to
 	}

 	spin_lock_irq(&zone->lru_lock);
+
+	reclaim_stat->recent_scanned[0] +=3D nr_anon;
+	reclaim_stat->recent_scanned[1] +=3D nr_file;

 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
