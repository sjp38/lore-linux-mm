Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A9A4B6B00E8
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 14:03:27 -0400 (EDT)
Message-ID: <4F6774E8.2050202@redhat.com>
Date: Mon, 19 Mar 2012 14:03:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
References: <20120319091821.17716.54031.stgit@zurg> <4F676FA4.50905@redhat.com> <4F6773CC.2010705@openvz.org>
In-Reply-To: <4F6773CC.2010705@openvz.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 03/19/2012 01:58 PM, Konstantin Khlebnikov wrote:
> Rik van Riel wrote:
>> On 03/19/2012 05:18 AM, Konstantin Khlebnikov wrote:
>>> This patch reset reclaim mode in shrink_active_list() to
>>> RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC.
>>> (sync/async sign is used only in shrink_page_list and does not affect
>>> shrink_active_list)
>>>
>>> Currenly shrink_active_list() sometimes works in lumpy-reclaim mode,
>>> if RECLAIM_MODE_LUMPYRECLAIM left over from earlier
>>> shrink_inactive_list().
>>> Meanwhile, in age_active_anon() sc->reclaim_mode is totally zero.
>>> So, current behavior is too complex and confusing, all this looks
>>> like bug.
>>>
>>> In general, shrink_active_list() populate inactive list for next
>>> shrink_inactive_list().
>>> Lumpy shring_inactive_list() isolate pages around choosen one from
>>> both active and
>>> inactive lists. So, there no reasons for lumpy-isolation in
>>> shrink_active_list()
>>>
>>> Proposed-by: Hugh Dickins<hughd@google.com>
>>> Link: https://lkml.org/lkml/2012/3/15/583
>>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>
>> Confirmed, this is already done by commit
>> 26f5f2f1aea7687565f55c20d69f0f91aa644fb8 in the
>> linux-next tree.
>>
>
> No, your patch fix this problem only if CONFIG_COMPACTION=y

True.

It was done that way, because Mel explained to me that deactivating
a whole chunk of active pages at once is a desired feature that makes
it more likely that a whole contiguous chunk of pages will eventually
reach the end of the inactive list.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
