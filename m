Message-ID: <46F13B6C.7020501@redhat.com>
Date: Wed, 19 Sep 2007 11:08:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 13/26] SLUB: Add SlabReclaimable() to avoid repeated reclaim
 attempts
References: <20070901014107.719506437@sgi.com> <20070901014222.303468369@sgi.com>
In-Reply-To: <20070901014222.303468369@sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Add a flag SlabReclaimable() that is set on slabs with a method
> that allows defrag/reclaim. Clear the flag if a reclaim action is not
> successful in reducing the number of objects in a slab. The reclaim
> flag is set again if all objects have been allocated from it.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  mm/slub.c |   42 ++++++++++++++++++++++++++++++++++++------
>  1 file changed, 36 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2007-08-28 20:10:37.000000000 -0700
> +++ linux-2.6/mm/slub.c	2007-08-28 20:10:47.000000000 -0700
> @@ -107,6 +107,8 @@
>  #define SLABDEBUG 0
>  #endif
>  
> +#define SLABRECLAIMABLE (1 << PG_dirty)
> +
>  static inline int SlabFrozen(struct page *page)
>  {
>  	return page->flags & FROZEN;
> @@ -137,6 +139,21 @@ static inline void ClearSlabDebug(struct
>  	page->flags &= ~SLABDEBUG;
>  }
>  
> +static inline int SlabReclaimable(struct page *page)
> +{
> +	return page->flags & SLABRECLAIMABLE;
> +}
> +
> +static inline void SetSlabReclaimable(struct page *page)
> +{
> +	page->flags |= SLABRECLAIMABLE;
> +}
> +
> +static inline void ClearSlabReclaimable(struct page *page)
> +{
> +	page->flags &= ~SLABRECLAIMABLE;
> +}

Why is it safe to not use the normal page flag bit operators
for these page flags operations?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
