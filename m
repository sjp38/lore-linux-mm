Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4EED06B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 12:07:52 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so5480255pde.15
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 09:07:51 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id bi5si4524375pbb.148.2014.04.11.09.07.51
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 09:07:51 -0700 (PDT)
Date: Fri, 11 Apr 2014 11:07:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm v2.2] mm: get rid of __GFP_KMEMCG
In-Reply-To: <1396537559-17453-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1404111104550.13278@nuc>
References: <1396419365-351-1-git-send-email-vdavydov@parallels.com> <1396537559-17453-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@gmail.com>, Pekka Enberg <penberg@kernel.org>

On Thu, 3 Apr 2014, Vladimir Davydov wrote:

> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -358,16 +358,7 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
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
> +extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order);


Hmmm... This was intentional inlined to allow inline expansion for calls
to kmalloc with large constants. The inline expansion directly converts
these calls to page allocator calls avoiding slab overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
