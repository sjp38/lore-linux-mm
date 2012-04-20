Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BFE9B6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 01:57:59 -0400 (EDT)
Received: by lagz14 with SMTP id z14so9354991lag.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 22:57:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F90AFDE.2000707@jp.fujitsu.com>
References: <1334773315-32215-1-git-send-email-yinghan@google.com>
	<20120418163330.ca1518c7.akpm@linux-foundation.org>
	<4F8F6368.2090005@jp.fujitsu.com>
	<20120419131211.GA1759@cmpxchg.org>
	<4F90AFDE.2000707@jp.fujitsu.com>
Date: Thu, 19 Apr 2012 22:57:57 -0700
Message-ID: <CALWz4iw5+ypsD_vwm6vcDKN-JrV_riF4mFvQME2zr2jR_iNuOg@mail.gmail.com>
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 19, 2012 at 5:37 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/04/19 22:12), Johannes Weiner wrote:
>
>> On Thu, Apr 19, 2012 at 09:59:20AM +0900, KAMEZAWA Hiroyuki wrote:
>>> (2012/04/19 8:33), Andrew Morton wrote:
>>>
>>>> On Wed, 18 Apr 2012 11:21:55 -0700
>>>> Ying Han <yinghan@google.com> wrote:
>>>>> =A0static void __free_pages_ok(struct page *page, unsigned int order)
>>>>> =A0{
>>>>> =A0 =A0unsigned long flags;
>>>>> - =A0int wasMlocked =3D __TestClearPageMlocked(page);
>>>>> + =A0bool locked;
>>>>>
>>>>> =A0 =A0if (!free_pages_prepare(page, order))
>>>>> =A0 =A0 =A0 =A0 =A0 =A0return;
>>>>>
>>>>> =A0 =A0local_irq_save(flags);
>>>>> - =A0if (unlikely(wasMlocked))
>>>>> + =A0mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>>>>
>>>> hm, what's going on here. =A0The page now has a zero refcount and is t=
o
>>>> be returned to the buddy. =A0But mem_cgroup_begin_update_page_stat()
>>>> assumes that the page still belongs to a memcg. =A0I'd have thought th=
at
>>>> any page_cgroup backreferences would have been torn down by now?
>>>>
>>>>> + =A0if (unlikely(__TestClearPageMlocked(page)))
>>>>> =A0 =A0 =A0 =A0 =A0 =A0free_page_mlock(page);
>>>>
>>>
>>>
>>> Ah, this is problem. Now, we have following code.
>>> =3D=3D
>>>
>>>> struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page =
*page,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0enum lru_list lru)
>>>> {
>>>> =A0 =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
>>>> =A0 =A0 =A0 =A0 struct mem_cgroup *memcg;
>>>> =A0 =A0 =A0 =A0 struct page_cgroup *pc;
>>>>
>>>> =A0 =A0 =A0 =A0 if (mem_cgroup_disabled())
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &zone->lruvec;
>>>>
>>>> =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
>>>> =A0 =A0 =A0 =A0 memcg =3D pc->mem_cgroup;
>>>>
>>>> =A0 =A0 =A0 =A0 /*
>>>> =A0 =A0 =A0 =A0 =A0* Surreptitiously switch any uncharged page to root=
:
>>>> =A0 =A0 =A0 =A0 =A0* an uncharged page off lru does nothing to secure
>>>> =A0 =A0 =A0 =A0 =A0* its former mem_cgroup from sudden removal.
>>>> =A0 =A0 =A0 =A0 =A0*
>>>> =A0 =A0 =A0 =A0 =A0* Our caller holds lru_lock, and PageCgroupUsed is =
updated
>>>> =A0 =A0 =A0 =A0 =A0* under page_cgroup lock: between them, they make a=
ll uses
>>>> =A0 =A0 =A0 =A0 =A0* of pc->mem_cgroup safe.
>>>> =A0 =A0 =A0 =A0 =A0*/
>>>> =A0 =A0 =A0 =A0 if (!PageCgroupUsed(pc) && memcg !=3D root_mem_cgroup)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc->mem_cgroup =3D memcg =3D root_mem_=
cgroup;
>>>
>>> =3D=3D
>>>
>>> Then, accessing pc->mem_cgroup without checking PCG_USED bit is dangero=
us.
>>> It may trigger #GP because of suddern removal of memcg or because of ab=
ove
>>> code, mis-accounting will happen... pc->mem_cgroup may be overwritten a=
lready.
>>>
>>> Proposal from me is calling TestClearPageMlocked(page) via mem_cgroup_u=
ncharge().
>>>
>>> Like this.
>>> =3D=3D
>>> =A0 =A0 =A0 =A0 mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
>>>
>>> =A0 =A0 =A0/*
>>> =A0 =A0 =A0 =A0 =A0* Pages reach here when it's fully unmapped or dropp=
ed from file cache.
>>> =A0 =A0 =A0 * we are under lock_page_cgroup() and have no race with mem=
cg activities.
>>> =A0 =A0 =A0 =A0 =A0*/
>>> =A0 =A0 =A0if (unlikely(PageMlocked(page))) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0if (TestClearPageMlocked())
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0decrement counter.
>>> =A0 =A0 =A0}
>>>
>>> =A0 =A0 =A0 =A0 ClearPageCgroupUsed(pc);
>>> =3D=3D
>>> But please check performance impact...
>>
>> This makes the lifetime rules of mlocked anon really weird.
>>
>
> yes.
>
>> Plus this code runs for ALL uncharges, the unlikely() and preliminary
>> flag testing don't make it okay. =A0It's bad that we have this in the
>> allocator, but at least it would be good to hook into that branch and
>> not add another one.
>>
>> pc->mem_cgroup stays intact after the uncharge. =A0Could we make the
>> memcg removal path wait on the mlock counter to drop to zero instead
>> and otherwise keep Ying's version?
>>
>
>
> handling problem in ->destroy() path ? Hmm, it will work against use-afte=
r-free.

