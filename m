Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 694F26B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 02:43:21 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so35817901pab.12
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:43:21 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id fg5si8738236pdb.221.2015.01.28.23.43.19
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 23:43:20 -0800 (PST)
Date: Thu, 29 Jan 2015 16:44:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 1/3] Slab infrastructure for array operations
Message-ID: <20150129074443.GA19607@js1304-P5Q-DELUXE>
References: <20150123213727.142554068@linux.com>
 <20150123213735.590610697@linux.com>
 <20150127082132.GE11358@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1501271054310.25124@gentwo.org>
 <CAAmzW4MzNfcRucHeTxJtXLks5T-Def=O1sRpQY6fo5ybTzKsBA@mail.gmail.com>
 <alpine.DEB.2.11.1501280923410.31753@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501280923410.31753@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Jan 28, 2015 at 09:30:56AM -0600, Christoph Lameter wrote:
> On Wed, 28 Jan 2015, Joonsoo Kim wrote:
> 
> > > GFP_SLAB_ARRAY new is best for large quantities in either allocator since
> > > SLAB also has to construct local metadata structures.
> >
> > In case of SLAB, there is just a little more work to construct local metadata so
> > GFP_SLAB_ARRAY_NEW would not show better performance
> > than GFP_SLAB_ARRAY_LOCAL, because it would cause more overhead due to
> > more page allocations. Because of this characteristic, I said that
> > which option is
> > the best is implementation specific and therefore we should not expose it.
> 
> For large amounts of objects (hundreds or higher) GFP_SLAB_ARRAY_LOCAL
> will never have enough objects. GFP_SLAB_ARRAY_NEW will go to the page
> allocator and bypass free table creation and all the queuing that objects
> go through normally in SLAB. AFAICT its going to be a significant win.
> 
> A similar situation is true for the freeing operation. If the freeing
> operation results in all objects in a page being freed then we can also
> bypass that and put the page directly back into the page allocator (to be
> implemented once we agree on an approach).
> 
> > Even if we narrow down the problem to the SLUB, choosing correct option is
> > difficult enough. User should know how many objects are cached in this
> > kmem_cache
> > in order to choose best option since relative quantity would make
> > performance difference.
> 
> Ok we can add a function call to calculate the number of objects cached
> per cpu and per node? But then that is rather fluid and could change any
> moment.
> 
> > And, how many objects are cached in this kmem_cache could be changed
> > whenever implementation changed.
> 
> The default when no options are specified is to first exhaust the node
> partial objects, then allocate new slabs as long as we have more than
> objects per page left and only then satisfy from cpu local object. I think
> that is satisfactory for the majority of the cases.
> 
> The detailed control options were requested at the meeting in Auckland at
> the LCA. I am fine with dropping those if they do not make sense. Makes
> the API and implementation simpler. Jesper, are you ok with this?

IMHO, it'd be better to choose a proper way of allocation by slab itself
and not to expose options to API user. We could decide the best option
according to current status of kmem_cache and requested object number
and internal implementation.

Is there any obvious example these option are needed for user?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
