Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 983446B0145
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 02:57:08 -0400 (EDT)
Message-ID: <4FE41752.8050305@kernel.org>
Date: Fri, 22 Jun 2012 15:57:22 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org> <4FE37434.808@linaro.org>
In-Reply-To: <4FE37434.808@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

Hi John,

On 06/22/2012 04:21 AM, John Stultz wrote:

> On 06/18/2012 10:49 PM, Minchan Kim wrote:
>> Hi everybody!
>>
>> Recently, there are some efforts to handle system memory pressure.
>>
>> 1) low memory notification - [1]
>> 2) fallocate(VOLATILE) - [2]
>> 3) fadvise(NOREUSE) - [3]
>>
>> For them, I would like to add new LRU list, aka "Ereclaimable" which
>> is opposite of "unevictable".
>> Reclaimable LRU list includes _easy_ reclaimable pages.
>> For example, easy reclaimable pages are following as.
>>
>> 1. invalidated but remained LRU list.
>> 2. pageout pages for reclaim(PG_reclaim pages)
>> 3. fadvise(NOREUSE)
>> 4. fallocate(VOLATILE)
>>
>> Their pages shouldn't stir normal LRU list and compaction might not
>> migrate them, even.
>> Reclaimer can reclaim Ereclaimable pages before normal lru list and
>> will avoid unnecessary
>> swapout in anon pages in easy-reclaimable LRU list.
> 
> I was hoping there would be further comment on this by more core VM
> devs, but so far things have been quiet (is everyone on vacation?).


At least, there are no dissent comment until now.
Let be a positive. :)

> 
> Overall this seems reasonable for the volatile ranges functionality. 
> The one down-side being that dealing with the ranges on a per-page basis
> can make marking and unmarking larger ranges as volatile fairly
> expensive. In my tests with my last patchset, it was over 75x slower
> (~1.5ms) marking and umarking a 1meg range when we deactivate and
> activate all of the pages, instead of just inserting the volatile range
> into an interval tree and purge via the shrinker (~20us).  Granted, my
> initial approach is somewhat naive, and some pagevec batching has
> improved things three-fold (down to ~500us) , but I'm still ~25x slower
> when iterating over all the pages.
> 
> There's surely further improvements to be made, but this added cost
> worries me, as users are unlikely to generously volunteer up memory to
> the kernel as volatile if doing so frequently adds significant overhead.
> 
> This makes me wonder if having something like an early-shrinker which
> gets called prior to shrinking the lrus might be a better approach for
> volatile ranges. It would still be numa-unaware, but would keep the
> overhead very light to both volatile users and non users.


How about doing it in background?
In your process context, you can schedule your work to workqueue and when work is executed,
you can move the pages into lru list you want.
Just an idea.

> 
> Even so, I'd be interested in seeing more about your approach, in the
> hopes that it might not be as costly as my initial attempt. Do you have
> any plans to start prototyping this?


I will wait response a few day and if anyone doesn't raise critical problems, will start.
But please keep in mind.I guess it's never trivial so you shouldn't depend on my schedule.
Thanks.

> 
> thanks
> -john
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
