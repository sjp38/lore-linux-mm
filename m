Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 4F8286B0088
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:52:55 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so5182378lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:52:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <501802DB.5030600@redhat.com>
References: <1343687538-24284-1-git-send-email-yinghan@google.com>
	<20120731155932.GB16924@tiehlicka.suse.cz>
	<501802DB.5030600@redhat.com>
Date: Tue, 31 Jul 2012 10:52:52 -0700
Message-ID: <CALWz4iy-KbrikrGBW+9MC=c63dxf-zvgG-+kW-Uq6Pna5b8ZjQ@mail.gmail.com>
Subject: Re: [PATCH V7 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jul 31, 2012 at 9:07 AM, Rik van Riel <riel@redhat.com> wrote:
> On 07/31/2012 11:59 AM, Michal Hocko wrote:
>
>>> @@ -1899,6 +1907,11 @@ static void shrink_zone(struct zone *zone, struct
>>> scan_control *sc)
>>>                 }
>>>                 memcg = mem_cgroup_iter(root, memcg,&reclaim);
>>>         } while (memcg);
>>> +
>>> +       if (!over_softlimit) {
>>
>>
>> Is this ever false? At least root cgroup is always above the limit.
>> Shouldn't we rather compare reclaimed pages?
>
>
> Uh oh.
>
> That could also result in us always reclaiming from the root cgroup
> first...

That is not true as far as I read. The mem_cgroup_reclaim_cookie
remembers the last scanned memcg under the priority in iter->position,
and the next round will just start at iter->position + 1. And that
cookie is shared between different reclaim threads, so depending on
how many threads entered reclaim and that starting point varies. By
saying that, it is true though if there is one reclaiming thread where
we always start from root and break when reading the end of the list.

>
> Is that really what we want?

Don't see my patch change that part. The only difference is that I
might end up scanning the same memcg list w/ the same priority twice.

>
> Having said that, in April I discussed an algorithm of LRU list
> weighting with Ying and others that should work.  Ying's patches
> look like a good basis to implement that on top of...

Yes.

--Ying
>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
