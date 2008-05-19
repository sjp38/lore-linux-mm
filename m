Subject: Re: [PATCH] Fix to return wrong pointer in slob
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <48317CA8.1080700@gmail.com>
References: <48317CA8.1080700@gmail.com>
Content-Type: text/plain
Date: Mon, 19 May 2008 12:40:37 -0500
Message-Id: <1211218837.18026.116.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-19 at 22:12 +0900, MinChan Kim wrote:
> Although slob_alloc return NULL, __kmalloc_node returns NULL + align.
> Because align always can be changed, it is very hard for debugging
> problem of no page if it don't return NULL.
> 
> We have to return NULL in case of no page.
> 
> Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
> ---
>  mm/slob.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/slob.c b/mm/slob.c
> index 6038cba..258d76d 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -469,9 +469,12 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>  			return ZERO_SIZE_PTR;
>  
>  		m = slob_alloc(size + align, gfp, align, node);
> -		if (m)
> -			*m = size;
> -		return (void *)m + align;
> +		if (!m)
> +			return NULL;
> +		else {
> +			*m = size; 
> +			return (void *)m + align;
> +		}

This looks good, but I would remove the 'else {' and '}' here. It's nice
to have the 'normal path' minimally indented.

Otherwise,

Acked-by: Matt Mackall <mpm@selenic.com>

[cc:ed to Pekka, who manages the allocator tree]

>  	} else {
>  		void *ret;
>  
-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
