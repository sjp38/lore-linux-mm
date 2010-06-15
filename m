Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5226B0232
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:59:48 -0400 (EDT)
Date: Tue, 15 Jun 2010 14:59:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Message-ID: <20100615135928.GK26788@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-13-git-send-email-mel@csn.ul.ie> <4C16A567.4080000@redhat.com> <20100615114510.GE26788@csn.ul.ie> <4C17815A.8080402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4C17815A.8080402@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 09:34:18AM -0400, Rik van Riel wrote:
> On 06/15/2010 07:45 AM, Mel Gorman wrote:
>> On Mon, Jun 14, 2010 at 05:55:51PM -0400, Rik van Riel wrote:
>>> On 06/14/2010 07:17 AM, Mel Gorman wrote:
>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index 4856a2a..574e816 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -372,6 +372,12 @@ int write_reclaim_page(struct page *page, struct address_space *mapping,
>>>>    	return PAGE_SUCCESS;
>>>>    }
>>>>
>>>> +/* kswapd and memcg can writeback as they are unlikely to overflow stack */
>>>> +static inline bool reclaim_can_writeback(struct scan_control *sc)
>>>> +{
>>>> +	return current_is_kswapd() || sc->mem_cgroup != NULL;
>>>> +}
>>>> +
>>>
>>> I'm not entirely convinced on this bit, but am willing to
>>> be convinced by the data.
>>>
>>
>> Which bit?
>>
>> You're not convinced that kswapd should be allowed to write back?
>> You're not convinced that memcg should be allowed to write back?
>> You're not convinced that direct reclaim writing back pages can overflow
>> 	the stack?
>
> If direct reclaim can overflow the stack, so can direct
> memcg reclaim.  That means this patch does not solve the
> stack overflow, while admitting that we do need the
> ability to get specific pages flushed to disk from the
> pageout code.
>

What path is taken with memcg != NULL that could overflow the stack? I
couldn't spot one but mm/memcontrol.c is a bit tangled so finding all
its use cases is tricky. The critical path I had in mind though was
direct reclaim and for that path, memcg == NULL or did I miss something?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
