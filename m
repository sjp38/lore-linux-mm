Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEB98D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 00:38:58 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2T4ctX5008616
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:38:55 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq5.eem.corp.google.com with ESMTP id p2T4cSp1002357
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:38:54 -0700
Received: by qyk36 with SMTP id 36so2129885qyk.4
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:38:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329102242.d2f6d583.kamezawa.hiroyu@jp.fujitsu.com>
References: <1301356270-26859-1-git-send-email-yinghan@google.com>
	<1301356270-26859-3-git-send-email-yinghan@google.com>
	<20110329102242.d2f6d583.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Mar 2011 21:38:48 -0700
Message-ID: <BANLkTi=oYYNuOP1E0BvhMtRVgpMxA6S_Hw@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] add stats to monitor soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 6:22 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 28 Mar 2011 16:51:10 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> The stat is added:
>>
>> /dev/cgroup/*/memory.stat
>> soft_steal: =A0 =A0 =A0 =A0- # of pages reclaimed from soft_limit hierar=
chical reclaim
>> total_soft_steal: =A0- # sum of all children's "soft_steal"
>>
>> Change log v2...v1
>> 1. removed the counting on number of skips on shrink_zone. This is due t=
o the
>> change on the previous patch.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> Hmm...
>
>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 =A02 ++
>> =A0include/linux/memcontrol.h =A0 =A0 =A0 | =A0 =A05 +++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 14 +++++++++=
+++++
>> =A03 files changed, 21 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index b6ed61c..dcda6c5 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -385,6 +385,7 @@ mapped_file =A0 =A0 =A0 - # of bytes of mapped file =
(includes tmpfs/shmem)
>> =A0pgpgin =A0 =A0 =A0 =A0 =A0 =A0 =A0 - # of pages paged in (equivalent =
to # of charging events).
>> =A0pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged out (equivalent=
 to # of uncharging events).
>> =A0swap =A0 =A0 =A0 =A0 - # of bytes of swap usage
>> +soft_steal =A0 - # of pages reclaimed from global hierarchical reclaim
>> =A0inactive_anon =A0 =A0 =A0 =A0- # of bytes of anonymous memory and swa=
p cache memory on
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 LRU list.
>> =A0active_anon =A0- # of bytes of anonymous and swap cache memory on act=
ive
>> @@ -406,6 +407,7 @@ total_mapped_file - sum of all children's "cache"
>> =A0total_pgpgin =A0 =A0 =A0 =A0 - sum of all children's "pgpgin"
>> =A0total_pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- sum of all children's =
"pgpgout"
>> =A0total_swap =A0 =A0 =A0 =A0 =A0 - sum of all children's "swap"
>> +total_soft_steal =A0 =A0 - sum of all children's "soft_steal"
>> =A0total_inactive_anon =A0- sum of all children's "inactive_anon"
>> =A0total_active_anon =A0 =A0- sum of all children's "active_anon"
>> =A0total_inactive_file =A0- sum of all children's "inactive_file"
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 01281ac..151ab40 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -115,6 +115,7 @@ struct zone_reclaim_stat*
>> =A0mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>> =A0extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct task_struct *p);
>> +void mem_cgroup_soft_steal(struct mem_cgroup *memcg, int val);
>>
>> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>> =A0extern int do_swap_account;
>> @@ -356,6 +357,10 @@ static inline void mem_cgroup_split_huge_fixup(stru=
ct page *head,
>> =A0{
>> =A0}
>>
>> +static inline void mem_cgroup_soft_steal(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0int val)
>> +{
>> +}
>> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>>
>> =A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 67fff28..5e4aa41 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -94,6 +94,8 @@ enum mem_cgroup_events_index {
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGPGIN, =A0 =A0 =A0 /* # of pages paged in=
 */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_PGPGOUT, =A0 =A0 =A0/* # of pages paged ou=
t */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_COUNT, =A0 =A0 =A0 =A0/* # of pages paged =
in/out */
>> + =A0 =A0 MEM_CGROUP_EVENTS_SOFT_STEAL, =A0 /* # of pages reclaimed from=
 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 /* oft reclaim =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS_NSTATS,
>> =A0};
>> =A0/*
>> @@ -624,6 +626,11 @@ static void mem_cgroup_charge_statistics(struct mem=
_cgroup *mem,
>> =A0 =A0 =A0 preempt_enable();
>> =A0}
>>
>> +void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL], =
val);
>> +}
>> +
>> =A0static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup =
*mem,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list idx)
>> =A0{
>> @@ -3326,6 +3333,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct=
 zone *zone, int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 &nr_scanned);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed +=3D reclaimed;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 *total_scanned +=3D nr_scanned;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_steal(mz->mem, reclaimed);
>> +
>
> Here, you add "the number of reclaimed pages from the all descendants und=
er me".
> Could you move this to mem_cgroup_hierarchical_reclaim() ? Then, you can =
report
> the correct stats even with hierarchy enabled.
>
> Even if the value is recorded into hierarchy, total_steal will show total=
.

good point. I will make that change.

>
> BTW, soft_scan and soft_total_scan aren't necessary ?

Hmm, i can look into that.

--Ying
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
