Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEE16B0071
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 10:48:02 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id e89so13700646qgf.9
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 07:48:01 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net ([2001:558:fe21:29:250:56ff:feaf:4189])
        by mx.google.com with ESMTPS id u91si3134504qgu.106.2015.02.13.07.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 07:48:01 -0800 (PST)
Date: Fri, 13 Feb 2015 09:47:59 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <20150213023534.GA6592@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1502130941360.9442@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org> <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
 <20150213023534.GA6592@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, 13 Feb 2015, Joonsoo Kim wrote:
>
> I also think that this implementation is slub-specific. For example,
> in slab case, it is always better to access local cpu cache first than
> page allocator since slab doesn't use list to manage free objects and
> there is no cache line overhead like as slub. I think that,
> in kmem_cache_alloc_array(), just call to allocator-defined
> __kmem_cache_alloc_array() is better approach.

What do you mean by "better"? Please be specific as to where you would see
a difference. And slab definititely manages free objects although
differently than slub. SLAB manages per cpu (local) objects, per node
partial lists etc. Same as SLUB. The cache line overhead is there but no
that big a difference in terms of choosing objects to get first.

For a large allocation it is beneficial for both allocators to fist reduce
the list of partial allocated slab pages on a node.

Going to the local objects first is enticing since these are cache hot but
there are only a limited number of these available and there are issues
with acquiring a large number of objects. For SLAB the objects dispersed
and not spatially local. For SLUB the number of objects is usually much
more limited than SLAB (but that is configurable these days via the cpu
partial pages). SLUB allocates spatially local objects from one page
before moving to the other. This is an advantage. However, it has to
traverse a linked list instead of an array (SLAB).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
