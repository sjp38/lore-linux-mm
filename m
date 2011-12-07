Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 2CFA26B004F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 12:39:28 -0500 (EST)
Received: by qcsd17 with SMTP id d17so739572qcs.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 09:39:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111207111334.b21fef3c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323215999-29164-1-git-send-email-yinghan@google.com>
	<1323215999-29164-2-git-send-email-yinghan@google.com>
	<20111207111334.b21fef3c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 7 Dec 2011 09:39:26 -0800
Message-ID: <CALWz4iwT9nCy+mY3yeJqEq6M+zDbL-gZDdU0PLKQpSm284KnLA@mail.gmail.com>
Subject: Re: [PATCH 1/3] memcg: rework softlimit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Tue, Dec 6, 2011 at 6:13 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, =A06 Dec 2011 15:59:57 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> Under the shrink_zone, we examine whether or not to reclaim from a memcg
>> based on its softlimit. We skip scanning the memcg for the first 3 prior=
ity.
>> This is to balance between isolation and efficiency. we don't want to ha=
lt
>> the system by skipping memcgs with low-hanging fruits forever.
>>
>> Another change is to set soft_limit_in_bytes to 0 by default. This is ne=
eded
>> for both functional and performance:
>>
>> 1. If soft_limit are all set to MAX, it wastes first three periority ite=
rations
>> without scanning anything.
>>
>> 2. By default every memcg is eligibal for softlimit reclaim, and we can =
also
>> set the value to MAX for special memcg which is immune to soft limit rec=
laim.
>>
>
> Could you update softlimit doc ?

Will do .
>
>
>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 =A07 ++++
>> =A0kernel/res_counter.c =A0 =A0 =A0 | =A0 =A01 -
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08 +++++
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 67 +++++++++++++++++=
+++++++++-----------------
>> =A04 files changed, 55 insertions(+), 28 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 81aabfb..53d483b 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -107,6 +107,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup=
 *,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struc=
t mem_cgroup_reclaim_cookie *);
>> =A0void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
>>
>> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *);
>> +
>> =A0/*
>> =A0 * For memory reclaim.
>> =A0 */
>> @@ -293,6 +295,11 @@ static inline void mem_cgroup_iter_break(struct mem=
_cgroup *root,
>> =A0{
>> =A0}
>>
>> +static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *me=
m)
>> +{
>> + =A0 =A0 return true;
>> +}
>> +
>> =A0static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *=
memcg)
>> =A0{
>> =A0 =A0 =A0 return 0;
>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> index b814d6c..92afdc1 100644
>> --- a/kernel/res_counter.c
>> +++ b/kernel/res_counter.c
>> @@ -18,7 +18,6 @@ void res_counter_init(struct res_counter *counter, str=
uct res_counter *parent)
>> =A0{
>> =A0 =A0 =A0 spin_lock_init(&counter->lock);
>> =A0 =A0 =A0 counter->limit =3D RESOURCE_MAX;
>> - =A0 =A0 counter->soft_limit =3D RESOURCE_MAX;
>> =A0 =A0 =A0 counter->parent =3D parent;
>> =A0}
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 4425f62..7c6cade 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -926,6 +926,14 @@ out:
>> =A0}
>> =A0EXPORT_SYMBOL(mem_cgroup_count_vm_event);
>>
>> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (mem_cgroup_disabled() || mem_cgroup_is_root(mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> +
>> + =A0 =A0 return res_counter_soft_limit_excess(&mem->res) > 0;
>> +}
>> +
>> =A0/**
>> =A0 * mem_cgroup_zone_lruvec - get the lru list vector for a zone and me=
mcg
>> =A0 * @zone: zone of the wanted lruvec
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 0ba7d35..b36d91b 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2091,6 +2091,17 @@ restart:
>> =A0 =A0 =A0 throttle_vm_writeout(sc->gfp_mask);
>> =A0}
>>
>> +static bool should_reclaim_mem_cgroup(struct scan_control *sc,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 st=
ruct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 in=
t priority)
>> +{
>> + =A0 =A0 if (!global_reclaim(sc) || priority <=3D DEF_PRIORITY - 3 ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_limit_exceeded=
(mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> +
>> + =A0 =A0 return false;
>> +}
>> +
>
> Why "priority <=3D DEF_PRIORTY - 3" is selected ?
> It seems there is no reason. Could you justify this check ?

There is no particular reason for this magic "3". And the plan is to
open for further tuning later after seeing real problems.

The idea here is to balance out the performance vs isolation. We don't
want to keep trying on "over softlimit memcgs" with hard to reclaim
memory while leaving the "under softlimit memcg" with low-hanging
fruit behind. This hurts the system performance as a whole.

>
> Thinking briefly, can't we caluculate the ratio as
>
> =A0 =A0 =A0 =A0number of pages in reclaimable memcg / number of reclaimab=
le pages
>
> And use 'priorty' ? If
>
> total_reclaimable_pages >> priority > number of pages in reclaimabe memcg
>
> memcg under softlimit should be scanned..then, we can avoid scanning page=
s
> twice.

Another thing we were talking about during summit is to reclaim the
pages proportionally based on how much each memcg exceeds its
softlimit, and the calculation above seems to be related to that.

I am pretty sure that we will tune the way to select memcg to reclaim
and how much to relciam while start running into problems, and there
are different ways to tune it. This patch is the very first step to
get started and the main purpose is to get rid of the big giant old
softlimit reclaim implementation.

 > Hmm, please give reason of the magic value here, anyway.
>
>> =A0static void shrink_zone(int priority, struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
>> =A0{
>> @@ -2108,7 +2119,9 @@ static void shrink_zone(int priority, struct zone =
*zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priority, &mz, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_mem_cgroup(sc, memcg, prior=
ity))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priorit=
y, &mz, sc);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Limit reclaim has historically picked o=
ne memcg and
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned it with decreasing priority lev=
els until
>> @@ -2152,8 +2165,8 @@ static bool shrink_zones(int priority, struct zone=
list *zonelist,
>> =A0{
>> =A0 =A0 =A0 struct zoneref *z;
>> =A0 =A0 =A0 struct zone *zone;
>> - =A0 =A0 unsigned long nr_soft_reclaimed;
>> - =A0 =A0 unsigned long nr_soft_scanned;
>> +// =A0 unsigned long nr_soft_reclaimed;
>> +// =A0 unsigned long nr_soft_scanned;
>
> Why do you leave these things ?

I steal this idea from Johannes's last posted softlimit rework patch.
My understanding is to make
the bisect easier later, maybe I am wrong.


> Hmm, but the whole logic seems clean to me except for magic number.

Thanks.

--Ying

>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
