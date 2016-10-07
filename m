Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B665F6B0263
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 01:27:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b80so3675601wme.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 22:27:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15si1446962wmg.83.2016.10.06.22.27.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 22:27:39 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
References: <20161004081215.5563-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e7dc1e23-10fe-99de-e9c8-581857e3ab9d@suse.cz>
Date: Fri, 7 Oct 2016 07:27:37 +0200
MIME-Version: 1.0
In-Reply-To: <20161004081215.5563-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/04/2016 10:12 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> direct compact when a high-order allocation fails"). The main reason
> is that the migration of page cache pages might recurse back to fs/io
> layer and we could potentially deadlock. This is overly conservative
> because all the anonymous memory is migrateable in the GFP_NOFS context
> just fine.  This might be a large portion of the memory in many/most
> workkloads.
>
> Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> (those with a mapping) while isolating pages to be migrated. We cannot
> consider clean fs pages because they might need a metadata update so
> only isolate pages without any mapping for nofs requests.
>
> The effect of this patch will be probably very limited in many/most
> workloads because higher order GFP_NOFS requests are quite rare,
> although different configurations might lead to very different results
> as GFP_NOFS usage is rather unleashed (e.g. I had hard time to trigger
> any with my setup). But still there shouldn't be any strong reason to
> completely back off and do nothing in that context. In the worst case
> we just skip parts of the block with fs pages. This might be still
> sufficient to make a progress for small orders.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>
> Hi,
> I am sending this as an RFC because I am not completely sure this a) is
> really worth it and b) it is 100% correct. I couldn't find any problems
> when staring into the code but as mentioned in the changelog I wasn't
> really able to trigger high order GFP_NOFS requests in my setup.
>
> Thoughts?
>
>  mm/compaction.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index badb92bf14b4..07254a73ee32 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -834,6 +834,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		    page_count(page) > page_mapcount(page))
>  			goto isolate_fail;
>
> +		/*
> +		 * Only allow to migrate anonymous pages in GFP_NOFS context
> +		 * because those do not depend on fs locks.
> +		 */
> +		if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
> +			goto isolate_fail;

Unless page can acquire a page_mapping between this check and migration, 
I don't see a problem with allowing this.

But make sure you don't break kcompactd and manual compaction from 
/proc, as they don't currently set cc->gfp_mask. Looks like until now it 
was only used to determine direct compactor's migratetype which is 
irrelevant in those contexts.

> +
>  		/* If we already hold the lock, we can skip some rechecking */
>  		if (!locked) {
>  			locked = compact_trylock_irqsave(zone_lru_lock(zone),
> @@ -1696,14 +1703,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  		unsigned int alloc_flags, const struct alloc_context *ac,
>  		enum compact_priority prio)
>  {
> -	int may_enter_fs = gfp_mask & __GFP_FS;
>  	int may_perform_io = gfp_mask & __GFP_IO;
>  	struct zoneref *z;
>  	struct zone *zone;
>  	enum compact_result rc = COMPACT_SKIPPED;
>
> -	/* Check if the GFP flags allow compaction */
> -	if (!may_enter_fs || !may_perform_io)
> +	/*
> +	 * Check if the GFP flags allow compaction - GFP_NOIO is really
> +	 * tricky context because the migration might require IO and
> +	 */
> +	if (!may_perform_io)
>  		return COMPACT_SKIPPED;
>
>  	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, prio);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
