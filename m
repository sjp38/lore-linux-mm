Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C01696B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 12:06:14 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d65so22790174ith.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 09:06:14 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0093.outbound.protection.outlook.com. [104.47.1.93])
        by mx.google.com with ESMTPS id e128si20212380oib.108.2016.08.01.09.06.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 09:06:13 -0700 (PDT)
Date: Mon, 1 Aug 2016 19:06:05 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-ID: <20160801160605.GA13263@esperanza>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
 <20160801152409.GC7603@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160801152409.GC7603@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 01, 2016 at 11:24:09AM -0400, Johannes Weiner wrote:
> On Mon, Aug 01, 2016 at 04:13:08PM +0300, Vladimir Davydov wrote:
> > Radix trees may be used not only for storing page cache pages, so
> > unconditionally accounting radix tree nodes to the current memory cgroup
> > is bad: if a radix tree node is used for storing data shared among
> > different cgroups we risk pinning dead memory cgroups forever. So let's
> > only account radix tree nodes if it was explicitly requested by passing
> > __GFP_ACCOUNT to INIT_RADIX_TREE. Currently, we only want to account
> > page cache entries, so mark mapping->page_tree so.
> 
> Is this a theoretical fix, or did you actually run into problems? I
> wouldn't expect any other radix tree node consumer in the kernel to
> come anywhere close to the page cache, so I wonder why it matters.

There are radix trees used for storing kernel data for different
cgroups, e.g. bdi->cgwb_tree. Nodes of such trees are shared among
different cgroups, so accounting a node to a particular memory cgroup
will pin the cgroup until all users of the node are gone which may never
happen. Although this can only result in slightly increased memory
consumption due to dangling offline memory cgroups and their kmem
caches, we'd better avoid it whenever possible. BTW this was one of the
arguments for switching to the white-list kmem accounting policy.

> 
> > @@ -351,6 +351,12 @@ static int __radix_tree_preload(gfp_t gfp_mask, int nr)
> >  	struct radix_tree_node *node;
> >  	int ret = -ENOMEM;
> >  
> > +	/*
> > +	 * Nodes preloaded by one cgroup can be be used by another cgroup, so
> > +	 * they should never be accounted to any particular memory cgroup.
> > +	 */
> > +	gfp_mask &= ~__GFP_ACCOUNT;
> 
> But *all* page cache radix tree nodes are allocated from inside the
> preload code, since the tree insertions need mapping->tree_lock. So
> this would effectively disable accounting of the biggest radix tree
> consumer in the kernel, no?

No, that's not how accounting of radix tree nodes works. We never
account preloaded nodes, because this could result in a node accounted
to one cgroup used by an unrelated cgroup. Instead we always try to
kmalloc a node on insertion falling back on preloads only if kmalloc
fails - see commit 58e698af4c634 ("radix-tree: account radix_tree_node
to memory cgroup").

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
