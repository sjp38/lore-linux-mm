Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5A08B82F64
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:19:18 -0500 (EST)
Received: by wmec201 with SMTP id c201so283781061wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:19:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ot8si4602475wjc.163.2015.11.18.07.19.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 07:19:17 -0800 (PST)
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-3-git-send-email-mhocko@kernel.org>
 <564C91E9.8000904@suse.cz> <20151118151119.GG19145@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564C96F2.10102@suse.cz>
Date: Wed, 18 Nov 2015 16:19:14 +0100
MIME-Version: 1.0
In-Reply-To: <20151118151119.GG19145@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 11/18/2015 04:11 PM, Michal Hocko wrote:
> On Wed 18-11-15 15:57:45, Vlastimil Babka wrote:
> [...]
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -3046,32 +3046,36 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>> >  		 * allocations are system rather than user orientated
>> >  		 */
>> >  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>> > -		do {
>> > -			page = get_page_from_freelist(gfp_mask, order,
>> > -							ALLOC_NO_WATERMARKS, ac);
>> > -			if (page)
>> > -				goto got_pg;
>> > -
>> > -			if (gfp_mask & __GFP_NOFAIL)
>> > -				wait_iff_congested(ac->preferred_zone,
>> > -						   BLK_RW_ASYNC, HZ/50);
>> 
>> I've been thinking if the lack of unconditional wait_iff_congested() can affect
>> something negatively. I guess not?
> 
> Considering that the wait_iff_congested is removed only for PF_MEMALLOC
> with __GFP_NOFAIL which should be non-existent in the kernel then I

Hm that one won't reach it indeed, but also not loop, so that wasn't my concern.
I was referring to:

        /* Keep reclaiming pages as long as there is reasonable progress */                            
        pages_reclaimed += did_some_progress;
        if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
            ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {                           
                /* Wait for some write requests to complete then retry */
                wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);                           
                goto retry;                                                                            
        }

Here we might skip the wait_iff_congested and go straight for oom. But it's true
that ordinary allocations that fail to make progress will also not wait, so I
guess it's fine.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> think the risk is really low. Even if there was a caller _and_ there
> was a congestion then the behavior wouldn't be much more worse than
> what we have currently. The system is out of memory hoplessly if
> ALLOC_NO_WATERMARKS allocation fails.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
