Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 6F7A96B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 14:22:16 -0400 (EDT)
Received: by lagz14 with SMTP id z14so10017091lag.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 11:22:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120420091731.GE4191@tiehlicka.suse.cz>
References: <1334680682-12430-1-git-send-email-yinghan@google.com>
	<20120420091731.GE4191@tiehlicka.suse.cz>
Date: Fri, 20 Apr 2012 11:22:14 -0700
Message-ID: <CALWz4iyTH8a77w2bOkSXiODiNEn+L7SFv8Njp1_fRwi8aFVZHw@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] memcg: softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 2:17 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 17-04-12 09:38:02, Ying Han wrote:
>> This patch reverts all the existing softlimit reclaim implementations an=
d
>> instead integrates the softlimit reclaim into existing global reclaim lo=
gic.
>>
>> The new softlimit reclaim includes the following changes:
>>
>> 1. add function should_reclaim_mem_cgroup()
>>
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
>
> I am not sure I understand but I think it does change the semantics.
> Previously we looked at a group with the biggest excess and reclaim that
> group _hierarchically_.

yes, we don't do _hierarchically_ reclaim reclaim in this patch. Hmm,
that might be what Johannes insists to preserve on the other
thread.... ?

Now we do not care about hierarchy for soft
> limit reclaim. Moreover we do kind-of soft reclaim even from hard limit
> reclaim.

Not yet. This patchset only do soft_limit reclaim under global
reclaim. The logic here:

> +     if (target_mem_cgroup || priority <=3D DEF_PRIORITY - 3 ||
> +                     mem_cgroup_soft_limit_exceeded(memcg))
> +             return true;

If target_mem_cgroup !=3D NULL, which is the target reclaim, we will
always reclaim from the memcg.

>
>> Under the global reclaim, we skip reclaiming from a memcg under its soft=
limit.
>> To prevent reclaim from trying too hard on hitting memcgs (above softlim=
it) w/
>> only hard-to-reclaim pages, the reclaim proirity is used to skip the sof=
tlimit
>> check. This is a trade-off of system performance and resource isolation.
>>
>> 2. detect no memcgs above softlimit under zone reclaim.
>>
>> The function zone_reclaimable() marks zone->all_unreclaimable based on
>> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is tr=
ue,
>> alloc_pages could go to OOM instead of getting stuck in page reclaim.
>>
>> In memcg kernel, cgroup under its softlimit is not targeted under global
>> reclaim. It could be possible that all memcgs are under their softlimit =
for
>> a particular zone. So the direct reclaim do_try_to_free_pages() will alw=
ays
>> return 1 which causes the caller __alloc_pages_direct_reclaim() enter ti=
ght
>> loop.
>>
>> The reclaim priority check we put in should_reclaim_mem_cgroup() should =
help
>> this case, but we still don't want to burn cpu cycles for first few prio=
rities
>> to get to that point. The idea is from LSF discussion where we detect it=
 after
>> the first round of scanning and restart the reclaim by not looking at so=
ftlimit
>> at all. This allows us to make forward progress on shrink_zone() and fre=
e some
>> pages on the zone.
>>
>> In order to do the detection for scanning all the memcgs under shrink_zo=
ne(),
>> i have to change the mem_cgroup_iter() from shared walk to full walk. Ot=
herwise,
>> it would be very easy to skip lots of memcgs above softlimit and it caus=
es the
>> flag "ignore_softlimit" being mistakenly set.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 18 +--
>> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A04 -
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0397 +--------------------=
-----------------------
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0113 +++++--------
>> =A04 files changed, 55 insertions(+), 477 deletions(-)
>>
> [...]
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 1a51868..a5f690b 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2128,24 +2128,51 @@ restart:
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

This comment is wrong and confusing... My fault.. It should be "This
is a target reclaim".

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
>> +
>> + =A0 =A0 return false;
>> +}
>> +
>> =A0static void shrink_zone(int priority, struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
>> =A0{
>> =A0 =A0 =A0 struct mem_cgroup *root =3D sc->target_mem_cgroup;
>> - =A0 =A0 struct mem_cgroup_reclaim_cookie reclaim =3D {
>> - =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .priority =3D priority,
>> - =A0 =A0 };
>> =A0 =A0 =A0 struct mem_cgroup *memcg;
>> + =A0 =A0 int above_softlimit, ignore_softlimit =3D 0;
>> +
>>
>> - =A0 =A0 memcg =3D mem_cgroup_iter(root, NULL, &reclaim);
>> +restart:
>> + =A0 =A0 above_softlimit =3D 0;
>> + =A0 =A0 memcg =3D mem_cgroup_iter(root, NULL, NULL);
>
> I am afraid this will not work for hard-limit reclaim. We need the
> cookie to remember the last memcg we were shrinking from the hierarchy
> otherwise mem_cgroup_reclaim would hammer on the same group again and
> again. Consider
> =A0 =A0 =A0 =A0A (hard limit 30M no pages)
> =A0 =A0 =A0 =A0|- B (10M)
> =A0 =A0 =A0 =A0\- C (20M)
>
> then we could easily end up in OOM, right? And the OOM would be for the
> A group which probably doesn't have any processes in it so we will not
> make any fwd. process.

Err... For some reason I missed the mem_cgroup_iter_break()
underneath. I have been imagining that we do walk the while hierarchy
for hard_limit reclaim as well.

Does it make more sense to walk the hierarchy under A if A hit's
limit, instead of keep hitting one memcg w/ all priority levels ?

--Ying

>
>> =A0 =A0 =A0 do {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup_zone mz =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 .zone =3D zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priority, &mz, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ignore_softlimit ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0should_reclaim_mem_cgroup(root, memcg, =
priority)) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_zone(priorit=
y, &mz, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 above_softlimit =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Limit reclaim has historically picked o=
ne memcg and
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned it with decreasing priority lev=
els until
>> @@ -2160,8 +2187,13 @@ static void shrink_zone(int priority, struct zone=
 *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_iter_break(root, =
memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 memcg =3D mem_cgroup_iter(root, memcg, &reclai=
m);
>> + =A0 =A0 =A0 =A0 =A0 =A0 memcg =3D mem_cgroup_iter(root, memcg, NULL);
>> =A0 =A0 =A0 } while (memcg);
>> +
>> + =A0 =A0 if (!above_softlimit) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ignore_softlimit =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto restart;
>> + =A0 =A0 }
>> =A0}
>>
>> =A0/* Returns true if compaction should go ahead for a high-order reques=
t */
> [...]
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
