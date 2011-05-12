Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 11208900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:41:43 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4CIfbin003843
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:41:37 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz29.hot.corp.google.com with ESMTP id p4CIde10021101
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:41:36 -0700
Received: by qyk2 with SMTP id 2so1097011qyk.9
        for <linux-mm@kvack.org>; Thu, 12 May 2011 11:41:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305212038-15445-7-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-7-git-send-email-hannes@cmpxchg.org>
Date: Thu, 12 May 2011 11:41:35 -0700
Message-ID: <BANLkTi=CsU-ahDDkE-3g3QQXJO844PC0cw@mail.gmail.com>
Subject: Re: [rfc patch 6/6] memcg: rework soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Johannes:

Thank you for the patchset, and i will definitely spend time read them
through later today.

Also, I have a patchset which implements the round-robin soft_limit
reclaim as we discussed in LSF. Before I read through this set, i
don't know if we are making the similar approach or not. My
implementation is the first step only replace the RB-tree based
soft_limit reclaim to link_list round-robin. Feel free to throw
comment on that.

--Ying

On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> The current soft limit reclaim algorithm entered from kswapd. =A0It
> selects the memcg that exceeds its soft limit the most in absolute
> bytes and reclaims from it most aggressively (priority 0).
>
> This has several disadvantages:
>
> =A0 =A0 =A0 =A01. because of the aggressiveness, kswapd can be stalled on=
 a
> =A0 =A0 =A0 =A0memcg that is hard to reclaim for a long time before going=
 for
> =A0 =A0 =A0 =A0other pages.
>
> =A0 =A0 =A0 =A02. it only considers the biggest violator (in absolute bye=
s!)
> =A0 =A0 =A0 =A0and does not put extra pressure on other memcgs in excess.
>
> =A0 =A0 =A0 =A03. it needs a ton of code to quickly find the target
>
> This patch removes all the explicit soft limit target selection and
> instead hooks into the hierarchical memcg walk that is done by direct
> reclaim and kswapd balancing. =A0If it encounters a memcg that exceeds
> its soft limit, or contributes to the soft limit excess in one of its
> hierarchy parents, it scans the memcg one priority level below the
> current reclaim priority.
>
> =A0 =A0 =A0 =A01. the primary goal is to reclaim pages, not to punish sof=
t
> =A0 =A0 =A0 =A0limit violators at any price
>
> =A0 =A0 =A0 =A02. increased pressure is applied to all violators, not jus=
t
> =A0 =A0 =A0 =A0the biggest one
>
> =A0 =A0 =A0 =A03. the soft limit is no longer only meaningful on global
> =A0 =A0 =A0 =A0memory pressure, but considered for any hierarchical recla=
im.
> =A0 =A0 =A0 =A0This means that even for hard limit reclaim, the children =
in
> =A0 =A0 =A0 =A0excess of their soft limit experience more pressure compar=
ed
> =A0 =A0 =A0 =A0to their siblings
>
> =A0 =A0 =A0 =A04. direct reclaim now also applies more pressure on memcgs=
 in
> =A0 =A0 =A0 =A0soft limit excess, not only kswapd
>
> =A0 =A0 =A0 =A05. the implementation is only a few lines of straight-forw=
ard
> =A0 =A0 =A0 =A0code
>
> RFC: since there is no longer a reliable way of counting the pages
> reclaimed solely because of an exceeding soft limit, this patch
> conflicts with Ying's exporting of exactly this number to userspace.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0include/linux/memcontrol.h | =A0 16 +-
> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A04 -
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0450 +++-------------------=
----------------------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 48 +-----
> =A04 files changed, 34 insertions(+), 484 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 65163c2..b0c7323 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -99,6 +99,7 @@ extern void mem_cgroup_end_migration(struct mem_cgroup =
*mem,
> =A0* For memory reclaim.
> =A0*/
> =A0void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup =
**);
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *, struct mem_cgro=
up *);
> =A0void mem_cgroup_count_reclaim(struct mem_cgroup *, bool, bool,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long,=
 unsigned long);
> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> @@ -140,8 +141,6 @@ static inline void mem_cgroup_dec_page_stat(struct pa=
ge *page,
> =A0 =A0 =A0 =A0mem_cgroup_update_page_stat(page, idx, -1);
> =A0}
>
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>
> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -294,6 +293,12 @@ static inline void mem_cgroup_hierarchy_walk(struct =
mem_cgroup *start,
> =A0 =A0 =A0 =A0*iter =3D start;
> =A0}
>
> +static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *roo=
t,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static inline void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0bool kswapd, bool hierarchy,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0unsigned long scanned,
> @@ -349,13 +354,6 @@ static inline void mem_cgroup_dec_page_stat(struct p=
age *page,
> =A0}
>
> =A0static inline
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask)
> -{
> - =A0 =A0 =A0 return 0;
> -}
> -
> -static inline
> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
> =A0{
> =A0 =A0 =A0 =A0return 0;
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a5c6da5..885cf19 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -254,10 +254,6 @@ extern unsigned long try_to_free_pages(struct zoneli=
st *zonelist, int order,
> =A0extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *m=
em,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask, bool noswap,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int swappiness);
> -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned int swappiness,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone);
> =A0extern int __isolate_lru_page(struct page *page, int mode, int file);
> =A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
> =A0extern int vm_swappiness;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f5d90ba..b0c6dd5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -34,7 +34,6 @@
> =A0#include <linux/rcupdate.h>
> =A0#include <linux/limits.h>
> =A0#include <linux/mutex.h>
> -#include <linux/rbtree.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/swap.h>
> =A0#include <linux/swapops.h>
> @@ -138,12 +137,6 @@ struct mem_cgroup_per_zone {
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 count[NR_LRU_LISTS];
>
> =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;
> - =A0 =A0 =A0 struct rb_node =A0 =A0 =A0 =A0 =A0tree_node; =A0 =A0 =A0/* =
RB tree node */
> - =A0 =A0 =A0 unsigned long long =A0 =A0 =A0usage_in_excess;/* Set to the=
 value by which */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* the soft limit is exceeded*/
> - =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;
> - =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *mem; =A0 =A0 =A0 =A0 =A0 /* =
Back pointer, we cannot */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/
> =A0};
> =A0/* Macro for accessing counter */
> =A0#define MEM_CGROUP_ZSTAT(mz, idx) =A0 =A0 =A0((mz)->count[(idx)])
> @@ -156,26 +149,6 @@ struct mem_cgroup_lru_info {
> =A0 =A0 =A0 =A0struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> =A0};
>
> -/*
> - * Cgroups above their limits are maintained in a RB-Tree, independent o=
f
> - * their hierarchy representation
> - */
> -
> -struct mem_cgroup_tree_per_zone {
> - =A0 =A0 =A0 struct rb_root rb_root;
> - =A0 =A0 =A0 spinlock_t lock;
> -};
> -
> -struct mem_cgroup_tree_per_node {
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone rb_tree_per_zone[MAX_NR_ZON=
ES];
> -};
> -
> -struct mem_cgroup_tree {
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rb_tree_per_node[MAX_NUMNO=
DES];
> -};
> -
> -static struct mem_cgroup_tree soft_limit_tree __read_mostly;
> -
> =A0struct mem_cgroup_threshold {
> =A0 =A0 =A0 =A0struct eventfd_ctx *eventfd;
> =A0 =A0 =A0 =A0u64 threshold;
> @@ -323,12 +296,7 @@ static bool move_file(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0&mc.to->move_charge_at_immigrate);
> =A0}
>
> -/*
> - * Maximum loops in mem_cgroup_soft_reclaim(), used for soft
> - * limit reclaim to prevent infinite loops, if they ever occur.
> - */
> =A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0 =
=A0 =A0(100)
> -#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)
>
> =A0enum charge_type {
> =A0 =A0 =A0 =A0MEM_CGROUP_CHARGE_TYPE_CACHE =3D 0,
> @@ -375,164 +343,6 @@ page_cgroup_zoneinfo(struct mem_cgroup *mem, struct=
 page *page)
> =A0 =A0 =A0 =A0return mem_cgroup_zoneinfo(mem, nid, zid);
> =A0}
>
> -static struct mem_cgroup_tree_per_zone *
> -soft_limit_tree_node_zone(int nid, int zid)
> -{
> - =A0 =A0 =A0 return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_=
zone[zid];
> -}
> -
> -static struct mem_cgroup_tree_per_zone *
> -soft_limit_tree_from_page(struct page *page)
> -{
> - =A0 =A0 =A0 int nid =3D page_to_nid(page);
> - =A0 =A0 =A0 int zid =3D page_zonenum(page);
> -
> - =A0 =A0 =A0 return &soft_limit_tree.rb_tree_per_node[nid]->rb_tree_per_=
zone[zid];
> -}
> -
> -static void
> -__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng long new_usage_in_excess)
> -{
> - =A0 =A0 =A0 struct rb_node **p =3D &mctz->rb_root.rb_node;
> - =A0 =A0 =A0 struct rb_node *parent =3D NULL;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz_node;
> -
> - =A0 =A0 =A0 if (mz->on_tree)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 mz->usage_in_excess =3D new_usage_in_excess;
> - =A0 =A0 =A0 if (!mz->usage_in_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 while (*p) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 parent =3D *p;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz_node =3D rb_entry(parent, struct mem_cgr=
oup_per_zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 tree_node);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mz->usage_in_excess < mz_node->usage_in=
_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D &(*p)->rb_left;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We can't avoid mem cgroups that are ov=
er their soft
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* limit by the same amount
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (mz->usage_in_excess >=3D mz_node->=
usage_in_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D &(*p)->rb_right;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 rb_link_node(&mz->tree_node, parent, p);
> - =A0 =A0 =A0 rb_insert_color(&mz->tree_node, &mctz->rb_root);
> - =A0 =A0 =A0 mz->on_tree =3D true;
> -}
> -
> -static void
> -__mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz)
> -{
> - =A0 =A0 =A0 if (!mz->on_tree)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 rb_erase(&mz->tree_node, &mctz->rb_root);
> - =A0 =A0 =A0 mz->on_tree =3D false;
> -}
> -
> -static void
> -mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz)
> -{
> - =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mem, mz, mctz);
> - =A0 =A0 =A0 spin_unlock(&mctz->lock);
> -}
> -
> -
> -static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *=
page)
> -{
> - =A0 =A0 =A0 unsigned long long excess;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> - =A0 =A0 =A0 int nid =3D page_to_nid(page);
> - =A0 =A0 =A0 int zid =3D page_zonenum(page);
> - =A0 =A0 =A0 mctz =3D soft_limit_tree_from_page(page);
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Necessary to update all ancestors when hierarchy is us=
ed.
> - =A0 =A0 =A0 =A0* because their event counter is not touched.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 for (; mem; mem =3D parent_mem_cgroup(mem)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
em->res);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We have to update the tree if mz is on=
 RB-tree or
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem is over its softlimit.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (excess || mz->on_tree) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if on-tree, remove it */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mz->on_tree)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgrou=
p_remove_exceeded(mem, mz, mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Insert again. mz->usag=
e_in_excess will be updated.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If excess is 0, no tre=
e ops.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceede=
d(mem, mz, mctz, excess);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -}
> -
> -static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
> -{
> - =A0 =A0 =A0 int node, zone;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> -
> - =A0 =A0 =A0 for_each_node_state(node, N_POSSIBLE) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (zone =3D 0; zone < MAX_NR_ZONES; zone+=
+) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(=
mem, node, zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mctz =3D soft_limit_tree_no=
de_zone(node, zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_remove_exceeded(=
mem, mz, mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -}
> -
> -static struct mem_cgroup_per_zone *
> -__mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mc=
tz)
> -{
> - =A0 =A0 =A0 struct rb_node *rightmost =3D NULL;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> -
> -retry:
> - =A0 =A0 =A0 mz =3D NULL;
> - =A0 =A0 =A0 rightmost =3D rb_last(&mctz->rb_root);
> - =A0 =A0 =A0 if (!rightmost)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* No=
thing to reclaim from */
> -
> - =A0 =A0 =A0 mz =3D rb_entry(rightmost, struct mem_cgroup_per_zone, tree=
_node);
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Remove the node now but someone else can add it back,
> - =A0 =A0 =A0 =A0* we will to add it back at the end of reclaim to its co=
rrect
> - =A0 =A0 =A0 =A0* position in the tree.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mz->mem, mz, mctz);
> - =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&mz->mem->res) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 !css_tryget(&mz->mem->css))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> -done:
> - =A0 =A0 =A0 return mz;
> -}
> -
> -static struct mem_cgroup_per_zone *
> -mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz=
)
> -{
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> -
> - =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 mz =3D __mem_cgroup_largest_soft_limit_node(mctz);
> - =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 return mz;
> -}
> -
> =A0/*
> =A0* Implementation Note: reading percpu statistics for memcg.
> =A0*
> @@ -570,15 +380,6 @@ static long mem_cgroup_read_stat(struct mem_cgroup *=
mem,
> =A0 =A0 =A0 =A0return val;
> =A0}
>
> -static long mem_cgroup_local_usage(struct mem_cgroup *mem)
> -{
> - =A0 =A0 =A0 long ret;
> -
> - =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> - =A0 =A0 =A0 ret +=3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
> - =A0 =A0 =A0 return ret;
> -}
> -
> =A0static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 bool charge)
> =A0{
> @@ -699,7 +500,6 @@ static void memcg_check_events(struct mem_cgroup *mem=
, struct page *page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_target_update(mem, MEM_CGROUP=
_TARGET_THRESH);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(__memcg_event_check(mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_SOFTLIMI=
T))){
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_tree(mem,=
 page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_target_update=
(mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP=
_TARGET_SOFTLIMIT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -1380,6 +1180,29 @@ void mem_cgroup_hierarchy_walk(struct mem_cgroup *=
start,
> =A0 =A0 =A0 =A0*iter =3D mem;
> =A0}
>
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 /* root_mem_cgroup never exceeds its soft limit */
> + =A0 =A0 =A0 if (!mem)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 if (!root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* See whether the memcg in question exceeds its soft lim=
it
> + =A0 =A0 =A0 =A0* directly, or contributes to the soft limit excess in t=
he
> + =A0 =A0 =A0 =A0* hierarchy below the given root.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 while (mem !=3D root) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&mem->res=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem->use_hierarchy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_from_cont(mem->css.cgrou=
p->parent);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return false;
> +}
> +
> =A0static unsigned long mem_cgroup_target_reclaim(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 bool noswap,
> @@ -1411,114 +1234,6 @@ static unsigned long mem_cgroup_target_reclaim(st=
ruct mem_cgroup *mem,
> =A0}
>
> =A0/*
> - * Visit the first child (need not be the first child as per the orderin=
g
> - * of the cgroup list, since we track last_scanned_child) of @mem and us=
e
> - * that to reclaim free pages from.
> - */
> -static struct mem_cgroup *
> -mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> -{
> - =A0 =A0 =A0 struct mem_cgroup *ret =3D NULL;
> - =A0 =A0 =A0 struct cgroup_subsys_state *css;
> - =A0 =A0 =A0 int nextid, found;
> -
> - =A0 =A0 =A0 if (!root_mem->use_hierarchy) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_get(&root_mem->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D root_mem;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 while (!ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nextid =3D root_mem->last_scanned_child + 1=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css =3D css_get_next(&mem_cgroup_subsys, ne=
xtid, &root_mem->css,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&fou=
nd);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css && css_tryget(css))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D container_of(css, s=
truct mem_cgroup, css);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Updates scanning parameter */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* this means start scan fr=
om ID:1 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem->last_scanned_chil=
d =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem->last_scanned_chil=
d =3D found;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return ret;
> -}
> -
> -/*
> - * Scan the hierarchy if needed to reclaim memory. We remember the last =
child
> - * we reclaimed from, so that we don't end up penalizing one child exten=
sively
> - * based on its position in the children list.
> - *
> - * root_mem is the original ancestor that we've been reclaim from.
> - *
> - * We give up and return to the caller when we visit root_mem twice.
> - * (other groups can be removed while we're walking....)
> - */
> -static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_=
t gfp_mask)
> -{
> - =A0 =A0 =A0 struct mem_cgroup *victim;
> - =A0 =A0 =A0 int ret, total =3D 0;
> - =A0 =A0 =A0 int loop =3D 0;
> - =A0 =A0 =A0 unsigned long excess;
> - =A0 =A0 =A0 bool noswap =3D false;
> -
> - =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&root_mem->res) >>=
 PAGE_SHIFT;
> -
> - =A0 =A0 =A0 /* If memsw_is_minimum=3D=3D1, swap-out is of-no-use. */
> - =A0 =A0 =A0 if (root_mem->memsw_is_minimum)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap =3D true;
> -
> - =A0 =A0 =A0 while (1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_select_victim(root_me=
m);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (victim =3D=3D root_mem) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_s=
tock_async();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 2) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we =
have not been able to reclaim
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* anythi=
ng, it might because there are
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no rec=
laimable pages under this hierarchy
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!total)=
 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 css_put(&victim->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We wan=
t to do more targeted reclaim.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* excess=
 >> 2 is not to excessive so as to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclai=
m too much, nor too less that we keep
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* coming=
 back to reclaim from this cgroup
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total >=
=3D (excess >> 2) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 css_put(&victim->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_local_usage(victim)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* this cgroup's local usag=
e =3D=3D 0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&victim->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we use swappiness of local cgroup */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_node_zone(victim,=
 gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get=
_swappiness(victim), zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&victim->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D ret;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&root_me=
m->res))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return total;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return total;
> -}
> -
> -/*
> =A0* Check OOM-Killer is already running under our hierarchy.
> =A0* If someone is running, return false.
> =A0*/
> @@ -3291,94 +3006,6 @@ static int mem_cgroup_resize_memsw_limit(struct me=
m_cgroup *memcg,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask)
> -{
> - =A0 =A0 =A0 unsigned long nr_reclaimed =3D 0;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz, *next_mz =3D NULL;
> - =A0 =A0 =A0 unsigned long reclaimed;
> - =A0 =A0 =A0 int loop =3D 0;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> - =A0 =A0 =A0 unsigned long long excess;
> -
> - =A0 =A0 =A0 if (order > 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 mctz =3D soft_limit_tree_node_zone(zone_to_nid(zone), zone_=
idx(zone));
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* This loop can run a while, specially if mem_cgroup's c=
ontinuously
> - =A0 =A0 =A0 =A0* keep exceeding their soft limit and putting the system=
 under
> - =A0 =A0 =A0 =A0* pressure
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next_mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D next_mz;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_largest_s=
oft_limit_node(mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_soft_reclaim(mz->m=
em, zone, gfp_mask);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed +=3D reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&mctz->lock);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we failed to reclaim anything from =
this memory cgroup
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it is time to move on to the next cgro=
up
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_mz =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!reclaimed) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Loop u=
ntil we find yet another one.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* By the=
 time we get the soft_limit lock
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* again,=
 someone might have aded the
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* group =
back on the RB tree. Iterate to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* make s=
ure we get a different mem.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cg=
roup_largest_soft_limit_node returns
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* NULL i=
f no other cgroup is present on
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the tr=
ee
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_mz =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgrou=
p_largest_soft_limit_node(mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next_mz=
 =3D=3D mz) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 css_put(&next_mz->mem->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 next_mz =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else /* n=
ext_mz =3D=3D NULL or other memcg */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mz->mem, mz, m=
ctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
z->mem->res);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* One school of thought says that we sho=
uld not add
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* back the node to the tree if reclaim r=
eturns 0.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* But our reclaim could return 0, simply=
 because due
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to priority we are exposing a smaller =
subset of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* memory to reclaim from. Consider this =
as a longer
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* term TODO.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If excess =3D=3D 0, no tree ops */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceeded(mz->mem, mz, m=
ctz, excess);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&mz->mem->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Could not reclaim anything and there a=
re no more
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem cgroups to try or we seem to be lo=
oping without
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclaiming anything.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nr_reclaimed &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (next_mz =3D=3D NULL ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop > MEM_CGROUP_MAX_SOFT_=
LIMIT_RECLAIM_LOOPS))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 } while (!nr_reclaimed);
> - =A0 =A0 =A0 if (next_mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&next_mz->mem->css);
> - =A0 =A0 =A0 return nr_reclaimed;
> -}
> -
> =A0/*
> =A0* This routine traverse page_cgroup in given list and drop them all.
> =A0* *And* this routine doesn't reclaim page itself, just removes page_cg=
roup.
> @@ -4449,9 +4076,6 @@ static int alloc_mem_cgroup_per_zone_info(struct me=
m_cgroup *mem, int node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz =3D &pn->zoneinfo[zone];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(l)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&mz->lruvec=
.lists[l]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_in_excess =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->on_tree =3D false;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->mem =3D mem;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -4504,7 +4128,6 @@ static void __mem_cgroup_free(struct mem_cgroup *me=
m)
> =A0{
> =A0 =A0 =A0 =A0int node;
>
> - =A0 =A0 =A0 mem_cgroup_remove_from_trees(mem);
> =A0 =A0 =A0 =A0free_css_id(&mem_cgroup_subsys, &mem->css);
>
> =A0 =A0 =A0 =A0for_each_node_state(node, N_POSSIBLE)
> @@ -4559,31 +4182,6 @@ static void __init enable_swap_cgroup(void)
> =A0}
> =A0#endif
>
> -static int mem_cgroup_soft_limit_tree_init(void)
> -{
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *rtpz;
> - =A0 =A0 =A0 int tmp, node, zone;
> -
> - =A0 =A0 =A0 for_each_node_state(node, N_POSSIBLE) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D node;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!node_state(node, N_NORMAL_MEMORY))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D -1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpn =3D kzalloc_node(sizeof(*rtpn), GFP_KE=
RNEL, tmp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rtpn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 soft_limit_tree.rb_tree_per_node[node] =3D =
rtpn;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (zone =3D 0; zone < MAX_NR_ZONES; zone+=
+) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpz =3D &rtpn->rb_tree_per=
_zone[zone];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpz->rb_root =3D RB_ROOT;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_init(&rtpz->lock)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return 0;
> -}
> -
> =A0static struct cgroup_subsys_state * __ref
> =A0mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> =A0{
> @@ -4605,8 +4203,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct =
cgroup *cont)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enable_swap_cgroup();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0parent =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0root_mem_cgroup =3D mem;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_tree_init())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_possible_cpu(cpu) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct memcg_stock_pcp *st=
ock =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&per_cpu(memcg_stock, cpu);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0381a5d..2b701e0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1937,10 +1937,13 @@ static void shrink_zone(int priority, struct zone=
 *zone,
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long reclaimed =3D sc->nr_reclaim=
ed;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scanned =3D sc->nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_hierarchy_walk(root, &mem);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->current_memcg =3D mem;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(priority, zone, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(root, me=
m))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(epriority, zone, sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_count_reclaim(mem, current_is_k=
swapd(),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 mem !=3D root, /* limit or hierarchy? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 sc->nr_scanned - scanned,
> @@ -2153,42 +2156,6 @@ unsigned long try_to_free_pages(struct zonelist *z=
onelist, int order,
> =A0}
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -
> -unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned int swappiness,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone)
> -{
> - =A0 =A0 =A0 struct scan_control sc =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !laptop_mode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D !noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D swappiness,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .memcg =3D mem,
> - =A0 =A0 =A0 };
> - =A0 =A0 =A0 sc.gfp_mask =3D (gfp_mask & GFP_RECLAIM_MASK) |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (GFP_HIGHUSER_MOVABLE & ~GF=
P_RECLAIM_MASK);
> -
> - =A0 =A0 =A0 trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.may_writepage,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.gfp_mask);
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* NOTE: Although we can get the priority field, using it
> - =A0 =A0 =A0 =A0* here is not a good idea, since it limits the pages we =
can scan.
> - =A0 =A0 =A0 =A0* if we don't reclaim here, the shrink_zone from balance=
_pgdat
> - =A0 =A0 =A0 =A0* will pick up pages from other mem cgroup's as well. We=
 hack
> - =A0 =A0 =A0 =A0* the priority and make it zero.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 do_shrink_zone(0, zone, &sc);
> -
> - =A0 =A0 =A0 trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed=
);
> -
> - =A0 =A0 =A0 return sc.nr_reclaimed;
> -}
> -
> =A0unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 bool noswap,
> @@ -2418,13 +2385,6 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_scanned =3D 0;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Call soft limit reclai=
m before calling shrink_zone.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For now we ignore the =
return value
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_limit_recla=
im(zone, order, sc.gfp_mask);
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We put equal pressure o=
n every zone, unless
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * one zone has way too ma=
ny pages free
> --
> 1.7.5.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
