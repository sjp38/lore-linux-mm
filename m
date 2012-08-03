Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 5EFCC6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 12:28:24 -0400 (EDT)
Received: by lbon3 with SMTP id n3so1161534lbo.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 09:28:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803140224.GC8434@dhcp22.suse.cz>
References: <1343942664-13365-1-git-send-email-yinghan@google.com>
	<20120803140224.GC8434@dhcp22.suse.cz>
Date: Fri, 3 Aug 2012 09:28:22 -0700
Message-ID: <CALWz4iwJaUB9QuSgAoj_cbwY88SZ5er-W7ss7TJ1DFbf7wyevg@mail.gmail.com>
Subject: Re: [PATCH V8 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Aug 3, 2012 at 7:02 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 02-08-12 14:24:24, Ying Han wrote:
>> In memcg kernel, cgroup under its softlimit is not targeted under global
>> reclaim. It could be possible that all memcgs are under their softlimit for
>> a particular zone. If that is the case, the current implementation will
>> burn extra cpu cycles without making forward progress.
>>
>> The idea is from LSF discussion where we detect it after the first round of
>> scanning and restart the reclaim by not looking at softlimit at all. This
>> allows us to make forward progress on shrink_zone().
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>>  include/linux/memcontrol.h |    9 +++++++++
>>  mm/memcontrol.c            |    3 +--
>>  mm/vmscan.c                |   18 ++++++++++++++++--
>>  3 files changed, 26 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 65538f9..cbad102 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -180,6 +180,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>>  }
>>
>>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>> +
>> +bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>  void mem_cgroup_split_huge_fixup(struct page *head);
>>  #endif
>> @@ -360,6 +362,13 @@ static inline
>>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>>  {
>>  }
>> +
>> +static inline bool
>> +mem_cgroup_is_root(struct mem_cgroup *memcg)
>> +{
>> +     return true;
>> +}
>> +
>>  static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
>>                               struct page *newpage)
>>  {
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index d8b91bb..368eecc 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -378,7 +378,6 @@ enum charge_type {
>>
>>  static void mem_cgroup_get(struct mem_cgroup *memcg);
>>  static void mem_cgroup_put(struct mem_cgroup *memcg);
>> -static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>>
>>  static inline
>>  struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>> @@ -850,7 +849,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
>>            iter != NULL;                              \
>>            iter = mem_cgroup_iter(NULL, iter, NULL))
>>
>> -static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>> +bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>>  {
>>       return (memcg == root_mem_cgroup);
>>  }
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 88487b3..8622022 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1861,6 +1861,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>>               .priority = sc->priority,
>>       };
>>       struct mem_cgroup *memcg;
>> +     bool over_softlimit, ignore_softlimit = false;
>> +
>> +restart:
>> +     over_softlimit = false;
>>
>>       memcg = mem_cgroup_iter(root, NULL, &reclaim);
>>       do {
>> @@ -1879,10 +1883,15 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>>                * we have to reclaim under softlimit instead of burning more
>>                * cpu cycles.
>>                */
>> -             if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY ||
>> -                             mem_cgroup_over_soft_limit(memcg))
>> +             if (ignore_softlimit || !global_reclaim(sc) ||
>> +                             sc->priority < DEF_PRIORITY ||
>> +                             mem_cgroup_over_soft_limit(memcg)) {
>>                       shrink_lruvec(lruvec, sc);
>>
>> +                     if (!mem_cgroup_is_root(memcg))
>> +                             over_softlimit = true;
>> +             }
>> +
>
> I think this is still not sufficient because you do not want to hammer
> root in the ignore_softlimit case.

Are you worried about over-reclaiming from root cgroup while the rest
of the cgroup are under softimit? Hmm.. That only affect the
DEF_PRIORITY level, and not sure how bad it is. On the other hand, I
wonder if it is necessary bad since the pages under root cgroup are
mainly re-parented pages which only get chance to be reclaimed under
global pressure.

--Ying

> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
