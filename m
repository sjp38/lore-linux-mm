Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB38A8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 00:52:48 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p2V4qhtV002319
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 21:52:44 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by hpaq12.eem.corp.google.com with ESMTP id p2V4qR9Q014706
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 21:52:41 -0700
Received: by qyl38 with SMTP id 38so1491972qyl.15
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 21:52:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331110147.a024115d.nishimura@mxp.nes.nec.co.jp>
References: <1301532498-20309-1-git-send-email-yinghan@google.com>
	<20110331110147.a024115d.nishimura@mxp.nes.nec.co.jp>
Date: Wed, 30 Mar 2011 21:52:39 -0700
Message-ID: <BANLkTikPwXxP6ovrTEFWX6xhrGCT9kg-9A@mail.gmail.com>
Subject: Re: [RFC][PATCH] memcg: isolate pages in memcg lru from global lru
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd0821e436e049fc01086
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd0821e436e049fc01086
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Mar 30, 2011 at 7:01 PM, Daisuke Nishimura <
nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
>
> On Wed, 30 Mar 2011 17:48:18 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > In memory controller, we do both targeting reclaim and global reclaim.
> The
> > later one walks through the global lru which links all the allocated
> pages
> > on the system. It breaks the memory isolation since pages are evicted
> > regardless of their memcg owners. This patch takes pages off global lru
> > as long as they are added to per-memcg lru.
> >
> > Memcg and cgroup together provide the solution of memory isolation where
> > multiple cgroups run in parallel without interfering with each other. In
> > vm, memory isolation requires changes in both page allocation and page
> > reclaim. The current memcg provides good user page accounting, but need
> > more work on the page reclaim.
> >
> > In an over-committed machine w/ 32G ram, here is the configuration:
> >
> > cgroup-A/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> > cgroup-B/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> >
> > 1) limit_in_bytes is the hard_limit where process will be throttled or
> OOM
> > killed by going over the limit.
> > 2) memory between soft_limit and limit_in_bytes are best-effort.
> soft_limit
> > provides "guarantee" in some sense.
> >
> > Then, it is easy to generate the following senario where:
> >
> > cgroup-A/  -- usage_in_bytes = 20G
> > cgroup-B/  -- usage_in_bytes = 12G
> >
> > The global memory pressure triggers while cgroup-A keep allocating
> memory. At
> > this point, pages belongs to cgroup-B can be evicted from global LRU.
> >
> I can agree that global memory reclaim should try to free memory from A
> first
> down to 15G(soft limit). But IMHO, if it cannot free enough memory from A,
> it must reclaim memory from B before causing global OOM(I don't want to see
> OOM
> as long as possible).
>

Thanks for your comments.

I kind of agree that sometimes keep the process running is better than being
OOMing killed, although the performance variation could be big. However,
most of the time users are expecting isolation by running in cgroup & memcg.
One way of thinking isolation is to provide better predictability. In the
example above, let's say both cgroup-A and cgroup-B have their working set
size being 15G (based on their soft_limit setting).  However, we shouldn't
hit cgroup-B's performance periodically by having cgroup-A's spiky memory
allocation.


> IOW, not-link-to-global-lru seems to be a bit overkill to me(it must be
> configurable
> at least, as Michal did). We should improve memcg/global reclaim(and OOM)
> logic first.
>
> Agree. This change might look a bit overkill due to the lack of good-enough
targeting reclaim, just like what I listed below. Those improvements will
even further prove the theory, and might just make this change looks safer
:)

--Ying


