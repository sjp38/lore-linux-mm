Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C83E86B006E
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 11:54:10 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so7853545qgf.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 08:54:10 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id gu9si8682726qcb.24.2015.04.16.08.54.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 08:54:09 -0700 (PDT)
Date: Thu, 16 Apr 2015 10:54:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: bulk allocation from per cpu partial pages
In-Reply-To: <20150416140638.684838a2@redhat.com>
Message-ID: <alpine.DEB.2.11.1504161049030.8605@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org> <20150408155304.4480f11f16b60f09879c350d@linux-foundation.org> <alpine.DEB.2.11.1504090859560.19278@gentwo.org> <alpine.DEB.2.11.1504091215330.18198@gentwo.org>
 <20150416140638.684838a2@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, 16 Apr 2015, Jesper Dangaard Brouer wrote:

> On CPU E5-2630 @ 2.30GHz, the cost of kmem_cache_alloc +
> kmem_cache_free, is a tight loop (most optimal fast-path), cost 22ns.
> With elem size 256 bytes, where slab chooses to make 32 obj-per-slab.
>
> With this patch, testing different bulk sizes, the cost of alloc+free
> per element is improved for small sizes of bulk (which I guess this the
> is expected outcome).
>
> Have something to compare against, I also ran the bulk sizes through
> the fallback versions __kmem_cache_alloc_bulk() and
> __kmem_cache_free_bulk(), e.g. the none optimized versions.
>
>  size    --  optimized -- fallback
>  bulk  8 --  15ns      --  22ns
>  bulk 16 --  15ns      --  22ns

Good.

>  bulk 30 --  44ns      --  48ns
>  bulk 32 --  47ns      --  50ns
>  bulk 64 --  52ns      --  54ns

Hmm.... We are hittling the atomics I guess... What you got so far is only
using the per cpu data. Wonder how many partial pages are available
there and how much is satisfied from which per cpu structure. There are a
couple of cmpxchg_doubles in the optimized patch to squeeze even the last
object out of the pages before going to the next. I could avoid those
and simply rotate to another per cpu partial page instead.

Got some more here that deals with per node partials but at that point we
will be taking spinlocks.

> For smaller bulk sizes 8 and 16, this is actually a significant
> improvement, especially considering the free side is not optimized.

I have some draft code here to do the same for the free side. But I
thought we better get to some working code on the free side first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
