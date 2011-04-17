Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D1EBE900086
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 20:04:01 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p3H03ucx023850
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 17:03:57 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz33.hot.corp.google.com with ESMTP id p3H03twE015108
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 17:03:55 -0700
Received: by pwj8 with SMTP id 8so2160020pwj.13
        for <linux-mm@kvack.org>; Sat, 16 Apr 2011 17:03:54 -0700 (PDT)
Date: Sat, 16 Apr 2011 17:03:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] print vmalloc() state after allocation failures
In-Reply-To: <1302889441.16562.3525.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104161702300.14788@chino.kir.corp.google.com>
References: <20110415170437.17E1AF36@kernel> <20110415170438.D5C317D5@kernel>  <op.vtzo4ejf3l0zgt@mnazarewicz-glaptop> <1302889441.16562.3525.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 15 Apr 2011, Dave Hansen wrote:

> diff -puN mm/vmalloc.c~vmalloc-warn mm/vmalloc.c
> --- linux-2.6.git/mm/vmalloc.c~vmalloc-warn	2011-04-15 10:39:05.928793559 -0700
> +++ linux-2.6.git-dave/mm/vmalloc.c	2011-04-15 10:39:18.716789177 -0700
> @@ -1534,6 +1534,7 @@ static void *__vmalloc_node(unsigned lon
>  static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  				 pgprot_t prot, int node, void *caller)
>  {
> +	const int order = 0;
>  	struct page **pages;
>  	unsigned int nr_pages, array_size, i;
>  	gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
> @@ -1560,11 +1561,12 @@ static void *__vmalloc_area_node(struct 
>  
>  	for (i = 0; i < area->nr_pages; i++) {
>  		struct page *page;
> +		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;
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
> +	warn_alloc_failed(gfp_mask, order, "vmalloc: allocation failure, "
> +			  "allocated %ld of %ld bytes\n",
> +			  (area->nr_pages*PAGE_SIZE), area->size);
>  	vfree(area->addr);
>  	return NULL;
>  }

Sorry, I still don't understand why this isn't just a three-liner patch to 
call warn_alloc_failed().  I don't see the benefit of the "order" or 
"tmp_mask" variables at all, they'll just be removed next time someone 
goes down the mm/* directory and looks for variables that are used only 
once or are unchanged as a cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
