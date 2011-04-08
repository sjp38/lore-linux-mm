Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CBC498D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 08:28:52 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3304299fxm.14
        for <linux-mm@kvack.org>; Fri, 08 Apr 2011 05:28:49 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/2] make new alloc_pages_exact()
References: <20110407172104.1F8B7329@kernel> <20110407172105.831B9A0A@kernel>
Date: Fri, 08 Apr 2011 14:28:47 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtmcx9kd3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <20110407172105.831B9A0A@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi
 Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 07 Apr 2011 19:21:05 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
wrote:
> +struct page *__alloc_pages_exact(gfp_t gfp_mask, size_t size)
>  {
>  	unsigned int order = get_order(size);
> -	unsigned long addr;
> +	struct page *page;
> -	addr = __get_free_pages(gfp_mask, order);
> -	if (addr) {
> -		unsigned long alloc_end = addr + (PAGE_SIZE << order);
> -		unsigned long used = addr + PAGE_ALIGN(size);
> +	page = alloc_pages(gfp_mask, order);
> +	if (page) {
> +		struct page *alloc_end = page + (1 << order);
> +		struct page *used = page + PAGE_ALIGN(size)/PAGE_SIZE;
> -		split_page(virt_to_page((void *)addr), order);
> +		split_page(page, order);
>  		while (used < alloc_end) {
> -			free_page(used);
> -			used += PAGE_SIZE;
> +			__free_page(used);
> +			used++;
>  		}

Have you thought about moving this loop to a separate function, ie.
_free_page_range(start, end)?  I'm asking because this loop appears
in two places and my CMA would also benefit from such a function.

>  	}
> -	return (void *)addr;
> +	return page;
> +}

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
