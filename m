Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1E416B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 07:28:33 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so63052879wmu.1
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 04:28:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sp13si57855411wjb.45.2016.12.29.04.28.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Dec 2016 04:28:32 -0800 (PST)
Date: Thu, 29 Dec 2016 13:28:29 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm: fix remote numa hits statistics
Message-ID: <20161229122829.GI29208@dhcp22.suse.cz>
References: <20161221075711.GF16502@dhcp22.suse.cz>
 <20161221080653.29437-1-mhocko@kernel.org>
 <20161229114601.wuadp2l6xwzdxv6s@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229114601.wuadp2l6xwzdxv6s@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Jia He <hejianet@gmail.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 29-12-16 11:46:01, Mel Gorman wrote:
> On Wed, Dec 21, 2016 at 09:06:52AM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Jia He has noticed that b9f00e147f27 ("mm, page_alloc: reduce branches
> > in zone_statistics") has an unintentional side effect that remote node
> > allocation requests are accounted as NUMA_MISS rathat than NUMA_HIT and
> > NUMA_OTHER if such a request doesn't use __GFP_OTHER_NODE. There are
> > many of these potentially because the flag is used very rarely while
> > we have many users of __alloc_pages_node.
> > 
> > Fix this by simply ignoring __GFP_OTHER_NODE (it can be removed in a
> > follow up patch) and treat all allocations that were satisfied from the
> > preferred zone's node as NUMA_HITS because this is the same node we
> > requested the allocation from in most cases. If this is not the local
> > node then we just account it as NUMA_OTHER rather than NUMA_LOCAL.
> > 
> > One downsize would be that an allocation request for a node which is
> > outside of the mempolicy nodemask would be reported as a hit which is a
> > bit weird but that was the case before b9f00e147f27 already.
> > 
> > Reported-by: Jia He <hejianet@gmail.com>
> > Fixes: b9f00e147f27 ("mm, page_alloc: reduce branches in zone_statistics")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> For both patches;
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks! I will give it a week for others to get back to it after holiday
and then resubmit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
