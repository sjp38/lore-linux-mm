Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DDBF6B03AB
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 05:21:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id e11so9653365wra.0
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 02:21:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si33534744wmz.53.2017.04.07.02.21.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 02:21:48 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: prevent potential recursive reclaim due to
 clearing PF_MEMALLOC
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-2-vbabka@suse.cz>
 <1f26f654-abaf-3878-6abb-5e27ff3a289e@virtuozzo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9c6ff585-f22f-3f90-fce7-793c56485019@suse.cz>
Date: Fri, 7 Apr 2017 11:21:45 +0200
MIME-Version: 1.0
In-Reply-To: <1f26f654-abaf-3878-6abb-5e27ff3a289e@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, stable@vger.kernel.org

On 04/05/2017 01:40 PM, Andrey Ryabinin wrote:
> On 04/05/2017 10:46 AM, Vlastimil Babka wrote:
>> The function __alloc_pages_direct_compact() sets PF_MEMALLOC to prevent
>> deadlock during page migration by lock_page() (see the comment in
>> __unmap_and_move()). Then it unconditionally clears the flag, which can clear a
>> pre-existing PF_MEMALLOC flag and result in recursive reclaim. This was not a
>> problem until commit a8161d1ed609 ("mm, page_alloc: restructure direct
>> compaction handling in slowpath"), because direct compation was called only
>> after direct reclaim, which was skipped when PF_MEMALLOC flag was set.
>> 
>> Even now it's only a theoretical issue, as the new callsite of
>> __alloc_pages_direct_compact() is reached only for costly orders and when
>> gfp_pfmemalloc_allowed() is true, which means either __GFP_NOMEMALLOC is in
>                            is false			
> 
>> gfp_flags or in_interrupt() is true. There is no such known context, but let's
>> play it safe and make __alloc_pages_direct_compact() robust for cases where
>> PF_MEMALLOC is already set.
>> 
>> Fixes: a8161d1ed609 ("mm, page_alloc: restructure direct compaction handling in slowpath")
>> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: <stable@vger.kernel.org>
>> ---
>>  mm/page_alloc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3589f8be53be..b84e6ffbe756 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3288,6 +3288,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>>  		enum compact_priority prio, enum compact_result *compact_result)
>>  {
>>  	struct page *page;
>> +	unsigned int noreclaim_flag = current->flags & PF_MEMALLOC;
>>  
>>  	if (!order)
>>  		return NULL;
>> @@ -3295,7 +3296,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>>  	current->flags |= PF_MEMALLOC;
>>  	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>>  									prio);
>> -	current->flags &= ~PF_MEMALLOC;
>> +	current->flags = (current->flags & ~PF_MEMALLOC) | noreclaim_flag;
> 
> Perhaps this would look better:
> 
> 	tsk_restore_flags(current, noreclaim_flag, PF_MEMALLOC);
> 
> ?

Well, I didn't care much considering this is for stable only, and patch 2/4
rewrites this to the new api.

>>  	if (*compact_result <= COMPACT_INACTIVE)
>>  		return NULL;
>> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
