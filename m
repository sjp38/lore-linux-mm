Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4626B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 05:27:19 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r68so78560076wmd.0
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 02:27:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e140si15745254wmd.117.2016.11.08.02.27.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 02:27:18 -0800 (PST)
Date: Tue, 8 Nov 2016 11:27:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] mm: workingset: switch shadow entry tracking to
 radix tree exceptional counting
Message-ID: <20161108102716.GL32353@quack2.suse.cz>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-6-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107190741.3619-6-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 07-11-16 14:07:40, Johannes Weiner wrote:
> Currently, we track the shadow entries in the page cache in the upper
> bits of the radix_tree_node->count, behind the back of the radix tree
> implementation. Because the radix tree code has no awareness of them,
> we rely on random subtleties throughout the implementation (such as
> the node->count != 1 check in the shrinking code which is meant to
> exclude multi-entry nodes, but also happens to skip nodes with only
> one shadow entry since it's accounted in the upper bits). This is
> error prone and has, in fact, caused the bug fixed in d3798ae8c6f3
> ("mm: filemap: don't plant shadow entries without radix tree node").
> 
> To remove these subtleties, this patch moves shadow entry tracking
> from the upper bits of node->count to the existing counter for
> exceptional entries. node->count goes back to being a simple counter
> of valid entries in the tree node and can be shrunk to a single byte.

...

> diff --git a/mm/truncate.c b/mm/truncate.c
> index 6ae44571d4c7..d3ce5f261f47 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -53,7 +53,6 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	mapping->nrexceptional--;
>  	if (!node)
>  		goto unlock;
> -	workingset_node_shadows_dec(node);
>  	/*
>  	 * Don't track node without shadow entries.
>  	 *
> @@ -61,8 +60,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
>  	 * The list_empty() test is safe as node->private_list is
>  	 * protected by mapping->tree_lock.
>  	 */
> -	if (!workingset_node_shadows(node) &&
> -	    !list_empty(&node->private_list))
> +	if (!node->exceptional && !list_empty(&node->private_list))
>  		list_lru_del(&workingset_shadow_nodes,
>  				&node->private_list);
>  	__radix_tree_delete_node(&mapping->page_tree, node);

Is this really correct now? The radix tree implementation can move a single
exceptional entry at index 0 from a node into a direct pointer and free
the node while it is still in the LRU list. Or am I missing something?
To fix this I'd prefer to just have a callback from radix tree code when it
is freeing a node, rather that trying to second-guess its implementation in
the page-cache code...

Otherwise the patch looks good to me and I really like the simplification!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
