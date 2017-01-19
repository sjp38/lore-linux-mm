Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 193056B0298
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 06:51:21 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id yr2so7878051wjc.4
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:51:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si6185995wmb.167.2017.01.19.03.51.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 03:51:19 -0800 (PST)
Date: Thu, 19 Jan 2017 12:51:14 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 1/5] mm/vmstat: retrieve suitable free pageblock
 information just once
Message-ID: <20170119115113.GQ30786@dhcp22.suse.cz>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri 13-01-17 16:14:29, Joonsoo Kim wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> It's inefficient to retrieve buddy information for fragmentation index
> calculation on every order. By using some stack memory, we could retrieve
> it once and reuse it to compute all the required values. MAX_ORDER is
> usually small enough so there is no big risk about stack overflow.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/vmstat.c | 25 ++++++++++++-------------
>  1 file changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7c28df3..e1ca5eb 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -821,7 +821,7 @@ unsigned long node_page_state(struct pglist_data *pgdat,
>  struct contig_page_info {
>  	unsigned long free_pages;
>  	unsigned long free_blocks_total;
> -	unsigned long free_blocks_suitable;
> +	unsigned long free_blocks_order[MAX_ORDER];
>  };

I haven't looked at the rest of the patch becaust this has already
raised a red flag.  This will increase the size of the structure quite a
bit and from a quick look at least compaction_suitable->fragmentation_index
will call with this allocated on the stack and this can be pretty deep
on the call chain already.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
