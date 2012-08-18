Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 3F1976B0069
	for <linux-mm@kvack.org>; Sat, 18 Aug 2012 00:02:46 -0400 (EDT)
Message-ID: <502F13DA.1090806@redhat.com>
Date: Sat, 18 Aug 2012 00:02:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH -mm -v2 3/4] mm,vmscan: reclaim from the highest
 score cgroups
References: <20120816113450.52f4e633@cuia.bos.redhat.com> <20120816113733.7ba45fde@cuia.bos.redhat.com> <CALWz4iz6QETaevrg4QAV390K=BXTQKdWfXb2_SOYj4eYWLxfAw@mail.gmail.com> <502ED6A1.9090201@redhat.com> <CALWz4ixRDG9biZrO2VXcvsCAYS5WS7CNwrw0i+3o1u+r1Ls_UQ@mail.gmail.com>
In-Reply-To: <CALWz4ixRDG9biZrO2VXcvsCAYS5WS7CNwrw0i+3o1u+r1Ls_UQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On 08/17/2012 08:26 PM, Ying Han wrote:

> Seems I should really look into the numbers, which i tried to avoid at
> the beginning... :(

It comes down to the same drawings we made on the white board
back in April :)

> Here are the test cases on top of my head as well as the expected
> output, forget about root cgroup for now:
>
> case 1. A & B above softlimit
>      a) score(B) > score(A), and keep reclaiming from B
>      b) as long as usage(B) > softlimit(B), no reclaim on A
>      c) until B under softlimit, reclaim from A

By reclaiming from (B), it is very possible (and likely) that
the score of (B) will be depressed below that of (A), after
which we will start reclaiming from (A).

This could happen even while both (A) and (B) are still over
their soft limits.

> case 2. A above softlimit and B under softlimit
>      a) score(A) > score(B), and keep reclaiming from A
>      b) as long as usage (A) > softlimit (A), no reclaim on B
>      c) until A under softlimit, then reclaim on both as case 3

Pretty much, yes.

If we have not scanned anything at all in (B), we might scan
SWAP_CLUSTER_MAX (32) pages in B, but that will instantly reduce
B's score by a factor 33 and get us to reclaim from (A) again.

That is 33 because we do a +1 in the calculation to avoid
division by zero :)

> case 3. A & B under softlimit
>      a) score(B) > score(A), and keep reclaiming from B
>      b) there should be no reclaim happen on A.

Reclaiming from (B) will reduce B's score, so eventually we will
end up reclaiming from (A) again.

The more memory pressure one lruvec gets, the lower its score,
and the more likely that somebody else has a higher score.

> My patch delivers the functionality of case 2, but not distributing
> the pressure across memcgs as this patch does (case 1 & 3).  Also, on
> case3 where in my patch I would scan all the memcgs for nothing where
> in this patch it will eventually pick a memcg to reclaim. Not sure if
> it is a lot save though.
>
> Over the three cases, I would say case 2 is the basic functionality we
> want to guarantee and the case 1 and case 3 are optimizations on top
> of that.

There is an additional optimization that becomes possible
with my approach, and not with round robin.

Some people want to run systems with hundreds, or even
thousands of memory cgroups. Having direct reclaim iterate
over all those cgroups could have a really bad impact on
direct reclaim latency.

Once we have a scoring mechanism, we can implement a further
optimization where we sort the lruvecs, adjusting their
priority as things happen (pages get allocated, freed or
scanned), instead of every time we go through the reclaim
code.

That way it will become possible to have a system that
truly scales to large numbers of cgroups.

> I would like to run the test above and please help to clarify if they
> make sense.

The test makes sense to me.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
