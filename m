Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6AA6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 20:20:10 -0500 (EST)
Received: by padbj1 with SMTP id bj1so1011815pad.5
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:20:10 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id tw8si19599120pbc.2.2015.02.24.17.20.08
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 17:20:09 -0800 (PST)
Date: Wed, 25 Feb 2015 10:20:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/memcontrol: fix NULL pointer dereference when
 use_hierarchy is 0
Message-ID: <20150225012013.GC16796@js1304-P5Q-DELUXE>
References: <1424150699-5395-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150217083327.GA32017@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150217083327.GA32017@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 17, 2015 at 09:33:27AM +0100, Michal Hocko wrote:
> On Tue 17-02-15 14:24:59, Joonsoo Kim wrote:
> > It can be possible to return NULL in parent_mem_cgroup()
> > if use_hierarchy is 0.
> 
> This alone is not sufficient because the low limit is present only in
> the unified hierarchy API and there is no use_hierarchy there. The
> primary issue here is that the memcg has 0 usage so the previous
> check for usage will not stop us. And that is bug IMO.
> 
> I think that the following patch would be more correct from semantic
> POV:
> ---
> >From f5d74671d30e44c50b45b4464c92f536f1dbdff6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 17 Feb 2015 08:02:12 +0100
> Subject: [PATCH] memcg: fix low limit calculation
> 
> A memcg is considered low limited even when the current usage is equal
> to the low limit. This leads to interesting side effects e.g.
> groups/hierarchies with no memory accounted are considered protected and
> so the reclaim will emit MEMCG_LOW event when encountering them.
> 
> Another and much bigger issue was reported by Joonsoo Kim. He has hit a
> NULL ptr dereference with the legacy cgroup API which even doesn't have
> low limit exposed. The limit is 0 by default but the initial check fails
> for memcg with 0 consumption and parent_mem_cgroup() would return NULL
> if use_hierarchy is 0 and so page_counter_read would try to dereference
> NULL.
> 
> I suppose that the current implementation is just an overlook because
> the documentation in Documentation/cgroups/unified-hierarchy.txt says:
> "
> The memory.low boundary on the other hand is a top-down allocated
> reserve.  A cgroup enjoys reclaim protection when it and all its
> ancestors are below their low boundaries
> "
> 
> Fix the usage and the low limit comparision in mem_cgroup_low accordingly.
> 
> Fixes: 241994ed8649 (mm: memcontrol: default hierarchy interface for memory)
> Reported-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Good! This fixes my issue.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
