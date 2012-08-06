Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 12E116B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:27:41 -0400 (EDT)
Message-ID: <501FD44D.40205@redhat.com>
Date: Mon, 06 Aug 2012 10:27:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
References: <1343687538-24284-1-git-send-email-yinghan@google.com> <20120731155932.GB16924@tiehlicka.suse.cz> <CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com> <20120731200205.GA19524@tiehlicka.suse.cz> <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com> <20120801084553.GD4436@tiehlicka.suse.cz> <CALWz4iwzJp8EwSeP6ap7_adW6sF8YR940sky6vJS3SD8FO6HkA@mail.gmail.com> <50198D38.1000905@redhat.com> <20120806140354.GE6150@dhcp22.suse.cz>
In-Reply-To: <20120806140354.GE6150@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/06/2012 10:03 AM, Michal Hocko wrote:
> On Wed 01-08-12 16:10:32, Rik van Riel wrote:
>> On 08/01/2012 03:04 PM, Ying Han wrote:
>>
>>> That is true. Hmm, then two things i can do:
>>>
>>> 1. for kswapd case, make sure not counting the root cgroup
>>> 2. or check nr_scanned. I like the nr_scanned which is telling us
>>> whether or not the reclaim ever make any attempt ?
>>
>> I am looking at a more advanced case of (3) right
>> now.  Once I have the basics working, I will send
>> you a prototype (that applies on top of your patches)
>> to play with.
>>
>> Basically, for every LRU in the system, we can keep
>> track of 4 things:
>> - reclaim_stat->recent_scanned
>> - reclaim_stat->recent_rotated
>> - reclaim_stat->recent_pressure
>> - LRU size
>>
>> The first two represent the fraction of pages on the
>> list that are actively used.  The larger the fraction
>> of recently used pages, the more valuable the cache
>> is. The inverse of that can be used to show us how
>> hard to reclaim this cache, compared to other caches
>> (everything else being equal).
>>
>> The recent pressure can be used to keep track of how
>> many pages we have scanned on each LRU list recently.
>> Pressure is scaled with LRU size.
>>
>> This would be the basic formula to decide which LRU
>> to reclaim from:
>>
>>            recent_scanned   LRU size
>> score =   -------------- * ----------------
>>            recent_rotated   recent_pressure
>>
>>
>> In other words, the less the objects on an LRU are
>> used, the more we should reclaim from that LRU. The
>> larger an LRU is, the more we should reclaim from
>> that LRU.
>
> The formula makes sense but I am afraid that it will be hard to tune it
> into something that wouldn't regress. For example I have seen workloads
> which had many small groups which are used to wrap up backup jobs and
> those are scanned a lot, you would see also many rotations because of
> the writeback but those are definitely good to scan rather than a large
> group which needs to keep its data resident.

Writeback rotations are not counted in
lruvec->reclaim_stat->recent_rotated - only the rotations
that were done because we really want to keep the page are
counted.

> Anyway, I am not saying the score approach is a bad idea but I am afraid
> it will be hard to validate and make it right.

One thing about the recent_scanned / recent_rotated metric is
that we have been using it since 2.6.28, to balance between
scanning the file and anonymous LRUs.

I believe it would help us balance between multiple sets of
LRUs, too.

>> The more we have already scanned an LRU, the lower
>> its score becomes. At some point, another LRU will
>> have the top score, and that will be the target to
>> scan.
>
> So you think we shouldn't do the full round over memcgs in shrink_zone a
> and rather do it oom way to pick up a victim and hammer it?

Not hammer it too far.  Only until its score ends up well
below (25% lower?) than that of the second highest scoring
list.

That way all the lists get hammered a little bit, in turn.

>> We can adjust the score for different LRUs in different
>> ways, eg.:
>> - swappiness adjustment for file vs anon LRUs, within
>>    an LRU set
>> - if an LRU set contains a file LRU with more inactive
>>    than active pages, reclaim from this LRU set first
>> - if an LRU set is over it's soft limit, reclaim from
>>    this LRU set first
>
> maybe we could replace LRU size by (LRU size - soft_limit) in the above
> formula?

Good idea, that could work.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
