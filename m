Date: Wed, 21 May 2008 10:27:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0805211024060.15494@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org>
 <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008, Pekka J Enberg wrote:

> So I suggest we fix up kobjsize() instead. Paul, does the following 
> untested patch work for you?

Regardless of the test : Pekka's patch is a bugfix and should go via 
stable. kobjsize seems to assume that page->index contains the order
of a page. For a pagecache page it contains the page number in the 
mapping. So this should bug frequently if used on arbitrary objects.

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
>  }
>  
>  /*
> diff --git a/mm/slab.c b/mm/slab.c
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
