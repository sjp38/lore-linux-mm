Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45F786B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:25:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so5365527wmh.9
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:25:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j71si4031103wmg.264.2017.07.24.02.25.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 02:25:50 -0700 (PDT)
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
References: <20170721143915.14161-1-mhocko@kernel.org>
 <20170721143915.14161-7-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <994c1d72-bc57-1378-586d-fdfce770e53e@suse.cz>
Date: Mon, 24 Jul 2017 11:25:47 +0200
MIME-Version: 1.0
In-Reply-To: <20170721143915.14161-7-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/21/2017 04:39 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> build_zonelists gradually builds zonelists from the nearest to the most
> distant node. As we do not know how many populated zones we will have in
> each node we rely on the _zoneref to terminate initialized part of the
> zonelist by a NULL zone. While this is functionally correct it is quite
> suboptimal because we cannot allow updaters to race with zonelists
> users because they could see an empty zonelist and fail the allocation
> or hit the OOM killer in the worst case.
> 
> We can do much better, though. We can store the node ordering into an
> already existing node_order array and then give this array to
> build_zonelists_in_node_order and do the whole initialization at once.
> zonelists consumers still might see halfway initialized state but that
> should be much more tolerateable because the list will not be empty and
> they would either see some zone twice or skip over some zone(s) in the
> worst case which shouldn't lead to immediate failures.
> 
> While at it let's simplify build_zonelists_node which is rather
> confusing now. It gets an index into the zoneref array and returns
> the updated index for the next iteration. Let's rename the function
> to build_zonerefs_node to better reflect its purpose and give it
> zoneref array to update. The function doesn't the index anymore. It
> just returns the number of added zones so that the caller can advance
> the zonered array start for the next update.
> 
> This patch alone doesn't introduce any functional change yet, though, it
> is merely a preparatory work for later changes.
> 
> Changes since v1
> - build_zonelists_node -> build_zonerefs_node and operate directly on
>   zonerefs array rather than play tricks with index into the array.
> - give build_zonelists_in_node_order nr_nodes to not iterate over all
>   MAX_NUMNODES as per Mel
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
