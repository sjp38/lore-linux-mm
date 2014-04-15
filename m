Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF6E6B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 22:16:28 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so7219863eek.32
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 19:16:27 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t3si23281043eeg.331.2014.04.14.19.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 19:16:26 -0700 (PDT)
Date: Mon, 14 Apr 2014 22:16:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 1/4] memcg, slab: do not schedule cache destruction
 when last page goes away
Message-ID: <20140415021614.GC7969@cmpxchg.org>
References: <cover.1397054470.git.vdavydov@parallels.com>
 <8ea8b57d5264f16ee33497a4317240648645704a.1397054470.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ea8b57d5264f16ee33497a4317240648645704a.1397054470.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Wed, Apr 09, 2014 at 07:02:30PM +0400, Vladimir Davydov wrote:
> After the memcg is offlined, we mark its kmem caches that cannot be
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
> 
> So I propose to remove this async cache destruction from
> memcg_release_pages, and check if the cache is empty explicitly after
> calling kmem_cache_shrink instead. This will simplify things a lot w/o
> introducing any functional changes.
> 
> And regarding dead memcg caches (i.e. those that are left hanging around
> after memcg offline for they have objects), I suppose we should reap
> them either periodically or on vmpressure as Glauber suggested
> initially. I'm going to implement this later.

memcg_release_pages() can be called after cgroup destruction, and thus
it *must* ensure that the now-empty cache is destroyed - or we'll leak
it.

There is no excuse to downgrade to periodic reaping when we already
directly hook into the event that makes the cache empty.  If slab
needs to hold on to the cache for slightly longer than the final
memcg_release_pages(), then it should grab a refcount to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
