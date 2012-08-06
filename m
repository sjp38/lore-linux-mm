Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 00E326B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 14:51:58 -0400 (EDT)
Message-ID: <5020122A.5070704@redhat.com>
Date: Mon, 06 Aug 2012 14:51:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
References: <1343687538-24284-1-git-send-email-yinghan@google.com> <20120731155932.GB16924@tiehlicka.suse.cz> <CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com> <20120731200205.GA19524@tiehlicka.suse.cz> <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com> <20120801084553.GD4436@tiehlicka.suse.cz> <CALWz4iwzJp8EwSeP6ap7_adW6sF8YR940sky6vJS3SD8FO6HkA@mail.gmail.com> <50198D38.1000905@redhat.com> <20120806140354.GE6150@dhcp22.suse.cz> <501FD44D.40205@redhat.com> <20120806151115.GA4850@dhcp22.suse.cz>
In-Reply-To: <20120806151115.GA4850@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/06/2012 11:11 AM, Michal Hocko wrote:
> On Mon 06-08-12 10:27:25, Rik van Riel wrote:

>>> So you think we shouldn't do the full round over memcgs in shrink_zone a
>>> and rather do it oom way to pick up a victim and hammer it?
>>
>> Not hammer it too far.  Only until its score ends up well
>> below (25% lower?) than that of the second highest scoring
>> list.
>>
>> That way all the lists get hammered a little bit, in turn.
>
> How do we provide the soft limit guarantee then?
>
> [...]

The easiest way would be to find the top 2 or 3 scoring memcgs
when we reclaim memory. After reclaiming some pages, recalculate
the scores of just these top lists, and see if the list we started
out with now has a lower score than the second one.

Once we have reclaimed some from each of the 2 or 3 lists, we can
go back and find the highest priority lists again.

Direct reclaim only reclaims a little bit at a time, anyway.

For kswapd, we could also remember the number of pages the group
has in excess of its soft limit, and recalculate after that...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
