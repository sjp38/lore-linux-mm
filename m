Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AA6DD6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 09:59:34 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1503752bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 06:59:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
Date: Thu, 2 Jun 2011 22:59:01 +0900
Message-ID: <BANLkTikKHq=NBAPOXJVDM7ZEc9CkW+HdmQ@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> When a memcg hits its hard limit, hierarchical target reclaim is
> invoked, which goes through all contributing memcgs in the hierarchy
> below the offending memcg and reclaims from the respective per-memcg
> lru lists. =A0This distributes pressure fairly among all involved
> memcgs, and pages are aged with respect to their list buddies.
>
> When global memory pressure arises, however, all this is dropped
> overboard. =A0Pages are reclaimed based on global lru lists that have
> nothing to do with container-internal age, and some memcgs may be
> reclaimed from much more than others.
>
> This patch makes traditional global reclaim consider container
> boundaries and no longer scan the global lru lists. =A0For each zone
> scanned, the memcg hierarchy is walked and pages are reclaimed from
> the per-memcg lru lists of the respective zone. =A0For now, the
> hierarchy walk is bounded to one full round-trip through the
> hierarchy, or if the number of reclaimed pages reach the overall
> reclaim target, whichever comes first.
>
> Conceptually, global memory pressure is then treated as if the root
> memcg had hit its limit. =A0Since all existing memcgs contribute to the
> usage of the root memcg, global reclaim is nothing more than target
> reclaim starting from the root memcg. =A0The code is mostly the same for
> both cases, except for a few heuristics and statistics that do not
> always apply. =A0They are distinguished by a newly introduced
> global_reclaim() primitive.
>
> One implication of this change is that pages have to be linked to the
> lru lists of the root memcg again, which could be optimized away with
> the old scheme. =A0The costs are not measurable, though, even with
> worst-case microbenchmarks.
>
> As global reclaim no longer relies on global lru lists, this change is
> also in preparation to remove those completely.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0include/linux/memcontrol.h | =A0 15 ++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0176 ++++++++++++++++++++++=
++++++----------------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0121 ++++++++++++++++++=
++++--------
> =A03 files changed, 218 insertions(+), 94 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5e9840f5..332b0a6 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -101,6 +101,10 @@ mem_cgroup_prepare_migration(struct page *page,
> =A0extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0struct page *oldpage, struct page *newpage, bool migration=
_ok);
>
> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct mem_cgroup *);
> +void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cgro=
up *);
> +
> =A0/*
> =A0* For memory reclaim.
> =A0*/
> @@ -321,6 +325,17 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *p=
age)
> =A0 =A0 =A0 =A0return NULL;
> =A0}
>
> +static inline struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cg=
roup *r,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *m)
> +{
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static inline void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *r,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *m)
> +{
> +}
> +
> =A0static inline void
> =A0mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct=
 *p)
