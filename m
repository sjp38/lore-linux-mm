Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 78722900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 11:47:05 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2634492qwa.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 08:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428110623.GU4658@suse.de>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
	<20110428110623.GU4658@suse.de>
Date: Sat, 30 Apr 2011 00:47:03 +0900
Message-ID: <BANLkTikzKBHfDkbxn89jtGxy2nAL-Fpt1w@mail.gmail.com>
Subject: Re: [RFC 6/8] In order putback lru core
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Apr 28, 2011 at 8:06 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Apr 27, 2011 at 01:25:23AM +0900, Minchan Kim wrote:
>> This patch defines new APIs to putback the page into previous position o=
f LRU.
>> The idea is simple.
>>
>> When we try to putback the page into lru list and if friends(prev, next)=
 of the pages
>> still is nearest neighbor, we can insert isolated page into prev's next =
instead of
>> head of LRU list. So it keeps LRU history without losing the LRU informa=
tion.
>>
>> Before :
>> =C2=A0 =C2=A0 =C2=A0 LRU POV : H - P1 - P2 - P3 - P4 -T
>>
>> Isolate P3 :
>> =C2=A0 =C2=A0 =C2=A0 LRU POV : H - P1 - P2 - P4 - T
>>
>> Putback P3 :
>> =C2=A0 =C2=A0 =C2=A0 if (P2->next =3D=3D P4)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 putback(P3, P2);
>> =C2=A0 =C2=A0 =C2=A0 So,
>> =C2=A0 =C2=A0 =C2=A0 LRU POV : H - P1 - P2 - P3 - P4 -T
>>
>> For implement, we defines new structure pages_lru which remebers
>> both lru friend pages of isolated one and handling functions.
>>
>> But this approach has a problem on contiguous pages.
>> In this case, my idea can not work since friend pages are isolated, too.
>> It means prev_page->next =3D=3D next_page always is false and both pages=
 are not
>> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
>> So for solving the problem, I can change the idea.
>> I think we don't need both friend(prev, next) pages relation but
>> just consider either prev or next page that it is still same LRU.
>> Worset case in this approach, prev or next page is free and allocate new
>> so it's in head of LRU and our isolated page is located on next of head.
>> But it's almost same situation with current problem. So it doesn't make =
worse
>> than now and it would be rare. But in this version, I implement based on=
 idea
>> discussed at LSF/MM. If my new idea makes sense, I will change it.
>>
>> Any comment?
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0include/linux/migrate.h =C2=A0| =C2=A0 =C2=A02 +
>> =C2=A0include/linux/mm_types.h | =C2=A0 =C2=A07 ++++
>> =C2=A0include/linux/swap.h =C2=A0 =C2=A0 | =C2=A0 =C2=A04 ++-
>> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03=
 +-
>> =C2=A0mm/internal.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =
=C2=A02 +
>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02=
 +-
>> =C2=A0mm/migrate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 36=
 +++++++++++++++++++++
>> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
 =C2=A0 =C2=A02 +-
>> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 79 +++++++++++++++++++++++++++++++++++++++++++--
>> =C2=A09 files changed, 129 insertions(+), 8 deletions(-)
>>
>> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>> index e39aeec..3aa5ab6 100644
>> --- a/include/linux/migrate.h
>> +++ b/include/linux/migrate.h
>> @@ -9,6 +9,7 @@ typedef struct page *new_page_t(struct page *, unsigned =
long private, int **);
>> =C2=A0#ifdef CONFIG_MIGRATION
>> =C2=A0#define PAGE_MIGRATION 1
>>
>> +extern void putback_pages_lru(struct list_head *l);
>> =C2=A0extern void putback_lru_pages(struct list_head *l);
>> =C2=A0extern int migrate_page(struct address_space *,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct page *, struct page *);
>> @@ -33,6 +34,7 @@ extern int migrate_huge_page_move_mapping(struct addre=
ss_space *mapping,
>> =C2=A0#else
>> =C2=A0#define PAGE_MIGRATION 0
>>
>> +static inline void putback_pages_lru(struct list_head *l) {}
>> =C2=A0static inline void putback_lru_pages(struct list_head *l) {}
>> =C2=A0static inline int migrate_pages(struct list_head *l, new_page_t x,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long private, =
bool offlining,
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index ca01ab2..35e80fb 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -102,6 +102,13 @@ struct page {
>> =C2=A0#endif
>> =C2=A0};
>>
>> +/* This structure is used for keeping LRU ordering of isolated page */
>> +struct pages_lru {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page; =C2=A0 =C2=A0 =C2=A0/* i=
solated page */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *prev_page; /* previous page of=
 isolate page as LRU order */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *next_page; /* next page of iso=
late page as LRU order */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head lru;
>> +};
>> =C2=A0/*
>
> So this thing has to be allocated from somewhere. We can't put it
> on the stack as we're already in danger there so we must be using
> kmalloc. In the reclaim paths, this should be avoided obviously.
> For compaction, we might hurt the compaction success rates if pages
> are pinned with control structures. It's something to be wary of.

Actually, 32 page unit of migration in compaction should be not a big probl=
em.
Maybe, just one page is enough to keep pages_lru arrays but I admit
dynamic allocation in reclaim patch and pinning the page in compaction
path isn't good.
So I have thought pagevec-like approach which is static allocated.
But the approach should be assume the migration unit should be small
like SWAP_CLUSTER_MAX It's true now but actually I don't want to
depends on the size.
But for free the size limitation, we have to allocate new page dynamically,

Hmm, any ideas?
Personally, I don't have any idea other than pagevec-like approach of 32 pa=
ges.

>
> At LSF/MM, I stated a preference for swapping the source and
> destination pages in the LRU. This unfortunately means that the LRU

I can't understand your point. swapping source and destination?
Could you elaborate on it?

> now contains a page in the process of being migrated to and the backout
> paths for migration failure become a lot more complex. Reclaim should
> be ok as it'll should fail to lock the page and recycle it in the list.
> This avoids allocations but I freely admit that I'm not in the position
> to implement such a thing right now :(
>
>> =C2=A0 * A region containing a mapping of a non-memory backed file under=
 NOMMU
>> =C2=A0 * conditions. =C2=A0These are held in a global tree and are pinne=
d by the VMAs that
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index baef4ad..4ad0a0c 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -227,6 +227,8 @@ extern void rotate_reclaimable_page(struct page *pag=
e);
>> =C2=A0extern void deactivate_page(struct page *page);
>> =C2=A0extern void swap_setup(void);
>>
>> +extern void update_page_reclaim_stat(struct zone *zone, struct page *pa=
ge,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int file, int rotate=
d);
>> =C2=A0extern void add_page_to_unevictable_list(struct page *page);
>>
>> =C2=A0/**
>> @@ -260,7 +262,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(str=
uct mem_cgroup *mem,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct zone *zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned long *nr_scanned);
>> =C2=A0extern int __isolate_lru_page(struct page *page, int mode, int fil=
e,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mapped);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mappe=
d, struct pages_lru *pages_lru);
>> =C2=A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
>> =C2=A0extern int vm_swappiness;
>> =C2=A0extern int remove_mapping(struct address_space *mapping, struct pa=
ge *page);
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 653b02b..c453000 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -335,7 +335,8 @@ static unsigned long isolate_migratepages(struct zon=
e *zone,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Try isolate the page=
 */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page(page,=
 ISOLATE_BOTH, 0, !cc->sync, 0) !=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page(page,=
 ISOLATE_BOTH, 0,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !cc->sync, 0, NULL)=
 !=3D 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(PageTransComp=
ound(page));
>> diff --git a/mm/internal.h b/mm/internal.h
>> index d071d38..3c8182c 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -43,6 +43,8 @@ extern unsigned long highest_memmap_pfn;
>> =C2=A0 * in mm/vmscan.c:
>> =C2=A0 */
>> =C2=A0extern int isolate_lru_page(struct page *page);
>> +extern bool keep_lru_order(struct pages_lru *pages_lru);
>> +extern void putback_page_to_lru(struct page *page, struct list_head *he=
ad);
>> =C2=A0extern void putback_lru_page(struct page *page);
>>
>> =C2=A0/*
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 471e7fd..92a9046 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1193,7 +1193,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned lo=
ng nr_to_scan,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scan++;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __isolate_lru_page(p=
age, mode, file, 0, 0);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __isolate_lru_page(p=
age, mode, file, 0, 0, NULL);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (ret) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case 0:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 list_move(&page->lru, dst);
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 819d233..9cfb63b 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -85,6 +85,42 @@ void putback_lru_pages(struct list_head *l)
>> =C2=A0}
>>
>> =C2=A0/*
>> + * This function is almost same iwth putback_lru_pages.
>> + * The difference is that function receives struct pages_lru list
>> + * and if possible, we add pages into original position of LRU
>> + * instead of LRU's head.
>> + */
>> +void putback_pages_lru(struct list_head *l)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pages_lru *isolated_page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pages_lru *isolated_page2;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry_safe(isolated_page, iso=
lated_page2, l, lru) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zo=
ne;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D isolat=
ed_page->page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&isola=
ted_page->lru);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_zone_page_s=
tate(page, NR_ISOLATED_ANON +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page_is_file_cache(page));
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone =3D page_z=
one(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&=
zone->lru_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (keep_lru_or=
der(isolated_page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0putback_page_to_lru(page, &isolated_page->prev_page->lru);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0putback_lru_page(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kfree(isolated_=
page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> +}
>
> I think we also need counters at least at discussion stage to see
> how successful this is.

Actually, I had some numbers but don't published it.
(4core, 1G DRAM and THP always, big stress(qemu, compile, web
browsing, eclipse and other programs fork, successful rate is about
50%)
That's because I have another idea to solve contiguous PFN problem.
Please, see the description and reply of Rik's question on this thread.
I guess the approach could make a high successful rate if there isn't
concurrent direct compaction processes.

>
> For example, early in the system there is a casual relationship
> between the age of a page and its location in physical memory. The
> buddy allocator gives pages back in PFN order where possible and
> there is a loose relationship between when pages get allocated and
> when they get reclaimed. As compaction is a linear scanner, there
> is a likelihood (that is highly variable) that physically contiguous
> pages will have similar positions in the LRU. They'll be isolated at
> the same time meaning they also won't be put back in order.

Indeed! but I hope my second idea would solve the problem.
What do you think about it?
>
> This might cease to matter when the system is running for some time but
> it's a concern.

Yes. It depends on aging of workloads.
I think it's not easy to get a meaningful number to justify all. :(

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
