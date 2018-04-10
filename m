Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E202D6B0030
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:47:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j47so7958445wre.11
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:47:17 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c4si3175390edd.109.2018.04.10.05.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 05:47:16 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:48:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410124844.GC6334@cmpxchg.org>
References: <20180409015815.235943-1-minchan@kernel.org>
 <20180409024925.GA21889@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409024925.GA21889@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Christopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>

On Sun, Apr 08, 2018 at 07:49:25PM -0700, Matthew Wilcox wrote:
> @@ -2714,8 +2714,10 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
>  		stat(s, ALLOC_FASTPATH);
>  	}
>  
> -	if (unlikely(gfpflags & __GFP_ZERO) && object)
> -		memset(object, 0, s->object_size);
> +	if (unlikely(gfpflags & __GFP_ZERO) && object) {
> +		if (!WARN_ON_ONCE(s->ctor))
> +			memset(object, 0, s->object_size);
> +	}
>  
>  	slab_post_alloc_hook(s, gfpflags, 1, &object);

This looks like a useful check to have. But maybe behind DEBUG_VM?