> =A0{
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf5ab87..850176e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -313,8 +313,8 @@ static bool move_file(void)
> =A0}
>
> =A0/*
> - * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> - * limit reclaim to prevent infinite loops, if they ever occur.
> + * Maximum loops in reclaim, used for soft limit reclaim to prevent
> + * infinite loops, if they ever occur.
> =A0*/
> =A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_RECLAIM_LOOPS =A0 =A0 =A0 =A0 =
=A0 =A0(100)
> =A0#define =A0 =A0 =A0 =A0MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS (2)
> @@ -340,7 +340,7 @@ enum charge_type {
> =A0#define OOM_CONTROL =A0 =A0 =A0 =A0 =A0 =A0(0)
>
> =A0/*
> - * Reclaim flags for mem_cgroup_hierarchical_reclaim
> + * Reclaim flags
> =A0*/
> =A0#define MEM_CGROUP_RECLAIM_NOSWAP_BIT =A00x0
> =A0#define MEM_CGROUP_RECLAIM_NOSWAP =A0 =A0 =A0(1 << MEM_CGROUP_RECLAIM_=
NOSWAP_BIT)
> @@ -846,8 +846,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum =
lru_list lru)
> =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no =
races. */
> =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 << compound_order(page);
> - =A0 =A0 =A0 if (mem_cgroup_is_root(pc->mem_cgroup))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0VM_BUG_ON(list_empty(&pc->lru));
> =A0 =A0 =A0 =A0list_del_init(&pc->lru);
> =A0}
> @@ -872,13 +870,11 @@ void mem_cgroup_rotate_reclaimable_page(struct page=
 *page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
> - =A0 =A0 =A0 /* unused or root page is not rotated. */
> + =A0 =A0 =A0 /* unused page is not rotated. */
> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0/* Ensure pc->mem_cgroup is visible after reading PCG_USED=
. */
> =A0 =A0 =A0 =A0smp_rmb();
> - =A0 =A0 =A0 if (mem_cgroup_is_root(pc->mem_cgroup))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> =A0 =A0 =A0 =A0list_move_tail(&pc->lru, &mz->lists[lru]);
> =A0}
> @@ -892,13 +888,11 @@ void mem_cgroup_rotate_lru_list(struct page *page, =
enum lru_list lru)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
> - =A0 =A0 =A0 /* unused or root page is not rotated. */
> + =A0 =A0 =A0 /* unused page is not rotated. */
> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0/* Ensure pc->mem_cgroup is visible after reading PCG_USED=
. */
> =A0 =A0 =A0 =A0smp_rmb();
> - =A0 =A0 =A0 if (mem_cgroup_is_root(pc->mem_cgroup))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> =A0 =A0 =A0 =A0list_move(&pc->lru, &mz->lists[lru]);
> =A0}
> @@ -920,8 +914,6 @@ void mem_cgroup_add_lru_list(struct page *page, enum =
lru_list lru)
> =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no =
races. */
> =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 << compound_order(page);
> =A0 =A0 =A0 =A0SetPageCgroupAcctLRU(pc);
> - =A0 =A0 =A0 if (mem_cgroup_is_root(pc->mem_cgroup))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0list_add(&pc->lru, &mz->lists[lru]);
> =A0}
>
> @@ -1381,6 +1373,97 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> =A0 =A0 =A0 =A0return min(limit, memsw);
> =A0}
>
> +/**
> + * mem_cgroup_hierarchy_walk - iterate over a memcg hierarchy
> + * @root: starting point of the hierarchy
> + * @prev: previous position or NULL
> + *
> + * Caller must hold a reference to @root. =A0While this function will
> + * return @root as part of the walk, it will never increase its
> + * reference count.
> + *
> + * Caller must clean up with mem_cgroup_stop_hierarchy_walk() when it
> + * stops the walk potentially before the full round trip.
> + */
> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct mem_cgroup *prev)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *mem;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 if (!root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 root =3D root_mem_cgroup;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Even without hierarchy explicitely enabled in the root
> + =A0 =A0 =A0 =A0* memcg, it is the ultimate parent of all memcgs.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!(root =3D=3D root_mem_cgroup || root->use_hierarchy))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return root;

Hmm, because ROOT cgroup has no limit and control, if root=3Droot_mem_cgrou=
p,
we do full hierarchy scan always. Right ?


> + =A0 =A0 =A0 if (prev && prev !=3D root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&prev->css);
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int id =3D root->last_scanned_child;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *css;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css =3D css_get_next(&mem_cgroup_subsys, id=
 + 1, &root->css, &id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css && (css =3D=3D &root->css || css_tr=
yget(css)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D container_of(css, s=
truct mem_cgroup, css);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 root->last_scanned_child =3D id;
> + =A0 =A0 =A0 } while (!mem);
> + =A0 =A0 =A0 return mem;
> +}
> +
> +/**
> + * mem_cgroup_stop_hierarchy_walk - clean up after partial hierarchy wal=
k
> + * @root: starting point in the hierarchy
> + * @mem: last position during the walk
> + */
> +void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 if (mem && mem !=3D root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&mem->css);
> +}

Recently I wonder it's better to cgroup_exclude_rmdir() and
cgroup_release_and_wakeup_rmdir() for this hierarchy scan...hm.


