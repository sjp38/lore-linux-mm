Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1286B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 07:22:57 -0400 (EDT)
Received: by wieq12 with SMTP id q12so15332525wie.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 04:22:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4si15287672wif.54.2015.10.12.04.22.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 04:22:56 -0700 (PDT)
Subject: Re: [RFC] mm: fix a BUG, the page is allocated 2 times
References: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com>
 <561B6379.2070407@suse.cz> <4D925B19-2187-4892-A99A-E59D575C2147@gmail.com>
 <20151012100514.GA2544@node>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561B980C.6060809@suse.cz>
Date: Mon, 12 Oct 2015 13:22:52 +0200
MIME-Version: 1.0
In-Reply-To: <20151012100514.GA2544@node>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, yalin wang <yalin.wang2010@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, David Rientjes <rientjes@google.com>, js1304@gmail.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/12/2015 12:05 PM, Kirill A. Shutemov wrote:
> On Mon, Oct 12, 2015 at 03:58:51PM +0800, yalin wang wrote:
>>
>>> On Oct 12, 2015, at 15:38, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>> On 10/12/2015 04:40 AM, yalin wang wrote:
>>>> Remove unlikely(order), because we are sure order is not zero if
>>>> code reach here, also add if (page == NULL), only allocate page again if
>>>> __rmqueue_smallest() failed or alloc_flags & ALLOC_HARDER == 0
>>>
>>> The second mentioned change is actually more important as it removes a memory leak! Thanks for catching this. The problem is in patch mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch and seems to have been due to a change in the last submitted version to make sure the tracepoint is called.
>>>
>>>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
>>>> ---
>>>>   mm/page_alloc.c | 6 +++---
>>>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 0d6f540..de82e2c 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -2241,13 +2241,13 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>>>>   		spin_lock_irqsave(&zone->lock, flags);
>>>>
>>>>   		page = NULL;
>>>> -		if (unlikely(order) && (alloc_flags & ALLOC_HARDER)) {
>>>> +		if (alloc_flags & ALLOC_HARDER) {
>>>>   			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
>>>>   			if (page)
>>>>   				trace_mm_page_alloc_zone_locked(page, order, migratetype);
>>>>   		}
>>>> -
>>>> -		page = __rmqueue(zone, order, migratetype, gfp_flags);
>>>> +		if (page == NULL)
>>>
>>> "if (!page)" is more common and already used below.
>>> We could skip the check for !page in case we don't go through the ALLOC_HARDER branch, but I guess it's not worth the goto, and hopefully the compiler is smart enough anywaya?|
>> agree with your comments,
>> do i need send a new patch for this ?

I'd guess no need to, Andrew can edit the patch?

>
> Looks like a two patches to me: memory leak and removing always-true part
> of condifition.

Yeah but I'd expect both would be in the end folded into the buggy patch 
in -mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
