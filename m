Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD26E6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 09:31:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z20so1000733pfn.11
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:31:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p88si1217672pfk.134.2018.04.18.06.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 06:31:41 -0700 (PDT)
Date: Wed, 18 Apr 2018 06:31:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
Message-ID: <20180418133139.GB27475@bombadil.infradead.org>
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
> Let's not make user scared.

Actually, can you explain why it's OK if this fails?  As I understand this
code, we'll fail to create a kmalloc cache for this memcg.  What problems
does that cause?

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 448db08d97a0..671d07e73a3b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2200,7 +2200,7 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
>  {
>  	struct memcg_kmem_cache_create_work *cw;
>  
> -	cw = kmalloc(sizeof(*cw), GFP_NOWAIT);
> +	cw = kmalloc(sizeof(*cw), GFP_NOWAIT | __GFP_NOWARN);
>  	if (!cw)
>  		return;
>  
> -- 
> 2.17.0.484.g0c8726318c-goog
> 
