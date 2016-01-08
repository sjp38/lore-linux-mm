Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 861FB828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 06:20:32 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id b35so219571741qge.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 03:20:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x4si6027085qka.74.2016.01.08.03.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 03:20:31 -0800 (PST)
Date: Fri, 8 Jan 2016 12:20:25 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 10/10] mm: new API kfree_bulk() for SLAB+SLUB allocators
Message-ID: <20160108122025.4605528c@redhat.com>
In-Reply-To: <20160108030348.GC14457@js1304-P5Q-DELUXE>
References: <20160107140253.28907.5469.stgit@firesoul>
	<20160107140423.28907.79558.stgit@firesoul>
	<20160108030348.GC14457@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, brouer@redhat.com

On Fri, 8 Jan 2016 12:03:48 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Thu, Jan 07, 2016 at 03:04:23PM +0100, Jesper Dangaard Brouer wrote:
> > This patch introduce a new API call kfree_bulk() for bulk freeing
> > memory objects not bound to a single kmem_cache.
> > 
> > Christoph pointed out that it is possible to implement freeing of
> > objects, without knowing the kmem_cache pointer as that information is
> > available from the object's page->slab_cache.  Proposing to remove the
> > kmem_cache argument from the bulk free API.
> > 
> > Jesper demonstrated that these extra steps per object comes at a
> > performance cost.  It is only in the case CONFIG_MEMCG_KMEM is
> > compiled in and activated runtime that these steps are done anyhow.
> > The extra cost is most visible for SLAB allocator, because the SLUB
> > allocator does the page lookup (virt_to_head_page()) anyhow.
> > 
> > Thus, the conclusion was to keep the kmem_cache free bulk API with a
> > kmem_cache pointer, but we can still implement a kfree_bulk() API
> > fairly easily.  Simply by handling if kmem_cache_free_bulk() gets
> > called with a kmem_cache NULL pointer.
> > 
> > This does increase the code size a bit, but implementing a separate
> > kfree_bulk() call would likely increase code size even more.
> > 
> > Below benchmarks cost of alloc+free (obj size 256 bytes) on
> > CPU i7-4790K @ 4.00GHz, no PREEMPT and CONFIG_MEMCG_KMEM=y.
> > 
> > Code size increase for SLAB:
> > 
> >  add/remove: 0/0 grow/shrink: 1/0 up/down: 74/0 (74)
> >  function                                     old     new   delta
> >  kmem_cache_free_bulk                         660     734     +74
> > 
> > SLAB fastpath: 85 cycles(tsc) 21.468 ns (step:0)
> >   sz - fallback             - kmem_cache_free_bulk - kfree_bulk
> >    1 - 101 cycles 25.291 ns -  41 cycles 10.499 ns - 130 cycles 32.522 ns
> 
> This looks experimental error. Why does kfree_bulk() takes more time
> than fallback?

This does look like an experimental error.  Sometimes instabilities
occurs, when slab_caches gets merged, but I tried to counter that by
using boot param slab_nomerge.

In the case for SLAB kfree_bulk() single object, then it can be slower
than the fallback, because it will likely always hit a branch
mispredict for the kfree case (which is okay, as that is not the case
we optimize for, single obj free).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
