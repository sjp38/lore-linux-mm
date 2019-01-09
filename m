Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3EE8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 00:44:44 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t17so3324822ywc.23
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 21:44:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v19sor24360952ybb.88.2019.01.08.21.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 21:44:43 -0800 (PST)
MIME-Version: 1.0
References: <20190109040107.4110-1-riel@surriel.com> <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
In-Reply-To: <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 8 Jan 2019 21:44:32 -0800
Message-ID: <CALvZod5+QFLtn4D+xn2REy3sHUR5z3EsJQPGrfzWobK5wmRnjg@mail.gmail.com>
Subject: Re: [PATCH] mm,slab,memcg: call memcg kmem put cache with same
 condition as get
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, stable@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Tue, Jan 8, 2019 at 9:36 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Tue, Jan 8, 2019 at 8:01 PM Rik van Riel <riel@surriel.com> wrote:
> >
> > There is an imbalance between when slab_pre_alloc_hook calls
> > memcg_kmem_get_cache and when slab_post_alloc_hook calls
> > memcg_kmem_put_cache.
> >
>
> Can you explain how there is an imbalance? If the returned kmem cache
> from memcg_kmem_get_cache() is the memcg kmem cache then the refcnt of
> memcg is elevated and the memcg_kmem_put_cache() will correctly
> decrement the refcnt of the memcg.
>
> > This can cause a memcg kmem cache to be destroyed right as
> > an object from that cache is being allocated,

Also please note that the memcg kmem caches are destroyed (if empty)
on memcg offline. The css_tryget_online() within
memcg_kmem_get_cache() will fail.

See kernel/cgroup/cgroup.c
* 2. When the percpu_ref is confirmed to be visible as killed on all CPUs
 *    and thus css_tryget_online() is guaranteed to fail, the css can be
 *    offlined by invoking offline_css().  After offlining, the base ref is
 *    put.  Implemented in css_killed_work_fn().

> > which is probably
> > not good. It could lead to things like a memcg allocating new
> > kmalloc slabs instead of using freed space in old ones, maybe
> > memory leaks, and maybe oopses as a memcg kmalloc slab is getting
> > destroyed on one CPU while another CPU is trying to do an allocation
> > from that same memcg.
> >
> > The obvious fix would be to use the same condition for calling
> > memcg_kmem_put_cache that we also use to decide whether to call
> > memcg_kmem_get_cache.
> >
> > I am not sure how long this bug has been around, since the last
> > changeset to touch that code - 452647784b2f ("mm: memcontrol: cleanup
> >  kmem charge functions") - merely moved the bug from one location to
> > another. I am still tagging that changeset, because the fix should
> > automatically apply that far back.
> >
> > Signed-off-by: Rik van Riel <riel@surriel.com>
> > Fixes: 452647784b2f ("mm: memcontrol: cleanup kmem charge functions")
> > Cc: kernel-team@fb.com
> > Cc: linux-mm@kvack.org
> > Cc: stable@vger.kernel.org
> > Cc: Alexey Dobriyan <adobriyan@gmail.com>
> > Cc: Christoph Lameter <cl@linux.com>
> > Cc: Pekka Enberg <penberg@kernel.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > ---
> >  mm/slab.h | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 4190c24ef0e9..ab3d95bef8a0 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -444,7 +444,8 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
> >                 p[i] = kasan_slab_alloc(s, object, flags);
> >         }
> >
> > -       if (memcg_kmem_enabled())
> > +       if (memcg_kmem_enabled() &&
> > +           ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT)))
>
> I don't think these extra checks are needed. They are safe but not needed.
>
> >                 memcg_kmem_put_cache(s);
> >  }
> >
> > --
> > 2.17.1
> >
>
> thanks,
> Shakeel
