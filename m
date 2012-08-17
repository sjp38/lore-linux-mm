Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4B9036B006C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 18:03:37 -0400 (EDT)
Received: by lbon3 with SMTP id n3so2847772lbo.14
        for <linux-mm@kvack.org>; Fri, 17 Aug 2012 15:03:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120806133324.GD6150@dhcp22.suse.cz>
References: <1343942658-13307-1-git-send-email-yinghan@google.com>
	<20120803152234.GE8434@dhcp22.suse.cz>
	<501BF952.7070202@redhat.com>
	<CALWz4iw6Q500k5qGWaubwLi-3V3qziPuQ98Et9Ay=LS0-PB0dQ@mail.gmail.com>
	<20120806133324.GD6150@dhcp22.suse.cz>
Date: Fri, 17 Aug 2012 15:03:35 -0700
Message-ID: <CALWz4iw2NqQw3FgjM9k6nbMb7k8Gy2khdyL_9NpGM6T7Ma5t3g@mail.gmail.com>
Subject: Re: [PATCH V8 1/2] mm: memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Aug 6, 2012 at 6:33 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 03-08-12 09:34:11, Ying Han wrote:
>> On Fri, Aug 3, 2012 at 9:16 AM, Rik van Riel <riel@redhat.com> wrote:
>> > On 08/03/2012 11:22 AM, Michal Hocko wrote:
>> >>
>> >> On Thu 02-08-12 14:24:18, Ying Han wrote:
>> >> [...]
>> >>>
>> >>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >>> index 3e0d0cd..88487b3 100644
>> >>> --- a/mm/vmscan.c
>> >>> +++ b/mm/vmscan.c
>> >>> @@ -1866,7 +1866,22 @@ static void shrink_zone(struct zone *zone, struct
>> >>> scan_control *sc)
>> >>>         do {
>> >>>                 struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone,
>> >>> memcg);
>> >>>
>> >>> -               shrink_lruvec(lruvec, sc);
>> >>> +               /*
>> >>> +                * Reclaim from mem_cgroup if any of these conditions are
>> >>> met:
>> >>> +                * - this is a targetted reclaim ( not global reclaim)
>> >>> +                * - reclaim priority is less than DEF_PRIORITY
>> >>> +                * - mem_cgroup or its ancestor ( not including root
>> >>> cgroup)
>> >>> +                * exceeds its soft limit
>> >>> +                *
>> >>> +                * Note: The priority check is a balance of how hard to
>> >>> +                * preserve the pages under softlimit. If the memcgs of
>> >>> the
>> >>> +                * zone having trouble to reclaim pages above their
>> >>> softlimit,
>> >>> +                * we have to reclaim under softlimit instead of burning
>> >>> more
>> >>> +                * cpu cycles.
>> >>> +                */
>> >>> +               if (!global_reclaim(sc) || sc->priority<  DEF_PRIORITY ||
>> >>> +                               mem_cgroup_over_soft_limit(memcg))
>> >>> +                       shrink_lruvec(lruvec, sc);
>> >>>
>> >>>                 /*
>> >>>                  * Limit reclaim has historically picked one memcg and
>> >>
>> >>
>> >> I am thinking that we could add a constant for the priority
>> >> limit. Something like
>> >> #define MEMCG_LOW_SOFTLIMIT_PRIORITY    DEF_PRIORITY
>> >>
>> >> Although it doesn't seem necessary at the moment, because there is just
>> >> one location where it matters but it could help in the future.
>> >> What do you think?
>> >
>> >
>> > I am working on changing the code to find the "highest priority"
>> > LRU and reclaim from that list first.  That will obviate the need
>> > for such a change. However, the other cleanups and simplifications
>> > made by Ying's patch are good to have...
>>
>> So what you guys think to take from here. I can make the change as
>> Michal suggested if that would be something helpful future changes.
>> However, I wonder whether or not it is necessary.
>
> I am afraid we will not move forward without a proper implementation of
> the "nobody under soft limit" case. Maybe Rik's idea would just work out
> but this patch on it's own could regress so taking it separately is no
> go IMO. I like how it reduces the code size but we are not "there" yet...
>

Sorry for getting back to the thread late. Being distracted to
something else which of course happens all the time.

Before me jumping into actions of any changes, let me clarify the
problem I am facing:

All the concerns are related to the configuration where none of the
memcg is eligible for reclaim ( usage < softlimit ) under global
pressure.   The current code works like the following:

1. walk the memcg tree and for each checks the softlimit
2. if none of the memcg is being reclaimed, then set the ignore_softlimit
3. restart the walk and this round forget about the softlimit

There are two problems I heard here:
1. doing a full walk on step 1 would cause potential scalability issue.

Note: I would argue the admin need to adjust the configuration
instead. In theory, it is not recommended to over-commit the
soft-limit based on the concept. However, it could happen but and the
case should be rare.
The issue hasn't been observed on our running environment by far.

2. root cgroup is a exception where it always eligible for reclaim (
softlimit = 0 always). That will cause root to be punished more than
necessary.

Note: Not sure what would be the expected behavior. On one side, we
declare the softlimit of root always be the default (0), and even
future it can not be changed. Any pages above the soft-limit is
low-priority and targeted to reclaim over others. So, in this case
where no other memcg above their softlimit, why adding pressure on
root would be a regression.

I would like to take a look at Rik's patch and especially I am
interested in if the score scheme helps the case 1. On the other hand,
I wonder how that would provide the gurantees of memory under
softlimit. We might be able to accomplish that but w/ cost of more
computation power.

Is there anything that I missed and need to look next as well?

Thanks

--Ying







>> --Ying
>>
>> >
>> > --
>> > All rights reversed
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
