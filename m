Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D90376B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:14:24 -0500 (EST)
Received: by qadc11 with SMTP id c11so2117262qad.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 11:14:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120123130221.GA15113@tiehlicka.suse.cz>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
	<20120123130221.GA15113@tiehlicka.suse.cz>
Date: Mon, 23 Jan 2012 11:14:23 -0800
Message-ID: <CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jan 23, 2012 at 5:02 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sat 21-01-12 22:49:23, Hillf Danton wrote:
>> In soft limit reclaim, overreclaim occurs when pages are reclaimed from =
mem
>> group that is under its soft limit, or when more pages are reclaimd than=
 the
>> exceeding amount, then performance of reclaimee goes down accordingly.
>
> First of all soft reclaim is more a help for the global memory pressure
> balancing rather than any guarantee about how much we reclaim for the
> group.
> We need to do more changes in order to make it a guarantee.
> For example you implementation will cause severe problems when all
> cgroups are soft unlimited (default conf.) or when nobody is above the
> limit but the total consumption triggers the global reclaim. Therefore
> nobody is in excess and you would skip all groups and only bang on the
> root memcg.
>
> Ying Han has a patch which basically skips all cgroups which are under
> its limit until we reach a certain reclaim priority but even for this we
> need some additional changes - e.g. reverse the current default setting
> of the soft limit.
>
> Anyway, I like the nr_to_reclaim reduction idea because we have to do
> this in some way because the global reclaim starts with ULONG
> nr_to_scan.

Agree with Michal where there are quite a lot changes we need to get
in for soft limit before any further optimization.

Hillf, please refer to the patch from Johannes
https://lkml.org/lkml/2012/1/13/99 which got quite a lot recent
discussions. I am expecting to get that in before further soft limit
changes.

Thanks

--Ying



>
>> A helper function is added to compute the number of pages that exceed th=
e soft
>> limit of given mem cgroup, then the excess pages are used when every rec=
laimee
>> is reclaimed to avoid overreclaim.
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> ---
>>
>> --- a/mm/memcontrol.c Tue Jan 17 20:41:36 2012
>> +++ b/mm/memcontrol.c Sat Jan 21 21:18:46 2012
>> @@ -1662,6 +1662,21 @@ static int mem_cgroup_soft_reclaim(struc
>> =A0 =A0 =A0 return total;
>> =A0}
>>
>> +unsigned long mem_cgroup_excess_pages(struct mem_cgroup *memcg)
>> +{
>> + =A0 =A0 unsigned long pages;
>> +
>> + =A0 =A0 if (mem_cgroup_disabled())
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 if (!memcg)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 if (mem_cgroup_is_root(memcg))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 pages =3D res_counter_soft_limit_excess(&memcg->res) >> PAGE_S=
HIFT;
>> + =A0 =A0 return pages;
>> +}
>> +
>> =A0/*
>> =A0 * Check OOM-Killer is already running under our hierarchy.
>> =A0 * If someone is running, return false.
>> --- a/mm/vmscan.c =A0 =A0 Sat Jan 14 14:02:20 2012
>> +++ b/mm/vmscan.c =A0 =A0 Sat Jan 21 21:30:06 2012
>> @@ -2150,8 +2150,34 @@ static void shrink_zone(int priority, st
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long old;
>> + =A0 =A0 =A0 =A0 =A0 =A0 bool clobbered =3D false;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (memcg !=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long excess;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D mem_cgroup_excess_p=
ages(memcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* No bother reclaiming page=
s from mem cgroup that
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is under soft limit
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!excess)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto next;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* And reclaim no more pages=
 than excess
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (excess < sc->nr_to_reclaim=
) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 old =3D sc->nr=
_to_reclaim;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_to_recl=
aim =3D excess;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clobbered =3D =
true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priority, &mz, sc);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (clobbered)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_to_reclaim =3D old;
>> +next:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Limit reclaim has historically picked o=
ne memcg and
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned it with decreasing priority lev=
els until
>> --- a/include/linux/memcontrol.h =A0 =A0 =A0Thu Jan 19 22:03:14 2012
>> +++ b/include/linux/memcontrol.h =A0 =A0 =A0Sat Jan 21 21:35:50 2012
>> @@ -161,6 +161,7 @@ unsigned long mem_cgroup_soft_limit_recl
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long *total_scanned);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
>> +unsigned long mem_cgroup_excess_pages(struct mem_cgroup *memcg);
>>
>> =A0void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_it=
em idx);
>> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> @@ -376,6 +377,11 @@ unsigned long mem_cgroup_soft_limit_recl
>>
>> =A0static inline
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline unsigned long mem_cgroup_excess_pages(struct mem_cgroup *=
memcg)
>> =A0{
>> =A0 =A0 =A0 return 0;
>> =A0}
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
