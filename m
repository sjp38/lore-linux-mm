Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id BC1336B0062
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 16:59:37 -0400 (EDT)
Received: by lahi5 with SMTP id i5so5201655lah.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:59:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120731200205.GA19524@tiehlicka.suse.cz>
References: <1343687538-24284-1-git-send-email-yinghan@google.com>
	<20120731155932.GB16924@tiehlicka.suse.cz>
	<CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com>
	<20120731200205.GA19524@tiehlicka.suse.cz>
Date: Tue, 31 Jul 2012 13:59:35 -0700
Message-ID: <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com>
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jul 31, 2012 at 1:02 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 31-07-12 10:54:38, Ying Han wrote:
>> On Tue, Jul 31, 2012 at 8:59 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Mon 30-07-12 15:32:18, Ying Han wrote:
>> >> In memcg kernel, cgroup under its softlimit is not targeted under global
>> >> reclaim. It could be possible that all memcgs are under their softlimit for
>> >> a particular zone.
>> >
>> > This is a bit misleading because there is no softlimit per zone...
>> >
>> >> If that is the case, the current implementation will burn extra cpu
>> >> cycles without making forward progress.
>> >
>> > This scales with the number of groups which is bareable I guess. We do
>> > not drop priority so the wasted round will not make a bigger pressure on
>> > the reclaim.
>> >
>> >> The idea is from LSF discussion where we detect it after the first round of
>> >> scanning and restart the reclaim by not looking at softlimit at all. This
>> >> allows us to make forward progress on shrink_zone().
>> >>
>> >> Signed-off-by: Ying Han <yinghan@google.com>
>> >> ---
>> >>  mm/vmscan.c |   17 +++++++++++++++--
>> >>  1 files changed, 15 insertions(+), 2 deletions(-)
>> >>
>> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> index 59e633c..747d903 100644
>> >> --- a/mm/vmscan.c
>> >> +++ b/mm/vmscan.c
>> >> @@ -1861,6 +1861,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>> >>               .priority = sc->priority,
>> >>       };
>> >>       struct mem_cgroup *memcg;
>> >> +     bool over_softlimit, ignore_softlimit = false;
>> >> +
>> >> +restart:
>> >> +     over_softlimit = false;
>> >>
>> >>       memcg = mem_cgroup_iter(root, NULL, &reclaim);
>> >>       do {
>> >> @@ -1879,10 +1883,14 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>> >>                * we have to reclaim under softlimit instead of burning more
>> >>                * cpu cycles.
>> >>                */
>> >> -             if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY - 2 ||
>> >> -                             mem_cgroup_over_soft_limit(memcg))
>> >> +             if (ignore_softlimit || !global_reclaim(sc) ||
>> >> +                             sc->priority < DEF_PRIORITY - 2 ||
>> >> +                             mem_cgroup_over_soft_limit(memcg)) {
>> >>                       shrink_lruvec(lruvec, sc);
>> >>
>> >> +                     over_softlimit = true;
>> >> +             }
>> >> +
>> >>               /*
>> >>                * Limit reclaim has historically picked one memcg and
>> >>                * scanned it with decreasing priority levels until
>> >> @@ -1899,6 +1907,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>> >>               }
>> >>               memcg = mem_cgroup_iter(root, memcg, &reclaim);
>> >>       } while (memcg);
>> >> +
>> >> +     if (!over_softlimit) {
>> >
>> > Is this ever false? At least root cgroup is always above the limit.
>> > Shouldn't we rather compare reclaimed pages?
>>
>> Do we always start from root? My understanding of reclaim_cookie is
>> that remembers the last scanned memcg under root and then start from
>> the one after it.
>
> Yes it visits all nodes of the hierarchy.
>
>> The loop breaks everytime we reach the end of it, and it could be
>> possible we didn't reach root at all.
>
> Global reclaim means the root is involved and the we do not break out
> the loop so the root will be visited as well. And if nobody is over the
> soft limit then at least root is (according to mem_cgroup_over_soft_limit).

That is slightly different from my understanding. Forgive me if I
totally misunderstood how the mem_cgroup_iter() works.

In mem_cgroup_over_soft_limit(), we always return true for root cgroup
which says that always reclaim from root if we get to root cgroup.
However, there is no guarantee the reclaim thread will get to root for
invoking shrink_zone() each time.

Let's say the following example where the cgroup is sorted by css_id,
and none of the cgroup's usage is above softlimit (except root)

                                        root  a  b  c  d  e f ...max
thread_1 (priority = 12)         ^
                                         iter->position = 1        (
over_softlimit = true )

                                                ^
                                                 iter->position = 2

thread_2 (priority = 12)                     ^
                                                     iter->position = 3

                                                      ....
                                                                          ^

   iter->position = 0  ( over_softlimit = false )

In this case, thread 1 gets root but not thread 2 since they share the
walk under same zone (same node) and same reclaim priority.

--Ying

>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
