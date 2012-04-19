Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 239536B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 18:43:09 -0400 (EDT)
Received: by lagz14 with SMTP id z14so9135434lag.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 15:43:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F8F6368.2090005@jp.fujitsu.com>
References: <1334773315-32215-1-git-send-email-yinghan@google.com>
	<20120418163330.ca1518c7.akpm@linux-foundation.org>
	<4F8F6368.2090005@jp.fujitsu.com>
Date: Thu, 19 Apr 2012 15:43:06 -0700
Message-ID: <CALWz4iyG4eSHjODSxhp=HahoO9DU4JbhWKVeMyQd4fJJ=f-b9w@mail.gmail.com>
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 18, 2012 at 5:59 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/04/19 8:33), Andrew Morton wrote:
>
>> On Wed, 18 Apr 2012 11:21:55 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>>> We have the nr_mlock stat both in meminfo as well as vmstat system wide=
, this
>>> patch adds the mlock field into per-memcg memory stat. The stat itself =
enhances
>>> the metrics exported by memcg since the unevictable lru includes more t=
han
>>> mlock()'d page like SHM_LOCK'd.
>>>
>>> Why we need to count mlock'd pages while they are unevictable and we ca=
n not
>>> do much on them anyway?
>>>
>>> This is true. The mlock stat I am proposing is more helpful for system =
admin
>>> and kernel developer to understand the system workload. The same inform=
ation
>>> should be helpful to add into OOM log as well. Many times in the past t=
hat we
>>> need to read the mlock stat from the per-container meminfo for differen=
t
>>> reason. Afterall, we do have the ability to read the mlock from meminfo=
 and
>>> this patch fills the info in memcg.
>>>
>>>
>>> ...
>>>
>>> =A0static inline int is_mlocked_vma(struct vm_area_struct *vma, struct =
page *page)
>>> =A0{
>>> + =A0 =A0bool locked;
>>> + =A0 =A0unsigned long flags;
>>> +
>>> =A0 =A0 =A0VM_BUG_ON(PageLRU(page));
>>>
>>> =A0 =A0 =A0if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) !=3D V=
M_LOCKED))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>>>
>>> + =A0 =A0mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>>> =A0 =A0 =A0if (!TestSetPageMlocked(page)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0inc_zone_page_state(page, NR_MLOCK);
>>> + =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK)=
;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0count_vm_event(UNEVICTABLE_PGMLOCKED);
>>> =A0 =A0 =A0}
>>> + =A0 =A0mem_cgroup_end_update_page_stat(page, &locked, &flags);
>>> +
>>> =A0 =A0 =A0return 1;
>>> =A0}
>>
>> Unrelated to this patch: is_mlocked_vma() is misnamed. =A0A function wit=
h
>> that name should be a bool-returning test which has no side-effects.
>>
>>>
>>> ...
>>>
>>> =A0static void __free_pages_ok(struct page *page, unsigned int order)
>>> =A0{
>>> =A0 =A0 =A0unsigned long flags;
>>> - =A0 =A0int wasMlocked =3D __TestClearPageMlocked(page);
>>> + =A0 =A0bool locked;
>>>
>>> =A0 =A0 =A0if (!free_pages_prepare(page, order))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>>>
>>> =A0 =A0 =A0local_irq_save(flags);
>>> - =A0 =A0if (unlikely(wasMlocked))
>>> + =A0 =A0mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>>
>> hm, what's going on here. =A0The page now has a zero refcount and is to
>> be returned to the buddy. =A0But mem_cgroup_begin_update_page_stat()
>> assumes that the page still belongs to a memcg. =A0I'd have thought that
>> any page_cgroup backreferences would have been torn down by now?
>>
>>> + =A0 =A0if (unlikely(__TestClearPageMlocked(page)))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0free_page_mlock(page);
>>
>
>
> Ah, this is problem. Now, we have following code.
> =3D=3D
>
>> struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *p=
age,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list lru)
>> {
>> =A0 =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
>> =A0 =A0 =A0 =A0 struct mem_cgroup *memcg;
>> =A0 =A0 =A0 =A0 struct page_cgroup *pc;
>>
>> =A0 =A0 =A0 =A0 if (mem_cgroup_disabled())
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &zone->lruvec;
>>
>> =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
>> =A0 =A0 =A0 =A0 memcg =3D pc->mem_cgroup;
>>
>> =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0* Surreptitiously switch any uncharged page to root:
>> =A0 =A0 =A0 =A0 =A0* an uncharged page off lru does nothing to secure
>> =A0 =A0 =A0 =A0 =A0* its former mem_cgroup from sudden removal.
>> =A0 =A0 =A0 =A0 =A0*
>> =A0 =A0 =A0 =A0 =A0* Our caller holds lru_lock, and PageCgroupUsed is up=
dated
>> =A0 =A0 =A0 =A0 =A0* under page_cgroup lock: between them, they make all=
 uses
>> =A0 =A0 =A0 =A0 =A0* of pc->mem_cgroup safe.
>> =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 if (!PageCgroupUsed(pc) && memcg !=3D root_mem_cgroup)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc->mem_cgroup =3D memcg =3D root_mem_cg=
roup;
>
> =3D=3D
>
> Then, accessing pc->mem_cgroup without checking PCG_USED bit is dangerous=
.
> It may trigger #GP because of suddern removal of memcg or because of abov=
e
> code, mis-accounting will happen... pc->mem_cgroup may be overwritten alr=
eady.
>
> Proposal from me is calling TestClearPageMlocked(page) via mem_cgroup_unc=
harge().
>
> Like this.
> =3D=3D
> =A0 =A0 =A0 =A0mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Pages reach here when it's fully unmapped or dropped fr=
om file cache.
> =A0 =A0 =A0 =A0 * we are under lock_page_cgroup() and have no race with m=
emcg activities.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (unlikely(PageMlocked(page))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (TestClearPageMlocked())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0decrement counter.
> =A0 =A0 =A0 =A0}

Hmm, so we save the call to mem_cgroup_begin/end_update_page_stat()
here. Are you suggesting to move the call to free_page_mlock() to
here?

> =A0 =A0 =A0 =A0ClearPageCgroupUsed(pc);
> =3D=3D

> But please check performance impact...

Yes, i will run some performance measurement on that.

--Ying

>
> Thanks,
> -Kame
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
