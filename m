Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 877A56B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:11:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so15886410wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:11:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o82si3969270wmd.89.2016.07.12.08.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 08:11:47 -0700 (PDT)
Date: Tue, 12 Jul 2016 11:11:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 19/34] mm: move most file-based accounting to the node
Message-ID: <20160712151139.GK5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-20-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-20-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:55AM +0100, Mel Gorman wrote:
> There are now a number of accounting oddities such as mapped file pages
> being accounted for on the node while the total number of file pages are
> accounted on the zone. This can be coped with to some extent but it's
> confusing so this patch moves the relevant file-based accounted. Due to
> throttling logic in the page allocator for reliable OOM detection, it is
> still necessary to track dirty and writeback pages on a per-zone basis.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

The straight conversion bits are mind-numbing to review, so I focussed
mostly on the NR_ZONE_WRITE_PENDING sites. They look good to me except
for the migration one:

> @@ -505,15 +505,17 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 * are mapped to swap space.
>  	 */
>  	if (newzone != oldzone) {
> -		__dec_zone_state(oldzone, NR_FILE_PAGES);
> -		__inc_zone_state(newzone, NR_FILE_PAGES);
> +		__dec_node_state(oldzone->zone_pgdat, NR_FILE_PAGES);
> +		__inc_node_state(newzone->zone_pgdat, NR_FILE_PAGES);
>  		if (PageSwapBacked(page) && !PageSwapCache(page)) {
> -			__dec_zone_state(oldzone, NR_SHMEM);
> -			__inc_zone_state(newzone, NR_SHMEM);
> +			__dec_node_state(oldzone->zone_pgdat, NR_SHMEM);
> +			__inc_node_state(newzone->zone_pgdat, NR_SHMEM);
>  		}
>  		if (dirty && mapping_cap_account_dirty(mapping)) {
> -			__dec_zone_state(oldzone, NR_FILE_DIRTY);
> -			__inc_zone_state(newzone, NR_FILE_DIRTY);
> +			__dec_node_state(oldzone->zone_pgdat, NR_FILE_DIRTY);
> +			__dec_zone_state(oldzone, NR_ZONE_WRITE_PENDING);
> +			__inc_node_state(newzone->zone_pgdat, NR_FILE_DIRTY);
> +			__dec_zone_state(newzone, NR_ZONE_WRITE_PENDING);

That double dec of NR_ZONE_WRITE_PENDING should be dec(old) -> inc(new).

Otherwise, the patch looks good to me.
Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
