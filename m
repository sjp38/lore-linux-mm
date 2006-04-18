Date: Wed, 19 Apr 2006 09:20:00 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH] slab: cleanup kmem_getpages
Message-ID: <20060418232000.GL2732@melbourne.sgi.com>
References: <20060414183618.GA21144@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060414183618.GA21144@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 14, 2006 at 08:36:18PM +0200, Christoph Hellwig wrote:
> The last ifdef addition hit the ugliness treshold on this functions, so:
> 
>  - rename the varibale i to nr_pages so it's somewhat descriptive
>  - remove the addr variable and do the page_address call at the very end
>  - instead of ifdef'ing the whole alloc_pages_node call just make the
>    __GFP_COMP addition to flags conditional
>  - rewrite the __GFP_COMP comment to make sense
....
> +	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
>  	if (!page)
>  		return NULL;
> -	addr = page_address(page);
.....
> +	while (nr_pages--) {
>  		__SetPageSlab(page);
>  		page++;
>  	}
> -	return addr;
> +	return page_address(page);

I think that's a bug - you return the address of the page after the
allocation, not the first page of the allocation.

Cheers,

Dave.
-- 
Dave Chinner
R&D Software Enginner
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
