Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6A746B006E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 14:22:47 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so2055369wgh.22
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 11:22:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vm3si15887450wjc.3.2014.10.21.11.22.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 11:22:46 -0700 (PDT)
Date: Tue, 21 Oct 2014 14:22:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaimable check from soft
 reclaim
Message-ID: <20141021182239.GA24899@phnom.home.cmpxchg.org>
References: <1413897350-32553-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413897350-32553-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 21, 2014 at 05:15:50PM +0400, Vladimir Davydov wrote:
> mem_cgroup_reclaimable() checks whether a cgroup has reclaimable pages
> on *any* NUMA node. However, the only place where it's called is
> mem_cgroup_soft_reclaim(), which tries to reclaim memory from a
> *specific* zone. So the way how it's used is incorrect - it will return
> true even if the cgroup doesn't have pages on the zone we're scanning.
> 
> I think we can get rid of this check completely, because
> mem_cgroup_shrink_node_zone(), which is called by
> mem_cgroup_soft_reclaim() if mem_cgroup_reclaimable() returns true, is
> equivalent to shrink_lruvec(), which exits almost immediately if the
> lruvec passed to it is empty. So there's no need to optimize anything
> here. Besides, we don't have such a check in the general scan path
> (shrink_zone) either.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

How about this on top?

---
