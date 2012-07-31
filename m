Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 0F2F96B00A1
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:54:41 -0400 (EDT)
Received: by lahi5 with SMTP id i5so5086187lah.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:54:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120731155932.GB16924@tiehlicka.suse.cz>
References: <1343687538-24284-1-git-send-email-yinghan@google.com>
	<20120731155932.GB16924@tiehlicka.suse.cz>
Date: Tue, 31 Jul 2012 10:54:38 -0700
Message-ID: <CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com>
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jul 31, 2012 at 8:59 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 30-07-12 15:32:18, Ying Han wrote:
>> In memcg kernel, cgroup under its softlimit is not targeted under global
>> reclaim. It could be possible that all memcgs are under their softlimit for
>> a particular zone.
>
> This is a bit misleading because there is no softlimit per zone...
>
>> If that is the case, the current implementation will burn extra cpu
>> cycles without making forward progress.
>
> This scales with the number of groups which is bareable I guess. We do
> not drop priority so the wasted round will not make a bigger pressure on
> the reclaim.
>
>> The idea is from LSF discussion where we detect it after the first round of
>> scanning and restart the reclaim by not looking at softlimit at all. This
>> allows us to make forward progress on shrink_zone().
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>>  mm/vmscan.c |   17 +++++++++++++++--
>>  1 files changed, 15 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 59e633c..747d903 100644
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
>> @@ -1879,10 +1883,14 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>>                * we have to reclaim under softlimit instead of burning more
>>                * cpu cycles.
>>                */
>> -             if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY - 2 ||
>> -                             mem_cgroup_over_soft_limit(memcg))
>> +             if (ignore_softlimit || !global_reclaim(sc) ||
>> +                             sc->priority < DEF_PRIORITY - 2 ||
>> +                             mem_cgroup_over_soft_limit(memcg)) {
>>                       shrink_lruvec(lruvec, sc);
>>
>> +                     over_softlimit = true;
>> +             }
>> +
>>               /*
>>                * Limit reclaim has historically picked one memcg and
>>                * scanned it with decreasing priority levels until
>> @@ -1899,6 +1907,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>>               }
>>               memcg = mem_cgroup_iter(root, memcg, &reclaim);
>>       } while (memcg);
>> +
>> +     if (!over_softlimit) {
>
> Is this ever false? At least root cgroup is always above the limit.
> Shouldn't we rather compare reclaimed pages?

Do we always start from root? My understanding of reclaim_cookie is
that remembers the last scanned memcg under root and then start from
the one after it. The loop breaks everytime we reach the end of it,
and it could be possible we didn't reach root at all.

--Ying

>
>> +             ignore_softlimit = true;
>> +             goto restart;
>> +     }
>>  }
>>
>>  /* Returns true if compaction should go ahead for a high-order request */
>> --
>> 1.7.7.3
>>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
