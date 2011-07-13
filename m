Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 703306B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 18:32:04 -0400 (EDT)
Date: Wed, 13 Jul 2011 15:31:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] sparc64: Kill page table quicklists.
Message-Id: <20110713153152.269b893c.akpm@linux-foundation.org>
In-Reply-To: <20110712122911.555480541@chello.nl>
References: <20110712122608.938583937@chello.nl>
	<20110712122911.555480541@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>

On Tue, 12 Jul 2011 14:26:09 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> --- linux-2.6.orig/arch/sparc/mm/tsb.c
> +++ linux-2.6/arch/sparc/mm/tsb.c
> @@ -236,6 +236,8 @@ static void setup_tsb_params(struct mm_s
>  	}
>  }
>  
> +struct kmem_cache *pgtable_cache __read_mostly;
> +
>  static struct kmem_cache *tsb_caches[8] __read_mostly;
>  
>  static const char *tsb_cache_names[8] = {
> @@ -253,6 +255,15 @@ void __init pgtable_cache_init(void)
>  {
>  	unsigned long i;
>  
> +	pgtable_cache = kmem_cache_create("pgtable_cache",
> +					  PAGE_SIZE, PAGE_SIZE,
> +					  0,
> +					  _clear_page);

The use of slab constructors is often dubious from a cache usage POV. 
But the lifecycle of a page-table page might well be that it slowly
gets non-zeroes written into it and then slowly gets zeroes written
into it until it is all-zeroes and then we free it up.  And often only
a subset of the page will ever be written.

So it could be that the slab constructor behaviour is a good match
here.  And not just for sparc!

Did such thinking and/or any testing go into this decision?


> +	if (!pgtable_cache) {
> +		prom_printf("pgtable_cache_init(): Could not create!\n");
> +		prom_halt();
> +	}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
