Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F8F56B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 08:13:56 -0400 (EDT)
Received: by gxk12 with SMTP id 12so6947218gxk.4
        for <linux-mm@kvack.org>; Thu, 20 Aug 2009 05:13:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090820114933.GB7359@localhost>
References: <20090820024929.GA19793@localhost>
	 <20090820121347.8a886e4b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090820040533.GA27540@localhost>
	 <28c262360908200401t41c03ad3n114b24e03b61de08@mail.gmail.com>
	 <20090820114933.GB7359@localhost>
Date: Thu, 20 Aug 2009 21:13:59 +0900
Message-ID: <28c262360908200513y3fee675do4e1f0204ffb8df63@mail.gmail.com>
Subject: Re: [PATCH -v2] mm: do batched scans for mem_cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 20, 2009 at 8:49 PM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Thu, Aug 20, 2009 at 07:01:21PM +0800, Minchan Kim wrote:
>> Hi, Wu.
>>
>> On Thu, Aug 20, 2009 at 1:05 PM, Wu Fengguang<fengguang.wu@intel.com> wr=
ote:
>> > On Thu, Aug 20, 2009 at 11:13:47AM +0800, KAMEZAWA Hiroyuki wrote:
>> >> On Thu, 20 Aug 2009 10:49:29 +0800
>> >> Wu Fengguang <fengguang.wu@intel.com> wrote:
>> >>
>> >> > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_sca=
n=3D1,
>> >> > in which case shrink_list() _still_ calls isolate_pages() with the =
much
>> >> > larger SWAP_CLUSTER_MAX. =C2=A0It effectively scales up the inactiv=
e list
>> >> > scan rate by up to 32 times.
>> >> >
>> >> > For example, with 16k inactive pages and DEF_PRIORITY=3D12, (16k >>=
 12)=3D4.
>> >> > So when shrink_zone() expects to scan 4 pages in the active/inactiv=
e
>> >> > list, it will be scanned SWAP_CLUSTER_MAX=3D32 pages in effect.
>> >> >
>> >> > The accesses to nr_saved_scan are not lock protected and so not 100=
%
>> >> > accurate, however we can tolerate small errors and the resulted sma=
ll
>> >> > imbalanced scan rates between zones.
>> >> >
>> >> > This batching won't blur up the cgroup limits, since it is driven b=
y
>> >> > "pages reclaimed" rather than "pages scanned". When shrink_zone()
>> >> > decides to cancel (and save) one smallish scan, it may well be call=
ed
>> >> > again to accumulate up nr_saved_scan.
>> >> >
>> >> > It could possibly be a problem for some tiny mem_cgroup (which may =
be
>> >> > _full_ scanned too much times in order to accumulate up nr_saved_sc=
an).
>> >> >
>> >> > CC: Rik van Riel <riel@redhat.com>
>> >> > CC: Minchan Kim <minchan.kim@gmail.com>
>> >> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
>> >> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>> >> > ---
>> >>
>> >> Hmm, how about this ?
>> >> =3D=3D
>> >> Now, nr_saved_scan is tied to zone's LRU.
>> >> But, considering how vmscan works, it should be tied to reclaim_stat.
>> >>
>> >> By this, memcg can make use of nr_saved_scan information seamlessly.
>> >
>> > Good idea, full patch updated with your signed-off-by :)
>> >
>> > Thanks,
>> > Fengguang
>> > ---
>> > mm: do batched scans for mem_cgroup
>> >
>> > For mem_cgroup, shrink_zone() may call shrink_list() with nr_to_scan=
=3D1,
>> > in which case shrink_list() _still_ calls isolate_pages() with the muc=
h
>> > larger SWAP_CLUSTER_MAX. =C2=A0It effectively scales up the inactive l=
ist
>> > scan rate by up to 32 times.
>>
>> Yes. It can scan 32 times pages in only inactive list, not active list.
>
> Yes and no ;)
>
> inactive anon list over scanned =3D> inactive_anon_is_low() =3D=3D TRUE
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D> shrink_active_list()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D> active anon list over scanned

Why inactive anon list is overscanned in case mem_cgroup ?

in shrink_zone,
1) The vm doesn't accumulate nr[l].
2) Below routine store min value to nr_to_scan.
nr_to_scan =3D min(nr[l], swap_cluster_max);
ex) if nr[l] =3D 4, vm calls shrink_active_list with 4 as nr_to_scan.
So I think overscan doesn't occur in active list.

> So the end result may be
>
> - anon inactive =C2=A0=3D> over scanned
> - anon active =C2=A0 =C2=A0=3D> over scanned (maybe not as much)
> - file inactive =C2=A0=3D> over scanned
> - file active =C2=A0 =C2=A0=3D> under scanned (relatively)
>
>> > For example, with 16k inactive pages and DEF_PRIORITY=3D12, (16k >> 12=
)=3D4.
>> > So when shrink_zone() expects to scan 4 pages in the active/inactive
>> > list, it will be scanned SWAP_CLUSTER_MAX=3D32 pages in effect.
>>
>> Active list scan would be scanned in 4, =C2=A0inactive list =C2=A0is 32.
>
> Exactly.
>
>> >
>> > The accesses to nr_saved_scan are not lock protected and so not 100%
>> > accurate, however we can tolerate small errors and the resulted small
>> > imbalanced scan rates between zones.
>>
>> Yes.
>>
>> > This batching won't blur up the cgroup limits, since it is driven by
>> > "pages reclaimed" rather than "pages scanned". When shrink_zone()
>> > decides to cancel (and save) one smallish scan, it may well be called
>> > again to accumulate up nr_saved_scan.
>>
>> You mean nr_scan_try_batch logic ?
>> But that logic works for just global reclaim?
>> Now am I missing something?
>>
>> Could you elaborate more? :)
>
> Sorry for the confusion. The above paragraph originates from Balbir's
> concern:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This might be a concern (although not a big AT=
M), since we can't
> =C2=A0 =C2=A0 =C2=A0 =C2=A0afford to miss limits by much. If a cgroup is =
near its limit and we
> =C2=A0 =C2=A0 =C2=A0 =C2=A0drop scanning it. We'll have to work out what =
this means for the end

