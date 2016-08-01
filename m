Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A14FB6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:26:25 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w207so300236274oiw.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:26:25 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10104.outbound.protection.outlook.com. [40.107.1.104])
        by mx.google.com with ESMTPS id 30si19727143otb.226.2016.08.01.07.26.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:26:24 -0700 (PDT)
Date: Mon, 1 Aug 2016 17:26:15 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] memcg: put soft limit reclaim out of way if the excess
 tree is empty
Message-ID: <20160801142615.GC19395@esperanza>
References: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
 <20160801135757.GB19395@esperanza>
 <20160801141227.GI13544@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160801141227.GI13544@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 01, 2016 at 04:12:28PM +0200, Michal Hocko wrote:
...
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 1 Aug 2016 10:42:06 +0200
> Subject: [PATCH] memcg: put soft limit reclaim out of way if the excess tree
>  is empty
> 
> We've had a report about soft lockups caused by lock bouncing in the
> soft reclaim path:
> 
> [331404.849734] BUG: soft lockup - CPU#0 stuck for 22s! [kav4proxy-kavic:3128]
> [331404.849920] RIP: 0010:[<ffffffff81469798>]  [<ffffffff81469798>] _raw_spin_lock+0x18/0x20
> [331404.849997] Call Trace:
> [331404.850010]  [<ffffffff811557ea>] mem_cgroup_soft_limit_reclaim+0x25a/0x280
> [331404.850020]  [<ffffffff8111041d>] shrink_zones+0xed/0x200
> [331404.850027]  [<ffffffff81111a94>] do_try_to_free_pages+0x74/0x320
> [331404.850034]  [<ffffffff81112072>] try_to_free_pages+0x112/0x180
> [331404.850042]  [<ffffffff81104a6f>] __alloc_pages_slowpath+0x3ff/0x820
> [331404.850049]  [<ffffffff81105079>] __alloc_pages_nodemask+0x1e9/0x200
> [331404.850056]  [<ffffffff81141e01>] alloc_pages_vma+0xe1/0x290
> [331404.850064]  [<ffffffff8112402f>] do_wp_page+0x19f/0x840
> [331404.850071]  [<ffffffff811257cd>] handle_pte_fault+0x1cd/0x230
> [331404.850079]  [<ffffffff8146d3ed>] do_page_fault+0x1fd/0x4c0
> [331404.850087]  [<ffffffff81469ec5>] page_fault+0x25/0x30
> 
> There are no memcgs created so there cannot be any in the soft limit
> excess obviously:
> [...]
> memory  0       1       1
> 
> so all this just seems to be mem_cgroup_largest_soft_limit_node
> trying to get spin_lock_irq(&mctz->lock) just to find out that the soft
> limit excess tree is empty. This is just pointless waisting of cycles
> and cache line bouncing during heavy parallel reclaim on large machines.
> The particular machine wasn't very healthy and most probably suffering
> from a memory leak which just caused the memory reclaim to trash
> heavily. But bouncing on the lock certainly didn't help...
> 
> Introduce soft_limit_tree_empty which does the optimistic lockless check
> and bail out early if the tree is empty. This is theoretically racy but
> that shouldn't matter all that much. First of all soft limit is a best
> effort feature and it is slowly getting deprecated and its usage should
> be really scarce. Bouncing on a lock without a good reason is surely
> much bigger problem, especially on large CPU machines.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
