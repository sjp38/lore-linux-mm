Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5BB8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:26:21 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id u73-v6so4019440lja.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:26:21 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y19si21286099lfg.67.2019.01.11.11.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 11:26:19 -0800 (PST)
Subject: Re: [PATCH 2/3] mm/vmalloc: do not call kmemleak_free() on not yet
 accounted memory
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-3-rpenyaev@suse.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b761b165-9892-0761-cd33-14300e39e36f@virtuozzo.com>
Date: Fri, 11 Jan 2019 22:26:39 +0300
MIME-Version: 1.0
In-Reply-To: <20190103145954.16942-3-rpenyaev@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/3/19 5:59 PM, Roman Penyaev wrote:
> __vmalloc_area_node() calls vfree() on error path, which in turn calls
> kmemleak_free(), but area is not yet accounted by kmemleak_vmalloc().
> 
> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/vmalloc.c | 16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 2cd24186ba84..dc6a62bca503 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1565,6 +1565,14 @@ void vfree_atomic(const void *addr)
>  	__vfree_deferred(addr);
>  }
>  
> +static void __vfree(const void *addr)
> +{
> +	if (unlikely(in_interrupt()))
> +		__vfree_deferred(addr);
> +	else
> +		__vunmap(addr, 1);
> +}
> +
>  /**
>   *	vfree  -  release memory allocated by vmalloc()
>   *	@addr:		memory base address
> @@ -1591,10 +1599,8 @@ void vfree(const void *addr)
>  
>  	if (!addr)
>  		return;
> -	if (unlikely(in_interrupt()))
> -		__vfree_deferred(addr);
> -	else
> -		__vunmap(addr, 1);
> +
> +	__vfree(addr);
>  }
>  EXPORT_SYMBOL(vfree);
>  
> @@ -1709,7 +1715,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  	warn_alloc(gfp_mask, NULL,
>  			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
>  			  (area->nr_pages*PAGE_SIZE), area->size);
> -	vfree(area->addr);
> +	__vfree(area->addr);

This can't be an interrupt context for a several reasons. One of them is BUG_ON(in_interrupt()) in __get_vm_area_node()
which is called right before __vmalloc_are_node().

So you can just do __vunmap(area->addr, 1); instead of __vfree().


>  	return NULL;
>  }
>  
> 
