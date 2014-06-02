Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF4CF6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 00:21:17 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so1481233pab.24
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 21:21:17 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id tn5si14620150pac.145.2014.06.01.21.21.15
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 21:21:16 -0700 (PDT)
Date: Mon, 2 Jun 2014 13:24:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm 7/8] slub: make dead caches discard free slabs
 immediately
Message-ID: <20140602042435.GA17964@js1304-P5Q-DELUXE>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405300955120.11943@gentwo.org>
 <20140531110456.GC25076@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140531110456.GC25076@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Christoph Lameter <cl@gentwo.org>, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, May 31, 2014 at 03:04:58PM +0400, Vladimir Davydov wrote:
> On Fri, May 30, 2014 at 09:57:10AM -0500, Christoph Lameter wrote:
> > On Fri, 30 May 2014, Vladimir Davydov wrote:
> > 
> > > (3) is a bit more difficult, because slabs are added to per-cpu partial
> > > lists lock-less. Fortunately, we only have to handle the __slab_free
> > > case, because, as there shouldn't be any allocation requests dispatched
> > > to a dead memcg cache, get_partial_node() should never be called. In
> > > __slab_free we use cmpxchg to modify kmem_cache_cpu->partial (see
> > > put_cpu_partial) so that setting ->partial to a special value, which
> > > will make put_cpu_partial bail out, will do the trick.
> > >
> > > Note, this shouldn't affect performance, because keeping empty slabs on
> > > per node lists as well as using per cpu partials are only worthwhile if
> > > the cache is used for allocations, which isn't the case for dead caches.
> > 
> > This all sounds pretty good to me but we still have some pretty extensive
> > modifications that I would rather avoid.
> > 
> > In put_cpu_partial you can simply check that the memcg is dead right? This
> > would avoid all the other modifications I would think and will not require
> > a special value for the per cpu partial pointer.
> 
> That would be racy. The check if memcg is dead and the write to per cpu
> partial ptr wouldn't proceed as one atomic operation. If we set the dead
> flag from another thread between these two operations, put_cpu_partial
> will add a slab to a per cpu partial list *after* the cache was zapped.

Hello, Vladimir.

I think that we can do (3) easily.
If we check memcg_cache_dead() in the end of put_cpu_partial() rather
than in the begin of put_cpu_partial(), we can avoid the race you 
mentioned. If someone do put_cpu_partial() before dead flag is set,
it can be zapped by who set dead flag. And if someone do
put_cpu_partial() after dead flag is set, it can be zapped by who
do put_cpu_partial().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
