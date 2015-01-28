Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0F46B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 10:31:00 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id i50so17090830qgf.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 07:30:59 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id g6si6333958qga.61.2015.01.28.07.30.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 07:30:58 -0800 (PST)
Date: Wed, 28 Jan 2015 09:30:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/3] Slab infrastructure for array operations
In-Reply-To: <CAAmzW4MzNfcRucHeTxJtXLks5T-Def=O1sRpQY6fo5ybTzKsBA@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1501280923410.31753@gentwo.org>
References: <20150123213727.142554068@linux.com> <20150123213735.590610697@linux.com> <20150127082132.GE11358@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1501271054310.25124@gentwo.org> <CAAmzW4MzNfcRucHeTxJtXLks5T-Def=O1sRpQY6fo5ybTzKsBA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 28 Jan 2015, Joonsoo Kim wrote:

> > GFP_SLAB_ARRAY new is best for large quantities in either allocator since
> > SLAB also has to construct local metadata structures.
>
> In case of SLAB, there is just a little more work to construct local metadata so
> GFP_SLAB_ARRAY_NEW would not show better performance
> than GFP_SLAB_ARRAY_LOCAL, because it would cause more overhead due to
> more page allocations. Because of this characteristic, I said that
> which option is
> the best is implementation specific and therefore we should not expose it.

For large amounts of objects (hundreds or higher) GFP_SLAB_ARRAY_LOCAL
will never have enough objects. GFP_SLAB_ARRAY_NEW will go to the page
allocator and bypass free table creation and all the queuing that objects
go through normally in SLAB. AFAICT its going to be a significant win.

A similar situation is true for the freeing operation. If the freeing
operation results in all objects in a page being freed then we can also
bypass that and put the page directly back into the page allocator (to be
implemented once we agree on an approach).

> Even if we narrow down the problem to the SLUB, choosing correct option is
> difficult enough. User should know how many objects are cached in this
> kmem_cache
> in order to choose best option since relative quantity would make
> performance difference.

Ok we can add a function call to calculate the number of objects cached
per cpu and per node? But then that is rather fluid and could change any
moment.

> And, how many objects are cached in this kmem_cache could be changed
> whenever implementation changed.

The default when no options are specified is to first exhaust the node
partial objects, then allocate new slabs as long as we have more than
objects per page left and only then satisfy from cpu local object. I think
that is satisfactory for the majority of the cases.

The detailed control options were requested at the meeting in Auckland at
the LCA. I am fine with dropping those if they do not make sense. Makes
the API and implementation simpler. Jesper, are you ok with this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
