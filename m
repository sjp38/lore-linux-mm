Message-ID: <4834732E.3040403@cs.helsinki.fi>
Date: Wed, 21 May 2008 22:08:30 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
References: <20080520095935.GB18633@linux-sh.org> <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: David Howells <dhowells@redhat.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pekka J Enberg wrote:
> As pointed out by Christoph, it. ksize() works with SLUB and SLOB 
> accidentally because they do page allocator pass-through and thus need to 
> deal with non-PageSlab pages. SLAB, however, does not do that which is why 
> all pages passed to it must have PageSlab set (we ought to add a WARN_ON() 
> there btw).
> 
> So I suggest we fix up kobjsize() instead. Paul, does the following 
> untested patch work for you?
> 
> diff --git a/mm/nommu.c b/mm/nommu.c
> index ef8c62c..a573aeb 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -115,10 +115,7 @@ unsigned int kobjsize(const void *objp)
>  	if (PageSlab(page))
>  		return ksize(objp);
>  
> -	BUG_ON(page->index < 0);
> -	BUG_ON(page->index >= MAX_ORDER);
> -
> -	return (PAGE_SIZE << page->index);
> +	return PAGE_SIZE << compound_order(page);

Hmm, actually this needs more fixing with SLOB as it never sets PageSlab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
