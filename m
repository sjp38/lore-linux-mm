Subject: Re: [patch 2/9] Store max number of objects in the page struct.
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20080317230528.279983034@sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230528.279983034@sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Wed, 19 Mar 2008 17:09:17 +0800
Message-Id: <1205917757.10318.1.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 16:05 -0700, Christoph Lameter wrote:
> plain text document attachment
> (0002-Store-number-of-objects-in-page-struct.patch)
> Split the inuse field up to be able to store the number of objects in this
> page in the page struct as well. Necessary if we want to have pages of
> various orders for a slab. Also avoids touching struct kmem_cache cachelines in
> __slab_alloc().
> 
> Update diagnostic code to check the number of objects and make sure that
> the number of objects always stays within the bounds of a 16 bit unsigned
> integer.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  include/linux/mm_types.h |    5 +++-
>  mm/slub.c                |   54 +++++++++++++++++++++++++++++------------------
>  2 files changed, 38 insertions(+), 21 deletions(-)
> 
> @@ -1487,7 +1498,7 @@ load_freelist:
>  		goto debug;
>  
>  	c->freelist = object[c->offset];
> -	c->page->inuse = s->objects;
> +	c->page->inuse = c->page->objects;
>  	c->page->freelist = NULL;
>  	c->node = page_to_nid(c->page);
>  unlock_out:
> @@ -1786,6 +1797,9 @@ static inline int slab_order(int size, i
>  	int rem;
>  	int min_order = slub_min_order;
>  
> +	if ((PAGE_SIZE << min_order) / size > 65535)
> +		return get_order(size * 65535) - 1;
Is it better to define something like USHORT_MAX to replace 65535?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