> +
> +static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 gfp_t gfp_mask,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long flags)
> +{
> + =A0 =A0 =A0 unsigned long total =3D 0;
> + =A0 =A0 =A0 bool noswap =3D false;
> + =A0 =A0 =A0 int loop;
> +
> + =A0 =A0 =A0 if ((flags & MEM_CGROUP_RECLAIM_NOSWAP) || mem->memsw_is_mi=
nimum)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap =3D true;
> + =A0 =A0 =A0 for (loop =3D 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop+=
+) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_async();

In recent patch, I removed this call here because this wakes up
kworker too much.
I will post that patch as a bugfix. So, please adjust this call
somewhere which is
not called frequently.


> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D try_to_free_mem_cgroup_pages(mem=
, gfp_mask, noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_swappiness(mem));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Avoid freeing too much when shrinking =
to resize the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* limit. =A0XXX: Shouldn't the margin ch=
eck be enough?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total && (flags & MEM_CGROUP_RECLAIM_SH=
RINK))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_margin(mem))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we have not been able to reclaim an=
ything after
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* two reclaim attempts, there may be no =
reclaimable
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages in this hierarchy.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop && !total)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return total;
> +}
> +
> =A0/*
> =A0* Visit the first child (need not be the first child as per the orderi=
ng
> =A0* of the cgroup list, since we track last_scanned_child) of @mem and u=
se
> @@ -1418,29 +1501,14 @@ mem_cgroup_select_victim(struct mem_cgroup *root_=
mem)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
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
> - *
> - * If shrink=3D=3Dtrue, for avoiding to free too much, this returns imme=
dieately.
> - */
> -static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long reclaim_options)
> +static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_mem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_=
t gfp_mask)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *victim;
> =A0 =A0 =A0 =A0int ret, total =3D 0;
> =A0 =A0 =A0 =A0int loop =3D 0;
> - =A0 =A0 =A0 bool noswap =3D reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP=
;
> - =A0 =A0 =A0 bool shrink =3D reclaim_options & MEM_CGROUP_RECLAIM_SHRINK=
;
> - =A0 =A0 =A0 bool check_soft =3D reclaim_options & MEM_CGROUP_RECLAIM_SO=
FT;
> + =A0 =A0 =A0 bool noswap =3D false;
> =A0 =A0 =A0 =A0unsigned long excess;
>
> =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&root_mem->res) >=
> PAGE_SHIFT;
> @@ -1461,7 +1529,7 @@ static int mem_cgroup_hierarchical_reclaim(struct m=
em_cgroup *root_mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * anythin=
g, it might because there are
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * no recl=
aimable pages under this hierarchy
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!check_=
soft || !total) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!total)=
 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -1483,26 +1551,11 @@ static int mem_cgroup_hierarchical_reclaim(struct=
 mem_cgroup *root_mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we use swappiness of local cgroup */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (check_soft)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_n=
ode_zone(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noswap, get=
_swappiness(victim), zone);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D try_to_free_mem_cgr=
oup_pages(victim, gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 noswap, get_swappiness(victim));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_shrink_node_zone(victim,=
 gfp_mask, noswap,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 get_swappiness(victim), zone);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* At shrinking usage, we can't check we =
should stop here or
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* reclaim more. It's depends on callers.=
 last_scanned_child
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* will work enough for keeping fairness =
under tree.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (shrink)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total +=3D ret;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (check_soft) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit=
_excess(&root_mem->res))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return tota=
l;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (mem_cgroup_margin(root_mem))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res_counter_soft_limit_excess(&root_me=
m->res))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return total;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return total;
> @@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *=
mem, gfp_t gfp_mask,
> =A0 =A0 =A0 =A0if (!(gfp_mask & __GFP_WAIT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_WOULDBLOCK;
>
> - =A0 =A0 =A0 ret =3D mem_cgroup_hierarchical_reclaim(mem_over_limit, NUL=
L,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 gfp_mask, flags);
> + =A0 =A0 =A0 ret =3D mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags)=
;
> =A0 =A0 =A0 =A0if (mem_cgroup_margin(mem_over_limit) >=3D nr_pages)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_RETRY;
> =A0 =A0 =A0 =A0/*

It seems this clean-up around hierarchy and softlimit can be in an
independent patch, no ?


> @@ -3085,7 +3137,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *me=
m,
>
> =A0/*
> =A0* A call to try to shrink memory usage on charge failure at shmem's sw=
apin.
> - * Calling hierarchical_reclaim is not enough because we should update
> + * Calling reclaim is not enough because we should update
> =A0* last_oom_jiffies to prevent pagefault_out_of_memory from invoking gl=
obal OOM.
> =A0* Moreover considering hierarchy, we should reclaim from the mem_over_=
limit,
> =A0* not from the memcg which this page would be charged to.
> @@ -3167,7 +3219,7 @@ static int mem_cgroup_resize_limit(struct mem_cgrou=
p *memcg,
> =A0 =A0 =A0 =A0int enlarge;
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* For keeping hierarchical_reclaim simple, how long we s=
hould retry
> + =A0 =A0 =A0 =A0* For keeping reclaim simple, how long we should retry
> =A0 =A0 =A0 =A0 * is depends on callers. We set our retry-count to be fun=
ction
> =A0 =A0 =A0 =A0 * of # of children which we should visit in this loop.
> =A0 =A0 =A0 =A0 */
> @@ -3210,8 +3262,8 @@ static int mem_cgroup_resize_limit(struct mem_cgrou=
p *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hierarchical_reclaim(memcg, NULL=
, GFP_KERNEL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SHRINK);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_reclaim(memcg, GFP_KERNEL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_=
CGROUP_RECLAIM_SHRINK);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0curusage =3D res_counter_read_u64(&memcg->=
res, RES_USAGE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage is reduced ? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (curusage >=3D oldusage)
> @@ -3269,9 +3321,9 @@ static int mem_cgroup_resize_memsw_limit(struct mem=
_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_hierarchical_reclaim(memcg, NULL=
, GFP_KERNEL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_NOSWAP |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SHRINK);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_reclaim(memcg, GFP_KERNEL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_=
CGROUP_RECLAIM_NOSWAP |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_=
CGROUP_RECLAIM_SHRINK);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0curusage =3D res_counter_read_u64(&memcg->=
memsw, RES_USAGE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Usage is reduced ? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (curusage >=3D oldusage)
> @@ -3311,9 +3363,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct =
zone *zone, int order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!mz)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_hierarchical_recla=
im(mz->mem, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_mask,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SOFT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaimed =3D mem_cgroup_soft_reclaim(mz->m=
em, zone, gfp_mask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_reclaimed +=3D reclaimed;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&mctz->lock);
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8bfd450..7e9bfca 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -104,7 +104,16 @@ struct scan_control {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0reclaim_mode_t reclaim_mode;
>
> - =A0 =A0 =A0 /* Which cgroup do we reclaim from */
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The memory cgroup that hit its hard limit and is the
> + =A0 =A0 =A0 =A0* primary target of this reclaim invocation.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct mem_cgroup *target_mem_cgroup;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The memory cgroup that is currently being scanned as a
> + =A0 =A0 =A0 =A0* child and contributor to the usage of target_mem_cgrou=
p.
> + =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0struct mem_cgroup *mem_cgroup;
>
> =A0 =A0 =A0 =A0/*
> @@ -154,9 +163,36 @@ static LIST_HEAD(shrinker_list);
> =A0static DECLARE_RWSEM(shrinker_rwsem);
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -#define scanning_global_lru(sc) =A0 =A0 =A0 =A0(!(sc)->mem_cgroup)
> +/**
> + * global_reclaim - whether reclaim is global or due to memcg hard limit
> + * @sc: scan control of this reclaim invocation
> + */
> +static bool global_reclaim(struct scan_control *sc)
> +{
> + =A0 =A0 =A0 return !sc->target_mem_cgroup;
> +}
> +/**
> + * scanning_global_lru - whether scanning global lrus or per-memcg lrus
> + * @sc: scan control of this reclaim invocation
> + */
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Unless memory cgroups are disabled on boot, the tradit=
ional
> + =A0 =A0 =A0 =A0* global lru lists are never scanned and reclaim will al=
ways
> + =A0 =A0 =A0 =A0* operate on the per-memcg lru lists.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 return mem_cgroup_disabled();
> +}
> =A0#else
> -#define scanning_global_lru(sc) =A0 =A0 =A0 =A0(1)
> +static bool global_reclaim(struct scan_control *sc)
> +{
> + =A0 =A0 =A0 return true;
> +}
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> + =A0 =A0 =A0 return true;
> +}
> =A0#endif
>
> =A0static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> @@ -1228,7 +1264,7 @@ static int too_many_isolated(struct zone *zone, int=
 file,
> =A0 =A0 =A0 =A0if (current_is_kswapd())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 if (!scanning_global_lru(sc))
> + =A0 =A0 =A0 if (!global_reclaim(sc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0if (file) {
> @@ -1397,13 +1433,6 @@ shrink_inactive_list(unsigned long nr_to_scan, str=
uct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->reclaim_mode & RECLAIM=
_MODE_LUMPYRECLAIM ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0ISOLATE_BOTH : ISOLATE_INACTIVE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, 0, file);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->pages_scanned +=3D nr_scanned;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSC=
AN_KSWAPD, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0nr_scanned);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSC=
AN_DIRECT, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0nr_scanned);
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken =3D mem_cgroup_isolate_pages(nr_t=
o_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&page_list, &nr_scanned, s=
c->order,
> @@ -1411,10 +1440,16 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0ISOLATE_BOTH : ISOLATE_INACTIVE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, sc->mem_cgroup,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00, file);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track=
 of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (global_reclaim(sc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->pages_scanned +=3D nr_scanned;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSC=
AN_KSWAPD, zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0nr_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSC=
AN_DIRECT, zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0nr_scanned);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (nr_taken =3D=3D 0) {
> @@ -1520,18 +1555,16 @@ static void shrink_active_list(unsigned long nr_p=
ages, struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&pgscanned, sc->order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0ISOLATE_ACTIVE, zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A01, file);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->pages_scanned +=3D pgscanned;
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken =3D mem_cgroup_isolate_pages(nr_p=
ages, &l_hold,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0&pgscanned, sc->order,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0ISOLATE_ACTIVE, zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0sc->mem_cgroup, 1, file);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track=
 of
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (global_reclaim(sc))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone->pages_scanned +=3D pgscanned;
> +
> =A0 =A0 =A0 =A0reclaim_stat->recent_scanned[file] +=3D nr_taken;
>
> =A0 =A0 =A0 =A0__count_zone_vm_events(PGREFILL, zone, pgscanned);
> @@ -1752,7 +1785,7 @@ static void get_scan_count(struct zone *zone, struc=
t scan_control *sc,
> =A0 =A0 =A0 =A0file =A0=3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_nr_lru_pages(zone, sc, LRU_INACTIVE_F=
ILE);
>
> - =A0 =A0 =A0 if (scanning_global_lru(sc)) {
> + =A0 =A0 =A0 if (global_reclaim(sc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free =A0=3D zone_page_state(zone, NR_FREE_=
PAGES);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* If we have very few page cache pages,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 force-scan anon pages. */
> @@ -1889,8 +1922,8 @@ static inline bool should_continue_reclaim(struct z=
one *zone,
> =A0/*
> =A0* This is a basic per-zone page freer. =A0Used by both kswapd and dire=
ct reclaim.
> =A0*/
> -static void shrink_zone(int priority, struct zone *zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan=
_control *sc)
> +static void do_shrink_zone(int priority, struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct scan_control =
*sc)
> =A0{
> =A0 =A0 =A0 =A0unsigned long nr[NR_LRU_LISTS];
> =A0 =A0 =A0 =A0unsigned long nr_to_scan;
> @@ -1943,6 +1976,31 @@ restart:
> =A0 =A0 =A0 =A0throttle_vm_writeout(sc->gfp_mask);
> =A0}
>
> +static void shrink_zone(int priority, struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
> +{
> + =A0 =A0 =A0 unsigned long nr_reclaimed_before =3D sc->nr_reclaimed;
> + =A0 =A0 =A0 struct mem_cgroup *root =3D sc->target_mem_cgroup;
> + =A0 =A0 =A0 struct mem_cgroup *first, *mem =3D NULL;
> +
> + =A0 =A0 =A0 first =3D mem =3D mem_cgroup_hierarchy_walk(root, mem);

Hmm, I think we should add some scheduling here, later.
(as select a group over softlimit or select a group which has
 easily reclaimable pages on this zone.)

This name as hierarchy_walk() sounds like "full scan in round-robin, always=
".
Could you find better name ?

> + =A0 =A0 =A0 for (;;) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->mem_cgroup =3D mem;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(priority, zone, sc);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed =3D sc->nr_reclaimed - nr_recl=
aimed_before;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D sc->nr_to_reclaim)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

what this calculation means ?  Shouldn't we do this quit based on the
number of "scan"
rather than "reclaimed" ?

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_hierarchy_walk(root, mem=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem =3D=3D first)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

Why we quit loop  ?

> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 mem_cgroup_stop_hierarchy_walk(root, mem);
> +}



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
