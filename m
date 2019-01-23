Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 111E78E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:02:59 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so803942edq.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 03:02:59 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y49si664017edd.80.2019.01.23.03.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 03:02:57 -0800 (PST)
Date: Wed, 23 Jan 2019 12:02:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: vmscan: do not iterate all mem cgroups for
 global direct reclaim
Message-ID: <20190123110254.GU4087@dhcp22.suse.cz>
References: <1548187782-108454-1-git-send-email-yang.shi@linux.alibaba.com>
 <fa1d9a1f-99c8-a4ae-da7f-ed90336497e9@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa1d9a1f-99c8-a4ae-da7f-ed90336497e9@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 23-01-19 13:28:03, Kirill Tkhai wrote:
> On 22.01.2019 23:09, Yang Shi wrote:
> > In current implementation, both kswapd and direct reclaim has to iterate
> > all mem cgroups.  It is not a problem before offline mem cgroups could
> > be iterated.  But, currently with iterating offline mem cgroups, it
> > could be very time consuming.  In our workloads, we saw over 400K mem
> > cgroups accumulated in some cases, only a few hundred are online memcgs.
> > Although kswapd could help out to reduce the number of memcgs, direct
> > reclaim still get hit with iterating a number of offline memcgs in some
> > cases.  We experienced the responsiveness problems due to this
> > occassionally.
> > 
> > Here just break the iteration once it reclaims enough pages as what
> > memcg direct reclaim does.  This may hurt the fairness among memcgs
> > since direct reclaim may awlays do reclaim from same memcgs.  But, it
> > sounds ok since direct reclaim just tries to reclaim SWAP_CLUSTER_MAX
> > pages and memcgs can be protected by min/low.
> 
> In case of we stop after SWAP_CLUSTER_MAX pages are reclaimed; it's possible
> the following situation. Memcgs, which are closest to root_mem_cgroup, will
> become empty, and you will have to iterate over empty memcg hierarchy long time,
> just to find a not empty memcg.
> 
> I'd suggest, we should not lose fairness. We may introduce
> mem_cgroup::last_reclaim_child parameter to save a child
> (or its id), where the last reclaim was interrupted. Then
> next reclaim should start from this child:

Why is not our reclaim_cookie based caching sufficient?

-- 
Michal Hocko
SUSE Labs
