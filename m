Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6814F6B0286
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 20:46:10 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x205so83586669oia.7
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 17:46:10 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id p25si4939309ioi.24.2016.11.02.17.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 17:46:09 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id n85so20747057pfi.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 17:46:09 -0700 (PDT)
Date: Wed, 2 Nov 2016 17:46:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] memcg: Prevent memcg caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
In-Reply-To: <CAJcbSZHic9gfpYHFXySZf=EmUjztBvuHeWWq7CQFi=0Om7OJoA@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1611021744150.110015@chino.kir.corp.google.com>
References: <1477939010-111710-1-git-send-email-thgarnie@google.com> <alpine.DEB.2.10.1610311625430.62482@chino.kir.corp.google.com> <CAJcbSZHic9gfpYHFXySZf=EmUjztBvuHeWWq7CQFi=0Om7OJoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Wed, 2 Nov 2016, Thomas Garnier wrote:

> >> diff --git a/mm/slab.h b/mm/slab.h
> >> index 9653f2e..58be647 100644
> >> --- a/mm/slab.h
> >> +++ b/mm/slab.h
> >> @@ -144,6 +144,9 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
> >>
> >>  #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
> >>
> >> +/* Common allocator flags allowed for cache_create. */
> >> +#define SLAB_FLAGS_PERMITTED (CACHE_CREATE_MASK | SLAB_KASAN)
> >> +
> >>  int __kmem_cache_shutdown(struct kmem_cache *);
> >>  void __kmem_cache_release(struct kmem_cache *);
> >>  int __kmem_cache_shrink(struct kmem_cache *, bool);
> >> diff --git a/mm/slab_common.c b/mm/slab_common.c
> >> index 71f0b28..01d067c 100644
> >> --- a/mm/slab_common.c
> >> +++ b/mm/slab_common.c
> >> @@ -329,6 +329,12 @@ static struct kmem_cache *create_cache(const char *name,
> >>       struct kmem_cache *s;
> >>       int err;
> >>
> >> +     /* Do not allow allocator specific flags */
> >> +     if (flags & ~SLAB_FLAGS_PERMITTED) {
> >> +             err = -EINVAL;
> >> +             goto out;
> >> +     }
> >> +
> >
> > Why not just flags &= SLAB_FLAGS_PERMITTED if we're concerned about this
> > like kmem_cache_create does &= CACHE_CREATE_MASK?
> >
> 
> Christoph on the first version advised removing invalid flags on the
> caller and checking they are correct in kmem_cache_create. The memcg
> path putting the wrong flags is through create_cache but I still used
> this approach.
> 

I think this is a rather trivial point since it doesn't matter if we clear 
invalid flags on the caller or in the callee and obviously 
kmem_cache_create() does it in the callee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
