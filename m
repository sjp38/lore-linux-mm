Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0FA06B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 05:31:22 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so7633538wme.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 02:31:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fk2si15667493wjb.20.2016.11.08.02.31.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 02:31:21 -0800 (PST)
Date: Tue, 8 Nov 2016 11:31:19 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] mm: workingset: restore refault tracking for
 single-page files
Message-ID: <20161108103119.GM32353@quack2.suse.cz>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107190741.3619-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 07-11-16 14:07:41, Johannes Weiner wrote:
> Shadow entries in the page cache used to be accounted behind the radix
> tree implementation's back in the upper bits of node->count, and the
> radix tree code extending a single-entry tree with a shadow entry in
> root->rnode would corrupt that counter. As a result, we could not put
> shadow entries at index 0 if the tree didn't have any other entries,
> and that means no refault detection for any single-page file.
> 
> Now that the shadow entries are tracked natively in the radix tree's
> exceptional counter, this is no longer necessary. Extending and
> shrinking the tree from and to single entries in root->rnode now does
> the right thing when the entry is exceptional, remove that limitation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 438f0b54f8fd..55a3b136a527 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -178,19 +178,12 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  
>  		radix_tree_clear_tags(&mapping->page_tree, node, slot);
>  
> -		if (!node) {
> -			VM_BUG_ON_PAGE(nr != 1, page);
> -			/*
> -			 * We need a node to properly account shadow
> -			 * entries. Don't plant any without. XXX
> -			 */
> -			shadow = NULL;
> -		}
> -
>  		__radix_tree_replace(&mapping->page_tree, node, slot, shadow);
>  
> -		if (!node)
> +		if (!node) {
> +			VM_BUG_ON_PAGE(nr != 1, page);
>  			break;
> +		}
>  
>  		if (!shadow &&
>  		    __radix_tree_delete_node(&mapping->page_tree, node))
> -- 
> 2.10.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
