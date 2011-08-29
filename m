Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7E572900138
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 03:22:13 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p7T7M4N3000578
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:22:05 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz37.hot.corp.google.com with ESMTP id p7T7M36I005457
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:22:03 -0700
Received: by qwc9 with SMTP id 9so5096591qwc.27
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 00:22:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
	<20110811210914.GB31229@cmpxchg.org>
	<CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
Date: Mon, 29 Aug 2011 00:22:02 -0700
Message-ID: <CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 12:15 AM, Ying Han <yinghan@google.com> wrote:
> On Thu, Aug 11, 2011 at 2:09 PM, Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>>
>> On Thu, Aug 11, 2011 at 01:39:45PM -0700, Ying Han wrote:
>> > Please consider including the following patch for the next post. It ca=
uses
>> > crash on some of the tests where sc->mem_cgroup is NULL (global kswapd=
).
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index b72a844..12ab25d 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2768,7 +2768,8 @@ loop_again:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do some backgroun=
d aging of the anon list, to
>> > give
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages a chance to=
 be referenced before
>> > reclaiming.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inactive_anon_is_low=
(zone, &sc))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scanning_global_lru(=
&sc) &&
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 inactive_anon_is_low(zone, &sc))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink=
_active_list(SWAP_CLUSTER_MAX, zone,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &sc, priority, 0);
>>
>> Thanks! =A0I completely overlooked this one and only noticed it after
>> changing the arguments to shrink_active_list().
>>
>> On memcg configurations, scanning_global_lru() will essentially never
>> be true again, so I moved the anon pre-aging to a separate function
>> that also does a hierarchy loop to preage the per-memcg anon lists.
>>
>> I hope to send out the next revision soon.
>
> Also, please consider to fold in the following patch as well. It fixes
> the root cgroup lru accounting and we could easily trigger OOM while
> doing some swapoff test w/o it.
>
> mm:fix the lru accounting for root cgroup.
>
> This patch is applied on top of:
> "
> mm: memcg-aware global reclaim
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> "
>
> This patch fixes the lru accounting for root cgroup.
>
> After the "memcg-aware global reclaim" patch, one of the changes is to ha=
ve
> lru pages linked back to root. Under the global memory pressure, we start=
 from
