Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D19436B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 19:38:40 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so2300849lbj.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 16:38:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339007007-10403-1-git-send-email-yinghan@google.com>
References: <1339007007-10403-1-git-send-email-yinghan@google.com>
Date: Fri, 8 Jun 2012 16:38:38 -0700
Message-ID: <CALWz4izNzUbRW_wniO_c6PEJq3ysByoZKOWUdz2tbRy9znyhaw@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm: memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Wed, Jun 6, 2012 at 11:23 AM, Ying Han <yinghan@google.com> wrote:
> This patch reverts all the existing softlimit reclaim implementations and
> instead integrates the softlimit reclaim into existing global reclaim log=
ic.
>
> The new softlimit reclaim includes the following changes:
>
> 1. add function should_reclaim_mem_cgroup()
>
> Add the filter function should_reclaim_mem_cgroup() under the common func=
tion
> shrink_zone(). The later one is being called both from per-memcg reclaim =
as
> well as global reclaim.
>
> Today the softlimit takes effect only under global memory pressure. The m=
emcgs
> get free run above their softlimit until there is a global memory content=
ion.
> This patch doesn't change the semantics.
>
> Under the global reclaim, we try to skip reclaiming from a memcg under it=
s
> softlimit. To prevent reclaim from trying too hard on hitting memcgs
> (above softlimit) w/ only hard-to-reclaim pages, the reclaim priority is =
used
> to skip the softlimit check. This is a trade-off of system performance an=
d
> resource isolation.
>
> 2. "hierarchical" softlimit reclaim
>
> This is consistant to how softlimit was previously implemented, where the
> pressure is put for the whole hiearchy as long as the "root" of the hiera=
rchy
> over its softlimit.
>
> This part is not in my previous posts, and is quite different from my
> understanding of softlimit reclaim. After quite a lot of discussions with
> Johannes and Michal, i decided to go with it for now. And this is designe=
d
> to work with both trusted setups and untrusted setups.
>
> What's the trusted and untrusted setups ?
>
> case 1 : Administrator is the only one setting up the limits and also he
> expects gurantees of memory under each cgroup's softlimit:
>
> Considering the following:
>
> root (soft: unlimited, use_hierarchy =3D 1)
> =A0-- A (soft: unlimited, usage 22G)
> =A0 =A0 =A0-- A1 (soft: 10G, usage 17G)
> =A0 =A0 =A0-- A2 (soft: 6G, usage 5G)
> =A0-- B (soft: 16G, usage 10G)
>
> So we have A1 above its softlimit and none of its ancestor does, then
> global reclaim will only pick A1 to reclaim first.
>
> case 2: Untrusted enviroment where cgroups changes its softlimit or
> adminstrator could make mistakes. In that case, we still want to attack t=
he
> mis-configured child if its parent is above softlimit.
>
> Considering the following:
>
> root (soft: unlimited, use_hierarchy =3D 1)
> =A0-- A (soft: 16G, usage 22G)
> =A0 =A0 =A0-- A1 (soft: 10G, usage 17G)
> =A0 =A0 =A0-- A2 (soft: 1000G, usage 5G)
> =A0-- B (soft: 16G, usage 10G)
>
> Here A2 would set its softlimit way higher than its parent, but the curre=
nt
> logic makes sure to still attack it when A exceeds its softlimit.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =A0include/linux/memcontrol.h | =A0 19 +-
> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A04 -
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0454 +++-------------------=
----------------------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 84 ++-------
> =A04 files changed, 50 insertions(+), 511 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f94efd2..7d47c7c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -130,6 +130,8 @@ extern void mem_cgroup_print_oom_info(struct mem_cgro=
up *memcg,
> =A0extern void mem_cgroup_replace_page_cache(struct page *oldpage,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct page *newpage);
>
> +extern bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg);
> +
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> =A0extern int do_swap_account;
> =A0#endif
> @@ -185,9 +187,6 @@ static inline void mem_cgroup_dec_page_stat(struct pa=
ge *page,
> =A0 =A0 =A0 =A0mem_cgroup_update_page_stat(page, idx, -1);
> =A0}
>
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *total_scanned);
> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
>
> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_ite=
m idx);
> @@ -390,14 +389,6 @@ static inline void mem_cgroup_dec_page_stat(struct p=
age *page,
> =A0}
>
> =A0static inline
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 unsigned long *total_scanned)
> -{
> - =A0 =A0 =A0 return 0;
> -}
> -
> -static inline
> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0return 0;
> @@ -415,6 +406,12 @@ static inline void mem_cgroup_replace_page_cache(str=
uct page *oldpage,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct pag=
e *newpage)
> =A0{
> =A0}
> +
> +bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 return true;
> +}
> +
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
>
> =A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index b1fd5c7..c9e9279 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -254,10 +254,6 @@ extern unsigned long try_to_free_pages(struct zoneli=
st *zonelist, int order,
> =A0extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, =
int file);
> =A0extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *m=
em,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask, bool noswap);
> -extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned);
> =A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
> =A0extern int vm_swappiness;
> =A0extern int remove_mapping(struct address_space *mapping, struct page *=
page);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7685d4a..2ee1532 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -35,7 +35,6 @@
> =A0#include <linux/limits.h>
> =A0#include <linux/export.h>
> =A0#include <linux/mutex.h>
> -#include <linux/rbtree.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/swap.h>
> =A0#include <linux/swapops.h>
> @@ -108,7 +107,6 @@ enum mem_cgroup_events_index {
> =A0*/
> =A0enum mem_cgroup_events_target {
> =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_THRESH,
> - =A0 =A0 =A0 MEM_CGROUP_TARGET_SOFTLIMIT,
> =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_NUMAINFO,
> =A0 =A0 =A0 =A0MEM_CGROUP_NTARGETS,
> =A0};
> @@ -139,12 +137,6 @@ struct mem_cgroup_per_zone {
> =A0 =A0 =A0 =A0struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY +=
 1];
>
> =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;
> - =A0 =A0 =A0 struct rb_node =A0 =A0 =A0 =A0 =A0tree_node; =A0 =A0 =A0/* =
RB tree node */
> - =A0 =A0 =A0 unsigned long long =A0 =A0 =A0usage_in_excess;/* Set to the=
 value by which */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* the soft limit is exceeded*/
> - =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;
> - =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *memcg; =A0 =A0 =A0 =A0 /* Ba=
ck pointer, we cannot */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/
> =A0};
>
> =A0struct mem_cgroup_per_node {
> @@ -155,26 +147,6 @@ struct mem_cgroup_lru_info {
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
> @@ -356,12 +328,7 @@ static bool move_file(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0&mc.to->move_charge_at_immigrate);
> =A0}
>
> -/*
> - * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> - * limit reclaim to prevent infinite loops, if they ever occur.
> - */
> =A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0 =
=A0 =A0(100)
> -#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)
>
> =A0enum charge_type {
> =A0 =A0 =A0 =A0MEM_CGROUP_CHARGE_TYPE_CACHE =3D 0,
> @@ -394,12 +361,12 @@ enum charge_type {
> =A0static void mem_cgroup_get(struct mem_cgroup *memcg);
> =A0static void mem_cgroup_put(struct mem_cgroup *memcg);
>
> +static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> =A0/* Writing them here to avoid exposing memcg's inner layout */
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> =A0#include <net/sock.h>
> =A0#include <net/ip.h>
>
> -static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> =A0void sock_update_memcg(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0if (mem_cgroup_sockets_enabled) {
> @@ -476,164 +443,6 @@ page_cgroup_zoneinfo(struct mem_cgroup *memcg, stru=
ct page *page)
> =A0 =A0 =A0 =A0return mem_cgroup_zoneinfo(memcg, nid, zid);
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
> -__mem_cgroup_insert_exceeded(struct mem_cgroup *memcg,
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
> -__mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
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
> -mem_cgroup_remove_exceeded(struct mem_cgroup *memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz)
> -{
> - =A0 =A0 =A0 spin_lock(&mctz->lock);
> - =A0 =A0 =A0 __mem_cgroup_remove_exceeded(memcg, mz, mctz);
> - =A0 =A0 =A0 spin_unlock(&mctz->lock);
> -}
> -
> -
> -static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page=
 *page)
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
> - =A0 =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(memcg, nid, zid)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
emcg->res);
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
p_remove_exceeded(memcg, mz, mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Insert again. mz->usag=
e_in_excess will be updated.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If excess is 0, no tre=
e ops.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceede=
d(memcg, mz, mctz, excess);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -}
> -
> -static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
> -{
> - =A0 =A0 =A0 int node, zone;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> -
> - =A0 =A0 =A0 for_each_node(node) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (zone =3D 0; zone < MAX_NR_ZONES; zone+=
+) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(=
memcg, node, zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mctz =3D soft_limit_tree_no=
de_zone(node, zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_remove_exceeded(=
memcg, mz, mctz);
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
> - =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mz->memcg, mz, mctz);
> - =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 !css_tryget(&mz->memcg->css))
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
> @@ -778,9 +587,6 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgr=
oup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case MEM_CGROUP_TARGET_THRESH:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next =3D val + THRESHOLDS_=
EVENTS_TARGET;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case MEM_CGROUP_TARGET_SOFTLIMIT:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D val + SOFTLIMIT_EV=
ENTS_TARGET;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case MEM_CGROUP_TARGET_NUMAINFO:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next =3D val + NUMAINFO_EV=
ENTS_TARGET;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -803,11 +609,8 @@ static void memcg_check_events(struct mem_cgroup *me=
mcg, struct page *page)
> =A0 =A0 =A0 =A0/* threshold event is triggered in finer grain than soft l=
imit */
> =A0 =A0 =A0 =A0if (unlikely(mem_cgroup_event_ratelimit(memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_THRESH))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool do_softlimit;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool do_numainfo __maybe_unused;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_softlimit =3D mem_cgroup_event_ratelimit=
(memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_TARGET_SOFTLIMIT);
> =A0#if MAX_NUMNODES > 1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_numainfo =3D mem_cgroup_event_ratelimit=
(memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_NUMAINFO);
> @@ -815,8 +618,6 @@ static void memcg_check_events(struct mem_cgroup *mem=
cg, struct page *page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0preempt_enable();
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_threshold(memcg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(do_softlimit))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_tree(memc=
g, page);
> =A0#if MAX_NUMNODES > 1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(do_numainfo))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_inc(&memcg->numainf=
o_events);
> @@ -867,6 +668,31 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct=
 mm_struct *mm)
> =A0 =A0 =A0 =A0return memcg;
> =A0}
>
> +bool should_reclaim_mem_cgroup(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We treat the root cgroup special here to always reclai=
m pages.
> + =A0 =A0 =A0 =A0* Now root cgroup has its own lru, and the only chance t=
o reclaim
> + =A0 =A0 =A0 =A0* pages from it is through global reclaim. note, root cg=
roup does
> + =A0 =A0 =A0 =A0* not trigger targeted reclaim.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (mem_cgroup_is_root(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> +
> + =A0 =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This is global reclaim, stop at root cgr=
oup */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_is_root(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&memcg->r=
es))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return false;
> +}
> +
> =A0/**
> =A0* mem_cgroup_iter - iterate over memory cgroup hierarchy
> =A0* @root: hierarchy root
> @@ -1628,106 +1454,13 @@ int mem_cgroup_select_victim_node(struct mem_cgr=
oup *memcg)
> =A0 =A0 =A0 =A0return node;
> =A0}
>
> -/*
> - * Check all nodes whether it contains reclaimable pages or not.
> - * For quick scan, we make use of scan_nodes. This will allow us to skip
> - * unused nodes. But scan_nodes is lazily updated and may not cotain
> - * enough new information. We need to do double check.
> - */
> -bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
> -{
> - =A0 =A0 =A0 int nid;
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* quick check...making use of scan_node.
> - =A0 =A0 =A0 =A0* We can skip unused nodes.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (!nodes_empty(memcg->scan_nodes)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (nid =3D first_node(memcg->scan_nodes);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nid < MAX_NUMNODES;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nid =3D next_node(nid, memcg->sc=
an_nodes)) {
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_mem_cgroup_node_re=
claimable(memcg, nid, noswap))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Check rest of nodes.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (node_isset(nid, memcg->scan_nodes))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_mem_cgroup_node_reclaimable(memcg,=
 nid, noswap))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return false;
> -}
> -
> =A0#else
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
> =A0{
> =A0 =A0 =A0 =A0return 0;
> =A0}
> -
> -bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
> -{
> - =A0 =A0 =A0 return test_mem_cgroup_node_reclaimable(memcg, 0, noswap);
> -}
> =A0#endif
>
> -static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_=
t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long *total_scanned)
> -{
> - =A0 =A0 =A0 struct mem_cgroup *victim =3D NULL;
> - =A0 =A0 =A0 int total =3D 0;
> - =A0 =A0 =A0 int loop =3D 0;
> - =A0 =A0 =A0 unsigned long excess;
> - =A0 =A0 =A0 unsigned long nr_scanned;
> - =A0 =A0 =A0 struct mem_cgroup_reclaim_cookie reclaim =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .priority =3D 0,
> - =A0 =A0 =A0 };
> -
> - =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&root_memcg->res) =
>> PAGE_SHIFT;
> -
> - =A0 =A0 =A0 while (1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_iter(root_memcg, vict=
im, &reclaim);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!victim) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop >=3D 2) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we =
have not been able to reclaim
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* anythi=
ng, it might because there are
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* no rec=
laimable pages under this hierarchy
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!total)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
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
 =A0 (loop > MEM_CGROUP_MAX_RECLAIM_LOOPS))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_reclaimable(victim, false))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_shrink_node_zone(vict=
im, gfp_mask, false,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, &nr_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&root_me=
mcg->res))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 mem_cgroup_iter_break(root_memcg, victim);
> - =A0 =A0 =A0 return total;
> -}
> -
> =A0/*
> =A0* Check OOM-Killer is already running under our hierarchy.
> =A0* If someone is running, return false.
> @@ -2539,8 +2272,6 @@ static void __mem_cgroup_commit_charge(struct mem_c=
group *memcg,
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * "charge_statistics" updated event counter. Then, check =
it.
> - =A0 =A0 =A0 =A0* Insert ancestor (and ancestor's ancestors), to softlim=
it RB-tree.
> - =A0 =A0 =A0 =A0* if they exceeds softlimit.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0memcg_check_events(memcg, page);
> =A0}
> @@ -3555,98 +3286,6 @@ static int mem_cgroup_resize_memsw_limit(struct me=
m_cgroup *memcg,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 unsigned long *total_scanned)
> -{
> - =A0 =A0 =A0 unsigned long nr_reclaimed =3D 0;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz, *next_mz =3D NULL;
> - =A0 =A0 =A0 unsigned long reclaimed;
> - =A0 =A0 =A0 int loop =3D 0;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *mctz;
> - =A0 =A0 =A0 unsigned long long excess;
> - =A0 =A0 =A0 unsigned long nr_scanned;
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
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_scanned =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_soft_reclaim(mz->m=
emcg, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_mask, &nr_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed +=3D reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanned;
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
 =3D=3D mz)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 css_put(&next_mz->memcg->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else /* nex=
t_mz =3D=3D NULL or other memcg */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_remove_exceeded(mz->memcg, mz,=
 mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
z->memcg->res);
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
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceeded(mz->memcg, mz,=
 mctz, excess);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&mctz->lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&mz->memcg->css);
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
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&next_mz->memcg->css);
> - =A0 =A0 =A0 return nr_reclaimed;
> -}
> -
> =A0/*
> =A0* This routine traverse page_cgroup in given list and drop them all.
> =A0* *And* this routine doesn't reclaim page itself, just removes page_cg=
roup.
> @@ -4790,9 +4429,6 @@ static int alloc_mem_cgroup_per_zone_info(struct me=
m_cgroup *memcg, int node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz =3D &pn->zoneinfo[zone];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(lru)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&mz->lruvec=
.lists[lru]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_in_excess =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->on_tree =3D false;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->memcg =3D memcg;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0memcg->info.nodeinfo[node] =3D pn;
> =A0 =A0 =A0 =A0return 0;
> @@ -4867,7 +4503,6 @@ static void __mem_cgroup_free(struct mem_cgroup *me=
mcg)
> =A0{
> =A0 =A0 =A0 =A0int node;
>
> - =A0 =A0 =A0 mem_cgroup_remove_from_trees(memcg);
> =A0 =A0 =A0 =A0free_css_id(&mem_cgroup_subsys, &memcg->css);
>
> =A0 =A0 =A0 =A0for_each_node(node)
> @@ -4923,41 +4558,6 @@ static void __init enable_swap_cgroup(void)
> =A0}
> =A0#endif
>
> -static int mem_cgroup_soft_limit_tree_init(void)
> -{
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;
> - =A0 =A0 =A0 struct mem_cgroup_tree_per_zone *rtpz;
> - =A0 =A0 =A0 int tmp, node, zone;
> -
> - =A0 =A0 =A0 for_each_node(node) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D node;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!node_state(node, N_NORMAL_MEMORY))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D -1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rtpn =3D kzalloc_node(sizeof(*rtpn), GFP_KE=
RNEL, tmp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rtpn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_cleanup;
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
> -
> -err_cleanup:
> - =A0 =A0 =A0 for_each_node(node) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!soft_limit_tree.rb_tree_per_node[node]=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(soft_limit_tree.rb_tree_per_node[node=
]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 soft_limit_tree.rb_tree_per_node[node] =3D =
NULL;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return 1;
> -
> -}
> -
> =A0static struct cgroup_subsys_state * __ref
> =A0mem_cgroup_create(struct cgroup *cont)
> =A0{
> @@ -4978,8 +4578,6 @@ mem_cgroup_create(struct cgroup *cont)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int cpu;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enable_swap_cgroup();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0parent =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_tree_init())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0root_mem_cgroup =3D memcg;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_possible_cpu(cpu) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct memcg_stock_pcp *st=
ock =3D
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 33dc256..0560783 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2150,7 +2150,22 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.zone =3D zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priority, &mz, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Reclaim from mem_cgroup if any of thes=
e conditions are met:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* - this is a targetted reclaim ( not gl=
obal reclaim)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* - reclaim priority is less than =A0DEF=
_PRIORITY - 2
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* - mem_cgroup or its ancestor ( not inc=
luding root cgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* exceeds its soft limit
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Note: The priority check is a balance =
of how hard to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* preserve the pages under softlimit. If=
 the memcgs of the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* zone having trouble to reclaim pages a=
bove their softlimit,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we have to reclaim under softlimit ins=
tead of burning more
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* cpu cycles.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!global_reclaim(sc) || priority < DEF_P=
RIORITY - 2 ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 should_recl=
aim_mem_cgroup(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(prio=
rity, &mz, sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Limit reclaim has historically picked o=
ne memcg and
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * scanned it with decreasing priority lev=
els until
> @@ -2231,8 +2246,6 @@ static bool shrink_zones(int priority, struct zonel=
ist *zonelist,
> =A0{
> =A0 =A0 =A0 =A0struct zoneref *z;
> =A0 =A0 =A0 =A0struct zone *zone;
> - =A0 =A0 =A0 unsigned long nr_soft_reclaimed;
> - =A0 =A0 =A0 unsigned long nr_soft_scanned;
> =A0 =A0 =A0 =A0bool aborted_reclaim =3D false;
>
> =A0 =A0 =A0 =A0/*
> @@ -2271,18 +2284,6 @@ static bool shrink_zones(int priority, struct zone=
list *zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This steals pages from=
 memory cgroups over softlimit
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and returns the number=
 of reclaimed pages and
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages. This wo=
rks for global memory pressure
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and balancing, not for=
 a memcg's limit.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_scanned =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_c=
group_soft_limit_reclaim(zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sc->order, sc->gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 &nr_soft_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_reclaimed +=3D nr_so=
ft_reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned +=3D nr_soft=
_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* need some check for avo=
id more shrink_zone() */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> @@ -2462,47 +2463,6 @@ unsigned long try_to_free_pages(struct zonelist *z=
onelist, int order,
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>
> -unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask, bool noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long *nr_scanned)
> -{
> - =A0 =A0 =A0 struct scan_control sc =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_scanned =3D 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !laptop_mode,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D !noswap,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .target_mem_cgroup =3D memcg,
> - =A0 =A0 =A0 };
> - =A0 =A0 =A0 struct mem_cgroup_zone mz =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
> - =A0 =A0 =A0 };
> -
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
> - =A0 =A0 =A0 shrink_mem_cgroup_zone(0, &mz, &sc);
> -
> - =A0 =A0 =A0 trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed=
);
> -
> - =A0 =A0 =A0 *nr_scanned =3D sc.nr_scanned;
> - =A0 =A0 =A0 return sc.nr_reclaimed;
> -}
> -
> =A0unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 bool noswap)
> @@ -2677,8 +2637,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat=
, int order,
> =A0 =A0 =A0 =A0int end_zone =3D 0; =A0 =A0 =A0 /* Inclusive. =A00 =3D ZON=
E_DMA */
> =A0 =A0 =A0 =A0unsigned long total_scanned;
> =A0 =A0 =A0 =A0struct reclaim_state *reclaim_state =3D current->reclaim_s=
tate;
> - =A0 =A0 =A0 unsigned long nr_soft_reclaimed;
> - =A0 =A0 =A0 unsigned long nr_soft_scanned;
> =A0 =A0 =A0 =A0struct scan_control sc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D GFP_KERNEL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,
> @@ -2781,16 +2739,6 @@ loop_again:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_scanned =3D 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_scanned =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Call soft limit reclai=
m before calling shrink_zone.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_c=
group_soft_limit_reclaim(zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order, sc.gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_soft_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.nr_reclaimed +=3D nr_sof=
t_reclaimed;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D nr_soft_=
scanned;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We put equal pressure o=
n every zone, unless
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * one zone has way too ma=
ny pages free
> --
> 1.7.7.3
>

The patch i have here is based on v3.4. Based on a offline
conversation, i am going to rebase it on mmotm/linux-next and post it
again.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
