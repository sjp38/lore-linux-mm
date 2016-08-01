Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D76F6B0265
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 11:24:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so84564543wmz.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 08:24:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b4si31936864wjy.245.2016.08.01.08.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 08:24:14 -0700 (PDT)
Date: Mon, 1 Aug 2016 11:24:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-ID: <20160801152409.GC7603@cmpxchg.org>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 01, 2016 at 04:13:08PM +0300, Vladimir Davydov wrote:
> Radix trees may be used not only for storing page cache pages, so
> unconditionally accounting radix tree nodes to the current memory cgroup
> is bad: if a radix tree node is used for storing data shared among
> different cgroups we risk pinning dead memory cgroups forever. So let's
> only account radix tree nodes if it was explicitly requested by passing
> __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> page cache entries, so mark mapping->page_tree so.

Is this a theoretical fix, or did you actually run into problems? I
wouldn't expect any other radix tree node consumer in the kernel to
come anywhere close to the page cache, so I wonder why it matters.

> @@ -351,6 +351,12 @@ static int __radix_tree_preload(gfp_t gfp_mask, int nr)
>  	struct radix_tree_node *node;
>  	int ret = -ENOMEM;
>  
> +	/*
> +	 * Nodes preloaded by one cgroup can be be used by another cgroup, so
> +	 * they should never be accounted to any particular memory cgroup.
> +	 */
> +	gfp_mask &= ~__GFP_ACCOUNT;

But *all* page cache radix tree nodes are allocated from inside the
preload code, since the tree insertions need mapping->tree_lock. So
this would effectively disable accounting of the biggest radix tree
consumer in the kernel, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
