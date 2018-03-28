Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6362E6B0026
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 17:30:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so2064601pgn.3
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:30:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6-v6sor2334466plp.145.2018.03.28.14.30.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 14:30:00 -0700 (PDT)
Date: Wed, 28 Mar 2018 14:29:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab, slub: skip unnecessary kasan_cache_shutdown()
In-Reply-To: <CALvZod5x+mYBaa_x_a00WVGGDGX55AwTcuFdeVQStUo2Db6f3w@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1803281424000.167685@chino.kir.corp.google.com>
References: <20180327230603.54721-1-shakeelb@google.com> <alpine.DEB.2.20.1803271715310.8944@chino.kir.corp.google.com> <CALvZod5x+mYBaa_x_a00WVGGDGX55AwTcuFdeVQStUo2Db6f3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Potapenko <glider@google.com>, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 27 Mar 2018, Shakeel Butt wrote:

> On Tue, Mar 27, 2018 at 5:16 PM, David Rientjes <rientjes@google.com> wrote:
> > On Tue, 27 Mar 2018, Shakeel Butt wrote:
> >
> >> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> >> index 49fffb0ca83b..135ce2838c89 100644
> >> --- a/mm/kasan/kasan.c
> >> +++ b/mm/kasan/kasan.c
> >> @@ -382,7 +382,8 @@ void kasan_cache_shrink(struct kmem_cache *cache)
> >>
> >>  void kasan_cache_shutdown(struct kmem_cache *cache)
> >>  {
> >> -     quarantine_remove_cache(cache);
> >> +     if (!__kmem_cache_empty(cache))
> >> +             quarantine_remove_cache(cache);
> >>  }
> >>
> >>  size_t kasan_metadata_size(struct kmem_cache *cache)
> >> diff --git a/mm/slab.c b/mm/slab.c
> >> index 9212c64bb705..b59f2cdf28d1 100644
> >> --- a/mm/slab.c
> >> +++ b/mm/slab.c
> >> @@ -2291,6 +2291,18 @@ static int drain_freelist(struct kmem_cache *cache,
> >>       return nr_freed;
> >>  }
> >>
> >> +bool __kmem_cache_empty(struct kmem_cache *s)
> >> +{
> >> +     int node;
> >> +     struct kmem_cache_node *n;
> >> +
> >> +     for_each_kmem_cache_node(s, node, n)
> >> +             if (!list_empty(&n->slabs_full) ||
> >> +                 !list_empty(&n->slabs_partial))
> >> +                     return false;
> >> +     return true;
> >> +}
> >> +
> >>  int __kmem_cache_shrink(struct kmem_cache *cachep)
> >>  {
> >>       int ret = 0;
> >> diff --git a/mm/slab.h b/mm/slab.h
> >> index e8981e811c45..68bdf498da3b 100644
> >> --- a/mm/slab.h
> >> +++ b/mm/slab.h
> >> @@ -166,6 +166,7 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
> >>                             SLAB_TEMPORARY | \
> >>                             SLAB_ACCOUNT)
> >>
> >> +bool __kmem_cache_empty(struct kmem_cache *);
> >>  int __kmem_cache_shutdown(struct kmem_cache *);
> >>  void __kmem_cache_release(struct kmem_cache *);
> >>  int __kmem_cache_shrink(struct kmem_cache *);
> >> diff --git a/mm/slub.c b/mm/slub.c
> >> index 1edc8d97c862..44aa7847324a 100644
> >> --- a/mm/slub.c
> >> +++ b/mm/slub.c
> >> @@ -3707,6 +3707,17 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> >>               discard_slab(s, page);
> >>  }
> >>
> >> +bool __kmem_cache_empty(struct kmem_cache *s)
> >> +{
> >> +     int node;
> >> +     struct kmem_cache_node *n;
> >> +
> >> +     for_each_kmem_cache_node(s, node, n)
> >> +             if (n->nr_partial || slabs_node(s, node))
> >> +                     return false;
> >> +     return true;
> >> +}
> >> +
> >>  /*
> >>   * Release all resources used by a slab cache.
> >>   */
> >
> > Any reason not to just make quarantine_remove_cache() part of
> > __kmem_cache_shutdown() instead of duplicating its logic?
> 
> Can you please explain what you mean by making
> quarantine_remove_cache() part of __kmem_cache_shutdown()? Do you mean
> calling quarantine_remove_cache() inside __kmem_cache_shutdown()? The
> __kmem_cache_shutdown() of both SLAB & SLUB does per-cpu
> draining/flushing and we want the free the quarantined objects before
> that. So, I am not sure how to incorporate  quarantine_remove_cache()
> into __kmem_cache_shutdown() without duplicating the for-loop &
> if-condition.
> 

__kmem_cache_empty() is largely a copy and paste of 
__kmem_cache_shutdown() logic, is there no way to simplify this?  I was 
thinking of generalizing the iteration (for_each_kmem_cach_node_nonempty?) 
that eliminates the need for __kmem_cache_empty().

kasan_cache_shutdown() would do

	for_each_kmem_cache_node_nonempty(cache, node, n) {
		quarantine_remove_cache(cache);
		break;
	}

and __kmem_cache_shutdown() would use it for the iteration over 
kmem_cache_node's to drain.
