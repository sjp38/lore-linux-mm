Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A13E86B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 20:26:36 -0400 (EDT)
Received: by lbon3 with SMTP id n3so2892716lbo.14
        for <linux-mm@kvack.org>; Fri, 17 Aug 2012 17:26:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502ED6A1.9090201@redhat.com>
References: <20120816113450.52f4e633@cuia.bos.redhat.com>
	<20120816113733.7ba45fde@cuia.bos.redhat.com>
	<CALWz4iz6QETaevrg4QAV390K=BXTQKdWfXb2_SOYj4eYWLxfAw@mail.gmail.com>
	<502ED6A1.9090201@redhat.com>
Date: Fri, 17 Aug 2012 17:26:34 -0700
Message-ID: <CALWz4ixRDG9biZrO2VXcvsCAYS5WS7CNwrw0i+3o1u+r1Ls_UQ@mail.gmail.com>
Subject: Re: [RFC][PATCH -mm -v2 3/4] mm,vmscan: reclaim from the highest
 score cgroups
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On Fri, Aug 17, 2012 at 4:41 PM, Rik van Riel <riel@redhat.com> wrote:
> On 08/17/2012 07:34 PM, Ying Han wrote:
>>
>> On Thu, Aug 16, 2012 at 8:37 AM, Rik van Riel <riel@redhat.com> wrote:
>
>
>>> +       /*
>>> +        * Reclaim from the top scoring lruvec until we freed enough
>>> +        * pages, or its reclaim priority has halved.
>>> +        */
>>> +       do {
>>> +               shrink_lruvec(victim_lruvec, sc);
>>> +               score = reclaim_score(memcg, victim_lruvec);
>>> +       } while (sc->nr_to_reclaim > 0 && score > max_score / 2);
>>
>>
>> This would violate the user expectation of soft_limit badly,
>> especially for background reclaim where nr_to_reclaim equals to
>> ULONG_MAX.
>>
>> Here we keep hitting cgroup A and potentially push it down to
>> softlimit until the score drops to certain level. It is bad since it
>> causes "hot" memory (under softlimit) of A being reclaimed while other
>> cgroups has plenty of "cold" (above softlimit) to give out.
>
>
> Look at the function reclaim_score().
>
> Once a group drops below its soft limit, its score will
> be a factor 10000 smaller, making sure we hit the second
> exit condition.
>
> After that, we will pick another group.
>
>
>> In general, pick one cgroup to reclaim instead of round-robin is ok as
>> long as we don't reclaim further down to the softlimit. The next
>> question then is what's the next cgroup to reclaim if that doesn't
>> give us enough.
>
>
> Again, look at the function reclaim_score().
>
> If there is a group above the softlimit, we pretty much
> guarantee we will reclaim from that group.  If any reclaim
> will happen from another group, it will be absolutely
> minimal (taking recent_pressure from 0 to SWAP_CLUSTER_MAX,
> and then moving on to another group).

Seems I should really look into the numbers, which i tried to avoid at
the beginning... :(

Another way of teaching myself on how it works is to run a sanity
test. Let's say I have two cgroups under root, and they are running
different workload:

root
   ->A ( mem_alloc which keep touching its working set)
   ->B ( stream IO, like dd )

Here are the test cases on top of my head as well as the expected
output, forget about root cgroup for now:

case 1. A & B above softlimit
    a) score(B) > score(A), and keep reclaiming from B
    b) as long as usage(B) > softlimit(B), no reclaim on A
    c) until B under softlimit, reclaim from A

case 2. A above softlimit and B under softlimit
    a) score(A) > score(B), and keep reclaiming from A
    b) as long as usage (A) > softlimit (A), no reclaim on B
    c) until A under softlimit, then reclaim on both as case 3

case 3. A & B under softlimit
    a) score(B) > score(A), and keep reclaiming from B
    b) there should be no reclaim happen on A.

My patch delivers the functionality of case 2, but not distributing
the pressure across memcgs as this patch does (case 1 & 3).  Also, on
case3 where in my patch I would scan all the memcgs for nothing where
in this patch it will eventually pick a memcg to reclaim. Not sure if
it is a lot save though.

Over the three cases, I would say case 2 is the basic functionality we
want to guarantee and the case 1 and case 3 are optimizations on top
of that.

I would like to run the test above and please help to clarify if they
make sense.

Thanks

--Ying


>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