Why does mem_cgroup drops scanning ?
It's because nr_scan_try_batch? or something ?

Sorry. Still, I can't understand your point. :(

> =C2=A0 =C2=A0 =C2=A0 =C2=A0user. May be more fundamental look through is =
required at the priority
> =C2=A0 =C2=A0 =C2=A0 =C2=A0based logic of exposing how much to scan, I do=
n't know.
>
> Thanks,
> Fengguang
>
>> > It could possibly be a problem for some tiny mem_cgroup (which may be
>> > _full_ scanned too much times in order to accumulate up nr_saved_scan)=
.
>> >
>> > CC: Rik van Riel <riel@redhat.com>
>> > CC: Minchan Kim <minchan.kim@gmail.com>
>> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
>> > CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>> > ---
>> > =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A06 +++++-
>> > =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
>> > =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 20=
 +++++++++++---------
>> > =C2=A03 files changed, 17 insertions(+), 11 deletions(-)
>> >
>> > --- linux.orig/include/linux/mmzone.h =C2=A0 2009-07-30 10:45:15.00000=
0000 +0800
>> > +++ linux/include/linux/mmzone.h =C2=A0 =C2=A0 =C2=A0 =C2=A02009-08-20=
 11:51:08.000000000 +0800
>> > @@ -269,6 +269,11 @@ struct zone_reclaim_stat {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 recent_rotated[2];
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 recent_scanned[2];
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* accumulated for batching
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 nr_saved_scan[NR_LRU_LISTS];
>> > =C2=A0};
>> >
>> > =C2=A0struct zone {
>> > @@ -323,7 +328,6 @@ struct zone {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0lru_lock;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone_lru {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_hea=
d list;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long nr_sa=
ved_scan; =C2=A0 =C2=A0/* accumulated for batching */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0} lru[NR_LRU_LISTS];
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone_reclaim_stat reclaim_stat;
>> > --- linux.orig/mm/vmscan.c =C2=A0 =C2=A0 =C2=A02009-08-20 11:48:46.000=
000000 +0800
>> > +++ linux/mm/vmscan.c =C2=A0 2009-08-20 12:00:55.000000000 +0800
>> > @@ -1521,6 +1521,7 @@ static void shrink_zone(int priority, st
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0enum lru_list l;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed =3D sc->nr_recla=
imed;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long swap_cluster_max =3D sc->swap=
_cluster_max;
>> > + =C2=A0 =C2=A0 =C2=A0 struct zone_reclaim_stat *reclaim_stat =3D get_=
reclaim_stat(zone, sc);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int noswap =3D 0;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If we have no swap space, do not bother =
scanning anon pages. */
>> > @@ -1540,12 +1541,9 @@ static void shrink_zone(int priority, st
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0scan >>=3D priority;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0scan =3D (scan * percent[file]) / 100;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (scanning_global=
_lru(sc))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nr[l] =3D nr_scan_try_batch(scan,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 &zone->lru[l].nr_saved_scan,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 swap_cluster_max);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nr[l] =3D scan;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr[l] =3D nr_scan_t=
ry_batch(scan,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &=
reclaim_stat->nr_saved_scan[l],
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
wap_cluster_max);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTI=
VE_FILE] ||
>> > @@ -2128,6 +2126,7 @@ static void shrink_all_zones(unsigned lo
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed =3D 0;
>> > + =C2=A0 =C2=A0 =C2=A0 struct zone_reclaim_stat *reclaim_stat;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_populated_zone(zone) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0enum lru_list l=
;
>> > @@ -2144,11 +2143,14 @@ static void shrink_all_zones(unsigned lo
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0l =3D=3D LRU_ACTIVE_FILE))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 zone->lru[l].nr_saved_scan +=3D (lru_pages >> prio) + 1;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (zone->lru[l].nr_saved_scan >=3D nr_pages || pass > 3) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 reclaim_stat =3D get_reclaim_stat(zone, sc);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 reclaim_stat->nr_saved_scan[l] +=3D
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 (lru_pages >> prio) + 1;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (reclaim_stat->nr_saved_scan[l]
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 >=3D nr_pages || pass > 3) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_to_scan;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->lru[l].nr_saved_scan =3D 0;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 reclaim_stat->nr_saved_scan[l] =3D 0=
;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_to_scan =3D min(nr_pages, lru_p=
ages);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed +=3D shrink_list(l, n=
r_to_scan, zone,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0sc, prio);
>> > --- linux.orig/mm/page_alloc.c =C2=A02009-08-20 11:57:54.000000000 +08=
00
>> > +++ linux/mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 2009-08-20 11:58:39.000=
000000 +0800
>> > @@ -3716,7 +3716,7 @@ static void __paginginit free_area_init_
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_pcp_init(z=
one);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_lru(l)=
 {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0INIT_LIST_HEAD(&zone->lru[l].list);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 zone->lru[l].nr_saved_scan =3D 0;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 zone->reclaim_stat.nr_saved_scan[l] =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->reclaim_s=
tat.recent_rotated[0] =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->reclaim_s=
tat.recent_rotated[1] =3D 0;
>> >
>> > --
>> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> > the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
>> > see: http://www.linux-mm.org/ .
>> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>>
>>
>>
>> --
>> Kind regards,
>> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
