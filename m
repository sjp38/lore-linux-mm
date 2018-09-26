Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D20B8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 12:14:20 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a130-v6so8143914qkb.7
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 09:14:20 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id 15-v6si1947728qku.267.2018.09.26.09.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Sep 2018 09:14:19 -0700 (PDT)
Date: Wed, 26 Sep 2018 16:14:19 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: disallow obj's allocation on page with mismatched
 pfmemalloc purpose
In-Reply-To: <1537944728-18036-1-git-send-email-kernelfans@gmail.com>
Message-ID: <0100016616a8e4ba-fb8d5b4e-27cf-4f4f-b86c-a37d4e08a759-000000@email.amazonses.com>
References: <1537944728-18036-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 26 Sep 2018, Pingfan Liu wrote:

> -
>  	if (unlikely(!freelist)) {
>  		slab_out_of_memory(s, gfpflags, node);
>  		return NULL;
>  	}
>
> +	VM_BUG_ON(!pfmemalloc_match(page, gfpflags));
>  	page = c->page;
> -	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
> +	if (likely(!kmem_cache_debug(s))
>  		goto load_freelist;
>
>  	/* Only entered in the debug case */
> -	if (kmem_cache_debug(s) &&
> -			!alloc_debug_processing(s, page, freelist, addr))
> +	if (!alloc_debug_processing(s, page, freelist, addr))
>  		goto new_slab;	/* Slab failed checks. Next slab needed */
> -
> -	deactivate_slab(s, page, get_freepointer(s, freelist), c);

In the debug case the slab needs to be deactivated. Otherwise the
slowpath will not be used and debug checks on the following objects will
not be done.

> -	return freelist;
> +	else
> +		goto load_freelist;
>  }
>
>  /*
>
