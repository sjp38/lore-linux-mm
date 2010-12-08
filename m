Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 09EF66B0093
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 03:16:02 -0500 (EST)
Received: by iwn1 with SMTP id 1so1309444iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 00:16:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208170504.1750.A69D9226@jp.fujitsu.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
	<20101208170504.1750.A69D9226@jp.fujitsu.com>
Date: Wed, 8 Dec 2010 17:16:01 +0900
Message-ID: <AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 5:04 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> invalidate_mapping_pages is very big hint to reclaimer.
>> It means user doesn't want to use the page any more.
>> So in order to prevent working set page eviction, this patch
>> move the page into tail of inactive list by PG_reclaim.
>>
>> Please, remember that pages in inactive list are working set
>> as well as active list. If we don't move pages into inactive list's
>> tail, pages near by tail of inactive list can be evicted although
>> we have a big clue about useless pages. It's totally bad.
>>
>> Now PG_readahead/PG_reclaim is shared.
>> fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
>> preventing fast reclaiming readahead marker page.
>>
>> In this series, PG_reclaim is used by invalidated page, too.
>> If VM find the page is invalidated and it's dirty, it sets PG_reclaim
>> to reclaim asap. Then, when the dirty page will be writeback,
>> clear_page_dirty_for_io will clear PG_reclaim unconditionally.
>> It disturbs this serie's goal.
>>
>> I think it's okay to clear PG_readahead when the page is dirty, not
>> writeback time. So this patch moves ClearPageReadahead.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>> Acked-by: Mel Gorman <mel@csn.ul.ie>
>> Cc: Wu Fengguang <fengguang.wu@intel.com>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Nick Piggin <npiggin@kernel.dk>
>
> Until anyone should data, I will not ack this. This patch increase
> VM state, but benefit is doubious.

Make sense to me. If Ben is busy, I will measure it and send the result.
Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
