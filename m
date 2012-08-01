Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 7E7736B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 04:45:57 -0400 (EDT)
Date: Wed, 1 Aug 2012 10:45:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
Message-ID: <20120801084553.GD4436@tiehlicka.suse.cz>
References: <1343687538-24284-1-git-send-email-yinghan@google.com>
 <20120731155932.GB16924@tiehlicka.suse.cz>
 <CALWz4iwnrXFSoqmPUsXfUMzgxz5bmBrRNU5Nisd=g2mjmu-u3Q@mail.gmail.com>
 <20120731200205.GA19524@tiehlicka.suse.cz>
 <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ixF8PzhDs2fuOMTrrRiBHkg+aMzaVOBhuUN78UenzmYbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue 31-07-12 13:59:35, Ying Han wrote:
[...]
> Let's say the following example where the cgroup is sorted by css_id,
> and none of the cgroup's usage is above softlimit (except root)
> 
>                                         root  a  b  c  d  e f ...max
> thread_1 (priority = 12)         ^
>                                          iter->position = 1        (
> over_softlimit = true )
> 
>                                                 ^
>                                                  iter->position = 2
> 
> thread_2 (priority = 12)                     ^
>                                                      iter->position = 3
> 
>                                                       ....
>                                                                           ^
> 
>    iter->position = 0  ( over_softlimit = false )
> 
> In this case, thread 1 gets root but not thread 2 since they share the
> walk under same zone (same node) and same reclaim priority.

That is true iterator is per zone per priority if the cookie is used but
that wasn't my point.
Take a much simpler case. Just the background reclaim without any direct
reclaim. Then there is nobody to race with and so we would always visit
the whole tree including the root and so if no group is above the soft
limit we would hammer the root cgroup until priority gets down when we
ignore the limit and reclaim from all. Makes sense?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