Thanks,
> Daisuke Nishimura.
>
> > We do have per-memcg targeting reclaim including per-memcg background
> reclaim
> > and soft_limit reclaim. Both of them need some improvement, and
> regardless we
> > still need this patch since it breaks isolation.
> >
> > Besides, here is to-do list I have on memcg page reclaim and they are
> sorted.
> > a) per-memcg background reclaim. to reclaim pages proactively
> > b) skipping global lru reclaim if soft_limit reclaim does enough work.
> this is
> > both for global background reclaim and global ttfp reclaim.
> > c) improve the soft_limit reclaim to be efficient.
> > d) isolate pages in memcg from global list since it breaks memory
> isolation.
> >
> > I have some basic test on this patch and more tests definitely are
> needed:
> >
> > Functional:
> > two memcgs under root. cgroup-A is reading 20g file with 2g limit,
> > cgroup-B is running random stuff with 500m limit. Check the counters for
> > per-memcg lru and global lru, and they should add-up.
> >
> > 1) total file pages
> > $ cat /proc/meminfo | grep Cache
> > Cached:          6032128 kB
> >
> > 2) file lru on global lru
> > $ cat /proc/vmstat | grep file
> > nr_inactive_file 0
> > nr_active_file 963131
> >
> > 3) file lru on root cgroup
> > $ cat /dev/cgroup/memory.stat | grep file
> > inactive_file 0
> > active_file 0
> >
> > 4) file lru on cgroup-A
> > $ cat /dev/cgroup/A/memory.stat | grep file
> > inactive_file 2145759232
> > active_file 0
> >
> > 5) file lru on cgroup-B
> > $ cat /dev/cgroup/B/memory.stat | grep file
> > inactive_file 401408
> > active_file 143360
> >
> > Performance:
> > run page fault test(pft) with 16 thread on faulting in 15G anon pages
> > in 16G cgroup. There is no regression noticed on "flt/cpu/s"
> >
> >
> +-------------------------------------------------------------------------+
> >     N           Min           Max        Median           Avg
>  Stddev
> > x  10     16682.962     17344.027     16913.524     16928.812
>  166.5362
> > +   9     16455.468     16961.779     16867.569      16802.83
> 157.43279
> > No difference proven at 95.0% confidence
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/memcontrol.h  |   17 ++++++-----
> >  include/linux/mm_inline.h   |   24 ++++++++++------
> >  include/linux/page_cgroup.h |    1 -
> >  mm/memcontrol.c             |   60
> +++++++++++++++++++++---------------------
> >  mm/page_cgroup.c            |    1 -
> >  mm/swap.c                   |   12 +++++++-
> >  mm/vmscan.c                 |   22 +++++++++++----
> >  7 files changed, 80 insertions(+), 57 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 5a5ce70..587a41e 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -60,11 +60,11 @@ extern void mem_cgroup_cancel_charge_swapin(struct
> mem_cgroup *ptr);
> >
> >  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct
> *mm,
> >                                       gfp_t gfp_mask);
> > -extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list
> lru);
> > -extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list
> lru);
> > +extern bool mem_cgroup_add_lru_list(struct page *page, enum lru_list
> lru);
> > +extern bool mem_cgroup_del_lru_list(struct page *page, enum lru_list
> lru);
> >  extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
> >  extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list
> lru);
> > -extern void mem_cgroup_del_lru(struct page *page);
> > +extern bool mem_cgroup_del_lru(struct page *page);
> >  extern void mem_cgroup_move_lists(struct page *page,
> >                                 enum lru_list from, enum lru_list to);
> >
> > @@ -207,13 +207,14 @@ static inline int
> mem_cgroup_shmem_charge_fallback(struct page *page,
> >       return 0;
> >  }
> >
> > -static inline void mem_cgroup_add_lru_list(struct page *page, int lru)
> > +static inline bool mem_cgroup_add_lru_list(struct page *page, int lru)
> >  {
> > +     return false;
> >  }
> >
> > -static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
> > +static inline bool mem_cgroup_del_lru_list(struct page *page, int lru)
> >  {
> > -     return ;
> > +     return false;
> >  }
> >
> >  static inline inline void mem_cgroup_rotate_reclaimable_page(struct page
> *page)
> > @@ -226,9 +227,9 @@ static inline void mem_cgroup_rotate_lru_list(struct
> page *page, int lru)
> >       return ;
> >  }
> >
> > -static inline void mem_cgroup_del_lru(struct page *page)
> > +static inline bool mem_cgroup_del_lru(struct page *page)
> >  {
> > -     return ;
> > +     return false;
> >  }
> >
> >  static inline void
> > diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> > index 8f7d247..f55b311 100644
> > --- a/include/linux/mm_inline.h
> > +++ b/include/linux/mm_inline.h
> > @@ -25,9 +25,11 @@ static inline void
> >  __add_page_to_lru_list(struct zone *zone, struct page *page, enum
> lru_list l,
> >                      struct list_head *head)
> >  {
> > -     list_add(&page->lru, head);
> > -     __mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
> > -     mem_cgroup_add_lru_list(page, l);
> > +     if (mem_cgroup_add_lru_list(page, l) == false) {
> > +             list_add(&page->lru, head);
> > +             __mod_zone_page_state(zone, NR_LRU_BASE + l,
> > +                                   hpage_nr_pages(page));
> > +     }
> >  }
> >
> >  static inline void
> > @@ -39,9 +41,11 @@ add_page_to_lru_list(struct zone *zone, struct page
> *page, enum lru_list l)
> >  static inline void
> >  del_page_from_lru_list(struct zone *zone, struct page *page, enum
> lru_list l)
> >  {
> > -     list_del(&page->lru);
> > -     __mod_zone_page_state(zone, NR_LRU_BASE + l,
> -hpage_nr_pages(page));
> > -     mem_cgroup_del_lru_list(page, l);
> > +     if (mem_cgroup_del_lru_list(page, l) == false) {
> > +             list_del(&page->lru);
> > +             __mod_zone_page_state(zone, NR_LRU_BASE + l,
> > +                                   -hpage_nr_pages(page));
> > +     }
> >  }
> >
> >  /**
> > @@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *page)
> >  {
> >       enum lru_list l;
> >
> > -     list_del(&page->lru);
> >       if (PageUnevictable(page)) {
> >               __ClearPageUnevictable(page);
> >               l = LRU_UNEVICTABLE;
> > @@ -75,8 +78,11 @@ del_page_from_lru(struct zone *zone, struct page
> *page)
> >                       l += LRU_ACTIVE;
> >               }
> >       }
> > -     __mod_zone_page_state(zone, NR_LRU_BASE + l,
> -hpage_nr_pages(page));
> > -     mem_cgroup_del_lru_list(page, l);
> > +     if (mem_cgroup_del_lru_list(page, l) == false) {
> > +             __mod_zone_page_state(zone, NR_LRU_BASE + l,
> > +                                   -hpage_nr_pages(page));
> > +             list_del(&page->lru);
> > +     }
> >  }
> >
> >  /**
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index f5de21d..7b2567b 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -31,7 +31,6 @@ enum {
> >  struct page_cgroup {
> >       unsigned long flags;
> >       struct mem_cgroup *mem_cgroup;
> > -     struct list_head lru;           /* per cgroup LRU list */
> >  };
> >
> >  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4407dd0..9079e2e 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -827,17 +827,17 @@ static inline bool mem_cgroup_is_root(struct
> mem_cgroup *mem)
> >   * When moving account, the page is not on LRU. It's isolated.
> >   */
> >
> > -void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> > +bool mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> >  {
> >       struct page_cgroup *pc;
> >       struct mem_cgroup_per_zone *mz;
> >
> >       if (mem_cgroup_disabled())
> > -             return;
> > +             return false;
> >       pc = lookup_page_cgroup(page);
> >       /* can happen while we handle swapcache. */
> >       if (!TestClearPageCgroupAcctLRU(pc))
> > -             return;
> > +             return false;
> >       VM_BUG_ON(!pc->mem_cgroup);
> >       /*
> >        * We don't check PCG_USED bit. It's cleared when the "page" is
> finally
> > @@ -845,16 +845,16 @@ void mem_cgroup_del_lru_list(struct page *page,
> enum lru_list lru)
> >        */
> >       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> >       /* huge page split is done under lru_lock. so, we have no races. */
> > -     MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> >       if (mem_cgroup_is_root(pc->mem_cgroup))
> > -             return;
> > -     VM_BUG_ON(list_empty(&pc->lru));
> > -     list_del_init(&pc->lru);
> > +             return false;
> > +     MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> > +     list_del_init(&page->lru);
> > +     return true;
> >  }
> >
> > -void mem_cgroup_del_lru(struct page *page)
> > +bool mem_cgroup_del_lru(struct page *page)
> >  {
> > -     mem_cgroup_del_lru_list(page, page_lru(page));
> > +     return mem_cgroup_del_lru_list(page, page_lru(page));
> >  }
> >
> >  /*
> > @@ -880,7 +880,7 @@ void mem_cgroup_rotate_reclaimable_page(struct page
> *page)
> >       if (mem_cgroup_is_root(pc->mem_cgroup))
> >               return;
> >       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> > -     list_move_tail(&pc->lru, &mz->lists[lru]);
> > +     list_move(&page->lru, &mz->lists[lru]);
> >  }
> >
> >  void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
> > @@ -900,29 +900,30 @@ void mem_cgroup_rotate_lru_list(struct page *page,
> enum lru_list lru)
> >       if (mem_cgroup_is_root(pc->mem_cgroup))
> >               return;
> >       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> > -     list_move(&pc->lru, &mz->lists[lru]);
> > +     list_move(&page->lru, &mz->lists[lru]);
> >  }
> >
> > -void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
> > +bool mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
> >  {
> >       struct page_cgroup *pc;
> >       struct mem_cgroup_per_zone *mz;
> >
> >       if (mem_cgroup_disabled())
> > -             return;
> > +             return false;
> >       pc = lookup_page_cgroup(page);
> >       VM_BUG_ON(PageCgroupAcctLRU(pc));
> >       if (!PageCgroupUsed(pc))
> > -             return;
> > +             return false;
> >       /* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> >       smp_rmb();
> >       mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> >       /* huge page split is done under lru_lock. so, we have no races. */
> > -     MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
> >       SetPageCgroupAcctLRU(pc);
> >       if (mem_cgroup_is_root(pc->mem_cgroup))
> > -             return;
> > -     list_add(&pc->lru, &mz->lists[lru]);
> > +             return false;
> > +     MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
> > +     list_add(&page->lru, &mz->lists[lru]);
> > +     return true;
> >  }
> >
> >  /*
> > @@ -1111,11 +1112,11 @@ unsigned long mem_cgroup_isolate_pages(unsigned
> long nr_to_scan,
> >                                       int active, int file)
> >  {
> >       unsigned long nr_taken = 0;
> > -     struct page *page;
> > +     struct page *page, *tmp;
> >       unsigned long scan;
> >       LIST_HEAD(pc_list);
> >       struct list_head *src;
> > -     struct page_cgroup *pc, *tmp;
> > +     struct page_cgroup *pc;
> >       int nid = zone_to_nid(z);
> >       int zid = zone_idx(z);
> >       struct mem_cgroup_per_zone *mz;
> > @@ -1127,24 +1128,24 @@ unsigned long mem_cgroup_isolate_pages(unsigned
> long nr_to_scan,
> >       src = &mz->lists[lru];
> >
> >       scan = 0;
> > -     list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
> > +     list_for_each_entry_safe_reverse(page, tmp, src, lru) {
> > +             pc = lookup_page_cgroup(page);
> >               if (scan >= nr_to_scan)
> >                       break;
> >
> >               if (unlikely(!PageCgroupUsed(pc)))
> >                       continue;
> > -
> > -             page = lookup_cgroup_page(pc);
> > -
> >               if (unlikely(!PageLRU(page)))
> >                       continue;
> >
> > +             BUG_ON(!PageCgroupAcctLRU(pc));
> > +
> >               scan++;
> >               ret = __isolate_lru_page(page, mode, file);
> >               switch (ret) {
> >               case 0:
> > -                     list_move(&page->lru, dst);
> >                       mem_cgroup_del_lru(page);
> > +                     list_add(&page->lru, dst);
> >                       nr_taken += hpage_nr_pages(page);
> >                       break;
> >               case -EBUSY:
> > @@ -3386,6 +3387,7 @@ static int mem_cgroup_force_empty_list(struct
> mem_cgroup *mem,
> >       struct page_cgroup *pc, *busy;
> >       unsigned long flags, loop;
> >       struct list_head *list;
> > +     struct page *page;
> >       int ret = 0;
> >
> >       zone = &NODE_DATA(node)->node_zones[zid];
> > @@ -3397,25 +3399,23 @@ static int mem_cgroup_force_empty_list(struct
> mem_cgroup *mem,
> >       loop += 256;
> >       busy = NULL;
> >       while (loop--) {
> > -             struct page *page;
> > -
> >               ret = 0;
> >               spin_lock_irqsave(&zone->lru_lock, flags);
> >               if (list_empty(list)) {
> >                       spin_unlock_irqrestore(&zone->lru_lock, flags);
> >                       break;
> >               }
> > -             pc = list_entry(list->prev, struct page_cgroup, lru);
> > +             page = list_entry(list->prev, struct page, lru);
> > +             pc = lookup_page_cgroup(page);
> >               if (busy == pc) {
> > -                     list_move(&pc->lru, list);
> > +                     /* XXX what should we do here? */
> > +                     list_move(&page->lru, list);
> >                       busy = NULL;
> >                       spin_unlock_irqrestore(&zone->lru_lock, flags);
> >                       continue;
> >               }
> >               spin_unlock_irqrestore(&zone->lru_lock, flags);
> >
> > -             page = lookup_cgroup_page(pc);
> > -
> >               ret = mem_cgroup_move_parent(page, pc, mem, GFP_KERNEL);
> >               if (ret == -ENOMEM)
> >                       break;
> > diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> > index 885b2ac..b812bf3 100644
> > --- a/mm/page_cgroup.c
> > +++ b/mm/page_cgroup.c
> > @@ -16,7 +16,6 @@ static void __meminit init_page_cgroup(struct
> page_cgroup *pc, unsigned long id)
> >       pc->flags = 0;
> >       set_page_cgroup_array_id(pc, id);
> >       pc->mem_cgroup = NULL;
> > -     INIT_LIST_HEAD(&pc->lru);
> >  }
> >  static unsigned long total_usage;
> >
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 0a33714..9cb95c5 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -31,6 +31,7 @@
> >  #include <linux/backing-dev.h>
> >  #include <linux/memcontrol.h>
> >  #include <linux/gfp.h>
> > +#include <linux/page_cgroup.h>
> >
> >  #include "internal.h"
> >
> > @@ -200,10 +201,17 @@ static void pagevec_move_tail(struct pagevec *pvec)
> >                       spin_lock(&zone->lru_lock);
> >               }
> >               if (PageLRU(page) && !PageActive(page) &&
> !PageUnevictable(page)) {
> > +                     struct page_cgroup *pc;
> >                       enum lru_list lru = page_lru_base_type(page);
> > -                     list_move_tail(&page->lru, &zone->lru[lru].list);
> > +
> >                       mem_cgroup_rotate_reclaimable_page(page);
> > -                     pgmoved++;
> > +                     pc = lookup_page_cgroup(page);
> > +                     smp_rmb();
> > +                     if (!PageCgroupAcctLRU(pc)) {
> > +                             list_move_tail(&page->lru,
> > +                                            &zone->lru[lru].list);
> > +                             pgmoved++;
> > +                     }
> >               }
> >       }
> >       if (zone)
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..5e54611 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -41,6 +41,7 @@
> >  #include <linux/memcontrol.h>
> >  #include <linux/delayacct.h>
> >  #include <linux/sysctl.h>
> > +#include <linux/page_cgroup.h>
> >
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> > @@ -1042,15 +1043,16 @@ static unsigned long isolate_lru_pages(unsigned
> long nr_to_scan,
> >
> >               switch (__isolate_lru_page(page, mode, file)) {
> >               case 0:
> > -                     list_move(&page->lru, dst);
> > +                     /* verify that it's not on any cgroups */
> >                       mem_cgroup_del_lru(page);
> > +                     list_move(&page->lru, dst);
> >                       nr_taken += hpage_nr_pages(page);
> >                       break;
> >
> >               case -EBUSY:
> >                       /* else it is being freed elsewhere */
> > -                     list_move(&page->lru, src);
> >                       mem_cgroup_rotate_lru_list(page, page_lru(page));
> > +                     list_move(&page->lru, src);
> >                       continue;
> >
> >               default:
> > @@ -1100,8 +1102,9 @@ static unsigned long isolate_lru_pages(unsigned
> long nr_to_scan,
> >                               break;
> >
> >                       if (__isolate_lru_page(cursor_page, mode, file) ==
> 0) {
> > -                             list_move(&cursor_page->lru, dst);
> > +                             /* verify that it's not on any cgroup */
> >                               mem_cgroup_del_lru(cursor_page);
> > +                             list_move(&cursor_page->lru, dst);
> >                               nr_taken += hpage_nr_pages(page);
> >                               nr_lumpy_taken++;
> >                               if (PageDirty(cursor_page))
> > @@ -1473,6 +1476,7 @@ static void move_active_pages_to_lru(struct zone
> *zone,
> >       unsigned long pgmoved = 0;
> >       struct pagevec pvec;
> >       struct page *page;
> > +     struct page_cgroup *pc;
> >
> >       pagevec_init(&pvec, 1);
> >
> > @@ -1482,9 +1486,15 @@ static void move_active_pages_to_lru(struct zone
> *zone,
> >               VM_BUG_ON(PageLRU(page));
> >               SetPageLRU(page);
> >
> > -             list_move(&page->lru, &zone->lru[lru].list);
> > -             mem_cgroup_add_lru_list(page, lru);
> > -             pgmoved += hpage_nr_pages(page);
> > +             pc = lookup_page_cgroup(page);
> > +             smp_rmb();
> > +             if (!PageCgroupAcctLRU(pc)) {
> > +                     list_move(&page->lru, &zone->lru[lru].list);
> > +                     pgmoved += hpage_nr_pages(page);
> > +             } else {
> > +                     list_del_init(&page->lru);
> > +                     mem_cgroup_add_lru_list(page, lru);
> > +             }
> >
> >               if (!pagevec_add(&pvec, page) || list_empty(list)) {
> >                       spin_unlock_irq(&zone->lru_lock);
> > --
> > 1.7.3.1
> >
>

--000e0cdfd0821e436e049fc01086
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Mar 30, 2011 at 7:01 PM, Daisuke=
 Nishimura <span dir=3D"ltr">&lt;<a href=3D"mailto:nishimura@mxp.nes.nec.co=
.jp">nishimura@mxp.nes.nec.co.jp</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">
Hi.<br>
<div class=3D"im"><br>
On Wed, 30 Mar 2011 17:48:18 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; In memory controller, we do both targeting reclaim and global reclaim.=
 The<br>
&gt; later one walks through the global lru which links all the allocated p=
ages<br>
&gt; on the system. It breaks the memory isolation since pages are evicted<=
br>
&gt; regardless of their memcg owners. This patch takes pages off global lr=
u<br>
&gt; as long as they are added to per-memcg lru.<br>
&gt;<br>
&gt; Memcg and cgroup together provide the solution of memory isolation whe=
re<br>
&gt; multiple cgroups run in parallel without interfering with each other. =
In<br>
&gt; vm, memory isolation requires changes in both page allocation and page=
<br>
&gt; reclaim. The current memcg provides good user page accounting, but nee=
d<br>
&gt; more work on the page reclaim.<br>
&gt;<br>
&gt; In an over-committed machine w/ 32G ram, here is the configuration:<br=
>
&gt;<br>
&gt; cgroup-A/ =A0-- limit_in_bytes =3D 20G, soft_limit_in_bytes =3D 15G<br=
>
&gt; cgroup-B/ =A0-- limit_in_bytes =3D 20G, soft_limit_in_bytes =3D 15G<br=
>
&gt;<br>
&gt; 1) limit_in_bytes is the hard_limit where process will be throttled or=
 OOM<br>
&gt; killed by going over the limit.<br>
&gt; 2) memory between soft_limit and limit_in_bytes are best-effort. soft_=
limit<br>
&gt; provides &quot;guarantee&quot; in some sense.<br>
&gt;<br>
&gt; Then, it is easy to generate the following senario where:<br>
&gt;<br>
&gt; cgroup-A/ =A0-- usage_in_bytes =3D 20G<br>
&gt; cgroup-B/ =A0-- usage_in_bytes =3D 12G<br>
&gt;<br>
&gt; The global memory pressure triggers while cgroup-A keep allocating mem=
ory. At<br>
&gt; this point, pages belongs to cgroup-B can be evicted from global LRU.<=
br>
&gt;<br>
</div>I can agree that global memory reclaim should try to free memory from=
 A first<br>
down to 15G(soft limit). But IMHO, if it cannot free enough memory from A,<=
br>
it must reclaim memory from B before causing global OOM(I don&#39;t want to=
 see OOM<br>
as long as possible).<br>
</blockquote><div><br></div><meta charset=3D"utf-8"><div>Thanks for your co=
mments.</div><div><br></div><div>I kind of agree that sometimes keep the pr=
ocess running is better=A0than being OOMing killed, although the performanc=
e variation could be big. However, most of the time users are expecting iso=
lation by running in cgroup &amp; memcg. One way of thinking isolation is t=
o provide better=A0predictability. In the example above, let&#39;s say both=
 cgroup-A and cgroup-B have their working set size being 15G (based on thei=
r soft_limit setting). =A0However, we shouldn&#39;t hit cgroup-B&#39;s perf=
ormance periodically by having cgroup-A&#39;s spiky memory allocation.=A0</=
div>
<div>=A0=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex;">IOW, not-link-to-global-lr=
u seems to be a bit overkill to me(it must be configurable<br>
at least, as Michal did). We should improve memcg/global reclaim(and OOM) l=
ogic first.<br>
<br></blockquote><div>Agree. This change might look a bit overkill due to t=
he lack of good-enough targeting reclaim, just like what I listed below. Th=
ose improvements will even further prove the theory, and might just make th=
is change looks safer :)</div>
<div><br></div><div>--Ying</div><div><br></div><div><br></div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">Thanks,<br>
<font color=3D"#888888">Daisuke Nishimura.<br>
</font><div><div></div><div class=3D"h5"><br>
&gt; We do have per-memcg targeting reclaim including per-memcg background =
reclaim<br>
&gt; and soft_limit reclaim. Both of them need some improvement, and regard=
less we<br>
&gt; still need this patch since it breaks isolation.<br>
&gt;<br>
&gt; Besides, here is to-do list I have on memcg page reclaim and they are =
sorted.<br>
&gt; a) per-memcg background reclaim. to reclaim pages proactively<br>
&gt; b) skipping global lru reclaim if soft_limit reclaim does enough work.=
 this is<br>
&gt; both for global background reclaim and global ttfp reclaim.<br>
&gt; c) improve the soft_limit reclaim to be efficient.<br>
&gt; d) isolate pages in memcg from global list since it breaks memory isol=
ation.<br>
&gt;<br>
&gt; I have some basic test on this patch and more tests definitely are nee=
ded:<br>
&gt;<br>
&gt; Functional:<br>
&gt; two memcgs under root. cgroup-A is reading 20g file with 2g limit,<br>
&gt; cgroup-B is running random stuff with 500m limit. Check the counters f=
or<br>
&gt; per-memcg lru and global lru, and they should add-up.<br>
&gt;<br>
&gt; 1) total file pages<br>
&gt; $ cat /proc/meminfo | grep Cache<br>
&gt; Cached: =A0 =A0 =A0 =A0 =A06032128 kB<br>
&gt;<br>
&gt; 2) file lru on global lru<br>
&gt; $ cat /proc/vmstat | grep file<br>
&gt; nr_inactive_file 0<br>
&gt; nr_active_file 963131<br>
&gt;<br>
&gt; 3) file lru on root cgroup<br>
&gt; $ cat /dev/cgroup/memory.stat | grep file<br>
&gt; inactive_file 0<br>
&gt; active_file 0<br>
&gt;<br>
&gt; 4) file lru on cgroup-A<br>
&gt; $ cat /dev/cgroup/A/memory.stat | grep file<br>
&gt; inactive_file 2145759232<br>
&gt; active_file 0<br>
&gt;<br>
&gt; 5) file lru on cgroup-B<br>
&gt; $ cat /dev/cgroup/B/memory.stat | grep file<br>
&gt; inactive_file 401408<br>
&gt; active_file 143360<br>
&gt;<br>
&gt; Performance:<br>
&gt; run page fault test(pft) with 16 thread on faulting in 15G anon pages<=
br>
&gt; in 16G cgroup. There is no regression noticed on &quot;flt/cpu/s&quot;=
<br>
&gt;<br>
&gt; +---------------------------------------------------------------------=
----+<br>
&gt; =A0 =A0 N =A0 =A0 =A0 =A0 =A0 Min =A0 =A0 =A0 =A0 =A0 Max =A0 =A0 =A0 =
=A0Median =A0 =A0 =A0 =A0 =A0 Avg =A0 =A0 =A0 =A0Stddev<br>
&gt; x =A010 =A0 =A0 16682.962 =A0 =A0 17344.027 =A0 =A0 16913.524 =A0 =A0 =
16928.812 =A0 =A0 =A0166.5362<br>
&gt; + =A0 9 =A0 =A0 16455.468 =A0 =A0 16961.779 =A0 =A0 16867.569 =A0 =A0 =
=A016802.83 =A0 =A0 157.43279<br>
&gt; No difference proven at 95.0% confidence<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h =A0| =A0 17 ++++++-----<br>
&gt; =A0include/linux/mm_inline.h =A0 | =A0 24 ++++++++++------<br>
&gt; =A0include/linux/page_cgroup.h | =A0 =A01 -<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 60 ++++++++++++++++++=
+++---------------------<br>
&gt; =A0mm/page_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 -<br>
&gt; =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 12 +++++++-<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 22 +++++++++++---=
-<br>
&gt; =A07 files changed, 80 insertions(+), 57 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index 5a5ce70..587a41e 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -60,11 +60,11 @@ extern void mem_cgroup_cancel_charge_swapin(struct=
 mem_cgroup *ptr);<br>
