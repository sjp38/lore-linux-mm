Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 31B656B00DF
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 08:06:38 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id z12so373886wgg.5
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 05:06:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sd12si17707844wjb.172.2014.02.25.05.06.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 05:06:36 -0800 (PST)
Date: Tue, 25 Feb 2014 13:06:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: exclude memory less nodes from zone_reclaim
Message-ID: <20140225130632.GR6732@suse.de>
References: <1392889904-18019-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1392889904-18019-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 20, 2014 at 10:51:44AM +0100, Michal Hocko wrote:
> We had a report about strange OOM killer strikes on a PPC machine
> although there was a lot of swap free and a tons of anonymous memory
> which could be swapped out. In the end it turned out that the OOM was
> a side effect of zone reclaim which wasn't doesn't unmap and swapp out
> and so the system was pushed to the OOM. Although this sounds like a bug
> somewhere in the kswapd vs. zone reclaim vs. direct reclaim interaction
> numactl on the said hardware suggests that the zone reclaim should
> have been set in the first place:
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
> node 0 size: 0 MB
> node 0 free: 0 MB
> node 2 cpus:
> node 2 size: 7168 MB
> node 2 free: 6019 MB
> node distances:
> node   0   2
> 0:  10  40
> 2:  40  10
> 
> So all the CPUs are associated with Node0 which doesn't have any memory
> while Node2 contains all the available memory. Node distances cause an
> automatic zone_reclaim_mode enabling.
> 
> Zone reclaim is intended to keep the allocations local but this doesn't
> make any sense on the memory less nodes. So let's exclude such nodes
> for init_zone_allows_reclaim which evaluates zone reclaim behavior and
> suitable reclaim_nodes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> Tested-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

FWIW, I do expect that memory hot-adding memory later will cause problems
because the node is only initialised if it was previously considered offline
but Nishanth is making changes in that area and it would be easier to fix
it up in that context.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
