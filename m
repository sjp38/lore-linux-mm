Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 1A3D26B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 18:54:49 -0400 (EDT)
Message-ID: <50204B13.1080102@redhat.com>
Date: Mon, 06 Aug 2012 18:54:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
References: <1343687538-24284-1-git-send-email-yinghan@google.com> <20120731155932.GB16924@tiehlicka.suse.cz> <CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com> <20120731200205.GA19524@tiehlicka.suse.cz> <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com> <20120801084553.GD4436@tiehlicka.suse.cz> <CALWz4iwzJp8EwSeP6ap7_adW6sF8YR940sky6vJS3SD8FO6HkA@mail.gmail.com> <50198D38.1000905@redhat.com> <20120806140354.GE6150@dhcp22.suse.cz> <501FD44D.40205@redhat.com> <20120806151115.GA4850@dhcp22.suse.cz> <5020122A.5070704@redhat.com> <CALWz4ix82v39ivF6yV6iPmwnqJb8i3BOfDU0-EKAxofoTX4SjQ@mail.gmail.com>
In-Reply-To: <CALWz4ix82v39ivF6yV6iPmwnqJb8i3BOfDU0-EKAxofoTX4SjQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/06/2012 05:18 PM, Ying Han wrote:
> On Mon, Aug 6, 2012 at 11:51 AM, Rik van Riel<riel@redhat.com>  wrote:
>> On 08/06/2012 11:11 AM, Michal Hocko wrote:
>>>
>>> On Mon 06-08-12 10:27:25, Rik van Riel wrote:
>>
>>
>>>>> So you think we shouldn't do the full round over memcgs in shrink_zone a
>>>>> and rather do it oom way to pick up a victim and hammer it?
>>>>
>>>>
>>>> Not hammer it too far.  Only until its score ends up well
>>>> below (25% lower?) than that of the second highest scoring
>>>> list.
>>>>
>>>> That way all the lists get hammered a little bit, in turn.
>>>
>>>
>>> How do we provide the soft limit guarantee then?
>>>
>>> [...]
>>
>>
>> The easiest way would be to find the top 2 or 3 scoring memcgs
>> when we reclaim memory. After reclaiming some pages, recalculate
>> the scores of just these top lists, and see if the list we started
>> out with now has a lower score than the second one.
>>
>> Once we have reclaimed some from each of the 2 or 3 lists, we can
>> go back and find the highest priority lists again.
>
> Sounds like quite a lot of calculation to pick which memcg to reclaim
> from, and I wonder if that is necessary at all.
> For most of the use cases, we don't need to pick the lowest score
> memcg to reclaim from first. My understanding is that if we can
> respect the (lru_size - softlimit) to calculate the nr_to_scan, that
> is good move from what we have today.
>
> If so, can we just still do the round-robin fashion in shrink_zone()
> and for each memcg, we calculate the nr_to_scan similar to
> get_scan_count() what have today but w/ the new formula. For memcg
> under its softlimit, we avoid reclaim pages unless no more pages can
> be reclaimed, and then we start reclaiming under the softlimit. That
> part can use the same logic depending on (softlimit - lru_size)

If we do the round robin, we will not know in advance whether
or not there are memcgs over (or under) the softlimit.

Another thing to consider is that the round robin code will
always iterate over the cgroups AND try to reclaim a little
from every one of them.

The first version of my code will just iterate over them to
pick the highest priority cgroups, and will then reclaim from
the that (or those) groups.  This is less work than what your
code does right now.

In the future, we can find a way to sort the cgroups (in a
tree?), so we do not have to walk over all of them.

Some workloads have thousands of cgroups on a system.
Iterating over all of them is not going to scale, it will
be an inconvenience when just calculating the priority,
and has the potential to be a total disaster when doing a
little bit of reclaim from every one of them.

Lets look at this one step at a time.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
