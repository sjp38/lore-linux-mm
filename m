Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id B5F1D6B025B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 22:00:47 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id q21so273641312iod.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 19:00:47 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id o81si11431086ioe.92.2016.01.07.19.00.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 19:00:47 -0800 (PST)
Date: Fri, 8 Jan 2016 12:03:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 10/10] mm: new API kfree_bulk() for SLAB+SLUB allocators
Message-ID: <20160108030348.GC14457@js1304-P5Q-DELUXE>
References: <20160107140253.28907.5469.stgit@firesoul>
 <20160107140423.28907.79558.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107140423.28907.79558.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jan 07, 2016 at 03:04:23PM +0100, Jesper Dangaard Brouer wrote:
> This patch introduce a new API call kfree_bulk() for bulk freeing
> memory objects not bound to a single kmem_cache.
> 
> Christoph pointed out that it is possible to implement freeing of
> objects, without knowing the kmem_cache pointer as that information is
> available from the object's page->slab_cache.  Proposing to remove the
> kmem_cache argument from the bulk free API.
> 
> Jesper demonstrated that these extra steps per object comes at a
> performance cost.  It is only in the case CONFIG_MEMCG_KMEM is
> compiled in and activated runtime that these steps are done anyhow.
> The extra cost is most visible for SLAB allocator, because the SLUB
> allocator does the page lookup (virt_to_head_page()) anyhow.
> 
> Thus, the conclusion was to keep the kmem_cache free bulk API with a
> kmem_cache pointer, but we can still implement a kfree_bulk() API
> fairly easily.  Simply by handling if kmem_cache_free_bulk() gets
> called with a kmem_cache NULL pointer.
> 
> This does increase the code size a bit, but implementing a separate
> kfree_bulk() call would likely increase code size even more.
> 
> Below benchmarks cost of alloc+free (obj size 256 bytes) on
> CPU i7-4790K @ 4.00GHz, no PREEMPT and CONFIG_MEMCG_KMEM=y.
> 
> Code size increase for SLAB:
> 
>  add/remove: 0/0 grow/shrink: 1/0 up/down: 74/0 (74)
>  function                                     old     new   delta
>  kmem_cache_free_bulk                         660     734     +74
> 
> SLAB fastpath: 85 cycles(tsc) 21.468 ns (step:0)
>   sz - fallback             - kmem_cache_free_bulk - kfree_bulk
>    1 - 101 cycles 25.291 ns -  41 cycles 10.499 ns - 130 cycles 32.522 ns

This looks experimental error. Why does kfree_bulk() takes more time
than fallback?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
