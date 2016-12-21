Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1748F6B03BB
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 11:42:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 26so230952451pgy.6
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 08:42:00 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10128.outbound.protection.outlook.com. [40.107.1.128])
        by mx.google.com with ESMTPS id 64si27279387ply.171.2016.12.21.08.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 08:41:58 -0800 (PST)
Subject: Re: [PATCH 1/2] kasan: drain quarantine of memcg slab objects
References: <1482257462-36948-1-git-send-email-gthelen@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <7a7bdc20-121e-07d7-cb02-bb44902cd797@virtuozzo.com>
Date: Wed, 21 Dec 2016 19:42:22 +0300
MIME-Version: 1.0
In-Reply-To: <1482257462-36948-1-git-send-email-gthelen@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2016 09:11 PM, Greg Thelen wrote:
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
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
