Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 07BD26B007D
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 20:14:42 -0400 (EDT)
Message-ID: <4FE7AD8A.2080508@kernel.org>
Date: Mon, 25 Jun 2012 09:15:06 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org> <4FE37434.808@linaro.org> <4FE41752.8050305@kernel.org> <4FE549E8.2050905@jp.fujitsu.com>
In-Reply-To: <4FE549E8.2050905@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

Hi Kame,

On 06/23/2012 01:45 PM, Kamezawa Hiroyuki wrote:

> (2012/06/22 15:57), Minchan Kim wrote:
>> Hi John,
>>
>> On 06/22/2012 04:21 AM, John Stultz wrote:
>>
>>> On 06/18/2012 10:49 PM, Minchan Kim wrote:
>>>> Hi everybody!
>>>>
>>>> Recently, there are some efforts to handle system memory pressure.
>>>>
>>>> 1) low memory notification - [1]
>>>> 2) fallocate(VOLATILE) - [2]
>>>> 3) fadvise(NOREUSE) - [3]
>>>>
>>>> For them, I would like to add new LRU list, aka "Ereclaimable" which
>>>> is opposite of "unevictable".
>>>> Reclaimable LRU list includes _easy_ reclaimable pages.
>>>> For example, easy reclaimable pages are following as.
>>>>
>>>> 1. invalidated but remained LRU list.
>>>> 2. pageout pages for reclaim(PG_reclaim pages)
>>>> 3. fadvise(NOREUSE)
>>>> 4. fallocate(VOLATILE)
>>>>
>>>> Their pages shouldn't stir normal LRU list and compaction might not
>>>> migrate them, even.
>>>> Reclaimer can reclaim Ereclaimable pages before normal lru list and
>>>> will avoid unnecessary
>>>> swapout in anon pages in easy-reclaimable LRU list.
>>>
>>> I was hoping there would be further comment on this by more core VM
>>> devs, but so far things have been quiet (is everyone on vacation?).
>>
>>
>> At least, there are no dissent comment until now.
>> Let be a positive. :)
> 
> I think this is interesting approach. Major concern is how to guarantee
> EReclaimable
> pages are really EReclaimable...Do you have any idea ? madviced pages
> are really
> EReclaimable ?


I would like to select just discardable pages.

1. unmapped file page 
2. PG_reclaimed page - (that pages would have no mapped and a candidate 
   for reclaim ASAP)
3. fallocate(VOLATILE) - (We can just discard them without swapout)
4. madvise(MADV_DONTNEED)/fadvise(NOREUSE) -
   (It could be difficult than (1,2,3) but it's very likely to reclaim easily than others.

> 
> A (very) small concern is will you use one more page-flags for this ? ;)


Maybe and it could be a serious problem on 32 bit machine.
I didn't dive into that but I guess we can reuse PG_reclaim bit.
PG_reclaim is always used by with !PageActive and Ereclaimable LRU list doesn't have 
active LRU list. so we can change following as

- #define PG_reclaim
+ #define PG_Ereclaim

SetPageReclaim(page)
{
	page->flags |= (PG_Ereclaim|PG_active);
}

TestPageReclaim(page)
{
	if (((page->flags && PG_Ereclaim|PG_active)) == (PG_Ereclaim|PG_active)) 
		return true;
	return false;
}

SetPageEreclaim(page)
{
	page->flags |= PG_Ereclaim;
}

Thanks for the comment, Kame.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
