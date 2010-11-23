Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B3426B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:40:11 -0500 (EST)
Received: by iwn10 with SMTP id 10so1021658iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 23:40:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122143817.E242.A69D9226@jp.fujitsu.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122143817.E242.A69D9226@jp.fujitsu.com>
Date: Tue, 23 Nov 2010 16:40:03 +0900
Message-ID: <AANLkTinZmv540r+EkjwUu6cd9c1u7qG9iR+pvp3YqZC1@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

Hi KOSAKI,

2010/11/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
>> By Other approach, app developer uses POSIX_FADV_DONTNEED.
>> But it has a problem. If kernel meets page is writing
>> during invalidate_mapping_pages, it can't work.
>> It is very hard for application programmer to use it.
>> Because they always have to sync data before calling
>> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
>> be discardable. At last, they can't use deferred write of kernel
>> so that they could see performance loss.
>> (http://insights.oetiker.ch/linux/fadvise.html)
>
> If rsync use the above url patch, we don't need your patch.
> fdatasync() + POSIX_FADV_DONTNEED should work fine.

It works well. But it needs always fdatasync before calling fadvise.
For small file, it hurt performance since we can't use the deferred write.

>
> So, I think the core worth of previous PeterZ's patch is in readahead
> based heuristics. I'm curious why you drop it.
>

In previous peter's patch, it couldn't move active page into inactive list.
So it's not what i want and I think invalidation is stronger hint than
the readahead heuristic.
But if we need it, I will add it in my series. It can help reclaiming
unnecessary inactive page asap.
but before that, I hope we make sure fadvise works well enough.

>
>> In fact, invalidate is very big hint to reclaimer.
>> It means we don't use the page any more. So let's move
>> the writing page into inactive list's head.
>
> But, I agree this.

Thank you.

>
>
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
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 update_page_re=
claim_stat(zone, page, file, 0);
>
> When PageActive is unset, we need to change cgroup lru too.

Doesn't add_page_to_lru_list/del_page_from_lru_list do it?

>
>
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
>> + */
>> +void lru_deactive_page(struct page *page)
>> +{
>> + =A0 =A0 if (likely(get_page_unless_zero(page))) {
>
> Probably, we can check PageLRU and PageActive here too. It help to avoid
> unnecessary batching and may slightly increase performance.

Yes. Thanks. Will fix.

>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pagevec *pvec =3D &get_cpu_var(lru_deac=
tive_pvecs);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!pagevec_add(pvec, page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_deactive(pvec);
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_cpu_var(lru_deactive_pvecs);
>> + =A0 =A0 }
>> =A0}
>>
>> +
>> =A0void lru_add_drain(void)
>> =A0{
>> =A0 =A0 =A0 drain_cpu_pagevecs(get_cpu());
>> diff --git a/mm/truncate.c b/mm/truncate.c
>> index cd94607..c73fb19 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -332,7 +332,8 @@ unsigned long invalidate_mapping_pages(struct addres=
s_space *mapping,
>> =A0{
>> =A0 =A0 =A0 struct pagevec pvec;
>> =A0 =A0 =A0 pgoff_t next =3D start;
>> - =A0 =A0 unsigned long ret =3D 0;
>> + =A0 =A0 unsigned long ret;
>> + =A0 =A0 unsigned long count =3D 0;
>> =A0 =A0 =A0 int i;
>>
>> =A0 =A0 =A0 pagevec_init(&pvec, 0);
>> @@ -359,8 +360,10 @@ unsigned long invalidate_mapping_pages(struct addre=
ss_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lock_failed)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D invalidate_inode_page=
(page);
>> -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D invalidate_inode_page(=
page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_deactive_p=
age(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D ret;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next > end)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> @@ -369,7 +372,7 @@ unsigned long invalidate_mapping_pages(struct addres=
s_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_end();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
>> =A0 =A0 =A0 }
>> - =A0 =A0 return ret;
>> + =A0 =A0 return count;
>> =A0}
>> =A0EXPORT_SYMBOL(invalidate_mapping_pages);
>>
>> --
>> 1.7.0.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
