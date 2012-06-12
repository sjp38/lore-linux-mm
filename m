Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 416B26B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 20:54:01 -0400 (EDT)
Message-ID: <4FD69302.20805@redhat.com>
Date: Mon, 11 Jun 2012 20:53:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
References: <1335214564-17619-1-git-send-email-yinghan@google.com> <CAHGf_=qn_f5Vm4S=X99siuQzAJcHe8vSLJzU48GXTZXLZgGuWQ@mail.gmail.com>
In-Reply-To: <CAHGf_=qn_f5Vm4S=X99siuQzAJcHe8vSLJzU48GXTZXLZgGuWQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 06/11/2012 07:33 PM, KOSAKI Motohiro wrote:
> On Mon, Apr 23, 2012 at 4:56 PM, Ying Han<yinghan@google.com>  wrote:
>> This is not a patch targeted to be merged at all, but trying to understand
>> a logic in global direct reclaim.
>>
>> There is a logic in global direct reclaim where reclaim fails on priority 0
>> and zone->all_unreclaimable is not set, it will cause the direct to start over
>> from DEF_PRIORITY. In some extreme cases, we've seen the system hang which is
>> very likely caused by direct reclaim enters infinite loop.
>>
>> There have been serious patches trying to fix similar issue and the latest
>> patch has good summary of all the efforts:
>>
>> commit 929bea7c714220fc76ce3f75bef9056477c28e74
>> Author: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>> Date:   Thu Apr 14 15:22:12 2011 -0700
>>
>>     vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
>>
>> Kosaki explained the problem triggered by async zone->all_unreclaimable and
>> zone->pages_scanned where the later one was being checked by direct reclaim.
>> However, after the patch, the problem remains where the setting of
>> zone->all_unreclaimable is asynchronous with zone is actually reclaimable or not.
>>
>> The zone->all_unreclaimable flag is set by kswapd by checking zone->pages_scanned in
>> zone_reclaimable(). Is that possible to have zone->all_unreclaimable == false while
>> the zone is actually unreclaimable?
>
> I'm backed very old threads. :-(
> I could reproduce this issue by using memory hotplug. Can anyone
> review following patch?

Looks like a sane approach to me.

> Reported-by: Aaditya Kumar<aaditya.kumar.30@gmail.com>
> Reported-by: Ying Han<yinghan@google.com>
> Cc: Nick Piggin<npiggin@gmail.com>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Mel Gorman<mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim<minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
