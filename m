Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6189000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 00:20:03 -0400 (EDT)
Received: by vws4 with SMTP id 4so1459573vws.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:20:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
Date: Wed, 27 Apr 2011 13:20:00 +0900
Message-ID: <BANLkTi=UGNJKhFDZwuQK7Oopk7p=Pz=NYQ@mail.gmail.com>
Subject: Re: [RFC 6/8] In order putback lru core
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 1:25 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> This patch defines new APIs to putback the page into previous position of=
 LRU.
> The idea is simple.
>
> When we try to putback the page into lru list and if friends(prev, next) =
of the pages
> still is nearest neighbor, we can insert isolated page into prev's next i=
nstead of
> head of LRU list. So it keeps LRU history without losing the LRU informat=
ion.
>
> Before :
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LRU POV : H - P1 - P2 - P3 - P4 -T
>
> Isolate P3 :
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LRU POV : H - P1 - P2 - P4 - T
>
> Putback P3 :
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (P2->next =3D=3D P4)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0putback(P3, P2);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0So,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LRU POV : H - P1 - P2 - P3 - P4 -T
>
> For implement, we defines new structure pages_lru which remebers
> both lru friend pages of isolated one and handling functions.
>
> But this approach has a problem on contiguous pages.
> In this case, my idea can not work since friend pages are isolated, too.
> It means prev_page->next =3D=3D next_page always is false and both pages =
are not
> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
> So for solving the problem, I can change the idea.
> I think we don't need both friend(prev, next) pages relation but
> just consider either prev or next page that it is still same LRU.
> Worset case in this approach, prev or next page is free and allocate new
> so it's in head of LRU and our isolated page is located on next of head.
> But it's almost same situation with current problem. So it doesn't make w=
orse
> than now and it would be rare. But in this version, I implement based on =
idea
> discussed at LSF/MM. If my new idea makes sense, I will change it.
>
> Any comment?
>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =C2=A0include/linux/migrate.h =C2=A0| =C2=A0 =C2=A02 +
> =C2=A0include/linux/mm_types.h | =C2=A0 =C2=A07 ++++
> =C2=A0include/linux/swap.h =C2=A0 =C2=A0 | =C2=A0 =C2=A04 ++-
> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03 =
+-
> =C2=A0mm/internal.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A02 +
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 =
+-
> =C2=A0mm/migrate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 36 =
+++++++++++++++++++++
> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =
=C2=A0 =C2=A02 +-
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 79 +++++++++++++++++++++++++++++++++++++++++++--
> =C2=A09 files changed, 129 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e39aeec..3aa5ab6 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -9,6 +9,7 @@ typedef struct page *new_page_t(struct page *, unsigned l=
ong private, int **);
> =C2=A0#ifdef CONFIG_MIGRATION
> =C2=A0#define PAGE_MIGRATION 1
>
> +extern void putback_pages_lru(struct list_head *l);
> =C2=A0extern void putback_lru_pages(struct list_head *l);
> =C2=A0extern int migrate_page(struct address_space *,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct page *, struct page *);
> @@ -33,6 +34,7 @@ extern int migrate_huge_page_move_mapping(struct addres=
s_space *mapping,
> =C2=A0#else
> =C2=A0#define PAGE_MIGRATION 0
>
> +static inline void putback_pages_lru(struct list_head *l) {}
> =C2=A0static inline void putback_lru_pages(struct list_head *l) {}
> =C2=A0static inline int migrate_pages(struct list_head *l, new_page_t x,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long priv=
ate, bool offlining,
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index ca01ab2..35e80fb 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -102,6 +102,13 @@ struct page {
> =C2=A0#endif
> =C2=A0};
>
> +/* This structure is used for keeping LRU ordering of isolated page */
> +struct pages_lru {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page; =C2=A0 =C2=A0 =C2=A0/* is=
olated page */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *prev_page; /* previous page of =
isolate page as LRU order */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *next_page; /* next page of isol=
ate page as LRU order */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head lru;
> +};
> =C2=A0/*
> =C2=A0* A region containing a mapping of a non-memory backed file under N=
OMMU
> =C2=A0* conditions. =C2=A0These are held in a global tree and are pinned =
by the VMAs that
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index baef4ad..4ad0a0c 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -227,6 +227,8 @@ extern void rotate_reclaimable_page(struct page *page=
);
> =C2=A0extern void deactivate_page(struct page *page);
> =C2=A0extern void swap_setup(void);
>
> +extern void update_page_reclaim_stat(struct zone *zone, struct page *pag=
e,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int file, int rotate=
d);
> =C2=A0extern void add_page_to_unevictable_list(struct page *page);
>
> =C2=A0/**
> @@ -260,7 +262,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(stru=
ct mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned long *nr_scanned);
> =C2=A0extern int __isolate_lru_page(struct page *page, int mode, int file=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mapped);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not=
_mapped, struct pages_lru *pages_lru);
> =C2=A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
> =C2=A0extern int vm_swappiness;
> =C2=A0extern int remove_mapping(struct address_space *mapping, struct pag=
e *page);
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 653b02b..c453000 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -335,7 +335,8 @@ static unsigned long isolate_migratepages(struct zone=
 *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Try isolate the=
 page */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page=
(page, ISOLATE_BOTH, 0, !cc->sync, 0) !=3D 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page=
(page, ISOLATE_BOTH, 0,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !cc->sync, 0=
, NULL) !=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(PageTran=
sCompound(page));
> diff --git a/mm/internal.h b/mm/internal.h
> index d071d38..3c8182c 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -43,6 +43,8 @@ extern unsigned long highest_memmap_pfn;
> =C2=A0* in mm/vmscan.c:
> =C2=A0*/
> =C2=A0extern int isolate_lru_page(struct page *page);
> +extern bool keep_lru_order(struct pages_lru *pages_lru);
> +extern void putback_page_to_lru(struct page *page, struct list_head *hea=
d);
> =C2=A0extern void putback_lru_page(struct page *page);
>
> =C2=A0/*
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 471e7fd..92a9046 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1193,7 +1193,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned lon=
g nr_to_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan++;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __isolate_lru_=
page(page, mode, file, 0, 0);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __isolate_lru_=
page(page, mode, file, 0, 0, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (ret) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case 0:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_move(&page->lru, dst);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 819d233..9cfb63b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -85,6 +85,42 @@ void putback_lru_pages(struct list_head *l)
> =C2=A0}
>
> =C2=A0/*
> + * This function is almost same iwth putback_lru_pages.
> + * The difference is that function receives struct pages_lru list
> + * and if possible, we add pages into original position of LRU
> + * instead of LRU's head.
> + */
> +void putback_pages_lru(struct list_head *l)
> +{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pages_lru *isolated_page;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pages_lru *isolated_page2;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry_safe(isolated_page, isol=
ated_page2, l, lru) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zon=
e;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D isolate=
d_page->page;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&isolat=
ed_page->lru);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_zone_page_st=
ate(page, NR_ISOLATED_ANON +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page_is_file_cache(page));
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone =3D page_zo=
ne(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&z=
one->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (keep_lru_ord=
er(isolated_page)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0putback_page_to_lru(page, &isolated_page->prev_page->lru);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0putback_lru_page(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kfree(isolated_p=
age);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +}
> +
> +
> +/*
> =C2=A0* Restore a potential migration pte to a working pte entry
> =C2=A0*/
> =C2=A0static int remove_migration_pte(struct page *new, struct vm_area_st=
ruct *vma,
> diff --git a/mm/swap.c b/mm/swap.c
> index a83ec5a..0cb15b7 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -252,7 +252,7 @@ void rotate_reclaimable_page(struct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
> -static void update_page_reclaim_stat(struct zone *zone, struct page *pag=
e,
> +void update_page_reclaim_stat(struct zone *zone, struct page *page,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int file, int rotated)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone_reclaim_stat *reclaim_stat =3D &zo=
ne->reclaim_stat;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5196f0c..06a7c9b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -550,6 +550,58 @@ int remove_mapping(struct address_space *mapping, st=
ruct page *page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> +/* zone->lru_lock must be hold */
> +bool keep_lru_order(struct pages_lru *pages_lru)
> +{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0bool ret =3D false;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *prev, *next;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pages_lru->prev_page)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0prev =3D pages_lru->prev_page;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0next =3D pages_lru->next_page;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageLRU(prev) || !PageLRU(next))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (prev->lru.next =3D=3D &next->lru)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D true;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(PageUnevictable(prev)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D false;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> +}
> +
> +/**
> + * putback_page_to_lru - put isolated @page onto @head
> + * @page: page to be put back to appropriate lru list
> + * @head: lru position to be put back
> + *
> + * Insert previously isolated @page to appropriate position of lru list
> + * zone->lru_lock must be hold.
> + */
> +void putback_page_to_lru(struct page *page, struct list_head *head)
> +{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0int lru, active, file;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D page_zone(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *prev_page =3D container_of(head=
, struct page, lru);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0lru =3D page_lru(prev_page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0active =3D is_active_lru(lru);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0file =3D is_file_lru(lru);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (active)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SetPageActive(pa=
ge);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ClearPageActive(page);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0update_page_reclaim_stat(zone, page, file, a=
ctive);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0SetPageLRU(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0__add_page_to_lru_list(zone, page, lru, head=
);
> +}
> +
> =C2=A0/**
> =C2=A0* putback_lru_page - put previously isolated page onto appropriate =
LRU list's head
> =C2=A0* @page: page to be put back to appropriate lru list
> @@ -959,8 +1011,8 @@ keep_lumpy:
> =C2=A0* not_mapped: page should be not mapped
> =C2=A0* returns 0 on success, -ve errno on failure.
> =C2=A0*/
> -int __isolate_lru_page(struct page *page, int mode, int file,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mapped)
> +int __isolate_lru_page(struct page *page, int mode, int file, int not_di=
rty,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_mapped, struct pages_lru *pages_=
lru)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D -EINVAL;
>
> @@ -996,12 +1048,31 @@ int __isolate_lru_page(struct page *page, int mode=
, int file,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -EBUSY;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(get_page_unless_zero(page))) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone =3D =
page_zone(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum lru_list l =3D pa=
ge_lru(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Be careful not =
to clear PageLRU until after we're
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * sure the page i=
s not being freed elsewhere -- the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * page release co=
de relies on it.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ClearPageLRU(page)=
;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pages_lru)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto skip;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages_lru->page =3D pa=
ge;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (&zone->lru[l].list=
 =3D=3D pages_lru->lru.prev ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 &zone->lru[l].list =3D=3D pages_lru->lru.next) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pages_lru->prev_page =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pages_lru->next_page =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto skip;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }

While I was refactoring the code, I might got sleep.
It should be following as,


@@ -1071,8 +1072,8 @@ int __isolate_lru_page(struct page *page, int
mode, int file, int not_dirty,
                        goto skip;

                pages_lru->page =3D page;
-               if (&zone->lru[l].list =3D=3D pages_lru->lru.prev ||
-                       &zone->lru[l].list =3D=3D pages_lru->lru.next) {
+               if (&zone->lru[l].list =3D=3D page->lru.prev ||
+                       &zone->lru[l].list =3D=3D page->lru.next) {
                        pages_lru->prev_page =3D NULL;
                        pages_lru->next_page =3D NULL;
                        goto skip;

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
