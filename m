Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 314F26B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 21:13:05 -0500 (EST)
Message-ID: <4F20B692.4080906@redhat.com>
Date: Wed, 25 Jan 2012 21:12:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mm 1/3] mm: reclaim at order 0 when compaction is
 enabled
References: <20120124131822.4dc03524@annuminas.surriel.com> <20120124132136.3b765f0c@annuminas.surriel.com> <20120125150016.GB3901@csn.ul.ie> <4F201F60.8080808@redhat.com> <20120125221632.GL30782@redhat.com>
In-Reply-To: <20120125221632.GL30782@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 01/25/2012 05:16 PM, Andrea Arcangeli wrote:
> On Wed, Jan 25, 2012 at 10:27:28AM -0500, Rik van Riel wrote:
>> On 01/25/2012 10:00 AM, Mel Gorman wrote:
>>> On Tue, Jan 24, 2012 at 01:21:36PM -0500, Rik van Riel wrote:
>>>> When built with CONFIG_COMPACTION, kswapd does not try to free
>>>> contiguous pages.
>>>
>>> balance_pgdat() gets its order from wakeup_kswapd(). This does not apply
>>> to THP because kswapd does not get woken for THP but it should be woken
>>> up for allocations like jumbo frames or order-1.
>>
>> In the kernel I run at home, I wake up kswapd for THP
>> as well. This is a larger change, which Andrea asked
>> me to delay submitting upstream for a bit.
>>
>> So far there seem to be no ill effects. I'll continue
>> watching for them.
>
> The only problem we had last time when we managed to add compaction in
> kswapd upstream, was a problem of that too high kswapd wakeup
> frequency that kept kswapd spinning at 100% load and destroying
> specsfs performance. It may have been a fundamental problem of
> compaction not being worthwhile to run to generate jumbo frames
> because the cost of migrating memory, copying, flushing ptes

I suspect the problem was much simpler back then.  Kswapd
invoked compaction inside the loop, instead of outside the
loop, and there was no throttling at all.

> About THP, it may not give problems for THP because the allocation
> rate is much slower.

> I'm still quite afraid that compaction in kswapd waken by jumbo frames
> may not work well,

THP allocations may be slower, but jumbo frames get freed
again quickly. We do not have to compact memory for every
few jumbo frame allocations, only when the number of packets
in flight is going up...

You are right that it should be tested, though :)

I will look into that.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
