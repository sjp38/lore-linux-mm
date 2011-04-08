Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 721928D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 16:39:49 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p38KdlNr002114
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 13:39:47 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by wpaz29.hot.corp.google.com with ESMTP id p38Kdjke004242
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 8 Apr 2011 13:39:46 -0700
Received: by pxi7 with SMTP id 7so1890788pxi.16
        for <linux-mm@kvack.org>; Fri, 08 Apr 2011 13:39:45 -0700 (PDT)
Date: Fri, 8 Apr 2011 13:39:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] print vmalloc() state after allocation failures
In-Reply-To: <20110408202255.9EE67DC9@kernel>
Message-ID: <alpine.DEB.2.00.1104081337470.12689@chino.kir.corp.google.com>
References: <20110408202253.6D6D231C@kernel> <20110408202255.9EE67DC9@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, 8 Apr 2011, Dave Hansen wrote:

> 
> I was tracking down a page allocation failure that ended up in vmalloc().
> Since vmalloc() uses 0-order pages, if somebody asks for an insane amount
> of memory, we'll still get a warning with "order:0" in it.  That's not
> very useful.
> 
> During recovery, vmalloc() also nicely frees all of the memory that it
> got up to the point of the failure.  That is wonderful, but it also
> quickly hides any issues.  We have a much different sitation if vmalloc()
> repeatedly fails 10GB in to:
> 
> 	vmalloc(100 * 1<<30);
> 
> versus repeatedly failing 4096 bytes in to a:
> 
> 	vmalloc(8192);
> 
> This patch will print out messages that look like this:
> 
> [   30.040774] bash: vmalloc failure allocating after 0 / 73728 bytes
> 

Either the changelog or the patch is still wrong because the format of 
this string is inconsistent.

> As a side issue, I also noticed that ctl_ioctl() does vmalloc() based
> solely on an unverified value passed in from userspace.  Granted, it's
> under CAP_SYS_ADMIN, but it still frightens me a bit.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/mm/vmalloc.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff -puN mm/vmalloc.c~vmalloc-warn mm/vmalloc.c
> --- linux-2.6.git/mm/vmalloc.c~vmalloc-warn	2011-04-08 09:36:05.877020199 -0700
> +++ linux-2.6.git-dave/mm/vmalloc.c	2011-04-08 09:38:00.373093593 -0700
> @@ -1534,6 +1534,7 @@ static void *__vmalloc_node(unsigned lon
>  static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  				 pgprot_t prot, int node, void *caller)
>  {
> +	int order = 0;

Unnecessary, we can continue to hardcode the 0, vmalloc isn't going to use 
higher order allocs (it's there to avoid such things!).

>  	struct page **pages;
>  	unsigned int nr_pages, array_size, i;
>  	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
> @@ -1560,11 +1561,12 @@ static void *__vmalloc_area_node(struct 
>  
>  	for (i = 0; i < area->nr_pages; i++) {
>  		struct page *page;
> +		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;

I think it would be better to just do away with this as well and just 
hardwire the __GFP_NOWARN directly into the two allocation calls.

>  
>  		if (node < 0)
> -			page = alloc_page(gfp_mask);
> +			page = alloc_page(tmp_mask);
>  		else
> -			page = alloc_pages_node(node, gfp_mask, 0);
> +			page = alloc_pages_node(node, tmp_mask, order);
>  
>  		if (unlikely(!page)) {
>  			/* Successfully allocated i pages, free them in __vunmap() */
> @@ -1579,6 +1581,9 @@ static void *__vmalloc_area_node(struct 
>  	return area->addr;
>  
>  fail:
> +	nopage_warning(gfp_mask, order, "vmalloc: allocation failure, "
> +			"allocated %ld of %ld bytes\n",
> +			(area->nr_pages*PAGE_SIZE), area->size);
>  	vfree(area->addr);
>  	return NULL;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
