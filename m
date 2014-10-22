Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A2C2A6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:04:23 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id r20so2096286wiv.17
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:04:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bl7si14302834wjc.30.2014.10.22.11.04.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 11:04:21 -0700 (PDT)
Date: Wed, 22 Oct 2014 20:04:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC 1/4] slub: Remove __slab_alloc code duplication
In-Reply-To: <20141022155526.942670823@linux.com>
Message-ID: <alpine.DEB.2.11.1410222002380.5308@nanos>
References: <20141022155517.560385718@linux.com> <20141022155526.942670823@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Wed, 22 Oct 2014, Christoph Lameter wrote:

> Somehow the two branches in __slab_alloc do the same.
> Unify them.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -2280,12 +2280,8 @@ redo:
>  		if (node != NUMA_NO_NODE && !node_present_pages(node))
>  			searchnode = node_to_mem_node(node);
>  
> -		if (unlikely(!node_match(page, searchnode))) {
> -			stat(s, ALLOC_NODE_MISMATCH);
> -			deactivate_slab(s, page, c->freelist);
> -			c->page = NULL;
> -			c->freelist = NULL;
> -			goto new_slab;
> +		if (unlikely(!node_match(page, searchnode)))
> +			goto deactivate;
>  		}

That's not compiling at all due to the left over '}' !

And shouldn't you keep the stat(); call in that code path?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
