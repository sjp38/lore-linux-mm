Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 127A26B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:58:43 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id j12so11155888lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:58:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k72si35895119wmd.79.2016.06.01.07.58.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 07:58:41 -0700 (PDT)
Subject: Re: [PATCH v2 03/18] mm, page_alloc: don't retry initial attempt in
 slowpath
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-4-vbabka@suse.cz>
 <20160601132643.GP26601@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <574EF81E.6030402@suse.cz>
Date: Wed, 1 Jun 2016 16:58:38 +0200
MIME-Version: 1.0
In-Reply-To: <20160601132643.GP26601@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 06/01/2016 03:26 PM, Michal Hocko wrote:
> On Tue 31-05-16 15:08:03, Vlastimil Babka wrote:
> [...]
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index da3a62a94b4a..9f83259a18a8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3367,10 +3367,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>>  	bool drained = false;
>>  
>>  	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
>> -	if (unlikely(!(*did_some_progress)))
>> -		return NULL;
>>  
>>  retry:
>> +	/* We attempt even when no progress, as kswapd might have done some */
>>  	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
> 
> Is this really likely to happen, though? Sure we might have last few
> reclaimable pages on the LRU lists but I am not sure this would make a
> large difference then.
> 
> That being said, I do not think this is harmful but I find it a bit
> weird to invoke a reclaim and then ignore the feedback... Will leave the
> decision up to you but the original patch seemed neater.

OK, I'll think about it.

>>  
>>  	/*
>> @@ -3378,7 +3377,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>>  	 * pages are pinned on the per-cpu lists or in high alloc reserves.
>>  	 * Shrink them them and try again
>>  	 */
>> -	if (!page && !drained) {
>> +	if (!page && *did_some_progress && !drained) {
>>  		unreserve_highatomic_pageblock(ac);
>>  		drain_all_pages(NULL);
>>  		drained = true;
> 
> I do not remember this in the previous version.

Because it's consequence of the new hunk above.

> Why shouldn't we
> unreserve highatomic reserves when there was no progress?

Previously the "return NULL" for no progress would also skip this. So I
wanted to change just the get_page_from_freelist() part. IIUC the
reasoning here is that if there was reclaim progress but we didn't
succeed getting the page, it can mean it's stuck on per-cpu or reserve.
If there was no progress, it's unlikely that anything is stuck there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
