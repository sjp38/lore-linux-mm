Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 120AE6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:47:00 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p192so4133379wme.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:47:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i76si3019939wmh.87.2017.01.18.08.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 08:46:58 -0800 (PST)
Date: Wed, 18 Jan 2017 11:46:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm, vmscan: consider eligible zones in get_scan_count
Message-ID: <20170118164647.GB32495@cmpxchg.org>
References: <20170117103702.28542-1-mhocko@kernel.org>
 <20170117103702.28542-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117103702.28542-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 17, 2017 at 11:37:01AM +0100, Michal Hocko wrote:
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
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
