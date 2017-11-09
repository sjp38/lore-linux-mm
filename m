Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8324440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:32:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b9so3570169wmh.5
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:32:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si1181918edk.106.2017.11.09.02.32.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:32:53 -0800 (PST)
Date: Thu, 9 Nov 2017 11:32:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/4] writeback: allow for dirty metadata accounting
Message-ID: <20171109103246.GB9263@quack2.suse.cz>
References: <1510167660-26196-1-git-send-email-josef@toxicpanda.com>
 <1510167660-26196-2-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510167660-26196-2-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed 08-11-17 14:00:58, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Provide a mechanism for file systems to indicate how much dirty metadata they
> are holding.  This introduces a few things
> 
> 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> 2) WB stat for dirty metadata.  This way we know if we need to try and call into
> the file system to write out metadata.  This could potentially be used in the
> future to make balancing of dirty pages smarter.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
...
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 13d711dd8776..0281abd62e87 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3827,7 +3827,8 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
>  
>  	/* If we can't clean pages, remove dirty pages from consideration */
>  	if (!(node_reclaim_mode & RECLAIM_WRITE))
> -		delta += node_page_state(pgdat, NR_FILE_DIRTY);
> +		delta += node_page_state(pgdat, NR_FILE_DIRTY) +
> +			node_page_state(pgdat, NR_METADATA_DIRTY);
>  
>  	/* Watch for any possible underflows due to delta */
>  	if (unlikely(delta > nr_pagecache_reclaimable))

Do you expect your metadata pages to be accounted in NR_FILE_PAGES?
Otherwise this doesn't make sense. And even if they would, this function is
about kswapd / direct page reclaim and I don't think you've added smarts
there to writeout metadata. So if your metadata pages are going to show up
in NR_FILE_PAGES, you need to subtract NR_METADATA_DIRTY from reclaimable
pages always. It would be good to see btrfs counterpart to these patches so
that we can answer questions like this easily...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
