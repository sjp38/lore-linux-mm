Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 01EFE280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 04:15:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 74so5496407wma.6
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:15:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lz10si21237453wjb.276.2016.10.07.01.15.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 01:15:08 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
References: <20161004081215.5563-1-mhocko@kernel.org>
 <e7dc1e23-10fe-99de-e9c8-581857e3ab9d@suse.cz>
 <20161007065019.GA18439@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b32db10d-3a89-b60e-ac2c-238484610d8c@suse.cz>
Date: Fri, 7 Oct 2016 10:15:07 +0200
MIME-Version: 1.0
In-Reply-To: <20161007065019.GA18439@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/07/2016 08:50 AM, Michal Hocko wrote:
> On Fri 07-10-16 07:27:37, Vlastimil Babka wrote:
> [...]
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> index badb92bf14b4..07254a73ee32 100644
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -834,6 +834,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>>>  		    page_count(page) > page_mapcount(page))
>>>  			goto isolate_fail;
>>>
>>> +		/*
>>> +		 * Only allow to migrate anonymous pages in GFP_NOFS context
>>> +		 * because those do not depend on fs locks.
>>> +		 */
>>> +		if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
>>> +			goto isolate_fail;
>>
>> Unless page can acquire a page_mapping between this check and migration, I
>> don't see a problem with allowing this.
>
> It can be become swapcache but I guess this should be OK. We do not
> allow to get here with GFP_NOIO and migrating swapcache pages in NOFS
> mode should be OK AFAICS.
>
>> But make sure you don't break kcompactd and manual compaction from /proc, as
>> they don't currently set cc->gfp_mask. Looks like until now it was only used
>> to determine direct compactor's migratetype which is irrelevant in those
>> contexts.
>
> OK, I see. This is really subtle. One way to go would be to provide a
> fake gfp_mask for them. How does the following look to you?

Looks OK. I'll have to think about the kcompactd case, as gfp mask 
implying unmovable migratetype might restrict it without good reason. 
But that would be separate patch anyway, yours doesn't change that 
(empty gfp_mask also means unmovable migratetype) and that's good.

> ---
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 557c165b63ad..d1d90e96ef4b 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1779,6 +1779,7 @@ static void compact_node(int nid)
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
>  		.whole_zone = true,
> +		.gfp_mask = GFP_KERNEL,
>  	};
>
>
> @@ -1904,6 +1905,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  		.classzone_idx = pgdat->kcompactd_classzone_idx,
>  		.mode = MIGRATE_SYNC_LIGHT,
>  		.ignore_skip_hint = true,
> +		.gfp_mask = GFP_KERNEL,
>
>  	};
>  	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