&gt;<br>
&gt; =A0extern int mem_cgroup_cache_charge(struct page *page, struct mm_str=
uct *mm,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 gfp_t gfp_mask);<br>
&gt; -extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list =
lru);<br>
&gt; -extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list =
lru);<br>
&gt; +extern bool mem_cgroup_add_lru_list(struct page *page, enum lru_list =
lru);<br>
&gt; +extern bool mem_cgroup_del_lru_list(struct page *page, enum lru_list =
lru);<br>
&gt; =A0extern void mem_cgroup_rotate_reclaimable_page(struct page *page);<=
br>
&gt; =A0extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_=
list lru);<br>
&gt; -extern void mem_cgroup_del_lru(struct page *page);<br>
&gt; +extern bool mem_cgroup_del_lru(struct page *page);<br>
&gt; =A0extern void mem_cgroup_move_lists(struct page *page,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum l=
ru_list from, enum lru_list to);<br>
&gt;<br>
&gt; @@ -207,13 +207,14 @@ static inline int mem_cgroup_shmem_charge_fallba=
ck(struct page *page,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; -static inline void mem_cgroup_add_lru_list(struct page *page, int lru=
)<br>
&gt; +static inline bool mem_cgroup_add_lru_list(struct page *page, int lru=
)<br>
&gt; =A0{<br>
&gt; + =A0 =A0 return false;<br>
&gt; =A0}<br>
&gt;<br>
&gt; -static inline void mem_cgroup_del_lru_list(struct page *page, int lru=
)<br>
&gt; +static inline bool mem_cgroup_del_lru_list(struct page *page, int lru=
)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 return ;<br>
&gt; + =A0 =A0 return false;<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static inline inline void mem_cgroup_rotate_reclaimable_page(struct=
 page *page)<br>
&gt; @@ -226,9 +227,9 @@ static inline void mem_cgroup_rotate_lru_list(stru=
ct page *page, int lru)<br>
&gt; =A0 =A0 =A0 return ;<br>
&gt; =A0}<br>
&gt;<br>
&gt; -static inline void mem_cgroup_del_lru(struct page *page)<br>
&gt; +static inline bool mem_cgroup_del_lru(struct page *page)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 return ;<br>
&gt; + =A0 =A0 return false;<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static inline void<br>
&gt; diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h<br>
&gt; index 8f7d247..f55b311 100644<br>
&gt; --- a/include/linux/mm_inline.h<br>
&gt; +++ b/include/linux/mm_inline.h<br>
&gt; @@ -25,9 +25,11 @@ static inline void<br>
&gt; =A0__add_page_to_lru_list(struct zone *zone, struct page *page, enum l=
ru_list l,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct list_head *head)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 list_add(&amp;page-&gt;lru, head);<br>
&gt; - =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(=
page));<br>
&gt; - =A0 =A0 mem_cgroup_add_lru_list(page, l);<br>
&gt; + =A0 =A0 if (mem_cgroup_add_lru_list(page, l) =3D=3D false) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 list_add(&amp;page-&gt;lru, head);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l,=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
hpage_nr_pages(page));<br>
&gt; + =A0 =A0 }<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static inline void<br>
&gt; @@ -39,9 +41,11 @@ add_page_to_lru_list(struct zone *zone, struct page=
 *page, enum lru_list l)<br>