> the root cgroup lru and walk through the memcg hierarchy of the system. F=
or
> each memcg, we reclaim pages based on the its lru size.
>
> However for root cgroup, we used not having a seperate lru and only count=
ing
> the pages charged to root as part of root lru size. Without this patch, a=
ll
> the pages which are linked to root lru but not charged to root like swapc=
ache
> readahead are not visible to page reclaim code and we are easily to get O=
OM.
>
> After this patch, all the pages linked under root lru are counted in the =
lru
> size, including Used and !Used.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Ying Han <yinghan@google.com>
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5518f54..f6c5f29 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *page,
> enum lru_list lru)
> =A0{
> =A0>------struct page_cgroup *pc;
> =A0>------struct mem_cgroup_per_zone *mz;
> +>------struct mem_cgroup *mem;
> =B7
> =A0>------if (mem_cgroup_disabled())
> =A0>------>-------return;
> =A0>------pc =3D lookup_page_cgroup(page);
> ->------/* can happen while we handle swapcache. */
> ->------if (!TestClearPageCgroupAcctLRU(pc))
> ->------>-------return;
> ->------VM_BUG_ON(!pc->mem_cgroup);
> ->------/*
> ->------ * We don't check PCG_USED bit. It's cleared when the "page" is f=
inally
> ->------ * removed from global LRU.
> ->------ */
> ->------mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> +
> +>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {
> +>------>-------VM_BUG_ON(!pc->mem_cgroup);
> +>------>-------mem =3D pc->mem_cgroup;
> +>------} else {
> +>------>-------/* can happen while we handle swapcache. */
> +>------>-------mem =3D root_mem_cgroup;
> +>------}
> +
> +>------mz =3D page_cgroup_zoneinfo(mem, page);
> =A0>------MEM_CGROUP_ZSTAT(mz, lru) -=3D 1;
> =A0>------VM_BUG_ON(list_empty(&pc->lru));
> =A0>------list_del_init(&pc->lru);
> @@ -961,22 +963,31 @@ void mem_cgroup_add_lru_list(struct page *page,
> enum lru_list lru)
> =A0{
> =A0>------struct page_cgroup *pc;
> =A0>------struct mem_cgroup_per_zone *mz;
> +>------struct mem_cgroup *mem;
> =B7
> =A0>------if (mem_cgroup_disabled())
> =A0>------>-------return;
> =A0>------pc =3D lookup_page_cgroup(page);
> =A0>------VM_BUG_ON(PageCgroupAcctLRU(pc));
> ->------/*
> ->------ * Used bit is set without atomic ops but after smp_wmb().
> ->------ * For making pc->mem_cgroup visible, insert smp_rmb() here.
> ->------ */
> ->------smp_rmb();
> ->------if (!PageCgroupUsed(pc))
> ->------>-------return;
> =B7
> ->------mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> +>------if (PageCgroupUsed(pc)) {
> +>------>-------/* Ensure pc->mem_cgroup is visible after reading PCG_USE=
D. */
> +>------>-------smp_rmb();
> +>------>-------mem =3D pc->mem_cgroup;
> +>------>-------SetPageCgroupAcctLRU(pc);
> +>------} else {
> +>------>-------/*
> +>------>------- * If the page is no longer charged, add it to the
> +>------>------- * root memcg's lru. =A0Either it will be freed soon, or
> +>------>------- * it will get charged again and the charger will
> +>------>------- * relink it to the right list.
> +>------>-------mem =3D root_mem_cgroup;
> +>------}
> +
> +>------mz =3D page_cgroup_zoneinfo(mem, page);
> =A0>------MEM_CGROUP_ZSTAT(mz, lru) +=3D 1;
> ->------SetPageCgroupAcctLRU(pc);
> +
> =A0>------list_add(&pc->lru, &mz->lists[lru]);
> =A0}
>
> --Ying
>

And this patch fixes the hierarchy_walk :

fix hierarchy_walk() to hold a reference to first mem_cgroup

The first mem_cgroup returned from hierarchy_walk() is used to
terminate a round-trip. However there is no reference hold on
that which the first could be removed during the walking. The
patch including the following change:

1. hold a reference on the first mem_cgroup during the walk.
2. rename the variable "root" to "target", which we found using
"root" is confusing in this content with root_mem_cgroup. better
naming is welcomed.

Signed-off-by: Ying Han <yinghan@google.com>

 include/linux/memcontrol.h |   10 +++++++---
 mm/memcontrol.c            |   41 ++++++++++++++++++++++++----------------=
-
 mm/vmscan.c                |   10 +++++-----
 3 files changed, 36 insertions(+), 25 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 15b713b..4de12ca 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -104,8 +104,10 @@ extern void mem_cgroup_end_migration(struct
mem_cgroup *mem,
 >------struct page *oldpage, struct page *newpage);
=B7
 struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
+>------>------->------->------->-------     struct mem_cgroup *,
 >------>------->------->------->-------     struct mem_cgroup *);
-void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup=
 *);
+void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup=
 *,
+>------>------->------->-------    struct mem_cgroup *);
=B7
 /*
  * For memory reclaim.
@@ -332,13 +334,15 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *pa=
ge)
 >------return NULL;
 }
=B7
-static inline struct mem_cgroup *mem_cgroup_hierarchy_walk(struct
mem_cgroup *r,
+static inline struct mem_cgroup *mem_cgroup_hierarchy_walk(struct
mem_cgroup *t,
+>------>------->------->------->------->------->-------   struct mem_cgrou=
p *f,
 >------>------->------->------->------->------->-------   struct mem_cgrou=
p *m)
 {
 >------return NULL;
 }
=B7
-static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,
+static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *t,
+>------>------->------->------->------->-------  struct mem_cgroup *f,
 >------>------->------->------->------->-------  struct mem_cgroup *m)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f6c5f29..80b62aa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1447,60 +1447,67 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
=B7
 /**
  * mem_cgroup_hierarchy_walk - iterate over a memcg hierarchy
- * @root: starting point of the hierarchy
+ * @target: starting point of the hierarchy
+ * @first: first node of the scanning
  * @prev: previous position or NULL
  *
- * Caller must hold a reference to @root.  While this function will
- * return @root as part of the walk, it will never increase its
+ * Caller must hold a reference to @parent.  While this function will
+ * return @parent as part of the walk, it will never increase its
  * reference count.
  *
  * Caller must clean up with mem_cgroup_stop_hierarchy_walk() when it
  * stops the walk potentially before the full round trip.
  */
-struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
+struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *target,
+>------>------->------->------->-------     struct mem_cgroup *first,
 >------>------->------->------->-------     struct mem_cgroup *prev)
 {
->------struct mem_cgroup *mem;
+>------struct mem_cgroup *mem =3D NULL;
=B7
 >------if (mem_cgroup_disabled())
 >------>-------return NULL;
=B7
->------if (!root)
->------>-------root =3D root_mem_cgroup;
+>------if (!target)
+>------>-------target =3D root_mem_cgroup;
 >------/*
 >------ * Even without hierarchy explicitely enabled in the root
 >------ * memcg, it is the ultimate parent of all memcgs.
 >------ */
->------if (!(root =3D=3D root_mem_cgroup || root->use_hierarchy))
->------>-------return root;
->------if (prev && prev !=3D root)
+>------if (!(target =3D=3D root_mem_cgroup || target->use_hierarchy))
+>------>-------return target;
+>------if (prev && prev !=3D target && prev !=3D first)
 >------>-------css_put(&prev->css);
 >------do {
->------>-------int id =3D root->last_scanned_child;
+>------>-------int id =3D target->last_scanned_child;
 >------>-------struct cgroup_subsys_state *css;
=B7
 >------>-------rcu_read_lock();
->------>-------css =3D css_get_next(&mem_cgroup_subsys, id + 1, &root->css=
, &id);
->------>-------if (css && (css =3D=3D &root->css || css_tryget(css)))
+>------>-------css =3D css_get_next(&mem_cgroup_subsys, id + 1,
&target->css, &id);
+>------>-------if (css && (css =3D=3D &target->css || css_tryget(css)))
 >------>------->-------mem =3D container_of(css, struct mem_cgroup, css);
 >------>-------rcu_read_unlock();
 >------>-------if (!css)
 >------>------->-------id =3D 0;
->------>-------root->last_scanned_child =3D id;
+>------>-------target->last_scanned_child =3D id;
 >------} while (!mem);
 >------return mem;
 }
=B7
 /**
  * mem_cgroup_stop_hierarchy_walk - clean up after partial hierarchy walk
- * @root: starting point in the hierarchy
+ * @target: starting point in the hierarchy
+ * @first: first node of the scanning
  * @mem: last position during the walk
  */
-void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,
+void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *target,
+>------>------->------->-------    struct mem_cgroup *first,
 >------>------->------->-------    struct mem_cgroup *mem)
 {
->------if (mem && mem !=3D root)
+>------if (mem && mem !=3D target)
 >------>-------css_put(&mem->css);
+
+>------if (first && first !=3D mem && first !=3D target)
+>------>-------css_put(&first->css);
 }
=B7
 static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3bcb212..aee958a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1751,10 +1751,10 @@ static void shrink_zone(int priority, struct zone *=
zone,
 >------>------->-------struct scan_control *sc)
 {
 >------unsigned long nr_reclaimed_before =3D sc->nr_reclaimed;
->------struct mem_cgroup *root =3D sc->target_mem_cgroup;
->------struct mem_cgroup *first, *mem =3D NULL;
+>------struct mem_cgroup *target =3D sc->target_mem_cgroup;
+>------struct mem_cgroup *first, *mem;
=B7
->------first =3D mem =3D mem_cgroup_hierarchy_walk(root, mem);
+>------first =3D mem =3D mem_cgroup_hierarchy_walk(target, NULL, NULL);
 >------for (;;) {
 >------>-------unsigned long nr_reclaimed;
=B7
@@ -1765,11 +1765,11 @@ static void shrink_zone(int priority, struct zone *=
zone,
 >------>-------if (nr_reclaimed >=3D sc->nr_to_reclaim)
 >------>------->-------break;
=B7
->------>-------mem =3D mem_cgroup_hierarchy_walk(root, mem);
+>------>-------mem =3D mem_cgroup_hierarchy_walk(target, first, mem);
 >------>-------if (mem =3D=3D first)
 >------>------->-------break;
 >------}
->------mem_cgroup_stop_hierarchy_walk(root, mem);
+>------mem_cgroup_stop_hierarchy_walk(target, first, mem);
 }

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
