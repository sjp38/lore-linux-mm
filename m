Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4C8A6B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:40:33 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l37so18374404wrc.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:40:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17si7020566wra.165.2017.03.01.07.40.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:40:32 -0800 (PST)
Date: Wed, 1 Mar 2017 16:40:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/9] mm: don't avoid high-priority reclaim on memcg limit
 reclaim
Message-ID: <20170301154027.GF11730@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 28-02-17 16:40:04, Johannes Weiner wrote:
> 246e87a93934 ("memcg: fix get_scan_count() for small targets") sought
> to avoid high reclaim priorities for memcg by forcing it to scan a
> minimum amount of pages when lru_pages >> priority yielded nothing.
> This was done at a time when reclaim decisions like dirty throttling
> were tied to the priority level.
> 
> Nowadays, the only meaningful thing still tied to priority dropping
> below DEF_PRIORITY - 2 is gating whether laptop_mode=1 is generally
> allowed to write. But that is from an era where direct reclaim was
> still allowed to call ->writepage, and kswapd nowadays avoids writes
> until it's scanned every clean page in the system. Potential changes
> to how quick sc->may_writepage could trigger are of little concern.
> 
> Remove the force_scan stuff, as well as the ugly multi-pass target
> calculation that it necessitated.

I _really_ like this, I hated the multi-pass part. One thig that I am
worried about and changelog doesn't mention it is what we are going to
do about small (<16MB) memcgs. On one hand they were already ignored in
the global reclaim so this is nothing really new but maybe we want to
preserve the behavior for the memcg reclaim at least which would reduce
side effect of this patch which is a great cleanup otherwise. Or at
least be explicit about this in the changelog.

Btw. why cannot we simply force scan at least SWAP_CLUSTER_MAX
unconditionally?

> +		/*
> +		 * If the cgroup's already been deleted, make sure to
> +		 * scrape out the remaining cache.
		   Also make sure that small memcgs will not get
		   unnoticed during the memcg reclaim

> +		 */
> +		if (!scan && !mem_cgroup_online(memcg))

		if (!scan && (!mem_cgroup_online(memcg) || !global_reclaim(sc)))

> +			scan = min(size, SWAP_CLUSTER_MAX);
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
