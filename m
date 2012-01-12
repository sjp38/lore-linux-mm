Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A6CD86B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 19:50:10 -0500 (EST)
Received: by qcsd17 with SMTP id d17so880113qcs.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 16:50:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120112085937.ae601869.kamezawa.hiroyu@jp.fujitsu.com>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
	<alpine.LSU.2.00.1201111512570.1846@eggly.anvils>
	<20120112085937.ae601869.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 11 Jan 2012 16:50:09 -0800
Message-ID: <CALWz4iyuT48FWuw52bcu3B9GvHbz3c3ODcsgPzOP80UOP1Q-bQ@mail.gmail.com>
Subject: Re: memcg: add mlock statistic in memory.stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Wed, Jan 11, 2012 at 3:59 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 11 Jan 2012 15:17:42 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
>
>> On Wed, 11 Jan 2012, Ying Han wrote:
>>
>> > We have the nr_mlock stat both in meminfo as well as vmstat system wid=
e, this
>> > patch adds the mlock field into per-memcg memory stat. The stat itself=
 enhances
>> > the metrics exported by memcg, especially is used together with "uneiv=
ctable"
>> > lru stat.
>> >
>> > --- a/include/linux/page_cgroup.h
>> > +++ b/include/linux/page_cgroup.h
>> > @@ -10,6 +10,7 @@ enum {
>> > =A0 =A0 /* flags for mem_cgroup and file and I/O status */
>> > =A0 =A0 PCG_MOVE_LOCK, /* For race between move_account v.s. following=
 bits */
>> > =A0 =A0 PCG_FILE_MAPPED, /* page is accounted as "mapped" */
>> > + =A0 PCG_MLOCK, /* page is accounted as "mlock" */
>> > =A0 =A0 /* No lock in page_cgroup */
>> > =A0 =A0 PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) =
*/
>> > =A0 =A0 __NR_PCG_FLAGS,
>>
>> Is this really necessary? =A0KAMEZAWA-san is engaged in trying to reduce
>> the number of PageCgroup flags, and I expect that in due course we shall
>> want to merge them in with Page flags, so adding more is unwelcome.
>> I'd =A0have thought that with memcg_ hooks in the right places,
>> a separate flag would not be necessary?
>>
>
> Please don't ;)
>
> NR_UNEIVCTABLE_LRU is not enough ?

Seems not.

The unevictable lru includes more than mlock()'d pages ( SHM_LOCK'd
etc). There are use cases where we like to know the mlock-ed size
per-cgroup. We used to archived that in fake-numa based container by
reading the value from per-node meminfo, however we miss that
information in memcg. What do you think?

Thank you Hugh and Kame for the reference. Apparently I missed that
patch and I will take a look at it. (still catching up emails after
vacation).

--Ying