> But accounting problem which may be caused by mem_cgroup_lru_add_list() c=
annot
> be handled, which overwrites pc->mem_cgroup.

Kame, can you clarify that? What the mem_cgroup_lru_add_list() has
anything to do w/ this problem?

>
> But hm, is this too slow ?...
> =3D=3D
> mem_cgroup_uncharge_common()
> {
> =A0 =A0 =A0 =A0....
> =A0 =A0 =A0 =A0if (PageSwapCache(page) || PageMlocked(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> }
>
> page_alloc.c::
>
> static inline void free_page_mlock(struct page *page)
> {
>
> =A0 =A0 =A0 =A0__dec_zone_page_state(page, NR_MLOCK);
> =A0 =A0 =A0 =A0__count_vm_event(UNEVICTABLE_MLOCKFREED);
>
> =A0 =A0 =A0 =A0mem_cgroup_uncharge_page(page);
> }
> =3D=3D
>
> BTW, at reading code briefly....why we have hooks in free_page() ?
>
> It seems do_munmap() and exit_mmap() calls munlock_vma_pages_all().
> So, it seems all vmas which has VM_MLOCKED are checked before freeing.
> vmscan never frees mlocked pages, I think.
>
> Any other path to free mlocked pages without munlock ?

I found this commit which introduced the hook in the freeing path,
however I couldn't get more details why it was introduced from the
commit description

commit 985737cf2ea096ea946aed82c7484d40defc71a8
Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date:   Sat Oct 18 20:26:53 2008 -0700

    mlock: count attempts to free mlocked page

    Allow free of mlock()ed pages.  This shouldn't happen, but during
    developement, it occasionally did.

    This patch allows us to survive that condition, while keeping the
    statistics and events correct for debug.

> I feel freeing Mlocked page is a cause of problems.

--Ying
>
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
