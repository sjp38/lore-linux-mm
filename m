Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 57CD26B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 21:30:38 -0400 (EDT)
Message-ID: <4F960257.9090509@kernel.org>
Date: Tue, 24 Apr 2012 10:31:03 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
References: <1335214564-17619-1-git-send-email-yinghan@google.com> <CAHGf_=pGhtieRpUqbF4GmAKt5XXhf_2y8c+EzGNx-cgqPNvfJw@mail.gmail.com> <CALWz4ix+MC_NuNdvQU3T8BhP+BULPLktLyNQ8osnrMOa2nfhdw@mail.gmail.com>
In-Reply-To: <CALWz4ix+MC_NuNdvQU3T8BhP+BULPLktLyNQ8osnrMOa2nfhdw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Hi Ying,

On 04/24/2012 08:18 AM, Ying Han wrote:

> On Mon, Apr 23, 2012 at 3:20 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, Apr 23, 2012 at 4:56 PM, Ying Han <yinghan@google.com> wrote:
>>> This is not a patch targeted to be merged at all, but trying to understand
>>> a logic in global direct reclaim.
>>>
>>> There is a logic in global direct reclaim where reclaim fails on priority 0
>>> and zone->all_unreclaimable is not set, it will cause the direct to start over
>>> from DEF_PRIORITY. In some extreme cases, we've seen the system hang which is
>>> very likely caused by direct reclaim enters infinite loop.
>>>
>>> There have been serious patches trying to fix similar issue and the latest
>>> patch has good summary of all the efforts:
>>>
>>> commit 929bea7c714220fc76ce3f75bef9056477c28e74
>>> Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> Date:   Thu Apr 14 15:22:12 2011 -0700
>>>
>>>    vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
>>>
>>> Kosaki explained the problem triggered by async zone->all_unreclaimable and
>>> zone->pages_scanned where the later one was being checked by direct reclaim.
>>> However, after the patch, the problem remains where the setting of
>>> zone->all_unreclaimable is asynchronous with zone is actually reclaimable or not.
>>>
>>> The zone->all_unreclaimable flag is set by kswapd by checking zone->pages_scanned in
>>> zone_reclaimable(). Is that possible to have zone->all_unreclaimable == false while
>>> the zone is actually unreclaimable?
>>>
>>> 1. while kswapd in reclaim priority loop, someone frees a page on the zone. It
>>> will end up resetting the pages_scanned.
>>>
>>> 2. kswapd is frozen for whatever reason. I noticed Kosaki's covered the
>>> hibernation case by checking oom_killer_disabled, but not sure if that is
>>> everything we need to worry about. The key point here is that direct reclaim
>>> relies on a flag which is set by kswapd asynchronously, that doesn't sound safe.
>>
>> If kswapd was frozen except hibernation, why don't you add frozen
>> check instead of
>> hibernation check? And when and why is that happen?
> 
> I haven't tried to reproduce the issue, so everything is based on
> eye-balling the code. The problem is that we have the potential
> infinite loop in direct reclaim where it keeps trying as long as
> !zone->all_unreclaimable.
> 
> The flag is only set by kswapd and it will skip setting the flag if
> the following condition is true:
> 
> zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> 
> In a few-pages-on-lru condition, the zone->pages_scanned is easily
> remains 0 and also it is reset to 0 everytime a page being freed.
> Then, i will cause global direct reclaim entering infinite loop.
> 


how does zone->pages_scanned become 0 easily in global reclaim?
Once VM has pages in LRU, it wouldn't be a zero. Look at isolate_lru_pages.
The problem is get_scan_count which could prevent scanning of LRU list but
it works well now. If the priority isn't zero and there are few pages in LRU,
it could be a zero scan but when the priority drop at zero, it could let VM scan
less pages under SWAP_CLUSTER_MAX. So pages_scanned would be increased.

I think the problem is live-lock as follows,


    A			kswapd				B

direct reclaim
reclaim a page						
                     	pages_scanned check <- skip
                          
							steal a page reclaimed by A
							use the page for user memory.
alloc failed
retry

In this scenario, process A would be a live-locked.
Does it make sense for infinite loop case you mentioned?


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
