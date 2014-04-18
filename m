Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id F38256B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:41:34 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so1639107eei.33
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 06:41:34 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id u5si40367120een.23.2014.04.18.06.41.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 06:41:33 -0700 (PDT)
Date: Fri, 18 Apr 2014 09:41:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC -mm v2 1/3] memcg, slab: do not schedule cache
 destruction when last page goes away
Message-ID: <20140418134122.GB26283@cmpxchg.org>
References: <cover.1397804745.git.vdavydov@parallels.com>
 <e929fb6cc3a10ce1a9dcee0440e6995bdf427090.1397804745.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e929fb6cc3a10ce1a9dcee0440e6995bdf427090.1397804745.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Fri, Apr 18, 2014 at 12:04:47PM +0400, Vladimir Davydov wrote:
> After a memcg is offlined, we mark its kmem caches that cannot be
> deleted right now due to pending objects as dead by setting the
> memcg_cache_params::dead flag, so that memcg_release_pages will schedule
> cache destruction (memcg_cache_params::destroy) as soon as the last slab
> of the cache is freed (memcg_cache_params::nr_pages drops to zero).
> 
> I guess the idea was to destroy the caches as soon as possible, i.e.
> immediately after freeing the last object. However, it just doesn't work
> that way, because kmem caches always preserve some pages for the sake of
> performance, so that nr_pages never gets to zero unless the cache is
> shrunk explicitly using kmem_cache_shrink. Of course, we could account
> the total number of objects on the cache or check if all the slabs
> allocated for the cache are empty on kmem_cache_free and schedule
> destruction if so, but that would be too costly.
> 
> Thus we have a piece of code that works only when we explicitly call
> kmem_cache_shrink, but complicates the whole picture a lot. Moreover,
> it's racy in fact. For instance, kmem_cache_shrink may free the last
> slab and thus schedule cache destruction before it finishes checking
> that the cache is empty, which can lead to use-after-free.

Can't this still happen when the last object free races with css
destruction?  IIRC, you were worried in the past that slab/slub might
need a refcount to the cache to prevent this.  What changed?

> So I propose to remove this async cache destruction from
> memcg_release_pages, and check if the cache is empty explicitly after
> calling kmem_cache_shrink instead. This will simplify things a lot w/o
> introducing any functional changes.

Agreed.

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
