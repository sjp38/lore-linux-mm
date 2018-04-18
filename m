Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC1D6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 23:08:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q22so222696pfh.20
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 20:08:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m13si245912pgq.398.2018.04.17.20.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 20:08:26 -0700 (PDT)
Date: Tue, 17 Apr 2018 20:08:24 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
Message-ID: <20180418030824.GA7320@bombadil.infradead.org>
References: <20180418022912.248417-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418022912.248417-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, Apr 18, 2018 at 11:29:12AM +0900, Minchan Kim wrote:
> If there are heavy memory pressure, page allocation with __GFP_NOWAIT
> fails easily although it's order-0 request.
> I got below warning 9 times for normal boot.
> 
> [   17.072747] c0 0      <snip >: page allocation failure: order:0, mode:0x2200000(GFP_NOWAIT|__GFP_NOTRACK)
> 
> Let's not make user scared.
>  
> -	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
> +	cw = kmalloc(sizeof(*cw), GFP_NOWAIT | __GFP_NOWARN);
>  	if (!cw)

Not arguing against this patch.  But how many places do we want to use
GFP_NOWAIT without __GFP_NOWARN?  Not many, and the few which do do this
seem like they simply haven't added it yet.  Maybe this would be a good idea?

-#define GFP_NOWAIT      (__GFP_KSWAPD_RECLAIM)
+#define GFP_NOWAIT      (__GFP_KSWAPD_RECLAIM | __GFP_NOWARN)
