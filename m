Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id CB83E6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 23:00:22 -0400 (EDT)
Message-ID: <5036EE39.706@redhat.com>
Date: Thu, 23 Aug 2012 23:00:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH -mm -v2 4/4] mm,vmscan: evict inactive file pages
 first
References: <20120816113450.52f4e633@cuia.bos.redhat.com> <20120816113805.5ae65af0@cuia.bos.redhat.com> <CALWz4iz4kxi=gasZsomqgKW+y4MgJEWMhefaiaBjO8Mktk932Q@mail.gmail.com>
In-Reply-To: <CALWz4iz4kxi=gasZsomqgKW+y4MgJEWMhefaiaBjO8Mktk932Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On 08/23/2012 07:07 PM, Ying Han wrote:
>
>
> On Thu, Aug 16, 2012 at 8:38 AM, Rik van Riel <riel@redhat.com
> <mailto:riel@redhat.com>> wrote:
>
>     When a lot of streaming file IO is happening, it makes sense to
>     evict just the inactive file pages and leave the other LRU lists
>     alone.
>
>     Likewise, when driving a cgroup hierarchy into its hard limit,
>     or over its soft limit, it makes sense to pick a child cgroup
>     that has lots of inactive file pages, and evict those first.
>
>     Being over its soft limit is considered a stronger preference
>     than just having a lot of inactive file pages, so a well behaved
>     cgroup is allowed to keep its file cache when there is a "badly
>     behaving" one in the same hierarchy.
>
>     Signed-off-by: Rik van Riel <riel@redhat.com <mailto:riel@redhat.com>>
>     ---
>       mm/vmscan.c |   37 +++++++++++++++++++++++++++++++++----
>       1 files changed, 33 insertions(+), 4 deletions(-)
>
>     diff --git a/mm/vmscan.c b/mm/vmscan.c
>     index 769fdcd..2884b4f 100644
>     --- a/mm/vmscan.c
>     +++ b/mm/vmscan.c
>     @@ -1576,6 +1576,19 @@ static int inactive_list_is_low(struct lruvec
>     *lruvec, enum lru_list lru)
>                      return inactive_anon_is_low(lruvec);
>       }
>
>     +/* If this lruvec has lots of inactive file pages, reclaim those
>     only. */
>     +static bool reclaim_file_only(struct lruvec *lruvec, struct
>     scan_control *sc,
>     +                             unsigned long anon, unsigned long file)
>     +{
>     +       if (inactive_file_is_low(lruvec))
>     +               return false;
>     +
>     +       if (file > (anon + file) >> sc->priority)
>     +               return true;
>     +
>     +       return false;
>     +}
>     +
>       static unsigned long shrink_list(enum lru_list lru, unsigned long
>     nr_to_scan,
>                                       struct lruvec *lruvec, struct
>     scan_control *sc)
>       {
>     @@ -1658,6 +1671,14 @@ static void get_scan_count(struct lruvec
>     *lruvec, struct scan_control *sc,
>                      }
>              }
>
>     +       /* Lots of inactive file pages? Reclaim those only. */
>     +       if (reclaim_file_only(lruvec, sc, anon, file)) {
>     +               fraction[0] = 0;
>     +               fraction[1] = 1;
>     +               denominator = 1;
>     +               goto out;
>     +       }
>     +
>              /*
>               * With swappiness at 100, anonymous and file have the same
>     priority.
>               * This scanning priority is essentially the inverse of IO
>     cost.
>     @@ -1922,8 +1943,8 @@ static void age_recent_pressure(struct lruvec
>     *lruvec, struct zone *zone)
>        * should always be larger than recent_rotated, and the size should
>        * always be larger than recent_pressure.
>        */
>     -static u64 reclaim_score(struct mem_cgroup *memcg,
>     -                        struct lruvec *lruvec)
>     +static u64 reclaim_score(struct mem_cgroup *memcg, struct lruvec
>     *lruvec,
>     +                        struct scan_control *sc)
>       {
>              struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>              u64 anon, file;
>     @@ -1949,6 +1970,14 @@ static u64 reclaim_score(struct mem_cgroup
>     *memcg,
>                      anon *= 10000;
>              }
>
>     +       /*
>     +        * Prefer reclaiming from an lruvec with lots of inactive file
>     +        * pages. Once those have been reclaimed, the score will drop so
>     +        * far we will pick another lruvec to reclaim from.
>     +        */
>     +       if (reclaim_file_only(lruvec, sc, anon, file))
>     +               file *= 100;
>     +
>              return max(anon, file);
>       }
>
>     @@ -1977,7 +2006,7 @@ static void shrink_zone(struct zone *zone,
>     struct scan_control *sc)
>
>                      age_recent_pressure(lruvec, zone);
>
>     -               score = reclaim_score(memcg, lruvec);
>     +               score = reclaim_score(memcg, lruvec, sc);
>
>                      /* Pick the lruvec with the highest score. */
>                      if (score > max_score) {
>     @@ -2002,7 +2031,7 @@ static void shrink_zone(struct zone *zone,
>     struct scan_control *sc)
>               */
>              do {
>                      shrink_lruvec(victim_lruvec, sc);
>     -               score = reclaim_score(memcg, victim_lruvec);
>     +               score = reclaim_score(memcg, victim_lruvec, sc);
>
>
> I wonder if you meant s/memcg/victim_memcg here.

You are totally right, that should be victim_memcg.

Time for me to get a tree that works here, and where my patches
will apply. I got the c-state governor patches sent out for KS,
now I should be able to get some time again for cgroups stuff :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
