Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id CDC486B007B
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 02:11:23 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so7974360lbi.28
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 23:11:22 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id le2si465303lbc.124.2014.04.01.23.11.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Apr 2014 23:11:22 -0700 (PDT)
Message-ID: <533BAA03.9000406@parallels.com>
Date: Wed, 2 Apr 2014 10:11:15 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 2/2] mm: get rid of __GFP_KMEMCG
References: <cover.1396335798.git.vdavydov@parallels.com> <c50644c5c979fbe21e72cc2751876ceaff6ef495.1396335798.git.vdavydov@parallels.com> <xr93a9c4k13q.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93a9c4k13q.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/02/2014 04:48 AM, Greg Thelen wrote:
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 3dd389aa91c7..6d6959292e00 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -358,17 +358,6 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
>  #include <linux/slub_def.h>
>  #endif
>  
> -static __always_inline void *
> -kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> -{
> -	void *ret;
> -
> -	flags |= (__GFP_COMP | __GFP_KMEMCG);
> -	ret = (void *) __get_free_pages(flags, order);
> -	kmemleak_alloc(ret, size, 1, flags);
> -	return ret;
> -}
> -
> Removing this from the header file breaks builds without
> CONFIG_TRACING.
> Example:
>     % make allnoconfig && make -j4 mm/
>     [...]
>     include/linux/slab.h: In function a??kmalloc_order_tracea??:
>     include/linux/slab.h:367:2: error: implicit declaration of function a??kmalloc_ordera?? [-Werror=implicit-function-declaration]

Oh, my bad - forgot to add the function declaration :-(

The fixed version is on its way. Thank you for catching this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
