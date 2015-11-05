Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6515C82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 00:09:18 -0500 (EST)
Received: by pasz6 with SMTP id z6so78221502pas.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 21:09:18 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id h4si7286347pat.127.2015.11.04.21.09.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 21:09:17 -0800 (PST)
Date: Thu, 5 Nov 2015 14:09:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [MM PATCH V4 6/6] slub: optimize bulk slowpath free by detached
 freelist
Message-ID: <20151105050924.GD20374@js1304-P5Q-DELUXE>
References: <20150929154605.14465.98995.stgit@canyon>
 <20150929154822.14465.50207.stgit@canyon>
 <20151014051524.GA29286@js1304-P5Q-DELUXE>
 <20151021095709.167e58d2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151021095709.167e58d2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, Oct 21, 2015 at 09:57:09AM +0200, Jesper Dangaard Brouer wrote:
> On Wed, 14 Oct 2015 14:15:25 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Tue, Sep 29, 2015 at 05:48:26PM +0200, Jesper Dangaard Brouer wrote:
> > > This change focus on improving the speed of object freeing in the
> > > "slowpath" of kmem_cache_free_bulk.
> > > 
> > > The calls slab_free (fastpath) and __slab_free (slowpath) have been
> > > extended with support for bulk free, which amortize the overhead of
> > > the (locked) cmpxchg_double.
> > > 
> > > To use the new bulking feature, we build what I call a detached
> > > freelist.  The detached freelist takes advantage of three properties:
> > > 
> > >  1) the free function call owns the object that is about to be freed,
> > >     thus writing into this memory is synchronization-free.
> > > 
> > >  2) many freelist's can co-exist side-by-side in the same slab-page
> > >     each with a separate head pointer.
> > > 
> > >  3) it is the visibility of the head pointer that needs synchronization.
> > > 
> > > Given these properties, the brilliant part is that the detached
> > > freelist can be constructed without any need for synchronization.  The
> > > freelist is constructed directly in the page objects, without any
> > > synchronization needed.  The detached freelist is allocated on the
> > > stack of the function call kmem_cache_free_bulk.  Thus, the freelist
> > > head pointer is not visible to other CPUs.
> > > 
> > > All objects in a SLUB freelist must belong to the same slab-page.
> > > Thus, constructing the detached freelist is about matching objects
> > > that belong to the same slab-page.  The bulk free array is scanned is
> > > a progressive manor with a limited look-ahead facility.
> [...]
> 
> 
> > Hello, Jesper.
> > 
> > AFAIK, it is uncommon to clear pointer to object in argument array.
> > At least, it is better to comment it on somewhere.
> 
> In this case, I think clearing the array is a good thing, as
> using/referencing objects after they have been free'ed is a bug (which
> can be hard to detect).

Okay.

> 
> > Or, how about removing  lookahead facility? Does it have real benefit?
> 
> In my earlier patch series I had a version with and without lookahead
> facility.  Just so I could benchmark the difference.  With Alex'es help
> we/I tuned the code with the lookahead feature to be just as fast.
> Thus, I merged the two patches. (Also did testing for worstcase [1])
> 
> I do wonder if the lookahead have any real benefit.  In micro
> benchmarking it might be "just-as-fast", but I do suspect (just the code
> size increase) it can affect real use-cases... Should we remove it?
> 
> [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test03.c

If it's not implemented yet, I would say that starting with simple
one first. But, now, we already have well implemented one so we don't
need to remove it. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
