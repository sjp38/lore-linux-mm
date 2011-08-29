Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0B530900138
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 03:16:03 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p7T7FxaP018481
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:15:59 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by wpaz37.hot.corp.google.com with ESMTP id p7T7Fv7b031838
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:15:57 -0700
Received: by qwf7 with SMTP id 7so3089589qwf.38
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:15:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110811210914.GB31229@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
	<20110811210914.GB31229@cmpxchg.org>
Date: Mon, 29 Aug 2011 00:15:57 -0700
Message-ID: <CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Thu, Aug 11, 2011 at 2:09 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
>
> On Thu, Aug 11, 2011 at 01:39:45PM -0700, Ying Han wrote:
> > Please consider including the following patch for the next post. It cau=
ses
> > crash on some of the tests where sc->mem_cgroup is NULL (global kswapd)=
.
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index b72a844..12ab25d 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2768,7 +2768,8 @@ loop_again:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do some background=
 aging of the anon list, to
> > give
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages a chance to =
be referenced before
> > reclaiming.
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inactive_anon_is_low(=
zone, &sc))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scanning_global_lru(&=
sc) &&
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 inactive_anon_is_low(zone, &sc))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_=
active_list(SWAP_CLUSTER_MAX, zone,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &sc, priority, 0);
>
> Thanks! =A0I completely overlooked this one and only noticed it after
> changing the arguments to shrink_active_list().
>
> On memcg configurations, scanning_global_lru() will essentially never
> be true again, so I moved the anon pre-aging to a separate function
> that also does a hierarchy loop to preage the per-memcg anon lists.
>
> I hope to send out the next revision soon.

Also, please consider to fold in the following patch as well. It fixes
the root cgroup lru accounting and we could easily trigger OOM while
doing some swapoff test w/o it.

mm:fix the lru accounting for root cgroup.

This patch is applied on top of:
"
mm: memcg-aware global reclaim
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
"

This patch fixes the lru accounting for root cgroup.

After the "memcg-aware global reclaim" patch, one of the changes is to have
lru pages linked back to root. Under the global memory pressure, we start f=
rom
the root cgroup lru and walk through the memcg hierarchy of the system. For
each memcg, we reclaim pages based on the its lru size.

However for root cgroup, we used not having a seperate lru and only countin=
g
the pages charged to root as part of root lru size. Without this patch, all
the pages which are linked to root lru but not charged to root like swapcac=
he
readahead are not visible to page reclaim code and we are easily to get OOM=
.

After this patch, all the pages linked under root lru are counted in the lr=
u
size, including Used and !Used.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Ying Han <yinghan@google.com>

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5518f54..f6c5f29 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *page,
enum lru_list lru)
 {
 >------struct page_cgroup *pc;
 >------struct mem_cgroup_per_zone *mz;
+>------struct mem_cgroup *mem;
=B7
 >------if (mem_cgroup_disabled())
 >------>-------return;
 >------pc =3D lookup_page_cgroup(page);
->------/* can happen while we handle swapcache. */
->------if (!TestClearPageCgroupAcctLRU(pc))
->------>-------return;
->------VM_BUG_ON(!pc->mem_cgroup);
->------/*
->------ * We don't check PCG_USED bit. It's cleared when the "page" is fin=
ally
->------ * removed from global LRU.
->------ */
->------mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
+
+>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {
+>------>-------VM_BUG_ON(!pc->mem_cgroup);
+>------>-------mem =3D pc->mem_cgroup;
+>------} else {
+>------>-------/* can happen while we handle swapcache. */
+>------>-------mem =3D root_mem_cgroup;
+>------}
+
+>------mz =3D page_cgroup_zoneinfo(mem, page);
 >------MEM_CGROUP_ZSTAT(mz, lru) -=3D 1;
 >------VM_BUG_ON(list_empty(&pc->lru));
 >------list_del_init(&pc->lru);
@@ -961,22 +963,31 @@ void mem_cgroup_add_lru_list(struct page *page,
enum lru_list lru)
 {
 >------struct page_cgroup *pc;
 >------struct mem_cgroup_per_zone *mz;
+>------struct mem_cgroup *mem;
=B7
 >------if (mem_cgroup_disabled())
 >------>-------return;
 >------pc =3D lookup_page_cgroup(page);
 >------VM_BUG_ON(PageCgroupAcctLRU(pc));
->------/*
->------ * Used bit is set without atomic ops but after smp_wmb().
->------ * For making pc->mem_cgroup visible, insert smp_rmb() here.
->------ */
->------smp_rmb();
->------if (!PageCgroupUsed(pc))
->------>-------return;
=B7
->------mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
+>------if (PageCgroupUsed(pc)) {
+>------>-------/* Ensure pc->mem_cgroup is visible after reading PCG_USED.=
 */
+>------>-------smp_rmb();
+>------>-------mem =3D pc->mem_cgroup;
+>------>-------SetPageCgroupAcctLRU(pc);
+>------} else {
+>------>-------/*
+>------>------- * If the page is no longer charged, add it to the
+>------>------- * root memcg's lru.  Either it will be freed soon, or
+>------>------- * it will get charged again and the charger will
+>------>------- * relink it to the right list.
+>------>-------mem =3D root_mem_cgroup;
+>------}
+
+>------mz =3D page_cgroup_zoneinfo(mem, page);
 >------MEM_CGROUP_ZSTAT(mz, lru) +=3D 1;
->------SetPageCgroupAcctLRU(pc);
+
 >------list_add(&pc->lru, &mz->lists[lru]);
 }

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
