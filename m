Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BA2B66B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 18:49:03 -0400 (EDT)
Message-ID: <51EDB6D9.30100@redhat.com>
Date: Mon, 22 Jul 2013 18:48:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <1374267325-22865-4-git-send-email-hannes@cmpxchg.org> <51ED9433.60707@redhat.com> <20130722210423.GG715@cmpxchg.org>
In-Reply-To: <20130722210423.GG715@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/22/2013 05:04 PM, Johannes Weiner wrote:
> On Mon, Jul 22, 2013 at 04:21:07PM -0400, Rik van Riel wrote:
>> On 07/19/2013 04:55 PM, Johannes Weiner wrote:
>>
>>> @@ -1984,7 +1992,8 @@ this_zone_full:
>>>   		goto zonelist_scan;
>>>   	}
>>>
>>> -	if (page)
>>> +	if (page) {
>>> +		atomic_sub(1U << order, &zone->alloc_batch);
>>>   		/*
>>>   		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
>>>   		 * necessary to allocate the page. The expectation is
>>
>> Could this be moved into the slow path in buffered_rmqueue and
>> rmqueue_bulk, or would the effect of ignoring the pcp buffers be
>> too detrimental to keeping the balance between zones?
>
> What I'm worried about is not the inaccury that comes from the buffer
> size but the fact that there are no guaranteed buffer empty+refill
> cycles.  The reclaimer could end up feeding the pcp list that the
> allocator is using indefinitely, which brings us back to the original
> problem.  If you have >= NR_CPU jobs running, the kswapds are bound to
> share CPUs with the allocating tasks, so the scenario is not unlikely.

You are absolutely right.  Thinking about it some more,
I cannot think of a better way to do this than your patch.

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
