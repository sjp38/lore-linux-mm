Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 448586B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:24:44 -0500 (EST)
Received: by iwn35 with SMTP id 35so115941iwn.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 15:24:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101123092826.GD19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101123092826.GD19571@csn.ul.ie>
Date: Wed, 24 Nov 2010 08:24:35 +0900
Message-ID: <AANLkTi=KunDRwVd73vtbng0F+a=QBgJeV5BXrewYJa3R@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, Nov 23, 2010 at 6:28 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Sun, Nov 21, 2010 at 11:30:23PM +0900, Minchan Kim wrote:
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
>> By Other approach, app developer uses POSIX_FADV_DONTNEED.
>> But it has a problem. If kernel meets page is writing
>> during invalidate_mapping_pages, it can't work.
>> It is very hard for application programmer to use it.
>> Because they always have to sync data before calling
>> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
>> be discardable. At last, they can't use deferred write of kernel
>> so that they could see performance loss.
>> (http://insights.oetiker.ch/linux/fadvise.html)
>>
>> In fact, invalidate is very big hint to reclaimer.
>> It means we don't use the page any more. So let's move
>> the writing page into inactive list's head.
>>
>> If it is real working set, it could have a enough time to
>> activate the page since we always try to keep many pages in
>> inactive list.
>>
>> I reuse lru_demote of Peter with some change.
>>
>> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>>
>> Ben, Remain thing is to modify rsync and use
>> fadvise(POSIX_FADV_DONTNEED). Could you test it?
>> ---
>> =A0include/linux/swap.h | =A0 =A01 +
>> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 61 +++++++++++++++++++++++++++=
+++++++++++++++++++++++
>> =A0mm/truncate.c =A0 =A0 =A0 =A0| =A0 11 +++++---
>> =A03 files changed, 69 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index eba53e7..a3c9248 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -213,6 +213,7 @@ extern void mark_page_accessed(struct page *);
>> =A0extern void lru_add_drain(void);
>> =A0extern int lru_add_drain_all(void);
>> =A0extern void rotate_reclaimable_page(struct page *page);
>> +extern void lru_deactive_page(struct page *page);
>> =A0extern void swap_setup(void);
>>
>> =A0extern void add_page_to_unevictable_list(struct page *page);
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 3f48542..56fa298 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -39,6 +39,8 @@ int page_cluster;
>>
>> =A0static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>> =A0static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>> +static DEFINE_PER_CPU(struct pagevec, lru_deactive_pvecs);
>> +
>>
>> =A0/*
>> =A0 * This path almost never happens for VM activity - pages are normall=
y
>> @@ -266,6 +268,45 @@ void add_page_to_unevictable_list(struct page *page=
)
>> =A0 =A0 =A0 spin_unlock_irq(&zone->lru_lock);
>> =A0}
>>
>> +static void __pagevec_lru_deactive(struct pagevec *pvec)
>> +{
>
> Might be worth commenting that this function must be called with pre-empt=
ion
> disabled. FWIW, I am reasonably sure your implementation is prefectly saf=
e
> but a note wouldn't hurt.

Will fix.

>
>> + =A0 =A0 int i, lru, file;
>> +
>> + =A0 =A0 struct zone *zone =3D NULL;
>> +
>> + =A0 =A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D pvec->pages[i];
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *pagezone =3D page_zone(page);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pagezone !=3D zone) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_ir=
q(&zone->lru_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone =3D pagezone;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_lock)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (PageLRU(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageActive(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 file =3D page_=
is_file_cache(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru =3D page_l=
ru_base_type(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_from_=
lru_list(zone, page,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 lru + LRU_ACTIVE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageActiv=
e(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageRefer=
enced(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_lr=
u_list(zone, page, lru);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_eve=
nt(PGDEACTIVATE);
>> +
>
> What about memcg, do we not need to be calling mem_cgroup_add_lru_list() =
here
> as well? I'm looking at the differences between what move_active_pages_to=
_lru()

Recently, add_page_to_lru_list contains mem_cgroup_add_lru_list.

> is doing and this. I'm wondering if it'd be worth your whole building a l=
ist
> of active pages that are to be moved to the inactive list and passing the=
m
> to move_active_pages_to_lru() ? I confuess I have not thought about it de=
eply
> so it might be a terrible suggestion but it might reduce duplication of c=
ode.

Firstly I tried it so I sent a patch about making
move_to_active_pages_to_lru more generic.
move_to_active_pages_to_lru needs zone argument so I need gathering
pages per zone in truncate.
I don't want for user of the function to consider even zone and
zone->lru_lock handling.

I think the lru_demote_pages could be used elsewhere(ex, readahead max
size heuristic).
So it's generic and easy to use. :)

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 update_page_re=
claim_stat(zone, page, file, 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> + =A0 =A0 if (zone)
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&zone->lru_lock);
>> +
>> + =A0 =A0 release_pages(pvec->pages, pvec->nr, pvec->cold);
>> + =A0 =A0 pagevec_reinit(pvec);
>> +}
>> +
>> =A0/*
>> =A0 * Drain pages out of the cpu's pagevecs.
>> =A0 * Either "cpu" is the current CPU, and preemption has already been
>> @@ -292,8 +333,28 @@ static void drain_cpu_pagevecs(int cpu)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pagevec_move_tail(pvec);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);
>> =A0 =A0 =A0 }
>> +
>> + =A0 =A0 pvec =3D &per_cpu(lru_deactive_pvecs, cpu);
>> + =A0 =A0 if (pagevec_count(pvec))
>> + =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactive(pvec);
>> +}
>> +
>> +/*
>> + * Function used to forecefully demote a page to the head of the inacti=
ve
>> + * list.
>
> s/forecefully/forcefully/
>
> The comment should also state *why* and under what circumstances we move
> pages to the inactive list like this. Also based on the discussions
> elsewhere in this thread, it'd be nice to include a comment why it's the
> head of the inactive list and not the tail.

Fair enough.

Thanks for the comment, Mel.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
