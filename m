Message-ID: <4834F539.2050707@cs.helsinki.fi>
Date: Thu, 22 May 2008 07:23:21 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
References: <20080520095935.GB18633@linux-sh.org> <2373.1211296724@redhat.com> <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>  mm/nommu.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6/mm/nommu.c
> ===================================================================
> --- linux-2.6.orig/mm/nommu.c	2008-05-20 09:50:25.686495370 -0700
> +++ linux-2.6/mm/nommu.c	2008-05-20 09:50:51.797745535 -0700
> @@ -109,16 +109,14 @@ unsigned int kobjsize(const void *objp)
>  	 * If the object we have should not have ksize performed on it,
>  	 * return size of 0
>  	 */
> -	if (!objp || (unsigned long)objp >= memory_end || !((page = virt_to_page(objp))))
> +	if (!objp || (unsigned long)objp >= memory_end ||
> +				!((page = virt_to_head_page(objp))))
>  		return 0;
>  
>  	if (PageSlab(page))
>  		return ksize(objp);
>  
> -	BUG_ON(page->index < 0);
> -	BUG_ON(page->index >= MAX_ORDER);
> -
> -	return (PAGE_SIZE << page->index);
> +	return PAGE_SIZE << compound_order(page);

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

Paul, David, please use this patch instead. Mine didn't have 
virt_to_head_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
