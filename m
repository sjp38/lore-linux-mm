Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id DECCC6B0262
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 06:55:51 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id y89so93260627qge.2
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 03:55:51 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0113.outbound.protection.outlook.com. [104.47.2.113])
        by mx.google.com with ESMTPS id w132si11548151qka.53.2016.04.01.03.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 03:55:50 -0700 (PDT)
Date: Fri, 1 Apr 2016 13:55:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH -mm v2 3/3] slub: make dead caches discard free slabs
 immediately
Message-ID: <20160401105539.GA6610@esperanza>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <6eecfafdc6c3dcbb98d2176cdebcb65abbc180b4.1422461573.git.vdavydov@parallels.com>
 <20160401090441.GD12845@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160401090441.GD12845@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 01, 2016 at 11:04:41AM +0200, Peter Zijlstra wrote:
> On Wed, Jan 28, 2015 at 07:22:51PM +0300, Vladimir Davydov wrote:
> > +++ b/mm/slub.c
> > @@ -2007,6 +2007,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >  	int pages;
> >  	int pobjects;
> >  
> > +	preempt_disable();
> >  	do {
> >  		pages = 0;
> >  		pobjects = 0;
> > @@ -2040,6 +2041,14 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >  
> >  	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
> >  								!= oldpage);
> > +	if (unlikely(!s->cpu_partial)) {
> > +		unsigned long flags;
> > +
> > +		local_irq_save(flags);
> > +		unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
> > +		local_irq_restore(flags);
> > +	}
> > +	preempt_enable();
> >  #endif
> >  }
> >  
> > @@ -3369,7 +3378,7 @@ EXPORT_SYMBOL(kfree);
> >   * being allocated from last increasing the chance that the last objects
> >   * are freed in them.
> >   */
> > -int __kmem_cache_shrink(struct kmem_cache *s)
> > +int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
> >  {
> >  	int node;
> >  	int i;
> > @@ -3381,14 +3390,26 @@ int __kmem_cache_shrink(struct kmem_cache *s)
> >  	unsigned long flags;
> >  	int ret = 0;
> >  
> > +	if (deactivate) {
> > +		/*
> > +		 * Disable empty slabs caching. Used to avoid pinning offline
> > +		 * memory cgroups by kmem pages that can be freed.
> > +		 */
> > +		s->cpu_partial = 0;
> > +		s->min_partial = 0;
> > +
> > +		/*
> > +		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
> > +		 * so we have to make sure the change is visible.
> > +		 */
> > +		kick_all_cpus_sync();
> > +	}
> 
> Argh! what the heck! and without a single mention in the changelog.

This function is only called when a memory cgroup is removed, which is
rather a rare event. I didn't think it would cause any pain. Sorry.

> 
> Why are you spraying IPIs across the entire machine? Why isn't
> synchronize_sched() good enough, that would allow you to get rid of the
> local_irq_save/restore as well.

synchronize_sched() is slower. Calling it for every per memcg kmem cache
would slow down cleanup on cgroup removal. The latter is async, so I'm
not sure if it would be a problem though. I think we can try to replace
kick_all_cpus_sync() with synchronize_sched() here.

Regarding local_irq_save/restore - synchronize_sched() wouldn't allow us
to get rid of them, because unfreeze_partials() must be called with irqs
disabled.

Come to think of it, kick_all_cpus_sync() is used as a memory barrier
here, so as to make sure that after it's finished all cpus will use the
new ->cpu_partial value, which makes me wonder if we could replace it
with a simple smp_mb. I mean, this_cpu_cmpxchg(), which is used by
put_cpu_partial to add a page to per-cpu partial list, must issue a full
memory barrier (am I correct?), so we have two possibilities here:

Case 1: smp_mb is called before this_cpu_cmpxchg is called on another
cpu executing put_cpu_partial. In this case, put_cpu_partial will see
cpu_partial == 0 and hence call the second unfreeze_partials, flushing
per cpu partial list.

Case 2: smp_mb is called after this_cpu_cmpxchg. Then
__kmem_cache_shrink ->flush_all -> has_cpu_slab should see (thanks to
the barriers) that there's a slab on a per-cpu list and so flush it
(provided it hasn't already been flushed by put_cpu_partial).

In any case, after __kmem_cache_shrink has finished, we are guaranteed
to not have any slabs on per cpu partial lists.

Does it make sense?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
