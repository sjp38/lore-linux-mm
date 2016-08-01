Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8191E6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 13:14:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so79067908lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 10:14:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x5si32324317wjv.206.2016.08.01.10.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 10:14:44 -0700 (PDT)
Date: Mon, 1 Aug 2016 13:14:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-ID: <20160801171435.GA8724@cmpxchg.org>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
 <20160801152409.GC7603@cmpxchg.org>
 <20160801160605.GA13263@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801160605.GA13263@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 01, 2016 at 07:06:05PM +0300, Vladimir Davydov wrote:
> On Mon, Aug 01, 2016 at 11:24:09AM -0400, Johannes Weiner wrote:
> > On Mon, Aug 01, 2016 at 04:13:08PM +0300, Vladimir Davydov wrote:
> > > @@ -351,6 +351,12 @@ static int __radix_tree_preload(gfp_t gfp_mask, int nr)
> > >  	struct radix_tree_node *node;
> > >  	int ret = -ENOMEM;
> > >  
> > > +	/*
> > > +	 * Nodes preloaded by one cgroup can be be used by another cgroup, so
> > > +	 * they should never be accounted to any particular memory cgroup.
> > > +	 */
> > > +	gfp_mask &= ~__GFP_ACCOUNT;
> > 
> > But *all* page cache radix tree nodes are allocated from inside the
> > preload code, since the tree insertions need mapping->tree_lock. So
> > this would effectively disable accounting of the biggest radix tree
> > consumer in the kernel, no?
> 
> No, that's not how accounting of radix tree nodes works. We never
> account preloaded nodes, because this could result in a node accounted
> to one cgroup used by an unrelated cgroup. Instead we always try to
> kmalloc a node on insertion falling back on preloads only if kmalloc
> fails - see commit 58e698af4c634 ("radix-tree: account radix_tree_node
> to memory cgroup").

You are right, I forgot we are doing this. The patch makes sense then.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
