Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBE886B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 12:02:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so35626768lfi.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 09:02:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id et19si1496099wjc.128.2016.07.20.09.02.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 09:02:47 -0700 (PDT)
Subject: Re: [PATCH 4/8] mm, page_alloc: restructure direct compaction
 handling in slowpath
References: <20160718112302.27381-1-vbabka@suse.cz>
 <20160718112302.27381-5-vbabka@suse.cz>
 <alpine.DEB.2.10.1607191548370.19940@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0a0a9812-2c51-dbb2-4f67-677d750e16ec@suse.cz>
Date: Wed, 20 Jul 2016 18:02:42 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1607191548370.19940@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On 07/20/2016 12:50 AM, David Rientjes wrote:
> On Mon, 18 Jul 2016, Vlastimil Babka wrote:
> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 30443804f156..a04a67745927 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3510,7 +3510,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  	struct page *page = NULL;
>>  	unsigned int alloc_flags;
>>  	unsigned long did_some_progress;
>> -	enum migrate_mode migration_mode = MIGRATE_ASYNC;
>> +	enum migrate_mode migration_mode = MIGRATE_SYNC_LIGHT;
>>  	enum compact_result compact_result;
>>  	int compaction_retries = 0;
>>  	int no_progress_loops = 0;
>> @@ -3552,6 +3552,49 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  	if (page)
>>  		goto got_pg;
>>  
>> +	/*
>> +	 * For costly allocations, try direct compaction first, as it's likely
>> +	 * that we have enough base pages and don't need to reclaim.
>> +	 */
>> +	if (can_direct_reclaim && order > PAGE_ALLOC_COSTLY_ORDER) {
>> +		page = __alloc_pages_direct_compact(gfp_mask, order,
>> +						alloc_flags, ac,
>> +						MIGRATE_ASYNC,
>> +						&compact_result);
>> +		if (page)
>> +			goto got_pg;
>> +
>> +		/* Checks for THP-specific high-order allocations */
>> +		if (is_thp_gfp_mask(gfp_mask)) {
>> +			/*
>> +			 * If compaction is deferred for high-order allocations,
>> +			 * it is because sync compaction recently failed. If
>> +			 * this is the case and the caller requested a THP
>> +			 * allocation, we do not want to heavily disrupt the
>> +			 * system, so we fail the allocation instead of entering
>> +			 * direct reclaim.
>> +			 */
>> +			if (compact_result == COMPACT_DEFERRED)
>> +				goto nopage;
>> +
>> +			/*
>> +			 * Compaction is contended so rather back off than cause
>> +			 * excessive stalls.
>> +			 */
>> +			if (compact_result == COMPACT_CONTENDED)
>> +				goto nopage;
>> +
>> +			/*
>> +			 * It can become very expensive to allocate transparent
>> +			 * hugepages at fault, so use asynchronous memory
>> +			 * compaction for THP unless it is khugepaged trying to
>> +			 * collapse. All other requests should tolerate at
>> +			 * least light sync migration.
>> +			 */
>> +			if (!(current->flags & PF_KTHREAD))
>> +				migration_mode = MIGRATE_ASYNC;
>> +		}
>> +	}
>>  
> 
> If gfp_pfmemalloc_allowed() == true, does this try to do compaction when 
> get_page_from_freelist() would have succeeded with no watermarks?

Yes, but the compaction will return immediately with COMPACT_SKIPPED, if
we are below min watermarks. So I don't think it's worth complicating
the code to avoid this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
