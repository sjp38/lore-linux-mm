Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 2C9DC6B00E8
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 23:42:19 -0400 (EDT)
Received: by lagz14 with SMTP id z14so1636096lag.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 20:42:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120412001942.GC1787@cmpxchg.org>
References: <1334181606-26777-1-git-send-email-yinghan@google.com>
	<20120412001942.GC1787@cmpxchg.org>
Date: Wed, 11 Apr 2012 20:42:16 -0700
Message-ID: <CALWz4ixHjhTMDwTF-xMS_tFs+WWbWBV-1_=r5c-tvASpvVgd=g@mail.gmail.com>
Subject: Re: [PATCH V2 2/5] memcg: add function should_reclaim_mem_cgroup()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 5:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Apr 11, 2012 at 03:00:06PM -0700, Ying Han wrote:
>> Add the filter function should_reclaim_mem_cgroup() under the common fun=
ction
>> shrink_zone(). The later one is being called both from per-memcg reclaim=
 as
>> well as global reclaim.
>>
>> Today the softlimit takes effect only under global memory pressure. The =
memcgs
>> get free run above their softlimit until there is a global memory conten=
tion.
>> This patch doesn't change the semantics.
>>
>> Under the global reclaim, we skip reclaiming from a memcg under its soft=
limit.
>> To prevent reclaim from trying too hard on hitting memcgs (above softlim=
it) w/
>> only hard-to-reclaim pages, the reclaim proirity is used to skip the sof=
tlimit
>> check. This is a trade-off of system performance and resource isolation.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 =A07 +++++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +++++++++-
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 25 +++++++++++++++++=
+++++++-
>> =A03 files changed, 40 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index db71193..3d14f90 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -110,6 +110,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup=
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
>> @@ -295,6 +297,11 @@ static inline void mem_cgroup_iter_break(struct mem=
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
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 9a64093..cffcded 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -358,12 +358,12 @@ enum charge_type {
>> =A0static void mem_cgroup_get(struct mem_cgroup *memcg);
>> =A0static void mem_cgroup_put(struct mem_cgroup *memcg);
>>
>> +static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>> =A0/* Writing them here to avoid exposing memcg's inner layout */
>> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> =A0#include <net/sock.h>
>> =A0#include <net/ip.h>
>>
>> -static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>
> The prototype is hardly shorter than the friggin function itself!
>
> I'll send a patch to remove this thing completely, doing memcg =3D=3D
> root_mem_cgroup should be pretty obvious without a helper function.

Ok, I will leave as it is now. Before your post, i will just do memcg
=3D=3D root_mem_cgroup.

>> @@ -2133,6 +2133,27 @@ restart:
>> =A0 =A0 =A0 throttle_vm_writeout(sc->gfp_mask);
>> =A0}
>>
>> +static bool should_reclaim_mem_cgroup(struct mem_cgroup *target_mem_cgr=
oup,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 st=
ruct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 in=
t priority)
>> +{
>> + =A0 =A0 /* Reclaim from mem_cgroup if any of these conditions are met:
>> + =A0 =A0 =A0* - This is a global reclaim
>> + =A0 =A0 =A0* - reclaim priority is higher than DEF_PRIORITY - 3
>> + =A0 =A0 =A0* - mem_cgroup exceeds its soft limit
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* The priority check is a balance of how hard to preserve t=
he pages
>> + =A0 =A0 =A0* under softlimit. If the memcgs of the zone having trouble=
 to reclaim
>> + =A0 =A0 =A0* pages above their softlimit, we have to reclaim under sof=
tlimit
>> + =A0 =A0 =A0* instead of burning more cpu cycles.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (target_mem_cgroup || priority <=3D DEF_PRIORITY - 3 ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_limit_exceeded=
(memcg))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>
> The comment is contradicting the code: global reclaim does not scan
> unconditionally, hard limit reclaim does. =A0Global reclaim scans only
> if the memcg is above soft limit or if the priority level dropped
> sufficiently.
>
> I suppose it's the comment that's wrong, not the code.

You are right. I will fix the comment on next post.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
