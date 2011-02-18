Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CFB0C8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 19:33:54 -0500 (EST)
Received: by vxb41 with SMTP id 41so1579626vxb.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 16:33:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110218005020.d202acd2.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<5677f3262774f4ddc24044065b7cbd6443ac5e16.1297940291.git.minchan.kim@gmail.com>
	<20110218005020.d202acd2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 18 Feb 2011 09:33:52 +0900
Message-ID: <AANLkTikfbqjk18JM8pTh+F6QR69m+QxQzdw6CQGOuZjH@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Fri, Feb 18, 2011 at 12:50 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 18 Feb 2011 00:08:19 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Recently, there are reported problem about thrashing.
>> (http://marc.info/?l=3Drsync&m=3D128885034930933&w=3D2)
>> It happens by backup workloads(ex, nightly rsync).
>> That's because the workload makes just use-once pages
>> and touches pages twice. It promotes the page into
>> active list so that it results in working set page eviction.
>>
>> Some app developer want to support POSIX_FADV_NOREUSE.
>> But other OSes don't support it, either.
>> (http://marc.info/?l=3Dlinux-mm&m=3D128928979512086&w=3D2)
>>
>> By other approach, app developers use POSIX_FADV_DONTNEED.
>> But it has a problem. If kernel meets page is writing
>> during invalidate_mapping_pages, it can't work.
>> It makes for application programmer to use it since they always
>> have to sync data before calling fadivse(..POSIX_FADV_DONTNEED) to
>> make sure the pages could be discardable. At last, they can't use
>> deferred write of kernel so that they could see performance loss.
>> (http://insights.oetiker.ch/linux/fadvise.html)
>>
>> In fact, invalidation is very big hint to reclaimer.
>> It means we don't use the page any more. So let's move
>> the writing page into inactive list's head if we can't truncate
>> it right now.
>>
>> Why I move page to head of lru on this patch, Dirty/Writeback page
>> would be flushed sooner or later. It can prevent writeout of pageout
>> which is less effective than flusher's writeout.
>>
>> Originally, I reused lru_demote of Peter with some change so added
>> his Signed-off-by.
>>
>> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Acked-by: Mel Gorman <mel@csn.ul.ie>
>> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> One question is ....it seems there is no flush() code for percpu pagevec
> in this patch. Is it safe against cpu hot plug ?
>
> And from memory hot unplug point of view, I'm grad if pagevec for this
> is flushed at the same time as when we clear other per-cpu lru pagevecs.
> (And compaction will be affected by the page_count() magic by pagevec
> =C2=A0which is flushed only when FADVISE is called.)
>
> Could you add add-on patches for flushing and hooks ?

Isn't it enough in my patch? If I miss your point, Could you elaborate plea=
se?

 * Drain pages out of the cpu's pagevecs.
 * Either "cpu" is the current CPU, and preemption has already been
 * disabled; or "cpu" is being hot-unplugged, and is already dead.
@@ -372,6 +427,29 @@ static void drain_cpu_pagevecs(int cpu)
               pagevec_move_tail(pvec);
               local_irq_restore(flags);
       }
+
+       pvec =3D &per_cpu(lru_deactivate_pvecs, cpu);
+       if (pagevec_count(pvec))
+               ____pagevec_lru_deactivate(pvec);
+}


>
> Thanks,
> -Kame
>
>
>
>> ---
>> Changelog since v4:
>> =C2=A0- Change function comments - suggested by Johannes
>> =C2=A0- Change function name - suggested by Johannes
>> =C2=A0- Drop only dirty/writeback pages to deactive pagevec - suggested =
by Johannes
>> =C2=A0- Add acked-by
>>
>> Changelog since v3:
>> =C2=A0- Change function comments - suggested by Johannes
>> =C2=A0- Change function name - suggested by Johannes
>> =C2=A0- add only dirty/writeback pages to deactive pagevec
>>
>> Changelog since v2:
>> =C2=A0- mapped page leaves alone - suggested by Mel
>> =C2=A0- pass part related PG_reclaim in next patch.
>>
>> Changelog since v1:
>> =C2=A0- modify description
>> =C2=A0- correct typo
>> =C2=A0- add some comment
>>
>> =C2=A0include/linux/swap.h | =C2=A0 =C2=A01 +
>> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 78 +++=
+++++++++++++++++++++++++++++++++++++++++++++++
>> =C2=A0mm/truncate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 17 ++++++++---
>> =C2=A03 files changed, 91 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 4d55932..c335055 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -215,6 +215,7 @@ extern void mark_page_accessed(struct page *);
>> =C2=A0extern void lru_add_drain(void);
>> =C2=A0extern int lru_add_drain_all(void);
>> =C2=A0extern void rotate_reclaimable_page(struct page *page);
>> +extern void deactivate_page(struct page *page);
>> =C2=A0extern void swap_setup(void);
>>
>> =C2=A0extern void add_page_to_unevictable_list(struct page *page);
>> diff --git a/mm/swap.c b/mm/swap.c
>> index c02f936..4aea806 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -39,6 +39,7 @@ int page_cluster;
>>
>> =C2=A0static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs)=
;
>> =C2=A0static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>> +static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>>
>> =C2=A0/*
>> =C2=A0 * This path almost never happens for VM activity - pages are norm=
ally
>> @@ -347,6 +348,60 @@ void add_page_to_unevictable_list(struct page *page=
)
>> =C2=A0}
>>
>> =C2=A0/*
>> + * If the page can not be invalidated, it is moved to the
>> + * inactive list to speed up its reclaim. =C2=A0It is moved to the
>> + * head of the list, rather than the tail, to give the flusher
>> + * threads some time to write it out, as this is much more
>> + * effective than the single-page writeout from reclaim.
>> + */
>> +static void lru_deactivate(struct page *page, struct zone *zone)
>> +{
>> + =C2=A0 =C2=A0 int lru, file;
>> +
>> + =C2=A0 =C2=A0 if (!PageLRU(page) || !PageActive(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> + =C2=A0 =C2=A0 /* Some processes are using the page */
>> + =C2=A0 =C2=A0 if (page_mapped(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> +
>> + =C2=A0 =C2=A0 file =3D page_is_file_cache(page);
>> + =C2=A0 =C2=A0 lru =3D page_lru_base_type(page);
>> + =C2=A0 =C2=A0 del_page_from_lru_list(zone, page, lru + LRU_ACTIVE);
>> + =C2=A0 =C2=A0 ClearPageActive(page);
>> + =C2=A0 =C2=A0 ClearPageReferenced(page);
>> + =C2=A0 =C2=A0 add_page_to_lru_list(zone, page, lru);
>> + =C2=A0 =C2=A0 __count_vm_event(PGDEACTIVATE);
>> +
>> + =C2=A0 =C2=A0 update_page_reclaim_stat(zone, page, file, 0);
>> +}
>> +
>> +static void ____pagevec_lru_deactivate(struct pagevec *pvec)
>> +{
>> + =C2=A0 =C2=A0 int i;
>> + =C2=A0 =C2=A0 struct zone *zone =3D NULL;
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page =3D pvec->=
pages[i];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *pagezone =3D pa=
ge_zone(page);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pagezone !=3D zone) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (zone)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
zone =3D pagezone;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
spin_lock_irq(&zone->lru_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru_deactivate(page, zone);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 if (zone)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_l=
ock);
>> +
>> + =C2=A0 =C2=A0 release_pages(pvec->pages, pvec->nr, pvec->cold);
>> + =C2=A0 =C2=A0 pagevec_reinit(pvec);
>> +}
>> +
>> +
>> +/*
>> =C2=A0 * Drain pages out of the cpu's pagevecs.
>> =C2=A0 * Either "cpu" is the current CPU, and preemption has already bee=
n
>> =C2=A0 * disabled; or "cpu" is being hot-unplugged, and is already dead.
>> @@ -372,6 +427,29 @@ static void drain_cpu_pagevecs(int cpu)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pagevec_move_tail(pvec)=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 local_irq_restore(flags=
);
>> =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 pvec =3D &per_cpu(lru_deactivate_pvecs, cpu);
>> + =C2=A0 =C2=A0 if (pagevec_count(pvec))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ____pagevec_lru_deactivate(p=
vec);
>> +}
>> +
>> +/**
>> + * deactivate_page - forcefully deactivate a page
>> + * @page: page to deactivate
>> + *
>> + * This function hints the VM that @page is a good reclaim candidate,
>> + * for example if its invalidation fails due to the page being dirty
>> + * or under writeback.
>> + */
>> +void deactivate_page(struct page *page)
>> +{
>> + =C2=A0 =C2=A0 if (likely(get_page_unless_zero(page))) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct pagevec *pvec =3D &ge=
t_cpu_var(lru_deactivate_pvecs);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pagevec_add(pvec, page)=
)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
____pagevec_lru_deactivate(pvec);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_cpu_var(lru_deactivate_p=
vecs);
>> + =C2=A0 =C2=A0 }
>> =C2=A0}
>>
>> =C2=A0void lru_add_drain(void)
>> diff --git a/mm/truncate.c b/mm/truncate.c
>> index 4d415b3..9ec7bc5 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -328,11 +328,12 @@ EXPORT_SYMBOL(truncate_inode_pages);
>> =C2=A0 * pagetables.
>> =C2=A0 */
>> =C2=A0unsigned long invalidate_mapping_pages(struct address_space *mappi=
ng,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgoff_t start, pgoff=
_t end)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t start, pgoff_t end)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct pagevec pvec;
>> =C2=A0 =C2=A0 =C2=A0 pgoff_t next =3D start;
>> - =C2=A0 =C2=A0 unsigned long ret =3D 0;
>> + =C2=A0 =C2=A0 unsigned long ret;
>> + =C2=A0 =C2=A0 unsigned long count =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 int i;
>>
>> =C2=A0 =C2=A0 =C2=A0 pagevec_init(&pvec, 0);
>> @@ -359,8 +360,14 @@ unsigned long invalidate_mapping_pages(struct addre=
ss_space *mapping,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (lock_failed)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
ret +=3D invalidate_inode_page(page);
>> -
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
ret =3D invalidate_inode_page(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
/*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0* Invalidation is a hint that the page is no longer
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0* of interest and try to speed up its reclaim.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (!ret)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 deactivate_page(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
count +=3D ret;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unlock_page(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (next > end)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> @@ -369,7 +376,7 @@ unsigned long invalidate_mapping_pages(struct addres=
s_space *mapping,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_uncharge_end=
();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
>> =C2=A0 =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 return ret;
>> + =C2=A0 =C2=A0 return count;
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL(invalidate_mapping_pages);
>>
>> --
>> 1.7.1
>>
>>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
