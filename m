Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D29628D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 06:02:06 -0500 (EST)
Received: by iyf13 with SMTP id 13so105634iyf.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 03:02:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinqs1+2UJzv0PUQNF95Cs1WVuOZoDa=RXzty49g@mail.gmail.com>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<442221b243154ef2546cb921d53b774f2c8f5df5.1297940291.git.minchan.kim@gmail.com>
	<20110218010416.230a65df.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=2s0efMsByDKAdVTWaouk0r84RQJVrwn2h6DG_@mail.gmail.com>
	<AANLkTinqs1+2UJzv0PUQNF95Cs1WVuOZoDa=RXzty49g@mail.gmail.com>
Date: Fri, 18 Feb 2011 20:02:04 +0900
Message-ID: <AANLkTi=8KJ3JTC1rNwkhavJ-gR90V2YAoy63JwQWYLWT@mail.gmail.com>
Subject: Re: [PATCH v5 2/4] memcg: move memcg reclaimable page into tail of
 inactive list
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Fri, Feb 18, 2011 at 1:16 PM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> 2011/2/18 Minchan Kim <minchan.kim@gmail.com>:
>> Hi Kame,
>>
>> On Fri, Feb 18, 2011 at 1:04 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> On Fri, 18 Feb 2011 00:08:20 +0900
>>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>>
>>>> The rotate_reclaimable_page function moves just written out
>>>> pages, which the VM wanted to reclaim, to the end of the
>>>> inactive list. =C2=A0That way the VM will find those pages first
>>>> next time it needs to free memory.
>>>> This patch apply the rule in memcg.
>>>> It can help to prevent unnecessary working page eviction of memcg.
>>>>
>>>> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>> Reviewed-by: Rik van Riel <riel@redhat.com>
>>>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>>>> ---
>>>> Changelog since v4:
>>>> =C2=A0- add acked-by and reviewed-by
>>>> =C2=A0- change description - suggested by Rik
>>>>
>>>> =C2=A0include/linux/memcontrol.h | =C2=A0 =C2=A06 ++++++
>>>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 27 +++++++++++++++++++++++++++
>>>> =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| =C2=A0 =C2=A03 ++-
>>>> =C2=A03 files changed, 35 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>>> index 3da48ae..5a5ce70 100644
>>>> --- a/include/linux/memcontrol.h
>>>> +++ b/include/linux/memcontrol.h
>>>> @@ -62,6 +62,7 @@ extern int mem_cgroup_cache_charge(struct page *page=
, struct mm_struct *mm,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 gfp_t gfp_ma=
sk);
>>>> =C2=A0extern void mem_cgroup_add_lru_list(struct page *page, enum lru_=
list lru);
>>>> =C2=A0extern void mem_cgroup_del_lru_list(struct page *page, enum lru_=
list lru);
>>>> +extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
>>>> =C2=A0extern void mem_cgroup_rotate_lru_list(struct page *page, enum l=
ru_list lru);
>>>> =C2=A0extern void mem_cgroup_del_lru(struct page *page);
>>>> =C2=A0extern void mem_cgroup_move_lists(struct page *page,
>>>> @@ -215,6 +216,11 @@ static inline void mem_cgroup_del_lru_list(struct=
 page *page, int lru)
>>>> =C2=A0 =C2=A0 =C2=A0 return ;
>>>> =C2=A0}
>>>>
>>>> +static inline inline void mem_cgroup_rotate_reclaimable_page(struct p=
age *page)
>>>> +{
>>>> + =C2=A0 =C2=A0 return ;
>>>> +}
>>>> +
>>>> =C2=A0static inline void mem_cgroup_rotate_lru_list(struct page *page,=
 int lru)
>>>> =C2=A0{
>>>> =C2=A0 =C2=A0 =C2=A0 return ;
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index 686f1ce..ab8bdff 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>>> @@ -813,6 +813,33 @@ void mem_cgroup_del_lru(struct page *page)
>>>> =C2=A0 =C2=A0 =C2=A0 mem_cgroup_del_lru_list(page, page_lru(page));
>>>> =C2=A0}
>>>>
>>>> +/*
>>>> + * Writeback is about to end against a page which has been marked for=
 immediate
>>>> + * reclaim. =C2=A0If it still appears to be reclaimable, move it to t=
he tail of the
>>>> + * inactive list.
>>>> + */
>>>> +void mem_cgroup_rotate_reclaimable_page(struct page *page)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz;
>>>> + =C2=A0 =C2=A0 struct page_cgroup *pc;
>>>> + =C2=A0 =C2=A0 enum lru_list lru =3D page_lru_base_type(page);
>>>> +
>>>> + =C2=A0 =C2=A0 if (mem_cgroup_disabled())
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>>> +
>>>> + =C2=A0 =C2=A0 pc =3D lookup_page_cgroup(page);
>>>> + =C2=A0 =C2=A0 /*
>>>> + =C2=A0 =C2=A0 =C2=A0* Used bit is set without atomic ops but after s=
mp_wmb().
>>>> + =C2=A0 =C2=A0 =C2=A0* For making pc->mem_cgroup visible, insert smp_=
rmb() here.
>>>> + =C2=A0 =C2=A0 =C2=A0*/
>>>> + =C2=A0 =C2=A0 smp_rmb();
>>>> + =C2=A0 =C2=A0 /* unused or root page is not rotated. */
>>>> + =C2=A0 =C2=A0 if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_=
cgroup))
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>>> + =C2=A0 =C2=A0 mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
>>>> + =C2=A0 =C2=A0 list_move_tail(&pc->lru, &mz->lists[lru]);
>>>> +}
>>>> +
>>>
>>> Hmm, I'm sorry I misunderstand this. IIUC, page_lru_base_type() always =
returns
>>> LRU_INACTIVE_XXX and this function may move page from active LRU to ina=
ctive LRU.
>>>
>>> Then, LRU counters for memcg should be updated.
>>
>> Goal of mem_cgroup_rotate_reclaimable_page is same with rotate_reclaimab=
le_page.
>> It means the page was already in inactive list.
>> Look at the check !PageActive(page).
>
> Hmm, ok. If so, could you change
>
> page_lru_base_type() -> page_lru() ?
>
> It's misleading.

No problem. Will resend.

>
> Thanks,
> -Kame
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