>
> Following is the patch I posted before to remove PCG_FILE_MAPPED.
> Then, I think you can use similar logic and make use of UNEVICTABLE flags=
.
>
> =3D=3D
> better (lockless) idea is welcomed.
>
> From fd2b5822838eebbacc41f343f9eb8c6f0ad8e1cc Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 15 Dec 2011 11:42:49 +0900
> Subject: [PATCH 2/5] memcg: safer page stat updating
>
> Now, page stat accounting is done like this.
>
> =A0 =A0 if (....set flag or some)
> =A0 =A0 =A0 =A0 =A0 =A0update vmstat
> =A0 =A0 =A0 =A0 =A0 =A0update memcg'stat
>
> Unlike vmstat, memcg must take care of changes in pc->mem_cgroup.
> This is done by page_cgroup_move_lock and other flags per stats.
>
> I think FileMapped works well. But, considering update of other
> statistics, current logic doesn't works well. Assume following case,
>
> =A0 =A0 set flag
> =A0 =A0 ..(delay by some preemption)..
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0clear flag
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0pc's flag is unset and
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0don't update anything.
> =A0 =A0 memcg =3D pc->mem_cgroup
> =A0 =A0 set flag to pc->mem_cgroup
> =A0 =A0 update memcg stat
>
> In this case, the stat will be leaked out. I think memcg's account
> routine should see no flags. To avoid using memcg's original flags,
> we need to prevent overwriting pc->mem_cgroup while we updating
> the memcg.
>
> This patch adds
> =A0 - mem_cgroup_begin_update_page_stats(),
> =A0 - mem_cgroup_end_update_page_stats()
>
> And guarantees pc->mem_cgroup is not overwritten while updating.
> The caller should do
>
> =A0 =A0 mem_cgroup_begin_update_page_stats()
> =A0 =A0 if (.... set flag or some)
> =A0 =A0 =A0 =A0 =A0 =A0update vmstat
> =A0 =A0 =A0 =A0 =A0 =A0update memcg's stat
> =A0 =A0 mem_cgroup_end_update_page_stats().
>
> This beign...end will check a counter (which is 0 in most case) under
> rcu_read_lock/rcu_read_unlock. And take a spinlock if required.
>
> Following patch in this series will remove PCG_FILE_MAPPED flag.
> ---
> =A0include/linux/memcontrol.h | =A0 49 ++++++++++++++++++++++++++++++++++=
+++++++-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 50 ++++++++++++++++++++++=
+++++++--------------
> =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++++
> =A03 files changed, 86 insertions(+), 18 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 598b3c9..4a61c4b 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -141,9 +141,52 @@ static inline bool mem_cgroup_disabled(void)
> =A0 =A0 =A0 =A0return false;
> =A0}
>
> -void mem_cgroup_update_page_stat(struct page *page,
> +/*
> + * Unlike vmstat, page's mem_cgroup can be overwritten and for which mem=
cg
> + * the page stats should be accounted to is determined dynamically.
> + * Unfortunately, there are many races. To avoid races, the caller shoul=
d do
> + *
> + * locked =3D mem_cgroup_begin_update_page_stat(page)
> + * if (set page flags etc)
> + * =A0 =A0 mem_cgroup_update_page_stat(page);
> + * mem_cgroup_end_update_page_stat(page, locked);
> + *
> + * Between [begin, end) calls, page's mem_cgroup will never be changed.
> + */
> +void __mem_cgroup_update_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_page_stat_i=
tem idx,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val);
> +
> +static inline void mem_cgroup_update_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_=
cgroup_page_stat_item idx,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int val)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int val)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 __mem_cgroup_update_page_stat(page, idx, val);
> +}
> +
> +bool __mem_cgroup_begin_update_page_stats(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *flags);
> +static inline bool
> +mem_cgroup_begin_update_page_stats(struct page *page, unsigned long *fla=
gs)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 return __mem_cgroup_begin_update_page_stats(page, flags);
> +}
> +
> +void __mem_cgroup_end_update_page_stats(struct page *page, bool locked,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *flags);
> +
> +static inline void
> +mem_cgroup_end_update_page_stats(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool locked, unsigned long *flags)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 __mem_cgroup_end_update_page_stats(page, locked, flags);
> +}
>
> =A0static inline void mem_cgroup_inc_page_stat(struct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0enum mem_cgroup_page_stat_item idx)
> @@ -171,6 +214,8 @@ void mem_cgroup_split_huge_fixup(struct page *head);
> =A0bool mem_cgroup_bad_page_check(struct page *page);
> =A0void mem_cgroup_print_bad_page(struct page *page);
> =A0#endif
> +
> +
> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> =A0struct mem_cgroup;
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d183e1b..f4e6d5c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1831,27 +1831,50 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem=
cg, gfp_t mask)
> =A0* possibility of race condition. If there is, we take a lock.
> =A0*/
>
> -void mem_cgroup_update_page_stat(struct page *page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem=
_cgroup_page_stat_item idx, int val)
> +/*
> + * This function calls rcu_read_lock(). This lock is unlocked by
> + * __mem_cgroup_end_update_page_stat().
> + */
> +bool __mem_cgroup_begin_update_page_stats(struct page *page, unsigned lo=
ng *flags)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg;
> =A0 =A0 =A0 =A0struct page_cgroup *pc =3D lookup_page_cgroup(page);
> =A0 =A0 =A0 =A0bool need_unlock =3D false;
> - =A0 =A0 =A0 unsigned long uninitialized_var(flags);
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0memcg =3D pc->mem_cgroup;
> - =A0 =A0 =A0 if (unlikely(!memcg || !PageCgroupUsed(pc)))
> + =A0 =A0 =A0 if (!memcg =A0|| !PageCgroupUsed(pc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> - =A0 =A0 =A0 /* pc->mem_cgroup is unstable ? */
> =A0 =A0 =A0 =A0if (unlikely(mem_cgroup_stealed(memcg)) || PageTransHuge(p=
age)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* take a lock against to access pc->mem_cg=
roup */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_lock_page_cgroup(pc, &flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_lock_page_cgroup(pc, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0need_unlock =3D true;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg =3D pc->mem_cgroup;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg || !PageCgroupUsed(pc))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 =A0 =A0}
> +out:
> + =A0 =A0 =A0 return need_unlock;
> +}
> +EXPORT_SYMBOL(__mem_cgroup_begin_update_page_stats);
> +
> +void __mem_cgroup_end_update_page_stats(struct page *page, bool locked,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long *flags)
> +{
> + =A0 =A0 =A0 struct page_cgroup *pc;
> +
> + =A0 =A0 =A0 if (unlikely(locked)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pc =3D lookup_page_cgroup(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_unlock_page_cgroup(pc, flags);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(__mem_cgroup_end_update_page_stats);
> +
> +void __mem_cgroup_update_page_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum mem=
_cgroup_page_stat_item idx, int val)
> +{
> + =A0 =A0 =A0 struct page_cgroup *pc =3D lookup_page_cgroup(page);
> + =A0 =A0 =A0 struct mem_cgroup *memcg =3D pc->mem_cgroup;
> +
> + =A0 =A0 =A0 if (!memcg || !PageCgroupUsed(pc))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>
> =A0 =A0 =A0 =A0switch (idx) {
> =A0 =A0 =A0 =A0case MEMCG_NR_FILE_MAPPED:
> @@ -1866,14 +1889,9 @@ void mem_cgroup_update_page_stat(struct page *page=
,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0this_cpu_add(memcg->stat->count[idx], val);
> -
> -out:
> - =A0 =A0 =A0 if (unlikely(need_unlock))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_unlock_page_cgroup(pc, &flags);
> - =A0 =A0 =A0 rcu_read_unlock();
> =A0 =A0 =A0 =A0return;
> =A0}
> -EXPORT_SYMBOL(mem_cgroup_update_page_stat);
> +EXPORT_SYMBOL(__mem_cgroup_update_page_stat);
>
> =A0/*
> =A0* size of first charge trial. "32" comes from vmscan.c's magic value.
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 54d140a..3648c88 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1105,10 +1105,15 @@ void page_add_new_anon_rmap(struct page *page,
> =A0*/
> =A0void page_add_file_rmap(struct page *page)
> =A0{
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 bool locked;
> +
> + =A0 =A0 =A0 locked =3D mem_cgroup_begin_update_page_stats(page, &flags)=
;
> =A0 =A0 =A0 =A0if (atomic_inc_and_test(&page->_mapcount)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__inc_zone_page_state(page, NR_FILE_MAPPED=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_inc_page_stat(page, MEMCG_NR_FI=
LE_MAPPED);
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 mem_cgroup_end_update_page_stats(page, locked, &flags);
> =A0}
>
> =A0/**
> --
> 1.7.4.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