&gt; =A0static inline void<br>
&gt; =A0del_page_from_lru_list(struct zone *zone, struct page *page, enum l=
ru_list l)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 list_del(&amp;page-&gt;lru);<br>
&gt; - =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages=
(page));<br>
&gt; - =A0 =A0 mem_cgroup_del_lru_list(page, l);<br>
&gt; + =A0 =A0 if (mem_cgroup_del_lru_list(page, l) =3D=3D false) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l,=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
-hpage_nr_pages(page));<br>
&gt; + =A0 =A0 }<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/**<br>
&gt; @@ -64,7 +68,6 @@ del_page_from_lru(struct zone *zone, struct page *pa=
ge)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 enum lru_list l;<br>
&gt;<br>
&gt; - =A0 =A0 list_del(&amp;page-&gt;lru);<br>
&gt; =A0 =A0 =A0 if (PageUnevictable(page)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 __ClearPageUnevictable(page);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =3D LRU_UNEVICTABLE;<br>
&gt; @@ -75,8 +78,11 @@ del_page_from_lru(struct zone *zone, struct page *p=
age)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l +=3D LRU_ACTIVE;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 }<br>
&gt; - =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l, -hpage_nr_pages=
(page));<br>
&gt; - =A0 =A0 mem_cgroup_del_lru_list(page, l);<br>
&gt; + =A0 =A0 if (mem_cgroup_del_lru_list(page, l) =3D=3D false) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_page_state(zone, NR_LRU_BASE + l,=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
-hpage_nr_pages(page));<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
&gt; + =A0 =A0 }<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/**<br>
&gt; diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h=
<br>
&gt; index f5de21d..7b2567b 100644<br>
&gt; --- a/include/linux/page_cgroup.h<br>
&gt; +++ b/include/linux/page_cgroup.h<br>
&gt; @@ -31,7 +31,6 @@ enum {<br>
&gt; =A0struct page_cgroup {<br>
&gt; =A0 =A0 =A0 unsigned long flags;<br>
&gt; =A0 =A0 =A0 struct mem_cgroup *mem_cgroup;<br>
&gt; - =A0 =A0 struct list_head lru; =A0 =A0 =A0 =A0 =A0 /* per cgroup LRU =
list */<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);<b=
r>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 4407dd0..9079e2e 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -827,17 +827,17 @@ static inline bool mem_cgroup_is_root(struct mem=
_cgroup *mem)<br>
&gt; =A0 * When moving account, the page is not on LRU. It&#39;s isolated.<=
br>
&gt; =A0 */<br>
&gt;<br>
&gt; -void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)<br=
>
&gt; +bool mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)<br=
>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct page_cgroup *pc;<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
&gt; =A0 =A0 =A0 /* can happen while we handle swapcache. */<br>
&gt; =A0 =A0 =A0 if (!TestClearPageCgroupAcctLRU(pc))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; =A0 =A0 =A0 VM_BUG_ON(!pc-&gt;mem_cgroup);<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0* We don&#39;t check PCG_USED bit. It&#39;s cleared whe=
n the &quot;page&quot; is finally<br>
&gt; @@ -845,16 +845,16 @@ void mem_cgroup_del_lru_list(struct page *page, =
enum lru_list lru)<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
&gt; =A0 =A0 =A0 /* huge page split is done under lru_lock. so, we have no =
races. */<br>
&gt; - =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 &lt;&lt; compound_order(pag=
e);<br>
&gt; =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; - =A0 =A0 VM_BUG_ON(list_empty(&amp;pc-&gt;lru));<br>
&gt; - =A0 =A0 list_del_init(&amp;pc-&gt;lru);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; + =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 &lt;&lt; compound_order(pag=
e);<br>
&gt; + =A0 =A0 list_del_init(&amp;page-&gt;lru);<br>
&gt; + =A0 =A0 return true;<br>
&gt; =A0}<br>
&gt;<br>
&gt; -void mem_cgroup_del_lru(struct page *page)<br>
&gt; +bool mem_cgroup_del_lru(struct page *page)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page));<br>
&gt; + =A0 =A0 return mem_cgroup_del_lru_list(page, page_lru(page));<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -880,7 +880,7 @@ void mem_cgroup_rotate_reclaimable_page(struct pag=
e *page)<br>
&gt; =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
&gt; - =A0 =A0 list_move_tail(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
&gt; + =A0 =A0 list_move(&amp;page-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lr=
u)<br>
&gt; @@ -900,29 +900,30 @@ void mem_cgroup_rotate_lru_list(struct page *pag=
e, enum lru_list lru)<br>
&gt; =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
&gt; - =A0 =A0 list_move(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
&gt; + =A0 =A0 list_move(&amp;page-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
&gt; =A0}<br>
&gt;<br>
&gt; -void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)<br=
>
&gt; +bool mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)<br=
>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct page_cgroup *pc;<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (mem_cgroup_disabled())<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
&gt; =A0 =A0 =A0 VM_BUG_ON(PageCgroupAcctLRU(pc));<br>
&gt; =A0 =A0 =A0 if (!PageCgroupUsed(pc))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; =A0 =A0 =A0 /* Ensure pc-&gt;mem_cgroup is visible after reading PCG_U=
SED. */<br>
&gt; =A0 =A0 =A0 smp_rmb();<br>
&gt; =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(pc-&gt;mem_cgroup, page);<br>
&gt; =A0 =A0 =A0 /* huge page split is done under lru_lock. so, we have no =
races. */<br>
&gt; - =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 &lt;&lt; compound_order(pag=
e);<br>
&gt; =A0 =A0 =A0 SetPageCgroupAcctLRU(pc);<br>
&gt; =A0 =A0 =A0 if (mem_cgroup_is_root(pc-&gt;mem_cgroup))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; - =A0 =A0 list_add(&amp;pc-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; + =A0 =A0 MEM_CGROUP_ZSTAT(mz, lru) +=3D 1 &lt;&lt; compound_order(pag=
e);<br>
&gt; + =A0 =A0 list_add(&amp;page-&gt;lru, &amp;mz-&gt;lists[lru]);<br>
&gt; + =A0 =A0 return true;<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -1111,11 +1112,11 @@ unsigned long mem_cgroup_isolate_pages(unsigne=
d long nr_to_scan,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 int active, int file)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 unsigned long nr_taken =3D 0;<br>
&gt; - =A0 =A0 struct page *page;<br>
&gt; + =A0 =A0 struct page *page, *tmp;<br>
&gt; =A0 =A0 =A0 unsigned long scan;<br>
&gt; =A0 =A0 =A0 LIST_HEAD(pc_list);<br>
&gt; =A0 =A0 =A0 struct list_head *src;<br>
&gt; - =A0 =A0 struct page_cgroup *pc, *tmp;<br>
&gt; + =A0 =A0 struct page_cgroup *pc;<br>
&gt; =A0 =A0 =A0 int nid =3D zone_to_nid(z);<br>
&gt; =A0 =A0 =A0 int zid =3D zone_idx(z);<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
&gt; @@ -1127,24 +1128,24 @@ unsigned long mem_cgroup_isolate_pages(unsigne=
d long nr_to_scan,<br>
&gt; =A0 =A0 =A0 src =3D &amp;mz-&gt;lists[lru];<br>
&gt;<br>
&gt; =A0 =A0 =A0 scan =3D 0;<br>
&gt; - =A0 =A0 list_for_each_entry_safe_reverse(pc, tmp, src, lru) {<br>
&gt; + =A0 =A0 list_for_each_entry_safe_reverse(page, tmp, src, lru) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (scan &gt;=3D nr_to_scan)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!PageCgroupUsed(pc)))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; -<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 page =3D lookup_cgroup_page(pc);<br>
&gt; -<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!PageLRU(page)))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!PageCgroupAcctLRU(pc));<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan++;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __isolate_lru_page(page, mode, fil=
e);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ret) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0:<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 dst);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&amp;page-&gt;lru, =
dst);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken +=3D hpage_nr_pag=
es(page);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 case -EBUSY:<br>
&gt; @@ -3386,6 +3387,7 @@ static int mem_cgroup_force_empty_list(struct me=
m_cgroup *mem,<br>
&gt; =A0 =A0 =A0 struct page_cgroup *pc, *busy;<br>
&gt; =A0 =A0 =A0 unsigned long flags, loop;<br>
&gt; =A0 =A0 =A0 struct list_head *list;<br>
&gt; + =A0 =A0 struct page *page;<br>
&gt; =A0 =A0 =A0 int ret =3D 0;<br>
&gt;<br>
&gt; =A0 =A0 =A0 zone =3D &amp;NODE_DATA(node)-&gt;node_zones[zid];<br>
&gt; @@ -3397,25 +3399,23 @@ static int mem_cgroup_force_empty_list(struct =
mem_cgroup *mem,<br>
&gt; =A0 =A0 =A0 loop +=3D 256;<br>
&gt; =A0 =A0 =A0 busy =3D NULL;<br>
&gt; =A0 =A0 =A0 while (loop--) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 struct page *page;<br>
&gt; -<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&amp;zone-&gt;lru_lock, =
flags);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (list_empty(list)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&am=
p;zone-&gt;lru_lock, flags);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 pc =3D list_entry(list-&gt;prev, struct page=
_cgroup, lru);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 page =3D list_entry(list-&gt;prev, struct pa=
ge, lru);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (busy =3D=3D pc) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;pc-&gt;lru, l=
ist);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* XXX what should we do her=
e? */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 list);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 busy =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&am=
p;zone-&gt;lru_lock, flags);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&amp;zone-&gt;lru_l=
ock, flags);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 page =3D lookup_cgroup_page(pc);<br>
&gt; -<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_move_parent(page, pc, m=
em, GFP_KERNEL);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D -ENOMEM)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c<br>
&gt; index 885b2ac..b812bf3 100644<br>
&gt; --- a/mm/page_cgroup.c<br>
&gt; +++ b/mm/page_cgroup.c<br>
&gt; @@ -16,7 +16,6 @@ static void __meminit init_page_cgroup(struct page_c=
group *pc, unsigned long id)<br>
&gt; =A0 =A0 =A0 pc-&gt;flags =3D 0;<br>
&gt; =A0 =A0 =A0 set_page_cgroup_array_id(pc, id);<br>
&gt; =A0 =A0 =A0 pc-&gt;mem_cgroup =3D NULL;<br>
&gt; - =A0 =A0 INIT_LIST_HEAD(&amp;pc-&gt;lru);<br>
&gt; =A0}<br>
&gt; =A0static unsigned long total_usage;<br>
&gt;<br>
&gt; diff --git a/mm/swap.c b/mm/swap.c<br>
&gt; index 0a33714..9cb95c5 100644<br>
&gt; --- a/mm/swap.c<br>
&gt; +++ b/mm/swap.c<br>
&gt; @@ -31,6 +31,7 @@<br>
&gt; =A0#include &lt;linux/backing-dev.h&gt;<br>
&gt; =A0#include &lt;linux/memcontrol.h&gt;<br>
&gt; =A0#include &lt;linux/gfp.h&gt;<br>
&gt; +#include &lt;linux/page_cgroup.h&gt;<br>
&gt;<br>
&gt; =A0#include &quot;internal.h&quot;<br>
&gt;<br>
&gt; @@ -200,10 +201,17 @@ static void pagevec_move_tail(struct pagevec *pv=
ec)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;zone-&gt;lr=
u_lock);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageLRU(page) &amp;&amp; !PageActive(p=
age) &amp;&amp; !PageUnevictable(page)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page_cgroup *pc;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru =3D page=
_lru_base_type(page);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;page-&gt=
;lru, &amp;zone-&gt;lru[lru].list);<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_reclaima=
ble_page(page);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgmoved++;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(pa=
ge);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_rmb();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!PageCgroupAcctLRU(pc)) =
{<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_ta=
il(&amp;page-&gt;lru,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0&amp;zone-&gt;lru[lru].list);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgmoved++;<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 if (zone)<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 060e4c1..5e54611 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -41,6 +41,7 @@<br>
&gt; =A0#include &lt;linux/memcontrol.h&gt;<br>
&gt; =A0#include &lt;linux/delayacct.h&gt;<br>
&gt; =A0#include &lt;linux/sysctl.h&gt;<br>
&gt; +#include &lt;linux/page_cgroup.h&gt;<br>
&gt;<br>
&gt; =A0#include &lt;asm/tlbflush.h&gt;<br>
&gt; =A0#include &lt;asm/div64.h&gt;<br>
&gt; @@ -1042,15 +1043,16 @@ static unsigned long isolate_lru_pages(unsigne=
d long nr_to_scan,<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (__isolate_lru_page(page, mode, fil=
e)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0:<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 dst);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* verify that it&#39;s not =
on any cgroups */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_del_lru(page);<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 dst);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken +=3D hpage_nr_pag=
es(page);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 case -EBUSY:<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* else it is being freed =
elsewhere */<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 src);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_lru_list=
(page, page_lru(page));<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 src);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:<br>
&gt; @@ -1100,8 +1102,9 @@ static unsigned long isolate_lru_pages(unsigned =
long nr_to_scan,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__isolate_lru_page(cur=
sor_page, mode, file) =3D=3D 0) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&a=
mp;cursor_page-&gt;lru, dst);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* verify th=
at it&#39;s not on any cgroup */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup=
_del_lru(cursor_page);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&a=
mp;cursor_page-&gt;lru, dst);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_taken +=
=3D hpage_nr_pages(page);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_lumpy_t=
aken++;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageDi=
rty(cursor_page))<br>
&gt; @@ -1473,6 +1476,7 @@ static void move_active_pages_to_lru(struct zone=
 *zone,<br>
&gt; =A0 =A0 =A0 unsigned long pgmoved =3D 0;<br>
&gt; =A0 =A0 =A0 struct pagevec pvec;<br>
&gt; =A0 =A0 =A0 struct page *page;<br>
&gt; + =A0 =A0 struct page_cgroup *pc;<br>
&gt;<br>
&gt; =A0 =A0 =A0 pagevec_init(&amp;pvec, 1);<br>
&gt;<br>
&gt; @@ -1482,9 +1486,15 @@ static void move_active_pages_to_lru(struct zon=
e *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(PageLRU(page));<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageLRU(page);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru, &amp;zone-&gt;l=
ru[lru].list);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_add_lru_list(page, lru);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 pgmoved +=3D hpage_nr_pages(page);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 smp_rmb();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!PageCgroupAcctLRU(pc)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,=
 &amp;zone-&gt;lru[lru].list);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgmoved +=3D hpage_nr_pages(=
page);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_init(&amp;page-&gt;=
lru);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_add_lru_list(page=
, lru);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pagevec_add(&amp;pvec, page) || list_=
empty(list)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&amp;zone-=
&gt;lru_lock);<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div></div></blockquote></div><br>

--000e0cdfd0821e436e049fc01086--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
