Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id D1C6C6B00CD
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 09:57:14 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id p9so19836075lbv.28
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 06:57:14 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id cz7si24742341wib.46.2015.01.06.06.57.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 06:57:13 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id r20so6212444wiv.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 06:57:13 -0800 (PST)
Date: Tue, 6 Jan 2015 15:57:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 3/4] mm: reduce try_to_compact_pages parameters
Message-ID: <20150106145710.GD20860@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420478263-25207-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hmm, wait a minute

On Mon 05-01-15 18:17:42, Vlastimil Babka wrote:
[...]
> -unsigned long try_to_compact_pages(struct zonelist *zonelist,
> -			int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx)
> +unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
> +			int alloc_flags, const struct alloc_context *ac,
> +			enum migrate_mode mode, int *contended)
>  {
> -	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>  	int may_enter_fs = gfp_mask & __GFP_FS;
>  	int may_perform_io = gfp_mask & __GFP_IO;
>  	struct zoneref *z;

gfp_mask might change since the high_zoneidx was set up in the call
chain. I guess this shouldn't change to the gfp_zone output but it is
worth double checking.

> @@ -1365,8 +1363,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  		return COMPACT_SKIPPED;
>  
>  	/* Compact each zone in the list */
> -	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> -								nodemask) {
> +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> +								ac->nodemask) {
>  		int status;
>  		int zone_contended;
>  
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
