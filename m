Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2B46B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 00:16:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x32-v6so315528pld.16
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 21:16:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor85494pfl.63.2018.04.17.21.16.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 21:16:44 -0700 (PDT)
Date: Tue, 17 Apr 2018 21:16:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
In-Reply-To: <20180418030824.GA7320@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.21.1804172113400.114494@chino.kir.corp.google.com>
References: <20180418022912.248417-1-minchan@kernel.org> <20180418030824.GA7320@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue, 17 Apr 2018, Matthew Wilcox wrote:

> Not arguing against this patch.  But how many places do we want to use
> GFP_NOWAIT without __GFP_NOWARN?  Not many, and the few which do do this
> seem like they simply haven't added it yet.  Maybe this would be a good idea?
> 
> -#define GFP_NOWAIT      (__GFP_KSWAPD_RECLAIM)
> +#define GFP_NOWAIT      (__GFP_KSWAPD_RECLAIM | __GFP_NOWARN)
> 

I don't think that's a good idea, slab allocators use GFP_NOWAIT during 
init, for example, followed up with a BUG_ON() if it fails.  With an 
implicit __GFP_NOWARN we wouldn't be able to see the state of memory when 
it crashes (likely memory that wasn't freed to the allocator).  I think 
whether the allocation failure should trigger a warning is up to the 
caller.
