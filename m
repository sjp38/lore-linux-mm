Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1846B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 16:36:00 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so9312282pab.12
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:36:00 -0700 (PDT)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id gp6si11058734pac.215.2014.05.12.13.35.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 13:35:59 -0700 (PDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so69994pbb.0
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:35:58 -0700 (PDT)
Date: Mon, 12 May 2014 13:35:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slub: Place count_partial() outside CONFIG_SLUB_DEBUG
 if block
In-Reply-To: <1399898190-18376-1-git-send-email-fabio.estevam@freescale.com>
Message-ID: <alpine.DEB.2.02.1405121333370.961@chino.kir.corp.google.com>
References: <1399898190-18376-1-git-send-email-fabio.estevam@freescale.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabio Estevam <fabio.estevam@freescale.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, festevam@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

On Mon, 12 May 2014, Fabio Estevam wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index 4d5002f..0a642a4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2127,12 +2127,6 @@ static inline int node_match(struct page *page, int node)
>  	return 1;
>  }
>  
> -#ifdef CONFIG_SLUB_DEBUG
> -static int count_free(struct page *page)
> -{
> -	return page->objects - page->inuse;
> -}
> -
>  static unsigned long count_partial(struct kmem_cache_node *n,
>  					int (*get_count)(struct page *))

This is wrong, gcc will now complain that count_partial() is unused if 
CONFIG_SYSFS is disabled.

>  {
> @@ -2147,6 +2141,12 @@ static unsigned long count_partial(struct kmem_cache_node *n,
>  	return x;
>  }
>  
> +#ifdef CONFIG_SLUB_DEBUG
> +static int count_free(struct page *page)
> +{
> +	return page->objects - page->inuse;
> +}
> +
>  static inline unsigned long node_nr_objs(struct kmem_cache_node *n)
>  {
>  	return atomic_long_read(&n->total_objects);

node_nr_objs() need only be defined when CONFIG_SLUB_DEBUG, there's no 
need for an #else variant that simply returns 0.  (CONFIG_SLABINFO 
requires CONFIG_SLUB_DEBUG.)

Please see http://marc.info/?l=linux-mm-commits&m=139992385527040 that has 
been merged into -mm which is the correct fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
