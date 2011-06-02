Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C4EF06B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 09:17:05 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1449987bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 06:17:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
Date: Thu, 2 Jun 2011 22:16:59 +0900
Message-ID: <BANLkTinHs7OCkpRf8=dYO0ObH5sndZ4__g@mail.gmail.com>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> All lru list walkers have been converted to operate on per-memcg
> lists, the global per-zone lists are no longer required.
>
> This patch makes the per-memcg lists exclusive and removes the global
> lists from memcg-enabled kernels.
>
> The per-memcg lists now string up page descriptors directly, which
> unifies/simplifies the list isolation code of page reclaim as well as
> it saves a full double-linked list head for each page in the system.
>
> At the core of this change is the introduction of the lruvec
> structure, an array of all lru list heads. =A0It exists for each zone
> globally, and for each zone per memcg. =A0All lru list operations are
> now done in generic code against lruvecs, with the memcg lru list
> primitives only doing accounting and returning the proper lruvec for
> the currently scanned memcg on isolation, or for the respective page
> on putback.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>


could you divide this into
  - introduce lruvec
  - don't record section? information into pc->flags because we see
"page" on memcg LRU
    and there is no requirement to get page from "pc".
  - remove pc->lru completely
?
Thanks,
-Kame

> ---
> =A0include/linux/memcontrol.h =A0| =A0 53 ++++-----
> =A0include/linux/mm_inline.h =A0 | =A0 14 ++-
> =A0include/linux/mmzone.h =A0 =A0 =A0| =A0 10 +-
> =A0include/linux/page_cgroup.h | =A0 36 ------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0271 ++++++++++++++++++---=
----------------------
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0mm/page_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 38 +------
> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 20 ++--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 88 ++++++--------
> =A09 files changed, 207 insertions(+), 325 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 56c1def..d3837f0 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -20,6 +20,7 @@
> =A0#ifndef _LINUX_MEMCONTROL_H
> =A0#define _LINUX_MEMCONTROL_H
> =A0#include <linux/cgroup.h>
> +#include <linux/mmzone.h>
> =A0struct mem_cgroup;
> =A0struct page_cgroup;
> =A0struct page;
> @@ -30,13 +31,6 @@ enum mem_cgroup_page_stat_item {
> =A0 =A0 =A0 =A0MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> =A0};
>
> -extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct list_head *dst,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long *scanned, int order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int mode, struct zone *z,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct mem_cgroup *mem_cont,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int active, int file);
> -
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> =A0/*
> =A0* All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -60,15 +54,14 @@ extern void mem_cgroup_cancel_charge_swapin(struct me=
m_cgroup *ptr);
>
> =A0extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct=
 *mm,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask);
> -struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enu=
m lru_list);
> -extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru=
);
> -extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru=
);
> -extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
> -extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list =
lru);
> -extern void mem_cgroup_del_lru(struct page *page);
> -extern void mem_cgroup_move_lists(struct page *page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lr=
u_list from, enum lru_list to);
> +
> +struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *=
);
> +struct lruvec *mem_cgroup_lru_add_list(struct zone *, struct page *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0enum lru_list);
> +void mem_cgroup_lru_del_list(struct page *, enum lru_list);
> +void mem_cgroup_lru_del(struct page *);
> +struct lruvec *mem_cgroup_lru_move_lists(struct zone *, struct page *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0enum lru_list, enum lru_list);
>
> =A0/* For coalescing uncharge for reducing memcg' overhead*/
> =A0extern void mem_cgroup_uncharge_start(void);
> @@ -214,33 +207,33 @@ static inline int mem_cgroup_shmem_charge_fallback(=
struct page *page,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
> -{
> -}
> -
> -static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
> +static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *mem)
> =A0{
> - =A0 =A0 =A0 return ;
> + =A0 =A0 =A0 return &zone->lruvec;
> =A0}
>
> -static inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
> +static inline struct lruvec *mem_cgroup_lru_add_list(struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list lru)
> =A0{
> - =A0 =A0 =A0 return ;
> + =A0 =A0 =A0 return &zone->lruvec;
> =A0}
>
> -static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru=
)
> +static inline void mem_cgroup_lru_del_list(struct page *page, enum lru_l=
ist lru)
> =A0{
> - =A0 =A0 =A0 return ;
> =A0}
>
> -static inline void mem_cgroup_del_lru(struct page *page)
> +static inline void mem_cgroup_lru_del(struct page *page)
> =A0{
> - =A0 =A0 =A0 return ;
> =A0}
>
> -static inline void
> -mem_cgroup_move_lists(struct page *page, enum lru_list from, enum lru_li=
st to)
> +static inline struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list from,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list to)
> =A0{
> + =A0 =A0 =A0 return &zone->lruvec;
> =A0}
>
> =A0static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct p=
age *page)
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 8f7d247..43d5d9f 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -25,23 +25,27 @@ static inline void
> =A0__add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_=
list l,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *head)
> =A0{
> + =A0 =A0 =A0 /* NOTE: Caller must ensure @head is on the right lruvec! *=
/
> + =A0 =A0 =A0 mem_cgroup_lru_add_list(zone, page, l);
> =A0 =A0 =A0 =A0list_add(&page->lru, head);
> =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_page=
s(page));
> - =A0 =A0 =A0 mem_cgroup_add_lru_list(page, l);
> =A0}
>
> =A0static inline void
> =A0add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_li=
st l)
> =A0{
> - =A0 =A0 =A0 __add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
> + =A0 =A0 =A0 struct lruvec *lruvec =3D mem_cgroup_lru_add_list(zone, pag=
e, l);
> +
> + =A0 =A0 =A0 list_add(&page->lru, &lruvec->lists[l]);
> + =A0 =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages=
(page));
> =A0}
>
> =A0static inline void
> =A0del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_=
list l)
> =A0{
> + =A0 =A0 =A0 mem_cgroup_lru_del_list(page, l);
> =A0 =A0 =A0 =A0list_del(&page->lru);
> =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pag=
es(page));
> - =A0 =A0 =A0 mem_cgroup_del_lru_list(page, l);
> =A0}
>
> =A0/**
> @@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
> =A0{
> =A0 =A0 =A0 =A0enum lru_list l;
>
> - =A0 =A0 =A0 list_del(&page->lru);
> =A0 =A0 =A0 =A0if (PageUnevictable(page)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__ClearPageUnevictable(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0l =3D LRU_UNEVICTABLE;
> @@ -75,8 +78,9 @@ del_page_from_lru(struct zone *zone, struct page *page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0l +=3D LRU_ACTIVE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 mem_cgroup_lru_del_list(page, l);
> + =A0 =A0 =A0 list_del(&page->lru);
> =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pag=
es(page));
> - =A0 =A0 =A0 mem_cgroup_del_lru_list(page, l);
> =A0}
>
> =A0/**
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e56f835..c2ddce5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -158,6 +158,10 @@ static inline int is_unevictable_lru(enum lru_list l=
)
> =A0 =A0 =A0 =A0return (l =3D=3D LRU_UNEVICTABLE);
> =A0}
>
> +struct lruvec {
> + =A0 =A0 =A0 struct list_head lists[NR_LRU_LISTS];
> +};
> +
> =A0enum zone_watermarks {
> =A0 =A0 =A0 =A0WMARK_MIN,
> =A0 =A0 =A0 =A0WMARK_LOW,
> @@ -344,10 +348,8 @@ struct zone {
> =A0 =A0 =A0 =A0ZONE_PADDING(_pad1_)
>
> =A0 =A0 =A0 =A0/* Fields commonly accessed by the page reclaim scanner */
> - =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_lock;
> - =A0 =A0 =A0 struct zone_lru {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head list;
> - =A0 =A0 =A0 } lru[NR_LRU_LISTS];
> + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_lock;
> + =A0 =A0 =A0 struct lruvec =A0 =A0 =A0 =A0 =A0 lruvec;
>
> =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 961ecc7..a42ddf9 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -31,7 +31,6 @@ enum {
> =A0struct page_cgroup {
> =A0 =A0 =A0 =A0unsigned long flags;
> =A0 =A0 =A0 =A0struct mem_cgroup *mem_cgroup;
> - =A0 =A0 =A0 struct list_head lru; =A0 =A0 =A0 =A0 =A0 /* per cgroup LRU=
 list */
> =A0};
>
> =A0void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> @@ -49,7 +48,6 @@ static inline void __init page_cgroup_init(void)
> =A0#endif
>
> =A0struct page_cgroup *lookup_page_cgroup(struct page *page);
> -struct page *lookup_cgroup_page(struct page_cgroup *pc);
>
> =A0#define TESTPCGFLAG(uname, lname) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0\
> =A0static inline int PageCgroup##uname(struct page_cgroup *pc) =A0 =A0\
> @@ -121,40 +119,6 @@ static inline void move_unlock_page_cgroup(struct pa=
ge_cgroup *pc,
> =A0 =A0 =A0 =A0bit_spin_unlock(PCG_MOVE_LOCK, &pc->flags);
> =A0 =A0 =A0 =A0local_irq_restore(*flags);
> =A0}
> -
> -#ifdef CONFIG_SPARSEMEM
> -#define PCG_ARRAYID_WIDTH =A0 =A0 =A0SECTIONS_SHIFT
> -#else
> -#define PCG_ARRAYID_WIDTH =A0 =A0 =A0NODES_SHIFT
> -#endif
> -
> -#if (PCG_ARRAYID_WIDTH > BITS_PER_LONG - NR_PCG_FLAGS)
> -#error Not enough space left in pc->flags to store page_cgroup array IDs
> -#endif
> -
> -/* pc->flags: ARRAY-ID | FLAGS */
> -
> -#define PCG_ARRAYID_MASK =A0 =A0 =A0 ((1UL << PCG_ARRAYID_WIDTH) - 1)
> -
> -#define PCG_ARRAYID_OFFSET =A0 =A0 (BITS_PER_LONG - PCG_ARRAYID_WIDTH)
> -/*
> - * Zero the shift count for non-existent fields, to prevent compiler
> - * warnings and ensure references are optimized away.
> - */
> -#define PCG_ARRAYID_SHIFT =A0 =A0 =A0(PCG_ARRAYID_OFFSET * (PCG_ARRAYID_=
WIDTH !=3D 0))
> -
> -static inline void set_page_cgroup_array_id(struct page_cgroup *pc,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 unsigned long id)
> -{
> - =A0 =A0 =A0 pc->flags &=3D ~(PCG_ARRAYID_MASK << PCG_ARRAYID_SHIFT);
> - =A0 =A0 =A0 pc->flags |=3D (id & PCG_ARRAYID_MASK) << PCG_ARRAYID_SHIFT=
;
> -}
> -
> -static inline unsigned long page_cgroup_array_id(struct page_cgroup *pc)
> -{
> - =A0 =A0 =A0 return (pc->flags >> PCG_ARRAYID_SHIFT) & PCG_ARRAYID_MASK;
> -}
> -
> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> =A0struct page_cgroup;
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d9d1a7e..4a365b7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -133,10 +133,7 @@ struct mem_cgroup_stat_cpu {
> =A0* per-zone information in memory controller.
> =A0*/
> =A0struct mem_cgroup_per_zone {
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* spin_lock to protect the per cgroup LRU
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0lists[NR_LRU_LISTS];
> + =A0 =A0 =A0 struct lruvec =A0 =A0 =A0 =A0 =A0 lruvec;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 count[NR_LRU_LISTS];
>
> =A0 =A0 =A0 =A0struct zone_reclaim_stat reclaim_stat;
> @@ -642,6 +639,26 @@ static inline bool mem_cgroup_is_root(struct mem_cgr=
oup *mem)
> =A0 =A0 =A0 =A0return (mem =3D=3D root_mem_cgroup);
> =A0}
>
> +/**
> + * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
> + * @zone: zone of the wanted lruvec
> + * @mem: memcg of the wanted lruvec
> + *
> + * Returns the lru list vector holding pages for the given @zone and
> + * @mem. =A0This can be the global zone lruvec, if the memory controller
> + * is disabled.
> + */
> +struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone, struct mem_cgro=
up *mem)
> +{
> + =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &zone->lruvec;
> +
> + =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx=
(zone));
> + =A0 =A0 =A0 return &mz->lruvec;
> +}
> +
> =A0/*
> =A0* Following LRU functions are allowed to be used without PCG_LOCK.
> =A0* Operations are called by routine of global LRU independently from me=
mcg.
> @@ -656,21 +673,74 @@ static inline bool mem_cgroup_is_root(struct mem_cg=
roup *mem)
> =A0* When moving account, the page is not on LRU. It's isolated.
> =A0*/
>
> -struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup=
 *mem,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enu=
