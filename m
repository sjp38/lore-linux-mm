Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA446B0272
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:56:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so37566199wmy.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:56:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r193si13741773wmf.14.2016.10.24.11.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:56:07 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:56:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Stable 4.4 - NEEDS REVIEW - 2/3] mm: filemap: don't plant
 shadow entries without radix tree node
Message-ID: <20161024185600.GB28326@cmpxchg.org>
References: <20161024152605.11707-1-mhocko@kernel.org>
 <20161024152605.11707-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024152605.11707-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>

Hi Michal,

On Mon, Oct 24, 2016 at 05:26:04PM +0200, Michal Hocko wrote:
> @@ -155,44 +155,27 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  				   struct page *page, void *shadow)
>  {
>  	struct radix_tree_node *node;
> -	unsigned long index;
> -	unsigned int offset;
> -	unsigned int tag;
>  	void **slot;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  
>  	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
>  
> -	if (shadow) {
> -		mapping->nrshadows++;
> -		/*
> -		 * Make sure the nrshadows update is committed before
> -		 * the nrpages update so that final truncate racing
> -		 * with reclaim does not see both counters 0 at the
> -		 * same time and miss a shadow entry.
> -		 */
> -		smp_wmb();
> -	}
> -	mapping->nrpages--;
> +	radix_tree_clear_tags(&mapping->page_tree, node, slot);
>  
>  	if (!node) {
> -		/* Clear direct pointer tags in root node */
> -		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> -		radix_tree_replace_slot(slot, shadow);
> -		return;
> -	}

There is no need to include the refactoring of the tag clearing in the
stable backport. I already sent a simpler backport of this patch for
4.4 to Greg, attached here for reference:
