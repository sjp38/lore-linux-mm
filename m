Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DD0286B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 19:21:01 -0500 (EST)
Received: by iwn5 with SMTP id 5so353817iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 16:21:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101206033455.GA3158@balbir.in.ibm.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<a11d438e09af9808ac0cb0aba3e74c8a8deb4076.1291568905.git.minchan.kim@gmail.com>
	<20101206033455.GA3158@balbir.in.ibm.com>
Date: Tue, 7 Dec 2010 09:20:59 +0900
Message-ID: <AANLkTi=Nc0dat=M0taEsBS=vffb1YcqOgk7hr68Rw-c4@mail.gmail.com>
Subject: Re: [PATCH v4 3/7] move memcg reclaimable page into tail of inactive list
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

On Mon, Dec 6, 2010 at 12:34 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * MinChan Kim <minchan.kim@gmail.com> [2010-12-06 02:29:11]:
>
>> Golbal page reclaim moves reclaimalbe pages into inactive list
>
> Some typos here and Rik already pointed out some other changes.
>
>> to reclaim asap. This patch apply the rule in memcg.
>> It can help to prevent unnecessary working page eviction of memcg.
>>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 =A06 ++++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 27 +++++++++++++++++++++=
++++++
>> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 ++-
>> =A03 files changed, 35 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 067115c..8317f5c 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -62,6 +62,7 @@ extern int mem_cgroup_cache_charge(struct page *page, =
struct mm_struct *mm,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 gfp_t gfp_mask);
>> =A0extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list =
lru);
>> =A0extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list =
lru);
>> +extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
>> =A0extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_li=
st lru);
>> =A0extern void mem_cgroup_del_lru(struct page *page);
>> =A0extern void mem_cgroup_move_lists(struct page *page,
>> @@ -207,6 +208,11 @@ static inline void mem_cgroup_del_lru_list(struct p=
age *page, int lru)
>> =A0 =A0 =A0 return ;
>> =A0}
>>
>> +static inline inline void mem_cgroup_rotate_reclaimable_page(struct pag=
e *page)
>> +{
>> + =A0 =A0 return ;
>> +}
>> +
>> =A0static inline void mem_cgroup_rotate_lru_list(struct page *page, int =
lru)
>> =A0{
>> =A0 =A0 =A0 return ;
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 729beb7..f9435be 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -829,6 +829,33 @@ void mem_cgroup_del_lru(struct page *page)
>> =A0 =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page));
>> =A0}
>>
>> +/*
>> + * Writeback is about to end against a page which has been marked for i=
mmediate
>> + * reclaim. =A0If it still appears to be reclaimable, move it to the ta=
il of the
>> + * inactive list.
>> + */
>> +void mem_cgroup_rotate_reclaimable_page(struct page *page)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz;
>> + =A0 =A0 struct page_cgroup *pc;
>> + =A0 =A0 enum lru_list lru =3D page_lru_base_type(page);
>> +
>> + =A0 =A0 if (mem_cgroup_disabled())
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 pc =3D lookup_page_cgroup(page);
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Used bit is set without atomic ops but after smp_wmb().
>> + =A0 =A0 =A0* For making pc->mem_cgroup visible, insert smp_rmb() here.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 smp_rmb();
>> + =A0 =A0 /* unused or root page is not rotated. */
>> + =A0 =A0 if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 mz =3D page_cgroup_zoneinfo(pc);
>> + =A0 =A0 list_move_tail(&pc->lru, &mz->lists[lru]);
>> +}
>> +
>> =A0void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>> =A0{
>> =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 1f36f6f..0fe98e7 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -122,8 +122,9 @@ static void pagevec_move_tail(struct pagevec *pvec)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageLRU(page) && !PageActive(page) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 !PageUnevictable(page)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int lru =3D page_lru_base_type=
(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru =3D page_lru=
_base_type(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&page->lru, &=
zone->lru[lru].list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_rotate_reclaimable_=
page(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgmoved++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>
> Looks good, do you have any numbers, workloads that benefit? I agree
> that keeping both global and memcg reclaim in sync is a good idea.

This patch series for Ben's fadvise problem in rsync.
As I fix the global reclaim, I found this patch could help memcg, too.
If Ben is busy, I will measure the benefit.

>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Thanks, Balbir.

>
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
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
