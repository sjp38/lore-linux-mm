Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id CCF2C9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 09:24:39 -0400 (EDT)
Received: by lbqc9 with SMTP id c9so52339240lbq.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 06:24:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cx3si13964181wib.115.2015.08.03.06.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 06:24:38 -0700 (PDT)
Date: Mon, 3 Aug 2015 09:23:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm: make workingset detection logic memcg aware
Message-ID: <20150803132358.GA18399@cmpxchg.org>
References: <cover.1438599199.git.vdavydov@parallels.com>
 <9662034e14549b9e1445684f674063ce8b092cb0.1438599199.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9662034e14549b9e1445684f674063ce8b092cb0.1438599199.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 03, 2015 at 03:04:22PM +0300, Vladimir Davydov wrote:
> @@ -179,8 +180,9 @@ static void unpack_shadow(void *shadow,
>  	eviction = entry;
>  
>  	*zone = NODE_DATA(nid)->node_zones + zid;
> +	*lruvec = mem_cgroup_page_lruvec(page, *zone);
>  
> -	refault = atomic_long_read(&(*zone)->inactive_age);
> +	refault = atomic_long_read(&(*lruvec)->inactive_age);
>  	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
>  			RADIX_TREE_EXCEPTIONAL_SHIFT);
>  	/*

You can not compare an eviction shadow entry from one lruvec with the
inactive age of another lruvec. The inactive ages are not related and
might differ significantly: memcgs are created ad hoc, memory hotplug,
page allocator fairness drift. In those cases the result will be pure
noise.

As much as I would like to see a simpler way, I am pessimistic that
there is a way around storing memcg ids in the shadow entries.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
