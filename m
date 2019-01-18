Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3347E8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 08:51:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so4871803edm.18
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 05:51:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si4378990edo.295.2019.01.18.05.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 05:51:01 -0800 (PST)
Subject: Re: [PATCH 25/25] mm, compaction: Do not direct compact remote memory
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-26-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <84a7b23a-1cb7-b888-4245-6b1e829f472b@suse.cz>
Date: Fri, 18 Jan 2019 14:51:00 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-26-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> Remote compaction is expensive and possibly counter-productive. Locality
> is expected to often have better performance characteristics than remote
> high-order pages. For small allocations, it's expected that locality is
> generally required or fallbacks are possible. For larger allocations such
> as THP, they are forbidden at the time of writing but if __GFP_THISNODE
> is ever removed, then it would still be preferable to fallback to small
> local base pages over remote THP in the general case. kcompactd is still
> woken via kswapd so compaction happens eventually.
> 
> While this patch potentially has both positive and negative effects,
> it is best to avoid the possibility of remote compaction given the cost
> relative to any potential benefit.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Generally agree with the intent, but what if there's e.g. high-order (but not
costly) kernel allocation on behalf of user process on cpu belonging to a
movable node, where the only non-movable node is node 0. It will have to keep
reclaiming until a large enough page is formed, or wait for kcompactd?
So maybe do this only for costly orders?

Also I think compaction_zonelist_suitable() should be also updated, or we might
be promising the reclaim-compact loop e.g. that we will compact after enough
reclaim, but then we won't.

> ---
>  mm/compaction.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index ae70be023b21..cc17f0c01811 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -2348,6 +2348,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  			continue;
>  		}
>  
> +		/*
> +		 * Do not compact remote memory. It's expensive and high-order
> +		 * small allocations are expected to prefer or require local
> +		 * memory. Similarly, larger requests such as THP can fallback
> +		 * to base pages in preference to remote huge pages if
> +		 * __GFP_THISNODE is not specified
> +		 */
> +		if (zone_to_nid(zone) != zone_to_nid(ac->preferred_zoneref->zone))
> +			continue;
> +
>  		status = compact_zone_order(zone, order, gfp_mask, prio,
>  				alloc_flags, ac_classzone_idx(ac), capture);
>  		rc = max(status, rc);
> 
