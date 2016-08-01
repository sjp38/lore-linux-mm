Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A37F6B0263
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:15:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so84467430wml.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:15:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i11si16466985wmh.67.2016.08.01.08.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 08:15:30 -0700 (PDT)
Date: Mon, 1 Aug 2016 11:15:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: fix memcg-aware shrinkers not called on
 global reclaim
Message-ID: <20160801151508.GB7603@cmpxchg.org>
References: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 01, 2016 at 04:03:10PM +0300, Vladimir Davydov wrote:
> We must call shrink_slab() for each memory cgroup on both global and
> memcg reclaim in shrink_node_memcg(). Commit d71df22b55099 accidentally
> changed that so that now shrink_slab() is only called with memcg != NULL
> on memcg reclaim. As a result, memcg-aware shrinkers (including
> dentry/inode) are never invoked on global reclaim. Fix that.
> 
> Fixes: d71df22b55099 ("mm, vmscan: begin reclaiming pages on a per-node basis")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Ouch, I missed that in the review. The change looked so obviously
correct, but the shrink_slab() interface is a little deceiving. It
would be great if shrink_slab() could handle root_mem_cgroup/NULL and
then we'd always call it from inside the loop. But AFAICS we need the
global call to get the cumulative scanned/lru_pages ratio from all of
the memcgs reclaimed... grr. Oh well.

This fix looks correct to me, anyway.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
