Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF2D6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 01:18:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 127so778310363pfg.5
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 22:18:51 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id z128si4738440pfz.92.2017.01.10.22.18.48
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 22:18:50 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170110125552.4170-1-mhocko@kernel.org> <20170110125552.4170-2-mhocko@kernel.org>
In-Reply-To: <20170110125552.4170-2-mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in get_scan_count
Date: Wed, 11 Jan 2017 14:18:33 +0800
Message-ID: <020201d26bd2$8958ad40$9c0a07c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Michal Hocko' <mhocko@suse.com>



On Tuesday, January 10, 2017 8:56 PM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> get_scan_count considers the whole node LRU size when
> - doing SCAN_FILE due to many page cache inactive pages
> - calculating the number of pages to scan
> 
> in both cases this might lead to unexpected behavior especially on 32b
> systems where we can expect lowmem memory pressure very often.
> 
> A large highmem zone can easily distort SCAN_FILE heuristic because
> there might be only few file pages from the eligible zones on the node
> lru and we would still enforce file lru scanning which can lead to
> trashing while we could still scan anonymous pages.
> 
> The later use of lruvec_lru_size can be problematic as well. Especially
> when there are not many pages from the eligible zones. We would have to
> skip over many pages to find anything to reclaim but shrink_node_memcg
> would only reduce the remaining number to scan by SWAP_CLUSTER_MAX
> at maximum. Therefore we can end up going over a large LRU many times
> without actually having chance to reclaim much if anything at all. The
> closer we are out of memory on lowmem zone the worse the problem will
> be.
> 
> Changes since v1
> - s@lruvec_lru_size_zone_idx@lruvec_lru_size_eligibe_zones@
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
