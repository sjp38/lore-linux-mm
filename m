Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18D826B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:51:46 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id d17so49972602wjx.5
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:51:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id is8si1776216wjb.233.2017.01.04.06.51.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 06:51:45 -0800 (PST)
Subject: Re: [PATCH 5/7] mm, vmscan: extract shrink_page_list reclaim counters
 into a struct
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-6-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <01c9e2c9-3a04-48cd-cf0e-265db33d1a24@suse.cz>
Date: Wed, 4 Jan 2017 15:51:43 +0100
MIME-Version: 1.0
In-Reply-To: <20170104101942.4860-6-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/04/2017 11:19 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> shrink_page_list returns quite some counters back to its caller. Extract
> the existing 5 into struct reclaim_stat because this makes the code
> easier to follow and also allows further counters to be returned.
> 
> While we are at it, make all of them unsigned rather than unsigned long
> as we do not really need full 64b for them (we never scan more than
> SWAP_CLUSTER_MAX pages at once). This should reduce some stack space.
> 
> This patch shouldn't introduce any functional change.

[...]

> @@ -1266,11 +1270,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  	list_splice(&ret_pages, page_list);
>  	count_vm_events(PGACTIVATE, pgactivate);
>  
> -	*ret_nr_dirty += nr_dirty;
> -	*ret_nr_congested += nr_congested;
> -	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
> -	*ret_nr_writeback += nr_writeback;
> -	*ret_nr_immediate += nr_immediate;
> +	if (stat) {
> +		stat->nr_dirty = nr_dirty;
> +		stat->nr_congested = nr_congested;
> +		stat->nr_unqueued_dirty = nr_unqueued_dirty;
> +		stat->nr_writeback = nr_writeback;
> +		stat->nr_immediate = nr_immediate;
> +	}

This change of '+=' to '=' raised my eybrows, but it seems both callers
don't care so this is indeed no functional change and potentially faster.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
