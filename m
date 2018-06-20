Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9DD16B0006
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 21:24:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h18-v6so1127944wmb.8
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 18:24:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b65-v6sor439695wmi.72.2018.06.19.18.24.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 18:24:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180619213352.71740-1-shakeelb@google.com> <alpine.DEB.2.21.1806191748040.25812@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1806191748040.25812@chino.kir.corp.google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Jun 2018 18:24:32 -0700
Message-ID: <CALvZod7A+QC5OqYNx-kQcJYOQmeSm8ie9JGnh3_-CUfYn7jpOA@mail.gmail.com>
Subject: Re: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jason@zx2c4.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue, Jun 19, 2018 at 5:49 PM David Rientjes <rientjes@google.com> wrote:
>
> On Tue, 19 Jun 2018, Shakeel Butt wrote:
>
> > diff --git a/mm/slub.c b/mm/slub.c
> > index a3b8467c14af..731c02b371ae 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3673,9 +3673,23 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> >
> >  bool __kmem_cache_empty(struct kmem_cache *s)
> >  {
> > -     int node;
> > +     int cpu, node;
>
> Nit: wouldn't cpu be unused if CONFIG_SLUB_DEBUG is disabled?
>

I think I didn't get the warning as I didn't use #ifdef.

> >       struct kmem_cache_node *n;
> >
> > +     /*
> > +      * slabs_node will always be 0 for !CONFIG_SLUB_DEBUG. So, manually
> > +      * check slabs for all cpus.
> > +      */
> > +     if (!IS_ENABLED(CONFIG_SLUB_DEBUG)) {
> > +             for_each_online_cpu(cpu) {
> > +                     struct kmem_cache_cpu *c;
> > +
> > +                     c = per_cpu_ptr(s->cpu_slab, cpu);
> > +                     if (c->page || slub_percpu_partial(c))
> > +                             return false;
> > +             }
> > +     }
> > +
> >       for_each_kmem_cache_node(s, node, n)
> >               if (n->nr_partial || slabs_node(s, node))
> >                       return false;
>
> Wouldn't it just be better to allow {inc,dec}_slabs_node() to adjust the
> nr_slabs counter instead of doing the per-cpu iteration on every shutdown?

Yes that is doable as the functions {inc,dec}_slabs_node() are called
in slow path. I can move them out of CONFIG_SLUB_DEBUG. I think the
reason 0f389ec63077 ("slub: No need for per node slab counters if
!SLUB_DEBUG") put them under CONFIG_SLUB_DEBUG is because these
counters were only read through sysfs API which were disabled on
!CONFIG_SLUB_DEBUG. However we have a usecase other than sysfs API.

Please let me know if there is any objection to this conversion. For
large machines I think this is preferable approach.

thanks,
Shakeel
