Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7D9CF6B0393
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 17:00:54 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so4576343bkc.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 14:00:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120619120523.GD27816@cmpxchg.org>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
	<1340038051-29502-5-git-send-email-yinghan@google.com>
	<20120619120523.GD27816@cmpxchg.org>
Date: Mon, 25 Jun 2012 14:00:52 -0700
Message-ID: <CALWz4izhVnyCgnv4b+QVOONm_-1edDBd_ejWNmLp5tJZczKZwQ@mail.gmail.com>
Subject: Re: [PATCH V5 5/5] mm: memcg discount pages under softlimit from
 per-zone reclaimable_pages
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jun 19, 2012 at 5:05 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, Jun 18, 2012 at 09:47:31AM -0700, Ying Han wrote:
>> The function zone_reclaimable() marks zone->all_unreclaimable based on
>> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is tr=
ue,
>> alloc_pages could go to OOM instead of getting stuck in page reclaim.
>
> There is no zone->all_unreclaimable at this point, you removed it in
> the previous patch.
>
>> In memcg kernel, cgroup under its softlimit is not targeted under global
>> reclaim. So we need to remove those pages from reclaimable_pages, otherw=
ise
>> it will cause reclaim mechanism to get stuck trying to reclaim from
>> all_unreclaimable zone.
>
> Can't you check if zone->pages_scanned changed in between reclaim
> runs?
>
> Or sum up the scanned and reclaimable pages encountered while
> iterating the hierarchy during regular reclaim and then use those
> numbers in the equation instead of the per-zone counters?
>
> Walking the full global hierarchy in all the places where we check if
> a zone is reclaimable is a scalability nightmare.

One way to solve this is to record the per-zone reclaimable pages (
sum of reclaimable pages of memcg above softlimits ) after each
shrink_zone(). The later function does walk the memcg hierarchy and
also checks the softlimit, so we don't need to do it again. The new
value pages_reclaimed is recorded per-zone, and the caller side could
use that to compare w/ zone->pages_scanned.

While I run tests on the patch, it turns out that I can not reproduce
the problem ( machine hang while over-committing the softlimit) even
w/o the patch. Then I realize that the problem only exist in the
internal version we don't have the check "sc->priority < DEF_PRIORITY
- 2" to bypass softlimit check. The reason we did that part is to
guarantee no global pressure on high priority memcgs.  So In that
case, global reclaim can never steal any pages from any memgs and the
system can easily hang.

This is not the case in the version I am posting here. The patch
guarantees not looping in memcgs all under softlimit by :
1. detects whether no memcg above their softlimit, if so, skip
checking softlimit
2. only check softlimit memcg if priority is >=3D DEF_PRIORITY - 2

In summary, the problem described in this patch doesn't exist. So I am
thinking to drop this one on my next post. Please comment.

--Ying

>> @@ -100,18 +100,36 @@ static __always_inline enum lru_list page_lru(stru=
ct page *page)
>> =A0 =A0 =A0 return lru;
>> =A0}
>>
>> +static inline unsigned long get_lru_size(struct lruvec *lruvec,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum lru_list lru)
>> +{
>> + =A0 =A0 if (!mem_cgroup_disabled())
>> + =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_get_lru_size(lruvec, lru);
>> +
>> + =A0 =A0 return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru)=
;
>> +}
>> +
>> =A0static inline unsigned long zone_reclaimable_pages(struct zone *zone)
>> =A0{
>> - =A0 =A0 int nr;
>> + =A0 =A0 int nr =3D 0;
>> + =A0 =A0 struct mem_cgroup *memcg;
>> +
>> + =A0 =A0 memcg =3D mem_cgroup_iter(NULL, NULL, NULL);
>> + =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct lruvec *lruvec =3D mem_cgroup_zone_lruv=
ec(zone, memcg);
>>
>> - =A0 =A0 nr =3D zone_page_state(zone, NR_ACTIVE_FILE) +
>> - =A0 =A0 =A0 =A0 =A0zone_page_state(zone, NR_INACTIVE_FILE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (should_reclaim_mem_cgroup(memcg)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D get_lru_size(lruvec, L=
RU_INACTIVE_FILE) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_lru_size(lruve=
c, LRU_ACTIVE_FILE);
>
> Sometimes, the number of reclaimable pages DO include those of groups
> for which should_reclaim_mem_cgroup() is false: when the priority
> level is <=3D DEF_PRIORITY - 2, as you defined in 1/5! =A0This means that
> you consider pages you just scanned unreclaimable, which can result in
> the zone being unreclaimable after the DEF_PRIORITY - 2 cycle, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
