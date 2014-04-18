Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6436B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:03:13 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1863598eek.9
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:03:12 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s46si41326989eeg.75.2014.04.18.11.03.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:03:11 -0700 (PDT)
Date: Fri, 18 Apr 2014 14:03:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/16] mm: page_alloc: Calculate classzone_idx once from
 the zonelist ref
Message-ID: <20140418180309.GC29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:33PM +0100, Mel Gorman wrote:
> @@ -2463,7 +2462,7 @@ static inline struct page *
>  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
>  	nodemask_t *nodemask, struct zone *preferred_zone,
> -	int migratetype)
> +	int classzone_idx, int migratetype)
>  {
>  	const gfp_t wait = gfp_mask & __GFP_WAIT;
>  	struct page *page = NULL;

There is another potential update of preferred_zone in this function
after which the classzone_idx should probably be refreshed:

	/*
	 * Find the true preferred zone if the allocation is unconstrained by
	 * cpusets.
	 */
	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask)
		first_zones_zonelist(zonelist, high_zoneidx, NULL,
					&preferred_zone);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
