Date: Thu, 30 Nov 2006 17:31:29 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
Message-Id: <20061130173129.4ebccaa2.akpm@osdl.org>
In-Reply-To: <20061130170746.GA11363@skynet.ie>
References: <20061130170746.GA11363@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Nov 2006 17:07:46 +0000
mel@skynet.ie (Mel Gorman) wrote:

> Am reporting this patch after there were no further comments on the last
> version.

Am not sure what to do with it - nothing actually uses __GFP_MOVABLE.

> It is often known at allocation time when a page may be migrated or not.

"often", yes.

> This
> page adds a flag called __GFP_MOVABLE and GFP_HIGH_MOVABLE. Allocations using
> the __GFP_MOVABLE can be either migrated using the page migration mechanism
> or reclaimed by syncing with backing storage and discarding.
> 
> Additional credit goes to Christoph Lameter and Linus Torvalds for shaping
> the concept. Credit to Hugh Dickens for catching issues with shmem swap
> vector and ramfs allocations.
>
> ...
> 
> @@ -65,7 +65,7 @@ static inline void clear_user_highpage(s
>  static inline struct page *
>  alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
>  {
> -	struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, vaddr);
> +	struct page *page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, vaddr);
>  
>  	if (page)
>  		clear_user_highpage(page, vaddr);

But this change is presumptuous.  alloc_zeroed_user_highpage() doesn't know
that its caller is going to use the page for moveable purposes.  (Ditto lots
of other places in this patch).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
