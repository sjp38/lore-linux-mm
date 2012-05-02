Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 077596B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 23:25:26 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so429704obb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 20:25:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA017FA.2000707@redhat.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com>
	<CAPa8GCATMxi2ON22T_daE9EMFg8BWgK4vRTDadDFR66aj_uGTg@mail.gmail.com>
	<CALWz4ixeBq7cMoopukaRZxUmH1i0+L4xZ_49B0YpZ4iZuRC+Uw@mail.gmail.com>
	<CAPa8GCC1opy9u6NHy9m=1xU4EfRsHu8VN2kU-bXtRz=z_Mq0PA@mail.gmail.com>
	<CALWz4iyv1wSkdS0e9iezbpAg_adBhKvxRVqmXX1i4mk3x_V34g@mail.gmail.com>
	<4FA017FA.2000707@redhat.com>
Date: Wed, 2 May 2012 13:25:25 +1000
Message-ID: <CAPa8GCC8YxQ9Z9y3QJprn_MeAUs4XqKi3DLZHpbUVGJbGp2Rpw@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 2 May 2012 03:06, Rik van Riel <riel@redhat.com> wrote:
> On 05/01/2012 12:18 PM, Ying Han wrote:
>
>> The current logic seems perfer to reclaim more than going oom kill,
>> and that might not fit all user's expectation. However, I guess it is
>> hard to convince for any changes since different users has different
>> bias as you said....
>
>
> However, it is a sure thing that desktop users and smartphone
> users do want an earlier OOM kill.
>
> I wonder if doing an OOM kill when the number of free pages
> plus the number of file lru pages in every zone is below
> pages_high and there is no more swap available might work?

This patch in the first place was required to even reach the
condition that "no more swap is available" on this virtual
machine server workload I was vaguely remembering.

Without this logic, it would be OOM killed before such condition
is hit, because we can require to go around the LRU a few times
to free enough pages. You can imagine with concurrent threads
touching ptes and possibly allocating memory themselves.


> On the other hand, that still leaves us cgroups. What could
> be appropriate there?

We always seem to end up with a tangle of mysterious dials
and knobs deep in the heart of the the implementation :(

I wonder if there is some other way to approach it, like a
QoS from point of view of caller? That seems to be not so
far removed from the "end result requirements".

e.g., if short term average page allocation latency for a task
exceeds {10us, 100us, 1ms, 10ms}, then start shooting.

This does not catch the theoretical corner case where memory
is reclaimed very quickly, but just reused for the same thing
because a task is thrashing. But in practice, I think thrashing
workloads quickly lead to a lot of write IOs and major allocation
slowdowns anyway, so in practice I think it could work.

And it could be adjusted per task, per cgroup, etc. and would
not depend on reclaim/allocator implementation details.

I'm sure someone will tell me how horribly flawed the idea is
though :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
