Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 97A126B006E
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 00:18:54 -0500 (EST)
Subject: Re: [patch 5/5]thp: split huge page if head page is isolated
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111108085952.GA15142@barrios-laptop.redhat.com>
References: <1319511580.22361.141.camel@sli10-conroe>
	 <20111029000624.GA1261@barrios-laptop.redhat.com>
	 <1320024088.22361.176.camel@sli10-conroe>
	 <20111031082317.GA21440@barrios-laptop.redhat.com>
	 <1320051813.22361.182.camel@sli10-conroe>
	 <1320203876.22361.192.camel@sli10-conroe>
	 <20111108085952.GA15142@barrios-laptop.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 09 Nov 2011 13:27:55 +0800
Message-ID: <1320816475.22361.216.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, 2011-11-08 at 16:59 +0800, Minchan Kim wrote:
> On Wed, Nov 02, 2011 at 11:17:55AM +0800, Shaohua Li wrote:
> > On Mon, 2011-10-31 at 17:03 +0800, Shaohua Li wrote:
> > > On Mon, 2011-10-31 at 16:23 +0800, Minchan Kim wrote:
> > > > On Mon, Oct 31, 2011 at 09:21:28AM +0800, Shaohua Li wrote:
> > > > > On Sat, 2011-10-29 at 08:06 +0800, Minchan Kim wrote:
> > > > > > On Tue, Oct 25, 2011 at 10:59:40AM +0800, Shaohua Li wrote:
> > > > > > > With current logic, if page reclaim finds a huge page, it will just reclaim
> > > > > > > the head page and leave tail pages reclaimed later. Let's take an example,
> > > > > > > lru list has page A and B, page A is huge page:
> > > > > > > 1. page A is isolated
> > > > > > > 2. page B is isolated
> > > > > > > 3. shrink_page_list() adds page A to swap page cache. so page A is split.
> > > > > > > page A+1, page A+2, ... are added to lru list.
> > > > > > > 4. shrink_page_list() adds page B to swap page cache.
> > > > > > > 5. page A and B is written out and reclaimed.
> > > > > > > 6. page A+1, A+2 ... is isolated and reclaimed later.
> > > > > > > So the reclaim order is A, B, ...(maybe other pages), A+1, A+2 ...
> > > > > > >
> > > > > > > We expected the whole huge page A is reclaimed in the meantime, so
> > > > > > > the order is A, A+1, ... A+HPAGE_PMD_NR-1, B, ....
> > > > > > >
> > > > > > > With this patch, we do huge page split just after the head page is isolated
> > > > > > > for inactive lru list, so the tail pages will be reclaimed immediately.
> > > > > > >
> > > > > > > In a test, a range of anonymous memory is written and will trigger swap.
> > > > > > > Without the patch:
> > > > > > > #cat /proc/vmstat|grep thp
> > > > > > > thp_fault_alloc 451
> > > > > > > thp_fault_fallback 0
> > > > > > > thp_collapse_alloc 0
> > > > > > > thp_collapse_alloc_failed 0
> > > > > > > thp_split 238
> > > > > > >
> > > > > > > With the patch:
> > > > > > > #cat /proc/vmstat|grep thp
> > > > > > > thp_fault_alloc 450
> > > > > > > thp_fault_fallback 1
> > > > > > > thp_collapse_alloc 0
> > > > > > > thp_collapse_alloc_failed 0
> > > > > > > thp_split 103
> > > > > > >
> > > > > > > So the thp_split number is reduced a lot, though there is one extra
> > > > > > > thp_fault_fallback.
> > > > > > >
> > > > > > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > > > > > ---
> > > > > > >  include/linux/memcontrol.h |    3 +-
> > > > > > >  mm/memcontrol.c            |   12 +++++++++--
> > > > > > >  mm/vmscan.c                |   49 ++++++++++++++++++++++++++++++++++-----------
> > > > > > >  3 files changed, 50 insertions(+), 14 deletions(-)
> > > > > > >
> > > > > > > Index: linux/mm/vmscan.c
> > > > > > > ===================================================================
> > > > > > > --- linux.orig/mm/vmscan.c    2011-10-25 08:36:08.000000000 +0800
> > > > > > > +++ linux/mm/vmscan.c 2011-10-25 09:51:44.000000000 +0800
> > > > > > > @@ -1076,7 +1076,8 @@ int __isolate_lru_page(struct page *page
> > > > > > >   */
> > > > > > >  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > > > > > >               struct list_head *src, struct list_head *dst,
> > > > > > > -             unsigned long *scanned, int order, int mode, int file)
> > > > > > > +             unsigned long *scanned, int order, int mode, int file,
> > > > > > > +             struct page **split_page)
> > > > > > >  {
> > > > > > >       unsigned long nr_taken = 0;
> > > > > > >       unsigned long nr_lumpy_taken = 0;
> > > > > > > @@ -1100,7 +1101,12 @@ static unsigned long isolate_lru_pages(u
> > > > > > >               case 0:
> > > > > > >                       list_move(&page->lru, dst);
> > > > > > >                       mem_cgroup_del_lru(page);
> > > > > > > -                     nr_taken += hpage_nr_pages(page);
> > > > > > > +                     if (PageTransHuge(page) && split_page) {
> > > > > > > +                             nr_taken++;
> > > > > > > +                             *split_page = page;
> > > > > > > +                             goto out;
> > > > > > > +                     } else
> > > > > > > +                             nr_taken += hpage_nr_pages(page);
> > > > > > >                       break;
> > > > > > >
> > > > > > >               case -EBUSY:
> > > > > > > @@ -1158,11 +1164,16 @@ static unsigned long isolate_lru_pages(u
> > > > > > >                       if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> > > > > > >                               list_move(&cursor_page->lru, dst);
> > > > > > >                               mem_cgroup_del_lru(cursor_page);
> > > > > > > -                             nr_taken += hpage_nr_pages(page);
> > > > > > >                               nr_lumpy_taken++;
> > > > > > >                               if (PageDirty(cursor_page))
> > > > > > >                                       nr_lumpy_dirty++;
> > > > > > >                               scan++;
> > > > > > > +                             if (PageTransHuge(page) && split_page) {
> > > > > > > +                                     nr_taken++;
> > > > > > > +                                     *split_page = page;
> > > > > > > +                                     goto out;
> > > > > > > +                             } else
> > > > > > > +                                     nr_taken += hpage_nr_pages(page);
> > > > > > >                       } else {
> > > > > > >                               /*
> > > > > > >                                * Check if the page is freed already.
> > > > > > > @@ -1188,6 +1199,7 @@ static unsigned long isolate_lru_pages(u
> > > > > > >                       nr_lumpy_failed++;
> > > > > > >       }
> > > > > > >
> > > > > > > +out:
> > > > > > >       *scanned = scan;
> > > > > > >
> > > > > > >       trace_mm_vmscan_lru_isolate(order,
> > > > > > > @@ -1202,7 +1214,8 @@ static unsigned long isolate_pages_globa
> > > > > > >                                       struct list_head *dst,
> > > > > > >                                       unsigned long *scanned, int order,
> > > > > > >                                       int mode, struct zone *z,
> > > > > > > -                                     int active, int file)
> > > > > > > +                                     int active, int file,
> > > > > > > +                                     struct page **split_page)
> > > > > > >  {
> > > > > > >       int lru = LRU_BASE;
> > > > > > >       if (active)
> > > > > > > @@ -1210,7 +1223,7 @@ static unsigned long isolate_pages_globa
> > > > > > >       if (file)
> > > > > > >               lru += LRU_FILE;
> > > > > > >       return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
> > > > > > > -                                                             mode, file);
> > > > > > > +                                                     mode, file, split_page);
> > > > > > >  }
> > > > > > >
> > > > > > >  /*
> > > > > > > @@ -1444,10 +1457,12 @@ shrink_inactive_list(unsigned long nr_to
> > > > > > >  {
> > > > > > >       LIST_HEAD(page_list);
> > > > > > >       unsigned long nr_scanned;
> > > > > > > +     unsigned long total_scanned = 0;
> > > > > > >       unsigned long nr_reclaimed = 0;
> > > > > > >       unsigned long nr_taken;
> > > > > > >       unsigned long nr_anon;
> > > > > > >       unsigned long nr_file;
> > > > > > > +     struct page *split_page;
> > > > > > >
> > > > > > >       while (unlikely(too_many_isolated(zone, file, sc))) {
> > > > > > >               congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > > > > > @@ -1458,16 +1473,19 @@ shrink_inactive_list(unsigned long nr_to
> > > > > > >       }
> > > > > > >
> > > > > > >       set_reclaim_mode(priority, sc, false);
> > > > > > > +again:
> > > > > > >       lru_add_drain();
> > > > > > > +     split_page = NULL;
> > > > > > >       spin_lock_irq(&zone->lru_lock);
> > > > > > >
> > > > > > >       if (scanning_global_lru(sc)) {
> > > > > > > -             nr_taken = isolate_pages_global(nr_to_scan,
> > > > > > > +             nr_taken = isolate_pages_global(nr_to_scan - total_scanned,
> > > > > > >                       &page_list, &nr_scanned, sc->order,
> > > > > > >                       sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
> > > > > > >                                       ISOLATE_BOTH : ISOLATE_INACTIVE,
> > > > > > > -                     zone, 0, file);
> > > > > > > +                     zone, 0, file, &split_page);
> > > > > > >               zone->pages_scanned += nr_scanned;
> > > > > > > +             total_scanned += nr_scanned;
> > > > > > >               if (current_is_kswapd())
> > > > > > >                       __count_zone_vm_events(PGSCAN_KSWAPD, zone,
> > > > > > >                                              nr_scanned);
> > > > > > > @@ -1475,12 +1493,13 @@ shrink_inactive_list(unsigned long nr_to
> > > > > > >                       __count_zone_vm_events(PGSCAN_DIRECT, zone,
> > > > > > >                                              nr_scanned);
> > > > > > >       } else {
> > > > > > > -             nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
> > > > > > > +             nr_taken = mem_cgroup_isolate_pages(nr_to_scan - total_scanned,
> > > > > > >                       &page_list, &nr_scanned, sc->order,
> > > > > > >                       sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
> > > > > > >                                       ISOLATE_BOTH : ISOLATE_INACTIVE,
> > > > > > >                       zone, sc->mem_cgroup,
> > > > > > > -                     0, file);
> > > > > > > +                     0, file, &split_page);
> > > > > > > +             total_scanned += nr_scanned;
> > > > > > >               /*
> > > > > > >                * mem_cgroup_isolate_pages() keeps track of
> > > > > > >                * scanned pages on its own.
> > > > > > > @@ -1491,11 +1510,19 @@ shrink_inactive_list(unsigned long nr_to
> > > > > > >               spin_unlock_irq(&zone->lru_lock);
> > > > > > >               return 0;
> > > > > > >       }
> > > > > > > +     if (split_page && total_scanned < nr_to_scan) {
> > > > > > > +             spin_unlock_irq(&zone->lru_lock);
> > > > > > > +             split_huge_page(split_page);
> > > > > > > +             goto again;
> > > > > > > +     }
> > > > > > >
> > > > > > >       update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
> > > > > > >
> > > > > > >       spin_unlock_irq(&zone->lru_lock);
> > > > > > >
> > > > > > > +     if (split_page)
> > > > > > > +             split_huge_page(split_page);
> > > > > > > +
> > > > > > >       nr_reclaimed = shrink_page_list(&page_list, zone, sc);
> > > > > > >
> > > > > > >       /* Check if we should syncronously wait for writeback */
> > > > > > > @@ -1589,13 +1616,13 @@ static void shrink_active_list(unsigned
> > > > > > >               nr_taken = isolate_pages_global(nr_pages, &l_hold,
> > > > > > >                                               &pgscanned, sc->order,
> > > > > > >                                               ISOLATE_ACTIVE, zone,
> > > > > > > -                                             1, file);
> > > > > > > +                                             1, file, NULL);
> > > > > > >               zone->pages_scanned += pgscanned;
> > > > > > >       } else {
> > > > > > >               nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
> > > > > > >                                               &pgscanned, sc->order,
> > > > > > >                                               ISOLATE_ACTIVE, zone,
> > > > > > > -                                             sc->mem_cgroup, 1, file);
> > > > > > > +                                             sc->mem_cgroup, 1, file, NULL);
> > > > > > >               /*
> > > > > > >                * mem_cgroup_isolate_pages() keeps track of
> > > > > > >                * scanned pages on its own.
> > > > > > > Index: linux/mm/memcontrol.c
> > > > > > > ===================================================================
> > > > > > > --- linux.orig/mm/memcontrol.c        2011-10-25 08:36:08.000000000 +0800
> > > > > > > +++ linux/mm/memcontrol.c     2011-10-25 09:33:51.000000000 +0800
> > > > > > > @@ -1187,7 +1187,8 @@ unsigned long mem_cgroup_isolate_pages(u
> > > > > > >                                       unsigned long *scanned, int order,
> > > > > > >                                       int mode, struct zone *z,
> > > > > > >                                       struct mem_cgroup *mem_cont,
> > > > > > > -                                     int active, int file)
> > > > > > > +                                     int active, int file,
> > > > > > > +                                     struct page **split_page)
> > > > > > >  {
> > > > > > >       unsigned long nr_taken = 0;
> > > > > > >       struct page *page;
> > > > > > > @@ -1224,7 +1225,13 @@ unsigned long mem_cgroup_isolate_pages(u
> > > > > > >               case 0:
> > > > > > >                       list_move(&page->lru, dst);
> > > > > > >                       mem_cgroup_del_lru(page);
> > > > > > > -                     nr_taken += hpage_nr_pages(page);
> > > > > > > +                     if (PageTransHuge(page) && split_page) {
> > > > > > > +                             nr_taken++;
> > > > > > > +                             *split_page = page;
> > > > > > > +                             goto out;
> > > > > > > +                     } else
> > > > > > > +                             nr_taken += hpage_nr_pages(page);
> > > > > > > +
> > > > > > >                       break;
> > > > > > >               case -EBUSY:
> > > > > > >                       /* we don't affect global LRU but rotate in our LRU */
> > > > > > > @@ -1235,6 +1242,7 @@ unsigned long mem_cgroup_isolate_pages(u
> > > > > > >               }
> > > > > > >       }
> > > > > > >
> > > > > > > +out:
> > > > > > >       *scanned = scan;
> > > > > > >
> > > > > > >       trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
> > > > > > > Index: linux/include/linux/memcontrol.h
> > > > > > > ===================================================================
> > > > > > > --- linux.orig/include/linux/memcontrol.h     2011-10-25 08:36:08.000000000 +0800
> > > > > > > +++ linux/include/linux/memcontrol.h  2011-10-25 09:33:51.000000000 +0800
> > > > > > > @@ -37,7 +37,8 @@ extern unsigned long mem_cgroup_isolate_
> > > > > > >                                       unsigned long *scanned, int order,
> > > > > > >                                       int mode, struct zone *z,
> > > > > > >                                       struct mem_cgroup *mem_cont,
> > > > > > > -                                     int active, int file);
> > > > > > > +                                     int active, int file,
> > > > > > > +                                     struct page **split_page);
> > > > > > >
> > > > > > >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > > > > > >  /*
> > > > > > >
> > > > > > >
> > > > > >
> > > > > > I saw the code. my concern is your patch could make unnecessary split of THP.
> > > > > >
> > > > > > When we isolates page, we can't know whether it's working set or not.
> > > > > > So split should happen after we judge it's working set page.
> > > > > yes, but since memory is big currently, it's unlikely the isolated page
> > > > > get accessed in the window. And I only did the split in
> > > >
> > > > We don't check page_reference when isolate happens.
> > > > Window which between isolation time and reclaim?
> > > > No. Window is from inactive's head to tail and it's the basic concept of
> > > > our LRU.
> > > >
> > > > > shrink_inactive_list, not in active list.
> > > >
> > > > But inactive list's size could be still big and
> > > > page reference heuristic is very important for reclaim algorithm.
> > > I mean pages aren't referenced. but ok, I can't take such assumption.
> > >
> > > > > And THP has mechanism to collapse small pages to huge page later.
> > > >
> > > > You mean "merge" instead of "collapse"?
> > > >
> > > > >
> > > > > > If you really want to merge this patch, I suggest that
> > > > > > we can handle it in shrink_page_list step, not isolation step.
> > > > > >
> > > > > > My totally untested code which is just to show the concept is as follows,
> > > > > I did consider this option before. It has its problem too. The isolation
> > > > > can isolate several huge page one time. And then later shrink_page_list
> > > > > can swap several huge page one time, which is unfortunate. I'm pretty
> > > > > sure this method can't reduce the thp_split count in my test. It could
> > > >
> > > > I understand your point but approach isn't good to me.
> > > > Maybe we can check whether we are going on or not before other THP page split happens
> > > > in shrink_page_list. If we split THP page successfully, maybe we can skip another THP split.
> > > > Another idea is we can avoid split of THP unless high order reclaim happens or low order
> > > > high priority pressure happens.
> > > I agreed the split better be done at shrink_page_list, but we must avoid
> > > isolate too many pages. I'll check if I can have a better solution for
> > > next post.
> > Let me try again.
> >
> > Subject: thp: improve huge page reclaim -v2
> >
> > With transparent huge page enabled, huge page will be split if it will
> > be reclaimed. With current logic, if page reclaim finds a huge page,
> > it will just reclaim the head page and leave tail pages reclaimed later.
> > Let's take an example, lru list has page A and B, page A is huge page:
> > 1. page A is isolated
> > 2. page B is isolated
> > 3. shrink_page_list() adds page A to swap page cache. so page A is split.
> > page A+1, page A+2, ... are added to lru list.
> > 4. shrink_page_list() adds page B to swap page cache.
> > 5. page A and B is written out and reclaimed.
> > 6. page A+1, A+2 ... is isolated and reclaimed later.
> > So the reclaim order is A, B, ...(maybe other pages), A+1, A+2 ...
> > The worst case could be we isolate/split 32 huge pages to try to reclaim
> > a huge page, but we only the 32 head pages are reclaimed.
> >
> > We expected the whole huge page A is reclaimed in the meantime, so
> > the order is A, A+1, ... A+HPAGE_PMD_NR-1, B, .... This could reduce a lot
> > of unnecessary huge page split and improve the reclaim.
> >
> > With this patch, if a huge page is found in isolation, don't continue
> > isolation. Since if the huge page is reclaimed, we can reclaim more pages
> > than SWAP_CLUSTER_MAX. In shrink_page_list(), the huge page is split and
> > all tail pages will be added to the isolation list, so the tail pages can
> > be reclaimed immediately.
> >
> > The drawback is we might isolate less pages if a huge page is found. But
> > I thought the benefit is far more than the drawback.
> >
> > All code path are with PageTransHuge(), so should have no impact to normal
> > cases.
> >
> > In a test, a range of anonymous memory is written and will trigger swap.
> > Without the patch:
> > #cat /proc/vmstat|grep thp
> > thp_fault_alloc 451
> > thp_fault_fallback 0
> > thp_collapse_alloc 0
> > thp_collapse_alloc_failed 0
> > thp_split 238
> >
> > With the patch:
> > #cat /proc/vmstat|grep thp
> > thp_fault_alloc 451
> > thp_fault_fallback 0
> > thp_collapse_alloc 0
> > thp_collapse_alloc_failed 0
> > thp_split 76
> >
> > So the thp_split number is reduced a lot.
> >
> > v1->v2: Do the huge page split in shrink_page_list(). Some code are adopted from
> > Minchan's.
> >
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> >
> > ---
> >  include/linux/huge_mm.h    |    7 ++++++-
> >  include/linux/memcontrol.h |    3 ++-
> >  include/linux/swap.h       |    3 ++-
> >  mm/huge_memory.c           |   14 ++++++++------
> >  mm/memcontrol.c            |    6 +++++-
> >  mm/swap.c                  |   10 +++++++++-
> >  mm/swap_state.c            |    6 ------
> >  mm/vmscan.c                |   27 ++++++++++++++++++++-------
> >  8 files changed, 52 insertions(+), 24 deletions(-)
> >
> > Index: linux/include/linux/huge_mm.h
> > ===================================================================
> > --- linux.orig/include/linux/huge_mm.h        2011-11-02 09:48:16.000000000 +0800
> > +++ linux/include/linux/huge_mm.h     2011-11-02 10:06:33.000000000 +0800
> > @@ -81,7 +81,12 @@ extern int copy_pte_range(struct mm_stru
> >  extern int handle_pte_fault(struct mm_struct *mm,
> >                           struct vm_area_struct *vma, unsigned long address,
> >                           pte_t *pte, pmd_t *pmd, unsigned int flags);
> > -extern int split_huge_page(struct page *page);
> > +extern int split_huge_page_list(struct page *page, struct list_head *dst);
> > +static inline int split_huge_page(struct page *page)
> > +{
> > +     return split_huge_page_list(page, NULL);
> > +}
> > +
> >  extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
> >  #define split_huge_page_pmd(__mm, __pmd)                             \
> >       do {                                                            \
> > Index: linux/include/linux/swap.h
> > ===================================================================
> > --- linux.orig/include/linux/swap.h   2011-11-02 09:48:16.000000000 +0800
> > +++ linux/include/linux/swap.h        2011-11-02 10:06:33.000000000 +0800
> > @@ -218,7 +218,8 @@ extern unsigned int nr_free_pagecache_pa
> >  extern void __lru_cache_add(struct page *, enum lru_list lru);
> >  extern void lru_cache_add_lru(struct page *, enum lru_list lru);
> >  extern void lru_add_page_tail(struct zone* zone,
> > -                           struct page *page, struct page *page_tail);
> > +                           struct page *page, struct page *page_tail,
> > +                           struct list_head *dst);
> >  extern void activate_page(struct page *);
> >  extern void mark_page_accessed(struct page *);
> >  extern void lru_add_drain(void);
> > Index: linux/mm/huge_memory.c
> > ===================================================================
> > --- linux.orig/mm/huge_memory.c       2011-11-02 09:48:16.000000000 +0800
> > +++ linux/mm/huge_memory.c    2011-11-02 10:58:21.000000000 +0800
> > @@ -1159,7 +1159,8 @@ static int __split_huge_page_splitting(s
> >       return ret;
> >  }
> >
> > -static void __split_huge_page_refcount(struct page *page)
> > +static void __split_huge_page_refcount(struct page *page,
> > +                                    struct list_head *list)
> >  {
> >       int i;
> >       struct zone *zone = page_zone(page);
> > @@ -1229,7 +1230,7 @@ static void __split_huge_page_refcount(s
> >
> >               mem_cgroup_split_huge_fixup(page, page_tail);
> >
> > -             lru_add_page_tail(zone, page, page_tail);
> > +             lru_add_page_tail(zone, page, page_tail, list);
> >       }
> >
> >       __dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> > @@ -1343,7 +1344,8 @@ static int __split_huge_page_map(struct
> >
> >  /* must be called with anon_vma->root->mutex hold */
> >  static void __split_huge_page(struct page *page,
> > -                           struct anon_vma *anon_vma)
> > +                           struct anon_vma *anon_vma,
> > +                           struct list_head *list)
> >  {
> >       int mapcount, mapcount2;
> >       struct anon_vma_chain *avc;
> > @@ -1375,7 +1377,7 @@ static void __split_huge_page(struct pag
> >                      mapcount, page_mapcount(page));
> >       BUG_ON(mapcount != page_mapcount(page));
> >
> > -     __split_huge_page_refcount(page);
> > +     __split_huge_page_refcount(page, list);
> >
> >       mapcount2 = 0;
> >       list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> > @@ -1392,7 +1394,7 @@ static void __split_huge_page(struct pag
> >       BUG_ON(mapcount != mapcount2);
> >  }
> >
> > -int split_huge_page(struct page *page)
> > +int split_huge_page_list(struct page *page, struct list_head *list)
> >  {
> >       struct anon_vma *anon_vma;
> >       int ret = 1;
> > @@ -1406,7 +1408,7 @@ int split_huge_page(struct page *page)
> >               goto out_unlock;
> >
> >       BUG_ON(!PageSwapBacked(page));
> > -     __split_huge_page(page, anon_vma);
> > +     __split_huge_page(page, anon_vma, list);
> >       count_vm_event(THP_SPLIT);
> >
> >       BUG_ON(PageCompound(page));
> > Index: linux/mm/swap.c
> > ===================================================================
> > --- linux.orig/mm/swap.c      2011-11-02 09:48:16.000000000 +0800
> > +++ linux/mm/swap.c   2011-11-02 10:06:33.000000000 +0800
> > @@ -634,7 +634,8 @@ EXPORT_SYMBOL(__pagevec_release);
> >
> >  /* used by __split_huge_page_refcount() */
> >  void lru_add_page_tail(struct zone* zone,
> > -                    struct page *page, struct page *page_tail)
> > +                    struct page *page, struct page *page_tail,
> > +                    struct list_head *dst)
> >  {
> >       int active;
> >       enum lru_list lru;
> > @@ -646,6 +647,13 @@ void lru_add_page_tail(struct zone* zone
> >       VM_BUG_ON(PageLRU(page_tail));
> >       VM_BUG_ON(!spin_is_locked(&zone->lru_lock));
> >
> > +     /* The huge page is isolated */
> > +     if (dst) {
> > +             get_page(page_tail);
> > +             list_add_tail(&page_tail->lru, dst);
> > +             return;
> > +     }
> > +
> >       SetPageLRU(page_tail);
> >
> >       if (page_evictable(page_tail, NULL)) {
> > Index: linux/mm/swap_state.c
> > ===================================================================
> > --- linux.orig/mm/swap_state.c        2011-11-02 09:48:16.000000000 +0800
> > +++ linux/mm/swap_state.c     2011-11-02 10:06:33.000000000 +0800
> > @@ -154,12 +154,6 @@ int add_to_swap(struct page *page)
> >       if (!entry.val)
> >               return 0;
> >
> > -     if (unlikely(PageTransHuge(page)))
> > -             if (unlikely(split_huge_page(page))) {
> > -                     swapcache_free(entry, NULL);
> > -                     return 0;
> > -             }
> > -
> >       /*
> >        * Radix-tree node allocations from PF_MEMALLOC contexts could
> >        * completely exhaust the page allocator. __GFP_NOMEMALLOC
> > Index: linux/mm/vmscan.c
> > ===================================================================
> > --- linux.orig/mm/vmscan.c    2011-11-02 09:48:16.000000000 +0800
> > +++ linux/mm/vmscan.c 2011-11-02 10:58:21.000000000 +0800
> > @@ -838,6 +838,10 @@ static unsigned long shrink_page_list(st
> >               if (PageAnon(page) && !PageSwapCache(page)) {
> >                       if (!(sc->gfp_mask & __GFP_IO))
> >                               goto keep_locked;
> > +                     if (unlikely(PageTransHuge(page)))
> > +                             if (unlikely(split_huge_page_list(page,
> > +                                     page_list)))
> > +                                 goto activate_locked;
> >                       if (!add_to_swap(page))
> >                               goto activate_locked;
> >                       may_enter_fs = 1;
> > @@ -1076,7 +1080,8 @@ int __isolate_lru_page(struct page *page
> >   */
> >  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >               struct list_head *src, struct list_head *dst,
> > -             unsigned long *scanned, int order, int mode, int file)
> > +             unsigned long *scanned, int order, int mode, int file,
> > +             bool break_on_thp)
> >  {
> 
> Sorry for late response.
> These day, I am very busy for new job.
Thanks for your time.

> Still, I don't like surgery of isolation part.
> What if we isolate a THP page but it is working set page?
> Let's assume as follows
> 
> 1. Ioslate 32 page
> 2. Unfortunately, 1st page is THP so isolate_lru_page isolates just a
>    page(of course, it's 512 pages)
> 3. shrink_page_list see that it's working set page but page_list
>    have just a page so it have to isolate pages once more with higher priority.
that's possible. we might scan more pages, but should not introduce more
THP split, since isolate stop at huge page. on the other hand, if
isolation doesn't break in huge page, we can't split it and reclaim it
as a whole immediately. I didn't get a way to make both sides good. I
still thought the benefit is bigger than the drawback.

> How about this?
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9fdfce7..8121415 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -960,7 +960,15 @@ free_it:
>                  * appear not as the counts should be low
>                  */
>                 list_add(&page->lru, &free_pages);
> -               continue;
> +
> +               /*
> +                * If we have reclaimed enough pages, let's cut it off.
> +                * It could prevent unnecessary THP split.
> +                */
> +               if (nr_reclaimed >= sc->nr_to_reclaim)
> +                       break;
> +               else
> +                       continue;
> 
>  cull_mlocked:
>                 if (PageSwapCache(page))
this doesn't work. the huge page is dirty, so can't be reclaimed
immediately.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
