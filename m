Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 730FC6B005C
	for <linux-mm@kvack.org>; Fri, 16 May 2014 09:06:45 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so1934239lab.34
        for <linux-mm@kvack.org>; Fri, 16 May 2014 06:06:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ub11si5565501lac.125.2014.05.16.06.06.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 May 2014 06:06:43 -0700 (PDT)
Date: Fri, 16 May 2014 17:06:30 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 1/3] slub: keep full slabs on list for per memcg
 caches
Message-ID: <20140516130629.GE32113@esperanza>
References: <cover.1399982635.git.vdavydov@parallels.com>
 <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141114040.16512@gentwo.org>
 <20140515063441.GA32113@esperanza>
 <alpine.DEB.2.10.1405151011210.24665@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405151011210.24665@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 15, 2014 at 10:15:10AM -0500, Christoph Lameter wrote:
> On Thu, 15 May 2014, Vladimir Davydov wrote:
> 
> > > That will significantly impact the fastpaths for alloc and free.
> > >
> > > Also a pretty significant change the logic of the fastpaths since they
> > > were not designed to handle the full lists. In debug mode all operations
> > > were only performed by the slow paths and only the slow paths so far
> > > supported tracking full slabs.
> >
> > That's the minimal price we have to pay for slab re-parenting, because
> > w/o it we won't be able to look up for all slabs of a particular per
> > memcg cache. The question is, can it be tolerated or I'd better try some
> > other way?
> 
> AFACIT these modifications all together will have a significant impact on
> performance.
> 
> You could avoid the refcounting on free relying on the atomic nature of
> cmpxchg operations. If you zap the per cpu slab then the fast path will be
> forced to fall back to the slowpaths where you could do what you need to
> do.

Hmm, looking at __slab_free once again, I tend to agree that we could
rely on cmpxchg to do re-parenting: we could freeze all slabs of the
cache being re-parented forcing every on-going kfree to do only a
cmpxchg w/o touching any lists and taking any locks, and then unfreeze
all the frozen slabs to the target cache. No need in the ugly "slow
mode" I introduced in this patch set would be necessary then.

But w/o ref-counting how can we make sure that all kfrees to the cache
we are going to re-parent have been completed so that it can be safely
destroyed? An example:

  CPU0:                                 CPU1:
  -----                                 -----
  kfree(obj):
    page = virt_to_head_page(obj)
    s = page->slab_cache
    slab_free(s, page, obj):
      <<< gets preempted here

                                        reparent_slab_cache:
                                          for each slab page
                                            [...]
                                            page->slab_cache = target_cache;

                                          kmem_cache_destroy(old_cache)

      <<< continues execution
      c = s->cpu_slab /* s points to the previous owner cache,
                         so we use-after-free here */

If kfree were not preemptable, we could make reparent_slab_cache wait
for all cpus to schedule() before destroying the cache to avoid this,
but since it is, we need ref-counting...

Thanks.

> There is no tracking of full slabs without adding much more logic to the
> fastpath. You could force any operation that affects tne full list into
> the slow path. But that also would have an impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
