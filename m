Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 556926B03BA
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:30:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so8478837wms.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 00:30:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v130si1578061wmf.126.2016.11.18.00.30.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 00:30:43 -0800 (PST)
Date: Fri, 18 Nov 2016 09:30:42 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 9/9] mm: workingset: restore refault tracking for
 single-page files
Message-ID: <20161118083042.GI18676@quack2.suse.cz>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
 <20161117193244.GF23430@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117193244.GF23430@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 17-11-16 14:32:44, Johannes Weiner wrote:
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

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 7d92032277ff..ae7b6992aded 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -164,14 +164,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  		__radix_tree_lookup(&mapping->page_tree, page->index + i,
>  				    &node, &slot);
>  
> -		if (!node) {
> -			VM_BUG_ON_PAGE(nr != 1, page);
> -			/*
> -			 * We need a node to properly account shadow
> -			 * entries. Don't plant any without. XXX
> -			 */
> -			shadow = NULL;
> -		}
> +		VM_BUG_ON_PAGE(!node && nr != 1, page);
>  
>  		radix_tree_clear_tags(&mapping->page_tree, node, slot);
>  		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
