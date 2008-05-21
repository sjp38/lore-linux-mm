Message-ID: <48343884.7060708@cs.helsinki.fi>
Date: Wed, 21 May 2008 17:58:12 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
References: <20080520095935.GB18633@linux-sh.org>
In-Reply-To: <20080520095935.GB18633@linux-sh.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Pekka Enberg <penberg@cs.helsinki.fi>, David Howells <dhowells@redhat.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Not really sure if we came to a conclusion with the discussion.)

Paul Mundt wrote:
> diff --git a/mm/nommu.c b/mm/nommu.c
> index ef8c62c..3e11814 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -112,13 +112,7 @@ unsigned int kobjsize(const void *objp)
>  	if (!objp || (unsigned long)objp >= memory_end || !((page = virt_to_page(objp))))
>  		return 0;
>  
> -	if (PageSlab(page))
> -		return ksize(objp);
> -
> -	BUG_ON(page->index < 0);
> -	BUG_ON(page->index >= MAX_ORDER);
> -
> -	return (PAGE_SIZE << page->index);
> +	return ksize(objp);
>  }
>  
>  /*
> diff --git a/mm/slab.c b/mm/slab.c
> index 06236e4..7a012bb 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4472,10 +4472,16 @@ const struct seq_operations slabstats_op = {
>   */
>  size_t ksize(const void *objp)
>  {
> +	struct page *page;
> +
>  	BUG_ON(!objp);
>  	if (unlikely(objp == ZERO_SIZE_PTR))
>  		return 0;
>  
> +	page = virt_to_head_page(objp);
> +	if (unlikely(!PageSlab(page)))
> +		return PAGE_SIZE << compound_order(page);
> +
>  	return obj_size(virt_to_cache(objp));
>  }
>  EXPORT_SYMBOL(ksize);

The patch looks good to me. Christoph, Matt, NAK/ACK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
