Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32F2A6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:42:32 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z67so109686377pgb.0
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:42:32 -0800 (PST)
Received: from out0-155.mail.aliyun.com (out0-155.mail.aliyun.com. [140.205.0.155])
        by mx.google.com with ESMTP id x136si4036428pgx.156.2017.01.16.19.42.30
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 19:42:31 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170116160123.GB30300@cmpxchg.org> <20170116193317.20390-1-mhocko@kernel.org> <20170116193317.20390-2-mhocko@kernel.org>
In-Reply-To: <20170116193317.20390-2-mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, vmscan: consider eligible zones in get_scan_count
Date: Tue, 17 Jan 2017 11:42:19 +0800
Message-ID: <033c01d27073$b4937bc0$1dba7340$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Johannes Weiner' <hannes@cmpxchg.org>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>


On Tuesday, January 17, 2017 3:33 AM Michal Hocko wrote: 
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
> Fix this by filtering out all the ineligible zones when calculating the
> lru size for both paths and consider only sc->reclaim_idx zones.
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
