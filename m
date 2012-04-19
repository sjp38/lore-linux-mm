Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id F39196B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 18:30:55 -0400 (EDT)
Received: by lagz14 with SMTP id z14so9127775lag.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 15:30:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120418163330.ca1518c7.akpm@linux-foundation.org>
References: <1334773315-32215-1-git-send-email-yinghan@google.com>
	<20120418163330.ca1518c7.akpm@linux-foundation.org>
Date: Thu, 19 Apr 2012 15:30:53 -0700
Message-ID: <CALWz4iydHSNfGaec9v8dO0Q4uJmj=gbRhVMSwoRSG-PNBiDPnQ@mail.gmail.com>
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 18, 2012 at 4:33 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 18 Apr 2012 11:21:55 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> We have the nr_mlock stat both in meminfo as well as vmstat system wide,=
 this
>> patch adds the mlock field into per-memcg memory stat. The stat itself e=
nhances
>> the metrics exported by memcg since the unevictable lru includes more th=
an
>> mlock()'d page like SHM_LOCK'd.
>>
>> Why we need to count mlock'd pages while they are unevictable and we can=
 not
>> do much on them anyway?
>>
>> This is true. The mlock stat I am proposing is more helpful for system a=
dmin
>> and kernel developer to understand the system workload. The same informa=
tion
>> should be helpful to add into OOM log as well. Many times in the past th=
at we
>> need to read the mlock stat from the per-container meminfo for different
>> reason. Afterall, we do have the ability to read the mlock from meminfo =
and
>> this patch fills the info in memcg.
>>
>>
>> ...
>>
>> =A0static inline int is_mlocked_vma(struct vm_area_struct *vma, struct p=
age *page)
>> =A0{
>> + =A0 =A0 bool locked;
>> + =A0 =A0 unsigned long flags;
>> +
>> =A0 =A0 =A0 VM_BUG_ON(PageLRU(page));
>>
>> =A0 =A0 =A0 if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) !=3D V=
M_LOCKED))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> + =A0 =A0 mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>> =A0 =A0 =A0 if (!TestSetPageMlocked(page)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inc_zone_page_state(page, NR_MLOCK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(UNEVICTABLE_PGMLOCKED);
>> =A0 =A0 =A0 }
>> + =A0 =A0 mem_cgroup_end_update_page_stat(page, &locked, &flags);
>> +
>> =A0 =A0 =A0 return 1;
>> =A0}
>
> Unrelated to this patch: is_mlocked_vma() is misnamed. =A0A function with
> that name should be a bool-returning test which has no side-effects.

That is true. Maybe a separate patch to fix that up :)

>
>>
>> ...
>>
>> =A0static void __free_pages_ok(struct page *page, unsigned int order)
>> =A0{
>> =A0 =A0 =A0 unsigned long flags;
>> - =A0 =A0 int wasMlocked =3D __TestClearPageMlocked(page);
>> + =A0 =A0 bool locked;
>>
>> =A0 =A0 =A0 if (!free_pages_prepare(page, order))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 local_irq_save(flags);
>> - =A0 =A0 if (unlikely(wasMlocked))
>> + =A0 =A0 mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>
> hm, what's going on here. =A0The page now has a zero refcount and is to
> be returned to the buddy. =A0But mem_cgroup_begin_update_page_stat()
> assumes that the page still belongs to a memcg. =A0I'd have thought that
> any page_cgroup backreferences would have been torn down by now?

True, I missed that at the first place. This will trigger GPF easily
if the memcg is destroyed after the charge drops to 0.

The problem is the time window between mem_cgroup_uncharge_page() and
free_hot_cold_page() which the later one calls
__TestClearPageMlocked(page).

I am wondering whether we can move the __TestClearPageMlocked(page)
earlier, before memcg_cgroup_uncharge_page(). Is there a particular
reason why the Clear Mlock bit has to be the last moment ?

--Ying
>
>> + =A0 =A0 if (unlikely(__TestClearPageMlocked(page)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page_mlock(page);
>
> And if the page _is_ still accessible via cgroup lookup, the use of the
> nonatomic RMW is dangerous.
>
>> =A0 =A0 =A0 __count_vm_events(PGFREE, 1 << order);
>> =A0 =A0 =A0 free_one_page(page_zone(page), page, order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 get_pageblock_migratetype(page));
>> + =A0 =A0 mem_cgroup_end_update_page_stat(page, &locked, &flags);
>> =A0 =A0 =A0 local_irq_restore(flags);
>> =A0}
>>
>> @@ -1250,7 +1256,7 @@ void free_hot_cold_page(struct page *page, int col=
d)
>
> The same comments apply in free_hot_cold_page().
>
>> =A0 =A0 =A0 struct per_cpu_pages *pcp;
>> =A0 =A0 =A0 unsigned long flags;
>> =A0 =A0 =A0 int migratetype;
>> - =A0 =A0 int wasMlocked =3D __TestClearPageMlocked(page);
>> + =A0 =A0 bool locked;
>>
>> =A0 =A0 =A0 if (!free_pages_prepare(page, 0))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> ...
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
