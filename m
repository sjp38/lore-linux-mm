Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90FCF6B002C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:43:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z15so8038072wrh.10
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:43:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q3si457114edd.300.2018.04.10.05.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 05:43:28 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:44:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: workingset: fix NULL ptr dereference
Message-ID: <20180410124459.GB6334@cmpxchg.org>
References: <20180409015815.235943-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409015815.235943-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Chris Fries <cfries@google.com>

On Mon, Apr 09, 2018 at 10:58:15AM +0900, Minchan Kim wrote:
> @@ -428,6 +428,7 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
>  		ret->exceptional = exceptional;
>  		ret->parent = parent;
>  		ret->root = root;
> +		INIT_LIST_HEAD(&ret->private_list);
>  	}
>  	return ret;
>  }
> @@ -2234,7 +2235,6 @@ radix_tree_node_ctor(void *arg)
>  	struct radix_tree_node *node = arg;
>  
>  	memset(node, 0, sizeof(*node));
> -	INIT_LIST_HEAD(&node->private_list);
>  }

I have to NAK this.

The slab constructor protocol requires objects to be in their initial
allocation state at the time of being freed. If this isn't the case
here, we need to fix whoever isn't doing this, not the alloc site.