m lru_list lru)
> +/**
> + * mem_cgroup_lru_add_list - account for adding an lru page and return l=
ruvec
> + * @zone: zone of the page
> + * @page: the page itself
> + * @lru: target lru list
> + *
> + * This function must be called when a page is to be added to an lru
> + * list.
> + *
> + * Returns the lruvec to hold @page, the callsite is responsible for
> + * physically linking the page to &lruvec->lists[@lru].
> + */
> +struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *p=
age,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0enum lru_list lru)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;
> =A0 =A0 =A0 =A0struct page_cgroup *pc;
> + =A0 =A0 =A0 struct mem_cgroup *mem;
>
> - =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx=
(zone));
> - =A0 =A0 =A0 pc =3D list_entry(mz->lists[lru].prev, struct page_cgroup, =
lru);
> - =A0 =A0 =A0 return lookup_cgroup_page(pc);
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &zone->lruvec;
> +
> + =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> + =A0 =A0 =A0 VM_BUG_ON(PageCgroupAcctLRU(pc));
> + =A0 =A0 =A0 if (PageCgroupUsed(pc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Ensure pc->mem_cgroup is visible after r=
eading PCG_USED. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_rmb();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D pc->mem_cgroup;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page is no longer charged, add =
it to the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* root memcg's lru. =A0Either it will be=
 freed soon, or
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it will get charged again and the char=
ger will
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* relink it to the right list.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D root_mem_cgroup;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(mem, page);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We do not account for uncharged pages: they are linked=
 to
> + =A0 =A0 =A0 =A0* root_mem_cgroup but when the page is unlinked upon fre=
e,
> + =A0 =A0 =A0 =A0* accounting would be done against pc->mem_cgroup.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (PageCgroupUsed(pc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Huge page splitting is serialized thro=
ugh the lru
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* lock, so compound_order() is stable he=
re.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 << compoun=
d_order(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageCgroupAcctLRU(pc);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return &mz->lruvec;
> =A0}
>
> -void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> +/**
> + * mem_cgroup_lru_del_list - account for removing an lru page
> + * @page: page to unlink
> + * @lru: lru list the page is sitting on
> + *
> + * This function must be called when a page is to be removed from an
> + * lru list.
> + *
> + * The callsite is responsible for physically unlinking &@page->lru.
> + */
> +void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
> =A0{
> - =A0 =A0 =A0 struct page_cgroup *pc;
> =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;
> + =A0 =A0 =A0 struct page_cgroup *pc;
>
> =A0 =A0 =A0 =A0if (mem_cgroup_disabled())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -686,75 +756,35 @@ void mem_cgroup_del_lru_list(struct page *page, enu=
m lru_list lru)
> =A0 =A0 =A0 =A0mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no =
races. */
> =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 << compound_order(page);
> - =A0 =A0 =A0 VM_BUG_ON(list_empty(&pc->lru));
> - =A0 =A0 =A0 list_del_init(&pc->lru);
> =A0}
>
> -void mem_cgroup_del_lru(struct page *page)
> +void mem_cgroup_lru_del(struct page *page)
> =A0{
> - =A0 =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page));
> + =A0 =A0 =A0 mem_cgroup_lru_del_list(page, page_lru(page));
> =A0}
>
> -/*
> - * Writeback is about to end against a page which has been marked for im=
mediate
> - * reclaim. =A0If it still appears to be reclaimable, move it to the tai=
l of the
> - * inactive list.
> +/**
> + * mem_cgroup_lru_move_lists - account for moving a page between lru lis=
ts
> + * @zone: zone of the page
> + * @page: page to move
> + * @from: current lru list
> + * @to: new lru list
> + *
> + * This function must be called when a page is moved between lru
> + * lists, or rotated on the same lru list.
> + *
> + * Returns the lruvec to hold @page in the future, the callsite is
> + * responsible for physically relinking the page to
> + * &lruvec->lists[@to].
> =A0*/
> -void mem_cgroup_rotate_reclaimable_page(struct page *page)
> -{
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct page_cgroup *pc;
> - =A0 =A0 =A0 enum lru_list lru =3D page_lru(page);
> -
> - =A0 =A0 =A0 if (mem_cgroup_disabled())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> - =A0 =A0 =A0 /* unused page is not rotated. */
> - =A0 =A0 =A0 if (!PageCgroupUsed(pc))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 /* Ensure pc->mem_cgroup is visible after reading PCG_USED.=
 */
> - =A0 =A0 =A0 smp_rmb();
> - =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> - =A0 =A0 =A0 list_move_tail(&pc->lru, &mz->lists[lru]);
> -}
> -
> -void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
> +struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0enum lru_list from,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0enum lru_list to)
> =A0{
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct page_cgroup *pc;
> -
> - =A0 =A0 =A0 if (mem_cgroup_disabled())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> - =A0 =A0 =A0 /* unused page is not rotated. */
> - =A0 =A0 =A0 if (!PageCgroupUsed(pc))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 /* Ensure pc->mem_cgroup is visible after reading PCG_USED.=
 */
> - =A0 =A0 =A0 smp_rmb();
> - =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> - =A0 =A0 =A0 list_move(&pc->lru, &mz->lists[lru]);
> -}
> -
> -void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
> -{
> - =A0 =A0 =A0 struct page_cgroup *pc;
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> -
> - =A0 =A0 =A0 if (mem_cgroup_disabled())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> - =A0 =A0 =A0 VM_BUG_ON(PageCgroupAcctLRU(pc));
> - =A0 =A0 =A0 if (!PageCgroupUsed(pc))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 /* Ensure pc->mem_cgroup is visible after reading PCG_USED.=
 */
> - =A0 =A0 =A0 smp_rmb();
> - =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
> - =A0 =A0 =A0 /* huge page split is done under lru_lock. so, we have no r=
aces. */
> - =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 << compound_order(page);
> - =A0 =A0 =A0 SetPageCgroupAcctLRU(pc);
> - =A0 =A0 =A0 list_add(&pc->lru, &mz->lists[lru]);
> + =A0 =A0 =A0 /* TODO: this could be optimized, especially if from =3D=3D=
 to */
> + =A0 =A0 =A0 mem_cgroup_lru_del_list(page, from);
> + =A0 =A0 =A0 return mem_cgroup_lru_add_list(zone, page, to);
> =A0}
>
> =A0/*
> @@ -786,7 +816,7 @@ static void mem_cgroup_lru_del_before_commit(struct p=
age *page)
> =A0 =A0 =A0 =A0 * is guarded by lock_page() because the page is SwapCache=
.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (!PageCgroupUsed(pc))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page=
));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_lru(zone, page);
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, flags);
> =A0}
>
> @@ -800,22 +830,11 @@ static void mem_cgroup_lru_add_after_commit(struct =
page *page)
> =A0 =A0 =A0 =A0if (likely(!PageLRU(page)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0spin_lock_irqsave(&zone->lru_lock, flags);
> - =A0 =A0 =A0 /* link when the page is linked to LRU but page_cgroup isn'=
t */
> =A0 =A0 =A0 =A0if (PageLRU(page) && !PageCgroupAcctLRU(pc))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_add_lru_list(page, page_lru(page=
));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_lru_list(zone, page, page_lru(p=
age));
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, flags);
> =A0}
>
> -
> -void mem_cgroup_move_lists(struct page *page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list from, =
enum lru_list to)
> -{
> - =A0 =A0 =A0 if (mem_cgroup_disabled())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 mem_cgroup_del_lru_list(page, from);
> - =A0 =A0 =A0 mem_cgroup_add_lru_list(page, to);
> -}
> -
> =A0int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgro=
up *mem)
> =A0{
> =A0 =A0 =A0 =A0int ret;
> @@ -935,67 +954,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *p=
age)
> =A0 =A0 =A0 =A0return &mz->reclaim_stat;
> =A0}
>
> -unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct list_head *dst,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long *scanned, int order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int mode, struct zone *z,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct mem_cgroup *mem_cont,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int active, int file)
> -{
> - =A0 =A0 =A0 unsigned long nr_taken =3D 0;
> - =A0 =A0 =A0 struct page *page;
> - =A0 =A0 =A0 unsigned long scan;
> - =A0 =A0 =A0 LIST_HEAD(pc_list);
> - =A0 =A0 =A0 struct list_head *src;
> - =A0 =A0 =A0 struct page_cgroup *pc, *tmp;
> - =A0 =A0 =A0 int nid =3D zone_to_nid(z);
> - =A0 =A0 =A0 int zid =3D zone_idx(z);
> - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 int lru =3D LRU_FILE * file + active;
> - =A0 =A0 =A0 int ret;
> -
> - =A0 =A0 =A0 BUG_ON(!mem_cont);
> - =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem_cont, nid, zid);
> - =A0 =A0 =A0 src =3D &mz->lists[lru];
> -
> - =A0 =A0 =A0 scan =3D 0;
> - =A0 =A0 =A0 list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scan >=3D nr_to_scan)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!PageCgroupUsed(pc)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lookup_cgroup_page(pc);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!PageLRU(page)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __isolate_lru_page(page, mode, file=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, dst);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken +=3D hpage_nr_page=
s(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case -EBUSY:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we don't affect global L=
RU but rotate in our LRU */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list(=
page, page_lru(page));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 *scanned =3D scan;
> -
> - =A0 =A0 =A0 trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 0, 0, 0, mode);
> -
> - =A0 =A0 =A0 return nr_taken;
> -}
> -
> =A0#define mem_cgroup_from_res_counter(counter, member) =A0 \
> =A0 =A0 =A0 =A0container_of(counter, struct mem_cgroup, member)
>
> @@ -3110,22 +3068,23 @@ static int mem_cgroup_resize_memsw_limit(struct m=
em_cgroup *memcg,
> =A0static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int node, =
int zid, enum lru_list lru)
> =A0{
> - =A0 =A0 =A0 struct zone *zone;
> =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;
> - =A0 =A0 =A0 struct page_cgroup *pc, *busy;
> =A0 =A0 =A0 =A0unsigned long flags, loop;
> =A0 =A0 =A0 =A0struct list_head *list;
> + =A0 =A0 =A0 struct page *busy;
> + =A0 =A0 =A0 struct zone *zone;
> =A0 =A0 =A0 =A0int ret =3D 0;
>
> =A0 =A0 =A0 =A0zone =3D &NODE_DATA(node)->node_zones[zid];
> =A0 =A0 =A0 =A0mz =3D mem_cgroup_zoneinfo(mem, node, zid);
> - =A0 =A0 =A0 list =3D &mz->lists[lru];
> + =A0 =A0 =A0 list =3D &mz->lruvec.lists[lru];
>
> =A0 =A0 =A0 =A0loop =3D MEM_CGROUP_ZSTAT(mz, lru);
> =A0 =A0 =A0 =A0/* give some margin against EBUSY etc...*/
> =A0 =A0 =A0 =A0loop +=3D 256;
> =A0 =A0 =A0 =A0busy =3D NULL;
> =A0 =A0 =A0 =A0while (loop--) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page_cgroup *pc;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D 0;
> @@ -3134,16 +3093,16 @@ static int mem_cgroup_force_empty_list(struct mem=
_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zo=
ne->lru_lock, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc =3D list_entry(list->prev, struct page_c=
group, lru);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (busy =3D=3D pc) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&pc->lru, list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D list_entry(list->prev, struct page=
, lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (busy =3D=3D page) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, list)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zo=
ne->lru_lock, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, fl=
ags);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lookup_cgroup_page(pc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_move_parent(page, pc, m=
em, GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret =3D=3D -ENOMEM)
> @@ -3151,7 +3110,7 @@ static int mem_cgroup_force_empty_list(struct mem_c=
group *mem,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret =3D=3D -EBUSY || ret =3D=3D -EINVA=
L) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* found lock contention o=
r "pc" is obsolete. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 busy =3D pc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 busy =3D page;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D NULL;
> @@ -4171,7 +4130,7 @@ static int alloc_mem_cgroup_per_zone_info(struct me=
m_cgroup *mem, int node)
> =A0 =A0 =A0 =A0for (zone =3D 0; zone < MAX_NR_ZONES; zone++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz =3D &pn->zoneinfo[zone];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(l)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&mz->lists[l=
]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&mz->lruvec.=
lists[l]);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> =A0}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3f8bce2..9da238d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4289,7 +4289,7 @@ static void __paginginit free_area_init_core(struct=
 pglist_data *pgdat,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone_pcp_init(zone);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_lru(l) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&zone->lru[l=
].list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&zone->lruve=
c.lists[l]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->reclaim_stat.nr_save=
d_scan[l] =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->reclaim_stat.recent_rotated[0] =3D 0=
;
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 2daadc3..916c6f9 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -11,12 +11,10 @@
> =A0#include <linux/swapops.h>
> =A0#include <linux/kmemleak.h>
>
> -static void __meminit init_page_cgroup(struct page_cgroup *pc, unsigned =
long id)
> +static void __meminit init_page_cgroup(struct page_cgroup *pc)
> =A0{
> =A0 =A0 =A0 =A0pc->flags =3D 0;
> - =A0 =A0 =A0 set_page_cgroup_array_id(pc, id);
> =A0 =A0 =A0 =A0pc->mem_cgroup =3D NULL;
> - =A0 =A0 =A0 INIT_LIST_HEAD(&pc->lru);
> =A0}
> =A0static unsigned long total_usage;
>
> @@ -42,19 +40,6 @@ struct page_cgroup *lookup_page_cgroup(struct page *pa=
ge)
> =A0 =A0 =A0 =A0return base + offset;
> =A0}
>
> -struct page *lookup_cgroup_page(struct page_cgroup *pc)
> -{
> - =A0 =A0 =A0 unsigned long pfn;
> - =A0 =A0 =A0 struct page *page;
> - =A0 =A0 =A0 pg_data_t *pgdat;
> -
> - =A0 =A0 =A0 pgdat =3D NODE_DATA(page_cgroup_array_id(pc));
> - =A0 =A0 =A0 pfn =3D pc - pgdat->node_page_cgroup + pgdat->node_start_pf=
n;
> - =A0 =A0 =A0 page =3D pfn_to_page(pfn);
> - =A0 =A0 =A0 VM_BUG_ON(pc !=3D lookup_page_cgroup(page));
> - =A0 =A0 =A0 return page;
> -}
> -
> =A0static int __init alloc_node_page_cgroup(int nid)
> =A0{
> =A0 =A0 =A0 =A0struct page_cgroup *base, *pc;
> @@ -75,7 +60,7 @@ static int __init alloc_node_page_cgroup(int nid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0for (index =3D 0; index < nr_pages; index++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D base + index;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc, nid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0NODE_DATA(nid)->node_page_cgroup =3D base;
> =A0 =A0 =A0 =A0total_usage +=3D table_size;
> @@ -117,19 +102,6 @@ struct page_cgroup *lookup_page_cgroup(struct page *=
page)
> =A0 =A0 =A0 =A0return section->page_cgroup + pfn;
> =A0}
>
> -struct page *lookup_cgroup_page(struct page_cgroup *pc)
> -{
> - =A0 =A0 =A0 struct mem_section *section;
> - =A0 =A0 =A0 struct page *page;
> - =A0 =A0 =A0 unsigned long nr;
> -
> - =A0 =A0 =A0 nr =3D page_cgroup_array_id(pc);
> - =A0 =A0 =A0 section =3D __nr_to_section(nr);
> - =A0 =A0 =A0 page =3D pfn_to_page(pc - section->page_cgroup);
> - =A0 =A0 =A0 VM_BUG_ON(pc !=3D lookup_page_cgroup(page));
> - =A0 =A0 =A0 return page;
> -}
> -
> =A0static void *__init_refok alloc_page_cgroup(size_t size, int nid)
> =A0{
> =A0 =A0 =A0 =A0void *addr =3D NULL;
> @@ -167,11 +139,9 @@ static int __init_refok init_section_page_cgroup(uns=
igned long pfn)
> =A0 =A0 =A0 =A0struct page_cgroup *base, *pc;
> =A0 =A0 =A0 =A0struct mem_section *section;
> =A0 =A0 =A0 =A0unsigned long table_size;
> - =A0 =A0 =A0 unsigned long nr;
> =A0 =A0 =A0 =A0int nid, index;
>
> - =A0 =A0 =A0 nr =3D pfn_to_section_nr(pfn);
> - =A0 =A0 =A0 section =3D __nr_to_section(nr);
> + =A0 =A0 =A0 section =3D __pfn_to_section(pfn);
>
> =A0 =A0 =A0 =A0if (section->page_cgroup)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> @@ -194,7 +164,7 @@ static int __init_refok init_section_page_cgroup(unsi=
gned long pfn)
>
> =A0 =A0 =A0 =A0for (index =3D 0; index < PAGES_PER_SECTION; index++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D base + index;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc, nr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_page_cgroup(pc);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0section->page_cgroup =3D base - pfn;
> diff --git a/mm/swap.c b/mm/swap.c
> index 5602f1a..0a5a93b 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -209,12 +209,14 @@ static void pagevec_lru_move_fn(struct pagevec *pve=
c,
> =A0static void pagevec_move_tail_fn(struct page *page, void *arg)
> =A0{
> =A0 =A0 =A0 =A0int *pgmoved =3D arg;
> - =A0 =A0 =A0 struct zone *zone =3D page_zone(page);
>
> =A0 =A0 =A0 =A0if (PageLRU(page) && !PageActive(page) && !PageUnevictable=
(page)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list lru =3D page_lru_base_type(p=
age);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&page->lru, &zone->lru[lru].=
list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_reclaimable_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(page_z=
one(page),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0page, lru, lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&page->lru, &lruvec->lists[l=
ru]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*pgmoved)++;
> =A0 =A0 =A0 =A0}
> =A0}
> @@ -420,12 +422,13 @@ static void lru_deactivate_fn(struct page *page, vo=
id *arg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageReclaim(page);
> =A0 =A0 =A0 =A0} else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * The page's writeback ends up during pag=
evec
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We moves tha page into tail of inactive=
.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&page->lru, &zone->lru[lru].=
list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_reclaimable_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(zone, =
page, lru, lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&page->lru, &lruvec->lists[l=
ru]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_event(PGROTATED);
> =A0 =A0 =A0 =A0}
>
> @@ -597,7 +600,6 @@ void lru_add_page_tail(struct zone* zone,
> =A0 =A0 =A0 =A0int active;
> =A0 =A0 =A0 =A0enum lru_list lru;
> =A0 =A0 =A0 =A0const int file =3D 0;
> - =A0 =A0 =A0 struct list_head *head;
>
> =A0 =A0 =A0 =A0VM_BUG_ON(!PageHead(page));
> =A0 =A0 =A0 =A0VM_BUG_ON(PageCompound(page_tail));
> @@ -617,10 +619,10 @@ void lru_add_page_tail(struct zone* zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0update_page_reclaim_stat(zone, page_tail, =
file, active);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (likely(PageLRU(page)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D page->lru.prev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __add_page_to_lru_list(zone=
, page_tail, lru,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0page->lru.prev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D &zone->lru[lru].li=
st;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __add_page_to_lru_list(zone, page_tail, lru=
, head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_lru_list(zone, =
page_tail, lru);
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageUnevictable(page_tail);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_page_to_lru_list(zone, page_tail, LRU_=
UNEVICTABLE);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 23fd2b1..87e1fcb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1080,15 +1080,14 @@ static unsigned long isolate_lru_pages(unsigned l=
ong nr_to_scan,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (__isolate_lru_page(page, mode, fil=
e)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 0:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_lru_del(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&page->lru, dst)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken +=3D hpage_nr_pag=
es(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case -EBUSY:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* else it is being freed =
elsewhere */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&page->lru, src)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list(=
page, page_lru(page));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> @@ -1138,8 +1137,8 @@ static unsigned long isolate_lru_pages(unsigned lon=
g nr_to_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (__isolate_lru_page(cur=
sor_page, mode, file) =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_=
lru_del(cursor_page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(=
&cursor_page->lru, dst);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_=
del_lru(cursor_page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_taken +=
=3D hpage_nr_pages(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_lumpy_t=
aken++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageDi=
rty(cursor_page))
> @@ -1168,19 +1167,22 @@ static unsigned long isolate_lru_pages(unsigned l=
ong nr_to_scan,
> =A0 =A0 =A0 =A0return nr_taken;
> =A0}
>
> -static unsigned long isolate_pages_global(unsigned long nr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct list_head *dst,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long *scanned, int order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int mode, struct zone *z,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int active, int file)
> +static unsigned long isolate_pages(unsigned long nr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct list_head *dst,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsi=
gned long *scanned, int order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =
mode, struct zone *z,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =
active, int file,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct mem_cgroup *mem)
> =A0{
> + =A0 =A0 =A0 struct lruvec *lruvec =3D mem_cgroup_zone_lruvec(z, mem);
> =A0 =A0 =A0 =A0int lru =3D LRU_BASE;
> +
> =A0 =A0 =A0 =A0if (active)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru +=3D LRU_ACTIVE;
> =A0 =A0 =A0 =A0if (file)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru +=3D LRU_FILE;
> - =A0 =A0 =A0 return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanne=
d, order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mode, file);
> + =A0 =A0 =A0 return isolate_lru_pages(nr, &lruvec->lists[lru], dst,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scanned,=
 order, mode, file);
> =A0}
>
> =A0/*
> @@ -1428,20 +1430,11 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct zone *zone,
> =A0 =A0 =A0 =A0lru_add_drain();
> =A0 =A0 =A0 =A0spin_lock_irq(&zone->lru_lock);
>
> - =A0 =A0 =A0 if (scanning_global_lru(sc)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D isolate_pages_global(nr_to_sca=
n,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &page_list, &nr_scanned, sc=
->order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode & RECLAIM_=
MODE_LUMPYRECLAIM ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ISOLATE_BOTH : ISOLATE_INACTIVE,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, 0, file);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D mem_cgroup_isolate_pages(nr_to=
_scan,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &page_list, &nr_scanned, sc=
->order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->reclaim_mode & RECLAIM_=
MODE_LUMPYRECLAIM ?
> + =A0 =A0 =A0 nr_taken =3D isolate_pages(nr_to_scan,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&page_li=
st, &nr_scanned, sc->order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->recl=
aim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0ISOLATE_BOTH : ISOLATE_INACTIVE,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc->mem_cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone, 0,=
 file, sc->mem_cgroup);
>
> =A0 =A0 =A0 =A0if (global_reclaim(sc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->pages_scanned +=3D nr_scanned;
> @@ -1514,13 +1507,15 @@ static void move_active_pages_to_lru(struct zone =
*zone,
> =A0 =A0 =A0 =A0pagevec_init(&pvec, 1);
>
> =A0 =A0 =A0 =A0while (!list_empty(list)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D lru_to_page(list);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(PageLRU(page));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageLRU(page);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &zone->lru[lru].list)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_add_lru_list(page, lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_add_list(zone, pa=
ge, lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &lruvec->lists[lru]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgmoved +=3D hpage_nr_pages(page);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pagevec_add(&pvec, page) || list_empt=
y(list)) {
> @@ -1551,17 +1546,10 @@ static void shrink_active_list(unsigned long nr_p=
ages, struct zone *zone,
>
> =A0 =A0 =A0 =A0lru_add_drain();
> =A0 =A0 =A0 =A0spin_lock_irq(&zone->lru_lock);
> - =A0 =A0 =A0 if (scanning_global_lru(sc)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D isolate_pages_global(nr_pages,=
 &l_hold,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 &pgscanned, sc->order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 ISOLATE_ACTIVE, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 1, file);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken =3D mem_cgroup_isolate_pages(nr_pa=
ges, &l_hold,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 &pgscanned, sc->order,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 ISOLATE_ACTIVE, zone,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sc->mem_cgroup, 1, file);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 nr_taken =3D isolate_pages(nr_pages, &l_hold,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&pgscann=
ed, sc->order,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ISOLATE_=
ACTIVE, zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01, file,=
 sc->mem_cgroup);
>
> =A0 =A0 =A0 =A0if (global_reclaim(sc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->pages_scanned +=3D pgscanned;
> @@ -3154,16 +3142,18 @@ int page_evictable(struct page *page, struct vm_a=
rea_struct *vma)
> =A0*/
> =A0static void check_move_unevictable_page(struct page *page, struct zone=
 *zone)
> =A0{
> - =A0 =A0 =A0 VM_BUG_ON(PageActive(page));
> + =A0 =A0 =A0 struct lruvec *lruvec;
>
> + =A0 =A0 =A0 VM_BUG_ON(PageActive(page));
> =A0retry:
> =A0 =A0 =A0 =A0ClearPageUnevictable(page);
> =A0 =A0 =A0 =A0if (page_evictable(page, NULL)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_list l =3D page_lru_base_type(pag=
e);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(zone, =
page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0LRU_UNEVICTABLE, l);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__dec_zone_state(zone, NR_UNEVICTABLE);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &zone->lru[l].list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_move_lists(page, LRU_UNEVICTABLE=
, l);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &lruvec->lists[l]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__inc_zone_state(zone, NR_INACTIVE_ANON + =
l);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_event(UNEVICTABLE_PGRESCUED);
> =A0 =A0 =A0 =A0} else {
> @@ -3171,8 +3161,9 @@ retry:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * rotate unevictable list
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SetPageUnevictable(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &zone->lru[LRU_UNEVIC=
TABLE].list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list(page, LRU_UNEVIC=
TABLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_lru_move_lists(zone, =
page, LRU_UNEVICTABLE,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0LRU_UNEVICTABLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&page->lru, &lruvec->lists[LRU_UN=
EVICTABLE]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (page_evictable(page, NULL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto retry;
> =A0 =A0 =A0 =A0}
> @@ -3233,14 +3224,6 @@ void scan_mapping_unevictable_pages(struct address=
_space *mapping)
>
> =A0}
>
> -static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup *m=
em,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru=
_list lru)
> -{
> - =A0 =A0 =A0 if (mem)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_lru_to_page(zone, mem, lr=
u);
> - =A0 =A0 =A0 return lru_to_page(&zone->lru[lru].list);
> -}
> -
> =A0/**
> =A0* scan_zone_unevictable_pages - check unevictable list for evictable p=
ages
> =A0* @zone - zone of which to scan the unevictable list
> @@ -3259,8 +3242,13 @@ static void scan_zone_unevictable_pages(struct zon=
e *zone)
> =A0 =A0 =A0 =A0first =3D mem =3D mem_cgroup_hierarchy_walk(NULL, mem);
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_to_scan;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *list;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_to_scan =3D zone_nr_lru_pages(zone, mem=
, LRU_UNEVICTABLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lruvec =3D mem_cgroup_zone_lruvec(zone, mem=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list =3D &lruvec->lists[LRU_UNEVICTABLE];
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (nr_to_scan > 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long batch_size;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scan;
> @@ -3272,7 +3260,7 @@ static void scan_zone_unevictable_pages(struct zone=
 *zone)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (scan =3D 0; scan < ba=
tch_size; scan++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct pag=
e *page;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lr=
u_tailpage(zone, mem, LRU_UNEVICTABLE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lr=
u_to_page(list);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!trylo=
ck_page(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (likely=
(PageLRU(page) &&
> --
> 1.7.5.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
