Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5FB8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:16:46 -0500 (EST)
Received: by iyi20 with SMTP id 20so3158288iyi.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:16:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=2s0efMsByDKAdVTWaouk0r84RQJVrwn2h6DG_@mail.gmail.com>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<442221b243154ef2546cb921d53b774f2c8f5df5.1297940291.git.minchan.kim@gmail.com>
	<20110218010416.230a65df.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=2s0efMsByDKAdVTWaouk0r84RQJVrwn2h6DG_@mail.gmail.com>
Date: Fri, 18 Feb 2011 13:16:43 +0900
Message-ID: <AANLkTinqs1+2UJzv0PUQNF95Cs1WVuOZoDa=RXzty49g@mail.gmail.com>
Subject: Re: [PATCH v5 2/4] memcg: move memcg reclaimable page into tail of
 inactive list
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

2011/2/18 Minchan Kim <minchan.kim@gmail.com>:
> Hi Kame,
>
> On Fri, Feb 18, 2011 at 1:04 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Fri, 18 Feb 2011 00:08:20 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>>> The rotate_reclaimable_page function moves just written out
>>> pages, which the VM wanted to reclaim, to the end of the
>>> inactive list. =A0That way the VM will find those pages first
>>> next time it needs to free memory.
>>> This patch apply the rule in memcg.
>>> It can help to prevent unnecessary working page eviction of memcg.
>>>
>>> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Reviewed-by: Rik van Riel <riel@redhat.com>
>>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>>> ---
>>> Changelog since v4:
>>> =A0- add acked-by and reviewed-by
>>> =A0- change description - suggested by Rik
>>>
>>> =A0include/linux/memcontrol.h | =A0 =A06 ++++++
>>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 27 ++++++++++++++++++++=
+++++++
>>> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 ++-
>>> =A03 files changed, 35 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>> index 3da48ae..5a5ce70 100644
>>> --- a/include/linux/memcontrol.h
>>> +++ b/include/linux/memcontrol.h
>>> @@ -62,6 +62,7 @@ extern int mem_cgroup_cache_charge(struct page *page,=
 struct mm_struct *mm,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 gfp_t gfp_mask);
>>> =A0extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list=
 lru);
>>> =A0extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list=
 lru);
>>> +extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
>>> =A0extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_l=
ist lru);
>>> =A0extern void mem_cgroup_del_lru(struct page *page);
>>> =A0extern void mem_cgroup_move_lists(struct page *page,
>>> @@ -215,6 +216,11 @@ static inline void mem_cgroup_del_lru_list(struct =
page *page, int lru)
>>> =A0 =A0 =A0 return ;
>>> =A0}
>>>
>>> +static inline inline void mem_cgroup_rotate_reclaimable_page(struct pa=
ge *page)
>>> +{
>>> + =A0 =A0 return ;
>>> +}
>>> +
>>> =A0static inline void mem_cgroup_rotate_lru_list(struct page *page, int=
 lru)
>>> =A0{
>>> =A0 =A0 =A0 return ;
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 686f1ce..ab8bdff 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -813,6 +813,33 @@ void mem_cgroup_del_lru(struct page *page)
>>> =A0 =A0 =A0 mem_cgroup_del_lru_list(page, page_lru(page));
>>> =A0}
>>>
>>> +/*
>>> + * Writeback is about to end against a page which has been marked for =
immediate
>>> + * reclaim. =A0If it still appears to be reclaimable, move it to the t=
ail of the
>>> + * inactive list.
>>> + */
>>> +void mem_cgroup_rotate_reclaimable_page(struct page *page)
>>> +{
>>> + =A0 =A0 struct mem_cgroup_per_zone *mz;
>>> + =A0 =A0 struct page_cgroup *pc;
>>> + =A0 =A0 enum lru_list lru =3D page_lru_base_type(page);
>>> +
>>> + =A0 =A0 if (mem_cgroup_disabled())
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> +
>>> + =A0 =A0 pc =3D lookup_page_cgroup(page);
>>> + =A0 =A0 /*
>>> + =A0 =A0 =A0* Used bit is set without atomic ops but after smp_wmb().
>>> + =A0 =A0 =A0* For making pc->mem_cgroup visible, insert smp_rmb() here=
.
>>> + =A0 =A0 =A0*/
>>> + =A0 =A0 smp_rmb();
>>> + =A0 =A0 /* unused or root page is not rotated. */
>>> + =A0 =A0 if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup)=
)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> + =A0 =A0 mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
>>> + =A0 =A0 list_move_tail(&pc->lru, &mz->lists[lru]);
>>> +}
>>> +
>>
>> Hmm, I'm sorry I misunderstand this. IIUC, page_lru_base_type() always r=
eturns
>> LRU_INACTIVE_XXX and this function may move page from active LRU to inac=
tive LRU.
>>
>> Then, LRU counters for memcg should be updated.
>
> Goal of mem_cgroup_rotate_reclaimable_page is same with rotate_reclaimabl=
e_page.
> It means the page was already in inactive list.
> Look at the check !PageActive(page).

Hmm, ok. If so, could you change

page_lru_base_type() -> page_lru() ?

It's misleading.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
