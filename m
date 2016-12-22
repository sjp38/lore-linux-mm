Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA2F76B03F8
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 03:55:11 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id iq1so2887832wjb.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 00:55:11 -0800 (PST)
Received: from smtp24.mail.ru (smtp24.mail.ru. [94.100.181.179])
        by mx.google.com with ESMTPS id us1si30989439wjc.102.2016.12.22.00.55.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 00:55:10 -0800 (PST)
Date: Thu, 22 Dec 2016 11:54:58 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 1/2] kasan: drain quarantine of memcg slab objects
Message-ID: <20161222085458.GA3494@esperanza>
References: <1482257462-36948-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482257462-36948-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 20, 2016 at 10:11:01AM -0800, Greg Thelen wrote:
> Per memcg slab accounting and kasan have a problem with kmem_cache
> destruction.
> - kmem_cache_create() allocates a kmem_cache, which is used for
>   allocations from processes running in root (top) memcg.
> - Processes running in non root memcg and allocating with either
>   __GFP_ACCOUNT or from a SLAB_ACCOUNT cache use a per memcg kmem_cache.
> - Kasan catches use-after-free by having kfree() and kmem_cache_free()
>   defer freeing of objects.  Objects are placed in a quarantine.
> - kmem_cache_destroy() destroys root and non root kmem_caches.  It takes
>   care to drain the quarantine of objects from the root memcg's
>   kmem_cache, but ignores objects associated with non root memcg.  This
>   causes leaks because quarantined per memcg objects refer to per memcg
>   kmem cache being destroyed.
> 
> To see the problem:
> 1) create a slab cache with kmem_cache_create(,,,SLAB_ACCOUNT,)
> 2) from non root memcg, allocate and free a few objects from cache
> 3) dispose of the cache with kmem_cache_destroy()
> kmem_cache_destroy() will trigger a "Slab cache still has objects"
> warning indicating that the per memcg kmem_cache structure was leaked.
> 
> Fix the leak by draining kasan quarantined objects allocated from non
> root memcg.
> 
> Racing memcg deletion is tricky, but handled.  kmem_cache_destroy() =>
> shutdown_memcg_caches() => __shutdown_memcg_cache() => shutdown_cache()
> flushes per memcg quarantined objects, even if that memcg has been
> rmdir'd and gone through memcg_deactivate_kmem_caches().
> 
> This leak only affects destroyed SLAB_ACCOUNT kmem caches when kasan is
> enabled.  So I don't think it's worth patching stable kernels.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
