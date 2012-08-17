Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id CE0086B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 19:41:32 -0400 (EDT)
Message-ID: <502ED6A1.9090201@redhat.com>
Date: Fri, 17 Aug 2012 19:41:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH -mm -v2 3/4] mm,vmscan: reclaim from the highest
 score cgroups
References: <20120816113450.52f4e633@cuia.bos.redhat.com> <20120816113733.7ba45fde@cuia.bos.redhat.com> <CALWz4iz6QETaevrg4QAV390K=BXTQKdWfXb2_SOYj4eYWLxfAw@mail.gmail.com>
In-Reply-To: <CALWz4iz6QETaevrg4QAV390K=BXTQKdWfXb2_SOYj4eYWLxfAw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On 08/17/2012 07:34 PM, Ying Han wrote:
> On Thu, Aug 16, 2012 at 8:37 AM, Rik van Riel <riel@redhat.com> wrote:

>> +       /*
>> +        * Reclaim from the top scoring lruvec until we freed enough
>> +        * pages, or its reclaim priority has halved.
>> +        */
>> +       do {
>> +               shrink_lruvec(victim_lruvec, sc);
>> +               score = reclaim_score(memcg, victim_lruvec);
>> +       } while (sc->nr_to_reclaim > 0 && score > max_score / 2);
>
> This would violate the user expectation of soft_limit badly,
> especially for background reclaim where nr_to_reclaim equals to
> ULONG_MAX.
>
> Here we keep hitting cgroup A and potentially push it down to
> softlimit until the score drops to certain level. It is bad since it
> causes "hot" memory (under softlimit) of A being reclaimed while other
> cgroups has plenty of "cold" (above softlimit) to give out.

Look at the function reclaim_score().

Once a group drops below its soft limit, its score will
be a factor 10000 smaller, making sure we hit the second
exit condition.

After that, we will pick another group.

> In general, pick one cgroup to reclaim instead of round-robin is ok as
> long as we don't reclaim further down to the softlimit. The next
> question then is what's the next cgroup to reclaim if that doesn't
> give us enough.

Again, look at the function reclaim_score().

If there is a group above the softlimit, we pretty much
guarantee we will reclaim from that group.  If any reclaim
will happen from another group, it will be absolutely
minimal (taking recent_pressure from 0 to SWAP_CLUSTER_MAX,
and then moving on to another group).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
