Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 45F466B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:13:12 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so3576325pab.0
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:13:12 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id zb5si6237421pbb.129.2015.02.16.21.13.10
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 21:13:11 -0800 (PST)
Date: Tue, 17 Feb 2015 14:15:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
Message-ID: <20150217051541.GA15413@js1304-P5Q-DELUXE>
References: <20150210194804.288708936@linux.com>
 <20150210194811.787556326@linux.com>
 <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1502111243380.3887@gentwo.org>
 <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
 <20150213023534.GA6592@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1502130941360.9442@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1502130941360.9442@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Feb 13, 2015 at 09:47:59AM -0600, Christoph Lameter wrote:
> On Fri, 13 Feb 2015, Joonsoo Kim wrote:
> >
> > I also think that this implementation is slub-specific. For example,
> > in slab case, it is always better to access local cpu cache first than
> > page allocator since slab doesn't use list to manage free objects and
> > there is no cache line overhead like as slub. I think that,
> > in kmem_cache_alloc_array(), just call to allocator-defined
> > __kmem_cache_alloc_array() is better approach.
> 
> What do you mean by "better"? Please be specific as to where you would see
> a difference. And slab definititely manages free objects although
> differently than slub. SLAB manages per cpu (local) objects, per node
> partial lists etc. Same as SLUB. The cache line overhead is there but no
> that big a difference in terms of choosing objects to get first.
> 
> For a large allocation it is beneficial for both allocators to fist reduce
> the list of partial allocated slab pages on a node.
> 
> Going to the local objects first is enticing since these are cache hot but
> there are only a limited number of these available and there are issues
> with acquiring a large number of objects. For SLAB the objects dispersed
> and not spatially local. For SLUB the number of objects is usually much
> more limited than SLAB (but that is configurable these days via the cpu
> partial pages). SLUB allocates spatially local objects from one page
> before moving to the other. This is an advantage. However, it has to
> traverse a linked list instead of an array (SLAB).

Hello,

Hmm...so far, SLAB focus on temporal locality rather than spatial locality
as you know. Why SLAB need to consider spatial locality first in this
kmem_cache_alloc_array() case?

And, although we use partial list first, we can't reduce
fragmentation as much as SLUB. Local cache may keep some free objects
of the partial slab so just exhausting free objects of partial slab doesn't
means that there is no free object left. For SLUB, exhausting free
objects of partial slab means there is no free object left.

If we allocate objects from local cache as much as possible, we can
keep temporal locality and return objects as fast as possible since
returing objects from local cache just needs memcpy from local array
cache to destination array.

This cannot be implemented by using kmem_cache_alloc_array() you
suggested and this is why I think just calling allocator-defined
__kmem_cache_alloc_array() is better approach.

As David said, there is no implementation for SLAB yet and we have
different opinion about implementation for SLAB. It's better
to delay detailed implementation of kmem_cache_alloc_array()
until implementation for SLAB is agreed. Before it, calling
__kmem_cache_alloc_array() in kmem_cache_alloc_array() is sufficient
to provide functionality.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
